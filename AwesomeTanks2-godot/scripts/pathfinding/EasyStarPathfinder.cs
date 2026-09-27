using System;
using System.Collections.Generic;
using Godot;

namespace EasyStarCs;

/// <summary>
/// EasyStarPathfinder —— 给 GDScript 用的寻路外观（[GlobalClass]，GDScript 可 `EasyStarPathfinder.new()`）。
///
/// 它与原来的 GDScript 版 `ATPathfinder`（scenes/level/pathfinder.gd）API 一一对应，
/// 只是把内部的 Godot AStarGrid2D 换成了 EasyStar 的 C# 实现（scripts/pathfinding/EasyStar.cs）。
/// GDScript 侧的门面类 ATPathfinder 只做转发，所以 Level / ATEnemy 的调用点一行都不用改。
///
/// 网格模型（与原 ATPathfinder 完全一致）：
///   - 格子类型：0 = 可走，1 = 不可走（solid）；由 SetSolid(x, y, on) 切换；
///   - 世界坐标 ↔ 格子坐标用 tileSize 换算，格心 = (x + 0.5) * tileSize；
///   - 必须整张地图都显式 SetSolid 一遍（构造时默认全可走）。
///
/// 寻路策略（与旧实现等价）：
///   - 起点/终点格被占时退到最近可走格；
///   - 目标不可达时返回"部分路径"（先洪水填充找出最接近目标的可达格）；
///   - 斜走规则：8 向、禁止贴角斜穿（两个正交邻居都要可走）；
///   - 启发式：标准 Octile（可采纳）→ 路径与 Godot AStarGrid2D 一样是最优的。
///
/// 线程：默认单线程（不建任何线程）。SetWorkerThreads(n) 的线程池能力保留着，
///       以后需要大量敌人并行寻路时再开（游戏当前不启用）。
/// </summary>
[GlobalClass]
public partial class EasyStarPathfinder : RefCounted
{
    /// <summary>可走格子的类型值（与 GDScript 版 ATPathfinder 的"非 solid"对应）</summary>
    public const int Walkable = 0;
    /// <summary>不可走格子的类型值（墙/障碍/固定单位占格）</summary>
    public const int Solid = 1;

    private EasyStar _es = new();
    private int _width;
    private int _height;
    private int _tileSize = 52;
    private bool _ready;

    public int Width => _width;
    public int Height => _height;
    public int TileSize => _tileSize;
    public bool IsReady => _ready;

    /// <summary>线程模式信息（当前游戏不启用线程池，恒为 false / 0）</summary>
    public bool Threaded => _es.Threaded;
    public int WorkerCount => _es.WorkerCount;

    // ============================================================
    // 初始化 / 可通行性
    // ============================================================
    /// <summary>按地图尺寸初始化网格（默认全部可走，之后逐个 SetSolid）</summary>
    public void Setup(int width, int height, int tileSize)
    {
        _width = Math.Max(width, 1);
        _height = Math.Max(height, 1);
        _tileSize = Math.Max(tileSize, 1);

        var tiles = new int[_width * _height];      // 全 0 = 全可走
        _es = new EasyStar();
        _es.SetGridFlat(tiles, _width, _height);
        _es.SetAcceptableTiles(Walkable);
        _es.EnableDiagonals();
        _es.DisableCornerCutting();                  // 禁止贴角斜穿（与旧 AStarGrid2D 口径一致）
        _es.SetDiagonalStepCost(MathF.Sqrt(2f));     // 斜走代价 √2（与旧口径一致）
        _es.UseAdmissibleOctile = true;              // 标准 Octile：路径最优
        _ready = true;
    }

    /// <summary>标记/取消某格不可通行（墙、障碍、被摧毁的固定单位占格）</summary>
    public void SetSolid(int x, int y, bool on)
    {
        if (!_ready)
        {
            return;
        }
        _es.SetTileType(x, y, on ? Solid : Walkable);
    }

    public bool IsSolid(int x, int y) => !_ready || !_es.IsWalkable(x, y);

