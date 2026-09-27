using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Threading;
using Godot;

namespace EasyStarCs;

/// <summary>方向（对应 EasyStar 的 TOP / TOP_RIGHT / ... 字符串常量）</summary>
public enum EasyStarDirection
{
    Top = 0,
    TopRight = 1,
    Right = 2,
    BottomRight = 3,
    Bottom = 4,
    BottomLeft = 5,
    Left = 6,
    TopLeft = 7,
}

/// <summary>
/// EasyStar —— EasyStarJS（github.com/prettymuchbryce/EasyStarJS，MIT）的 Godot C# 移植。
///
/// 它解决的问题：网格 A* 最坏情况要遍历整张地图（目标被墙隔开时），一次同步算完会卡帧。
/// EasyStar 的思路不是多线程，而是"时间切片"：
///   - FindPath() 只把请求排进队列，立刻返回 instanceId；
///   - 每帧调用一次 Calculate()，一次最多展开 SetIterationsPerCalculation() 个节点，
///     剩余留到下一帧 → 单帧耗时封顶，帧率不抖。
/// 本移植保持这套 API/语义，并额外提供 C# 才有的能力：
///   - TryFindPathSync()：立刻算完（工具/测试用，不进队列）；
///   - SetWorkerThreads(n)：固定后台线程池并行算（GDScript 做不到），
///     结果在 Calculate() 里回主线程再触发回调（Godot 对象只能在主线程碰）；
///   - EnableFairScheduling()：轮转调度，避免队首请求霸占每次 Calculate 的预算。
///
/// 与 EasyStarJS 的差异（源码里都标了"差异"）：
///   1. 可走性/代价预计算成扁平数组，热循环里不查字典；
///   2. 节点表用"数组 + 版本戳"，且请求对象/Nodes 表循环复用（长时间跑不产生 GC 尖峰）；
///   3. 新增 TryFindPathSync / 线程池 / 轮转调度 / ReopenClosedNodes 开关。
/// 默认行为与 EasyStarJS 一致，包括它"已关闭节点不因更优路径重新入队"的小瑕疵，
/// 想改成教科书 A* 就把 ReopenClosedNodes 设为 true。
/// </summary>
public sealed class EasyStar
{
    public const float StraightCost = 1.0f;
    public const float DiagonalCost = 1.4f;

    // ------------------------------------------------------------
    // 网格数据（扁平数组，索引 = y * Width + x）
    // ------------------------------------------------------------
    public int Width { get; private set; }
    public int Height { get; private set; }
    public int CellCount => Width * Height;

    private int[] _tiles = Array.Empty<int>();
    private bool[] _walkable = Array.Empty<bool>();
    private float[] _cellCost = Array.Empty<float>();
    private float[] _pointCost = Array.Empty<float>();
    private bool[] _avoided = Array.Empty<bool>();
    private EasyStarDirection[]?[] _dirConditions = Array.Empty<EasyStarDirection[]?>();

    private readonly Dictionary<int, float> _costByType = new();
    private readonly HashSet<int> _acceptableTiles = new();

    // ------------------------------------------------------------
    // 配置
    // ------------------------------------------------------------
    private bool _syncEnabled;
    private bool _diagonalsEnabled;
    private bool _allowCornerCutting = true;
    private bool _fairScheduling;
    private float _diagonalStepCost = DiagonalCost;
    private int _iterationsPerCalculation = int.MaxValue;
    private int _workerThreads;
    private int _nextInstanceId = 1;

    /// <summary>
    /// EasyStarJS 不会把"已关闭但发现更优路径"的节点重新入队（可能得到次优路径）。
    /// false（默认）= 与 EasyStar 行为一致；true = 标准 A*（可重新打开已关闭节点）。
    /// </summary>
    public bool ReopenClosedNodes { get; set; }

    // ------------------------------------------------------------
    // 请求
    // ------------------------------------------------------------
    private sealed class PathInstance
    {
        public int Id;
        public int StartX, StartY, EndX, EndY;
        public Action<List<Vector2I>?>? Callback;
        public bool Done;
        public bool Cancelled;
        public string? Error;
        public List<Vector2I>? Result;