    public bool InBounds(int x, int y) =>
        x >= 0 && y >= 0 && x < _width && y < _height;

    /// <summary>线程池：保留能力，游戏当前不调用（0 = 单线程）</summary>
    public void SetWorkerThreads(int workers)
    {
        _es.SetWorkerThreads(workers);
    }

    // ============================================================
    // 坐标换算
    // ============================================================
    public Vector2I WorldToCell(Vector2 world) =>
        new((int)Math.Floor(world.X / _tileSize), (int)Math.Floor(world.Y / _tileSize));

    public Vector2 CellCenter(Vector2I cell) =>
        new((cell.X + 0.5f) * _tileSize, (cell.Y + 0.5f) * _tileSize);

    // ============================================================
    // 寻路
    // ============================================================
    /// <summary>
    /// 世界坐标 → 世界坐标路径点（含终点格中心）。空数组 = 完全不可达（连部分路径都没有）。
    /// 目标不可达时返回"部分路径"：终点落在最接近目标的可达格，敌人会一路推进到墙边。
    /// </summary>
    public Vector2[] FindPath(Vector2 fromWorld, Vector2 toWorld)
    {
        if (!_ready)
        {
            return Array.Empty<Vector2>();
        }
        Vector2I a = WorldToCell(fromWorld);
        Vector2I b = WorldToCell(toWorld);
        if (!InBounds(a.X, a.Y) || !InBounds(b.X, b.Y))
        {
            return Array.Empty<Vector2>();
        }
        if (IsSolid(a.X, a.Y))
        {
            // 起点格被占（单位正压在已摧毁的固定单位格上）：从最近的可走格出发
            a = NearestFree(a);
            if (a.X < 0)
            {
                return Array.Empty<Vector2>();
            }
        }
        if (a == b)
        {
            return Array.Empty<Vector2>();
        }
        if (IsSolid(b.X, b.Y))
        {
            // 目标格被占（例如站在障碍格里）：退而求其次找旁边的可走格
            b = NearestFree(b);
            if (b.X < 0)
            {
                return Array.Empty<Vector2>();
            }
        }

        List<Vector2I>? cells = _es.TryFindPathSync(a.X, a.Y, b.X, b.Y);
        if (cells == null)
        {
            // 不可达：退化成"部分路径"——洪水填充找最接近目标的可达格，再走过去
            Vector2I fallback = ClosestReachable(a, b);
            if (fallback == a)
            {
                return Array.Empty<Vector2>();
            }
            cells = _es.TryFindPathSync(a.X, a.Y, fallback.X, fallback.Y);
            if (cells == null)
            {
                return Array.Empty<Vector2>();
            }
        }
        return CellsToWorld(cells, fromWorld);
    }

    /// <summary>路径平滑：从起点开始，能直线看到更远的点就跳过中间点（string pulling）</summary>
    public Vector2[] SmoothPath(Vector2[] path, Vector2 fromWorld)
    {
        if (!_ready || path == null || path.Length <= 1)
        {
            return path ?? Array.Empty<Vector2>();
        }
        var outPath = new List<Vector2>(path.Length);
        Vector2 anchor = fromWorld;
        int i = 0;
        while (i < path.Length)
        {
            int far = i;
            for (int j = path.Length - 1; j > i; j--)
            {
                if (IsLineWalkable(anchor, path[j]))
                {
                    far = j;
                    break;
                }
            }
            outPath.Add(path[far]);
            anchor = path[far];
            i = far + 1;
        }
        return outPath.ToArray();
    }

    /// <summary>两点之间是否可直线通行（Bresenham 走格，遇 solid 即 false）</summary>
    public bool IsLineWalkable(Vector2 fromWorld, Vector2 toWorld) =>
        IsCellLineWalkable(WorldToCell(fromWorld), WorldToCell(toWorld));