        // 每条请求独占一张节点表 + 一个开放表：切片与线程模式都能安全并存；
        // 请求结束后对象回池复用（Nodes/Stamp 表保留，靠 SearchStamp 失效旧数据）
        public readonly EasyStarHeap Open = new();
        public EasyStarNode?[] Nodes = Array.Empty<EasyStarNode?>();
        public int[] Stamp = Array.Empty<int>();
        public int SearchStamp = 1;

        public void EnsureTables(int cells)
        {
            if (Nodes.Length >= cells)
            {
                NextStamp();
                return;
            }
            Nodes = new EasyStarNode?[cells];
            Stamp = new int[cells];
            SearchStamp = 1;
        }

        /// <summary>换一次搜索：版本戳 +1，旧格子的数据自动失效</summary>
        public void NextStamp()
        {
            SearchStamp++;
            if (SearchStamp == int.MaxValue)
            {
                Array.Clear(Stamp);
                SearchStamp = 1;
            }
        }

        public void ResetForReuse()
        {
            Id = 0;
            Callback = null;
            Done = false;
            Cancelled = false;
            Error = null;
            Result = null;
            Open.Clear();
        }

        public EasyStarNode GetOrCreate(EasyStar owner, int x, int y, EasyStarNode? parent, float cost)
        {
            int idx = y * owner.Width + x;
            if (Stamp[idx] == SearchStamp && Nodes[idx] != null)
            {
                return Nodes[idx]!;
            }
            EasyStarNode node = Nodes[idx] ?? new EasyStarNode();
            node.Reset();
            node.X = x;
            node.Y = y;
            node.Estimated = owner.GetDistance(x, y, EndX, EndY);
            node.CostSoFar = parent != null ? parent.CostSoFar + cost : 0f;
            node.Parent = parent;
            Nodes[idx] = node;
            Stamp[idx] = SearchStamp;
            return node;
        }
    }

    private readonly Dictionary<int, PathInstance> _instances = new();
    private readonly Queue<int> _queue = new();
    private readonly ConcurrentQueue<PathInstance> _threadResults = new();
    private readonly ConcurrentBag<PathInstance> _pool = new();
    private BlockingCollection<PathInstance>? _workQueue;
    private readonly List<Thread> _workers = new();
    private int _threadsInFlight;

    // ------------------------------------------------------------
    // 统计（调试/基准用）
    // ------------------------------------------------------------
    private long _totalExpanded;

    /// <summary>上一次 Calculate() 展开的节点数</summary>
    public int LastExpandedNodes { get; private set; }
    /// <summary>累计展开的节点数</summary>
    public long TotalExpandedNodes => Interlocked.Read(ref _totalExpanded);
    /// <summary>还没算完的请求数（含后台在飞的）</summary>
    public int PendingCount => _queue.Count + Volatile.Read(ref _threadsInFlight);
    /// <summary>是否开启了后台线程池</summary>
    public bool Threaded => _workerThreads > 0;
    /// <summary>当前后台工作线程数（单线程模式下恒为 0）</summary>
    public int WorkerCount => _workers.Count;

    // ============================================================
    // 网格设置
    // ============================================================
    /// <summary>设置网格（grid[y, x] = 格子类型；类型是否可走见 SetAcceptableTiles）</summary>
    public void SetGrid(int[,] grid)
    {
        int h = grid.GetLength(0);
        int w = grid.GetLength(1);
        int[] flat = new int[w * h];
        for (int y = 0; y < h; y++)
        {
            for (int x = 0; x < w; x++)
            {
                flat[y * w + x] = grid[y, x];
            }
        }
        SetGridFlat(flat, w, h);
    }

    /// <summary>扁平网格版本（索引 = y * width + x）</summary>
    public void SetGridFlat(int[] tiles, int width, int height)
    {
        if (width <= 0 || height <= 0 || tiles.Length < width * height)
        {
            throw new ArgumentException("SetGridFlat: 网格尺寸与数据不匹配");
        }
        Width = width;
        Height = height;
        _tiles = new int[width * height];
        Array.Copy(tiles, _tiles, _tiles.Length);
        _walkable = new bool[_tiles.Length];
        _cellCost = new float[_tiles.Length];
        _pointCost = new float[_tiles.Length];
        _avoided = new bool[_tiles.Length];
        _dirConditions = new EasyStarDirection[]?[_tiles.Length];

        _costByType.Clear();
        foreach (int t in _tiles)
        {
            if (!_costByType.ContainsKey(t))
            {
                _costByType[t] = 1f;   // EasyStar: setGrid 时给每个出现的类型初始化 cost = 1
            }
        }
        RebuildWalkable();
        RebuildCellCost();
    }

    /// <summary>哪些格子类型算可走（EasyStar 的 setAcceptableTiles）</summary>
    public void SetAcceptableTiles(params int[] tiles)
    {
        _acceptableTiles.Clear();
        foreach (int t in tiles)
        {
            _acceptableTiles.Add(t);
        }
        RebuildWalkable();
    }

    /// <summary>某格当前是否可走（越界算不可走）</summary>
    public bool IsWalkable(int x, int y) => InBounds(x, y) && _walkable[y * Width + x];

    /// <summary>某格当前的通行代价</summary>
    public float GetCellCost(int x, int y) => InBounds(x, y) ? GetTileCost(x, y) : 0f;

    /// <summary>
    /// 改单格类型并立即刷新它的可走性/代价（游戏里"炸掉砖墙后路径重新打通"就用这个）。
    /// 注意：有后台搜索在飞时不要调用（数据竞争）。
    /// </summary>
    public void SetTileType(int x, int y, int tileType)
    {
        if (!InBounds(x, y))
        {
            return;
        }
        int idx = y * Width + x;
        _tiles[idx] = tileType;
        _walkable[idx] = _acceptableTiles.Contains(tileType);
        _cellCost[idx] = _costByType.TryGetValue(tileType, out float c) ? c : 1f;
    }

    /// <summary>某类型的通行代价倍率（EasyStar 的 setTileCost）</summary>
    public void SetTileCost(int tileType, float cost)
    {
        _costByType[tileType] = cost;
        RebuildCellCost();
    }

    /// <summary>某点的额外代价，覆盖类型代价（EasyStar 的 setAdditionalPointCost）</summary>
    public void SetAdditionalPointCost(int x, int y, float cost)
    {
        if (InBounds(x, y))
        {
            _pointCost[y * Width + x] = cost;
        }
    }

    public void RemoveAdditionalPointCost(int x, int y)
    {
        if (InBounds(x, y))
        {
            _pointCost[y * Width + x] = 0f;
        }
    }

    public void RemoveAllAdditionalPointCosts() => Array.Clear(_pointCost);

    /// <summary>无视可走性强制避开某点（EasyStar 的 avoidAdditionalPoint）</summary>
    public void AvoidAdditionalPoint(int x, int y)
    {
        if (InBounds(x, y))
        {
            _avoided[y * Width + x] = true;
        }
    }

    public void StopAvoidingAdditionalPoint(int x, int y)
    {
        if (InBounds(x, y))
        {
            _avoided[y * Width + x] = false;
        }
    }

    public void StopAvoidingAllAdditionalPoints() => Array.Clear(_avoided);

    /// <summary>方向条件：只允许从列出的方向进入该格（EasyStar 的 setDirectionalCondition）</summary>
    public void SetDirectionalCondition(int x, int y, params EasyStarDirection[] allowed)
    {
        if (InBounds(x, y))
        {
            _dirConditions[y * Width + x] = allowed;
        }
    }

    public void RemoveAllDirectionalConditions() => Array.Clear(_dirConditions);

    // ============================================================
    // 开关
    // ============================================================
    /// <summary>同步模式：Calculate() 一次把队列算完（EasyStar 的 enableSync）</summary>
    public void EnableSync() => _syncEnabled = true;
    public void DisableSync() => _syncEnabled = false;
    public void EnableDiagonals() => _diagonalsEnabled = true;
    public void DisableDiagonals() => _diagonalsEnabled = false;
    public void EnableCornerCutting() => _allowCornerCutting = true;
    public void DisableCornerCutting() => _allowCornerCutting = false;

    /// <summary>
    /// 斜走一步的代价。默认 1.4（EasyStarJS 原值，保持行为一致）；
    /// 设成 √2≈1.41421 就和"真实几何长度"/Godot AStarGrid2D 的口径完全一致，
    /// 路径能再短 1~4%（代价是偏离 EasyStar 原版数值）。
    /// </summary>
    public void SetDiagonalStepCost(float cost) =>
        _diagonalStepCost = cost > 0f ? cost : DiagonalCost;