    public bool IsCellLineWalkable(Vector2I a, Vector2I b)
    {
        if (!_ready)
        {
            return false;
        }
        int x = a.X;
        int y = a.Y;
        int dx = Math.Abs(b.X - a.X);
        int dy = -Math.Abs(b.Y - a.Y);
        int sx = a.X < b.X ? 1 : -1;
        int sy = a.Y < b.Y ? 1 : -1;
        int err = dx + dy;
        while (true)
        {
            if (IsSolid(x, y))
            {
                return false;
            }
            if (x == b.X && y == b.Y)
            {
                return true;
            }
            int e2 = 2 * err;
            if (e2 >= dy)
            {
                err += dy;
                x += sx;
            }
            if (e2 <= dx)
            {
                err += dx;
                y += sy;
            }
        }
    }

    // ============================================================
    // 内部工具
    // ============================================================
    private Vector2[] CellsToWorld(List<Vector2I> cells, Vector2 fromWorld)
    {
        var outPts = new List<Vector2>(cells.Count);
        foreach (Vector2I c in cells)
        {
            outPts.Add(CellCenter(c));
        }
        // 去掉"起点所在格"：避免先往回走一小步（与旧实现一致）
        if (outPts.Count > 1 && fromWorld.DistanceTo(outPts[0]) < _tileSize * 0.6f)
        {
            outPts.RemoveAt(0);
        }
        return outPts.ToArray();
    }

    /// <summary>最近的可走格（半径 1~3 搜索），找不到返回 (-1,-1)</summary>
    private Vector2I NearestFree(Vector2I c)
    {
        for (int radius = 1; radius < 4; radius++)
        {
            for (int dy = -radius; dy <= radius; dy++)
            {
                for (int dx = -radius; dx <= radius; dx++)
                {
                    var n = new Vector2I(c.X + dx, c.Y + dy);
                    if (InBounds(n.X, n.Y) && !IsSolid(n.X, n.Y))
                    {
                        return n;
                    }
                }
            }
        }
        return new Vector2I(-1, -1);
    }

    /// <summary>
    /// 从 start 洪水填充（8 向、同样禁止贴角斜穿），返回"离 goal 最近"的可达格。
    /// 用于目标不可达时生成部分路径（与旧 AStarGrid2D 的 allow_partial_path 行为等价）。
    /// </summary>
    private Vector2I ClosestReachable(Vector2I start, Vector2I goal)
    {
        int cells = _width * _height;
        var seen = new bool[cells];
        var queue = new Queue<int>();
        int startIdx = start.Y * _width + start.X;
        seen[startIdx] = true;
        queue.Enqueue(startIdx);
        Vector2I best = start;
        float bestScore = Heuristic(start, goal);
        while (queue.Count > 0)
        {
            int idx = queue.Dequeue();
            int cx = idx % _width;
            int cy = idx / _width;
            float score = Heuristic(new Vector2I(cx, cy), goal);
            if (score < bestScore - 1e-4f)
            {
                bestScore = score;
                best = new Vector2I(cx, cy);
            }
            for (int dy = -1; dy <= 1; dy++)
            {
                for (int dx = -1; dx <= 1; dx++)
                {
                    if (dx == 0 && dy == 0)
                    {
                        continue;
                    }
                    int nx = cx + dx;
                    int ny = cy + dy;
                    if (!InBounds(nx, ny) || IsSolid(nx, ny))
                    {
                        continue;
                    }
                    if (dx != 0 && dy != 0
                        && (IsSolid(cx + dx, cy) || IsSolid(cx, cy + dy)))
                    {
                        continue;   // 禁止贴角斜穿
                    }
                    int ni = ny * _width + nx;
                    if (seen[ni])
                    {
                        continue;
                    }
                    seen[ni] = true;
                    queue.Enqueue(ni);
                }
            }
        }
        return best;
    }

    private static float Heuristic(Vector2I a, Vector2I b)
    {
        int dx = Math.Abs(a.X - b.X);
        int dy = Math.Abs(a.Y - b.Y);
        int min = Math.Min(dx, dy);
        int max = Math.Max(dx, dy);
        return 1.41421356f * min + (max - min);
    }
}