    /// <summary>
    /// 差异（EasyStar 没有）：轮转调度。
    /// false（默认）= EasyStar 语义：队列里第一个没算完的请求会一直霸占每次 Calculate 的预算，
    /// 后面的请求要排队等它（敌人一多，最后一个要等很久）；
    /// true = 每个请求一次最多推进一步，算完就轮到下一个 → 不会饿死。
    /// </summary>
    public void EnableFairScheduling() => _fairScheduling = true;
    public void DisableFairScheduling() => _fairScheduling = false;

    /// <summary>每次 Calculate() 最多展开多少节点（越小越不卡帧，算得越慢）</summary>
    public void SetIterationsPerCalculation(int iterations) =>
        _iterationsPerCalculation = Math.Max(1, iterations);

    /// <summary>
    /// 后台工作线程数（0 = 关，走 EasyStar 式时间切片）。
    /// 固定线程池：提交请求只是入队，线程常驻，避免 Task-per-request 的线程池挤兑。
    /// 注意：有后台搜索在飞时不要改网格（SetGrid / Avoid... / SetTileCost），否则数据竞争。
    /// </summary>
    public void SetWorkerThreads(int workers)
    {
        // 先停掉旧线程池：CompleteAdding 后工作线程把队列里的活干完就自行退出
        _workQueue?.CompleteAdding();
        _workers.Clear();
        _workQueue = null;
        _workerThreads = Math.Max(0, workers);
        if (_workerThreads == 0)
        {
            return;
        }
        _workQueue = new BlockingCollection<PathInstance>();
        for (int i = 0; i < _workerThreads; i++)
        {
            var t = new Thread(WorkerLoop)
            {
                IsBackground = true,
                Name = $"EasyStarWorker{i}",
            };
            t.Start();
            _workers.Add(t);
        }
    }

    // ============================================================
    // 主 API
    // ============================================================
    /// <summary>
    /// 请求一条路径，返回 instanceId（可传 CancelPath 取消）。
    /// 回调在主线程触发：找到 → 路径点列表（含起点与终点）；不可达 → null。
    /// 未配置网格/起点终点越界会抛异常（与 EasyStar 一致）。
    /// </summary>
    public int FindPath(int startX, int startY, int endX, int endY, Action<List<Vector2I>?>? callback)
    {
        EnsureConfigured("FindPath");
        if (!InBounds(startX, startY) || !InBounds(endX, endY))
        {
            throw new ArgumentOutOfRangeException(nameof(startX), "起点或终点超出网格范围。");
        }
        // 起终点同格 → 空路径；终点不可走 → null（EasyStar 同，立刻回调、不进队列）
        if (startX == endX && startY == endY)
        {
            callback?.Invoke(new List<Vector2I>());
            return 0;
        }
        if (!_walkable[endY * Width + endX])
        {
            callback?.Invoke(null);
            return 0;
        }

        PathInstance inst = RentInstance(startX, startY, endX, endY, callback);
        if (_workerThreads > 0 && _workQueue != null)
        {
            _instances[inst.Id] = inst;
            Interlocked.Increment(ref _threadsInFlight);
            _workQueue.Add(inst);
            return inst.Id;
        }
        _instances[inst.Id] = inst;
        _queue.Enqueue(inst.Id);
        return inst.Id;
    }

    public bool CancelPath(int instanceId)
    {
        if (!_instances.TryGetValue(instanceId, out PathInstance? inst))
        {
            return false;
        }
        inst.Cancelled = true;
        if (!inst.Done && !Threaded)
        {
            // 切片模式：直接从队列摘掉；线程模式：结果回来时丢弃（正在算的那一步不打断）
            _instances.Remove(instanceId);
        }
        return true;
    }

    /// <summary>
    /// 每帧调用一次：推进时间切片，并把后台线程算好的结果取回主线程触发回调。
    /// </summary>
    public void Calculate()
    {
        PollThreadResults();
        LastExpandedNodes = 0;
        if (_syncEnabled || _iterationsPerCalculation == int.MaxValue)
        {
            while (_queue.Count > 0 && StepNext())
            {
            }
            return;
        }
        for (int i = 0; i < _iterationsPerCalculation && _queue.Count > 0; i++)
        {
            StepNext();
        }
    }

    /// <summary>立刻同步算完一条路径（不进队列）：null = 不可达</summary>
    public List<Vector2I>? TryFindPathSync(int startX, int startY, int endX, int endY)
    {
        EnsureConfigured("TryFindPathSync");
        if (!InBounds(startX, startY) || !InBounds(endX, endY))
        {
            throw new ArgumentOutOfRangeException(nameof(startX), "起点或终点超出网格范围。");
        }
        if (startX == endX && startY == endY)
        {
            return new List<Vector2I>();
        }
        if (!_walkable[endY * Width + endX])
        {
            return null;
        }
        PathInstance inst = RentInstance(startX, startY, endX, endY, null);
        while (!inst.Done)
        {
            StepInstance(inst, invokeCallback: false);
        }
        List<Vector2I>? result = inst.Result;
        ReturnInstance(inst);
        return result;
    }

    /// <summary>等待后台线程全部算完（测试/基准用；游戏里不需要）</summary>
    public void WaitForThreads()
    {
        while (Volatile.Read(ref _threadsInFlight) > 0)
        {
            Thread.Sleep(1);
        }
        PollThreadResults();
    }

    /// <summary>把后台已完成的结果取回主线程、触发回调（Calculate 内部已调用）</summary>
    public void PollThreadResults()
    {
        while (_threadResults.TryDequeue(out PathInstance? inst))
        {
            _instances.Remove(inst.Id);
            if (inst.Error != null)
            {
                GD.PushError($"EasyStar 后台搜索失败: {inst.Error}");
                inst.Callback?.Invoke(null);
                ReturnInstance(inst);
                continue;
            }
            if (inst.Cancelled)
            {
                ReturnInstance(inst);
                continue;
            }
            inst.Callback?.Invoke(inst.Result);
            ReturnInstance(inst);
        }
    }

    // ============================================================
    // 请求对象池（避免每次请求都新建 Nodes/Stamp 大数组 → 长时间跑不产生 GC 尖峰）
    // ============================================================
    private PathInstance RentInstance(int sx, int sy, int ex, int ey, Action<List<Vector2I>?>? callback)
    {
        PathInstance inst = _pool.TryTake(out PathInstance? pooled) ? pooled : new PathInstance();
        inst.ResetForReuse();
        inst.Id = _nextInstanceId++;
        inst.StartX = sx;
        inst.StartY = sy;
        inst.EndX = ex;
        inst.EndY = ey;
        inst.Callback = callback;
        // 表在"真正开始搜"时再保证尺寸：线程模式下这一步就落在工作线程上
        inst.EnsureTables(CellCount);
        // 起点入队（EasyStar: push(coordinateToNode(start, null, STRAIGHT_COST))，起点 g = 0）
        EasyStarNode startNode = inst.GetOrCreate(this, sx, sy, null, StraightCost);
        startNode.List = EasyStarNode.OpenList;
        inst.Open.Push(startNode);
        return inst;
    }

    private void ReturnInstance(PathInstance inst)
    {
        if (_pool.Count > 4096)
        {
            return;
        }
        _pool.Add(inst);
    }

    // ============================================================
    // 搜索核心
    // ============================================================
    /// <summary>推进队首请求一步；返回 false = 没有可推进的请求</summary>
    private bool StepNext()
    {
        while (_queue.Count > 0)
        {
            int id = _queue.Peek();
            if (!_instances.TryGetValue(id, out PathInstance? inst))
            {
                _queue.Dequeue();   // 被取消
                continue;
            }
            StepInstance(inst, invokeCallback: true);
            if (inst.Done)
            {
                _instances.Remove(id);
                _queue.Dequeue();
            }
            else if (_fairScheduling)
            {
                _queue.Dequeue();   // 轮转：本步用完就排到队尾
                _queue.Enqueue(id);
            }
            return true;
        }
        return false;
    }

    /// <summary>推进一个请求一步（弹出并展开一个节点），或一步判定完成</summary>
    private void StepInstance(PathInstance inst, bool invokeCallback)
    {
        if (inst.Done)
        {
            return;
        }
        if (inst.Open.Count == 0)
        {
            Finish(inst, null, invokeCallback);   // 开放表空 = 不可达
            return;
        }
        EasyStarNode node = inst.Open.Pop();
        Interlocked.Increment(ref _totalExpanded);
        LastExpandedNodes++;

        if (node.X == inst.EndX && node.Y == inst.EndY)
        {
            Finish(inst, BuildPath(node), invokeCallback);
            return;
        }
        node.List = EasyStarNode.ClosedList;
        ExpandNeighbors(inst, node);
    }

    private void Finish(PathInstance inst, List<Vector2I>? result, bool invokeCallback)
    {
        inst.Done = true;
        inst.Result = result;
        if (!invokeCallback)
        {
            return;
        }
        inst.Callback?.Invoke(result);
        ReturnInstance(inst);   // 回调之后再回池（回调里可能又发起新请求）
    }

    private static List<Vector2I> BuildPath(EasyStarNode end)
    {
        var path = new List<Vector2I>();
        for (EasyStarNode? n = end; n != null; n = n.Parent)
        {
            path.Add(new Vector2I(n.X, n.Y));
        }
        path.Reverse();
        return path;
    }

    private void ExpandNeighbors(PathInstance inst, EasyStarNode node)
    {
        int x = node.X;
        int y = node.Y;
        if (y > 0)
        {
            CheckAdjacentNode(inst, node, 0, -1, StraightCost);
        }
        if (x < Width - 1)
        {
            CheckAdjacentNode(inst, node, 1, 0, StraightCost);
        }
        if (y < Height - 1)
        {
            CheckAdjacentNode(inst, node, 0, 1, StraightCost);
        }
        if (x > 0)
        {
            CheckAdjacentNode(inst, node, -1, 0, StraightCost);
        }
        if (!_diagonalsEnabled)
        {
            return;
        }
        // 四个斜向：禁止切角时要求两个正交邻居都可走
        // （= AStarGrid2D 的 DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES / H5 disableCornerCutting）
        if (x > 0 && y > 0 && CanCutCorner(node, x, y - 1, x - 1, y))
        {
            CheckAdjacentNode(inst, node, -1, -1, _diagonalStepCost);
        }
        if (x < Width - 1 && y < Height - 1 && CanCutCorner(node, x, y + 1, x + 1, y))
        {
            CheckAdjacentNode(inst, node, 1, 1, _diagonalStepCost);
        }
        if (x < Width - 1 && y > 0 && CanCutCorner(node, x, y - 1, x + 1, y))
        {
            CheckAdjacentNode(inst, node, 1, -1, _diagonalStepCost);
        }
        if (x > 0 && y < Height - 1 && CanCutCorner(node, x, y + 1, x - 1, y))
        {
            CheckAdjacentNode(inst, node, -1, 1, _diagonalStepCost);
        }
    }

    private bool CanCutCorner(EasyStarNode source, int orthoX1, int orthoY1, int orthoX2, int orthoY2)
    {
        if (_allowCornerCutting)
        {
            return true;
        }
        return IsTileWalkable(orthoX1, orthoY1, source.X, source.Y)
            && IsTileWalkable(orthoX2, orthoY2, source.X, source.Y);
    }

    private void CheckAdjacentNode(PathInstance inst, EasyStarNode node, int dx, int dy, float stepCost)
    {
        int nx = node.X + dx;
        int ny = node.Y + dy;
        int idx = ny * Width + nx;
        if (_avoided[idx] || !IsTileWalkable(nx, ny, node.X, node.Y))
        {
            return;
        }
        float cost = stepCost * GetTileCost(nx, ny);
        EasyStarNode neighbour = inst.GetOrCreate(this, nx, ny, node, cost);

        if (neighbour.List == EasyStarNode.NoList)
        {
            neighbour.List = EasyStarNode.OpenList;
            inst.Open.Push(neighbour);
        }
        else if (node.CostSoFar + cost < neighbour.CostSoFar)
        {
            neighbour.CostSoFar = node.CostSoFar + cost;
            neighbour.Parent = node;
            if (neighbour.List == EasyStarNode.ClosedList)
            {
                if (ReopenClosedNodes)   // 差异：EasyStar 不重开，这里可选
                {
                    neighbour.List = EasyStarNode.OpenList;
                    inst.Open.Push(neighbour);
                }
            }
            else
            {
                inst.Open.UpdateItem(neighbour);
            }
        }
    }

    // ============================================================
    // 网格查询
    // ============================================================
    private void EnsureConfigured(string who)
    {
        if (Width <= 0 || Height <= 0)
        {
            throw new InvalidOperationException($"{who} 之前必须先 SetGrid()。");
        }
        if (_acceptableTiles.Count == 0)
        {
            throw new InvalidOperationException($"{who} 之前必须先 SetAcceptableTiles()。");
        }
    }

    private bool InBounds(int x, int y) => x >= 0 && y >= 0 && x < Width && y < Height;

    private bool IsTileWalkable(int x, int y, int sourceX, int sourceY)
    {
        if (!InBounds(x, y))
        {
            return false;
        }
        int idx = y * Width + x;
        EasyStarDirection[]? cond = _dirConditions[idx];
        if (cond != null && !DirectionAllowed(cond, sourceX - x, sourceY - y))
        {
            return false;
        }
        return _walkable[idx];
    }

    private static bool DirectionAllowed(EasyStarDirection[] allowed, int diffX, int diffY)
    {
        EasyStarDirection dir = CalculateDirection(diffX, diffY);
        foreach (EasyStarDirection d in allowed)
        {
            if (d == dir)
            {
                return true;
            }
        }
        return false;
    }

    private static EasyStarDirection CalculateDirection(int diffX, int diffY) => (diffX, diffY) switch
    {
        (0, -1) => EasyStarDirection.Top,
        (1, -1) => EasyStarDirection.TopRight,
        (1, 0) => EasyStarDirection.Right,
        (1, 1) => EasyStarDirection.BottomRight,
        (0, 1) => EasyStarDirection.Bottom,
        (-1, 1) => EasyStarDirection.BottomLeft,
        (-1, 0) => EasyStarDirection.Left,
        (-1, -1) => EasyStarDirection.TopLeft,
        _ => throw new ArgumentException($"非法方向差: {diffX},{diffY}"),
    };

    private float GetTileCost(int x, int y)
    {
        int idx = y * Width + x;
        float pointCost = _pointCost[idx];
        return pointCost != 0f ? pointCost : _cellCost[idx];
    }

    private void RebuildWalkable()
    {
        for (int i = 0; i < _tiles.Length; i++)
        {
            _walkable[i] = _acceptableTiles.Contains(_tiles[i]);
        }
    }

    private void RebuildCellCost()
    {
        for (int i = 0; i < _tiles.Length; i++)
        {
            _cellCost[i] = _costByType.TryGetValue(_tiles[i], out float c) ? c : 1f;
        }
    }

    /// <summary>
    /// 启发式：开对角用 Octile，否则曼哈顿（EasyStar 的 getDistance）。
    ///
    /// 注意 EasyStarJS 原式在开对角时是 `D*min + max`，而真实最短路长度是 `D*min + (max-min)`，
    /// 也就是它的启发式**高估了 min(dx,dy)** → 不可采纳（inadmissible）→ 找到的路径平均比最优长 1~4%
    /// （基准里实测：小地图 +1.1%，100x100 +4.0%，且与 AStarGrid2D 的 1.0000x 最优解对比 200/300 条次优）。
    /// UseAdmissibleOctile = true 时改用标准 Octile（`D*min + (max-min)`，可采纳且一致），
    /// 路径与 AStarGrid2D 一样最优；默认 false 保持与 EasyStar 行为完全一致。
    /// </summary>
    public bool UseAdmissibleOctile { get; set; }

    private float GetDistance(int x1, int y1, int x2, int y2)
    {
        int dx = Math.Abs(x1 - x2);
        int dy = Math.Abs(y1 - y2);
        if (!_diagonalsEnabled)
        {
            return dx + dy;
        }
        int min = Math.Min(dx, dy);
        int max = Math.Max(dx, dy);
        if (UseAdmissibleOctile)
        {
            return _diagonalStepCost * min + (max - min);   // 标准 Octile（可采纳）
        }
        return _diagonalStepCost * min + max;               // EasyStar 原式（高估 min）
    }

    // ============================================================
    // 后台线程池：整条路径在工作线程算完，结果回主线程触发回调
    // ============================================================
    private void WorkerLoop()
    {
        BlockingCollection<PathInstance> queue = _workQueue!;
        foreach (PathInstance inst in queue.GetConsumingEnumerable())
        {
            try
            {
                while (!inst.Done)
                {
                    StepInstance(inst, invokeCallback: false);
                }
            }
            catch (Exception e)
            {
                inst.Done = true;
                inst.Error = e.ToString();   // 错误回主线程再报（后台线程不碰 Godot API）
            }
            finally
            {
                _threadResults.Enqueue(inst);
                Interlocked.Decrement(ref _threadsInFlight);
            }
        }
    }
}
