namespace EasyStarCs;

/// <summary>
/// A* 搜索节点 —— 对应 EasyStarJS 的 src/node.js。
/// f = g(CostSoFar) + h(Estimated)，堆按 f 排序（与 EasyStar 的 bestGuessDistance() 一致）。
/// </summary>
public sealed class EasyStarNode
{
    /// <summary>不在任何表里（EasyStar 里 list === undefined）</summary>
    public const int NoList = -1;
    public const int ClosedList = 0;
    public const int OpenList = 1;

    public int X;
    public int Y;
    /// <summary>g：从起点走到本格的累计代价</summary>
    public float CostSoFar;
    /// <summary>h：到终点的启发式距离</summary>
    public float Estimated;
    public EasyStarNode? Parent;
    /// <summary>NoList / OpenList / ClosedList</summary>
    public int List = NoList;
    /// <summary>在二叉堆中的下标（-1 = 不在堆里），用于 decrease-key 的 UpdateItem</summary>
    public int HeapIndex = -1;

    public float BestGuessDistance => CostSoFar + Estimated;

    public void Reset()
    {
        Parent = null;
        List = NoList;
        HeapIndex = -1;
        CostSoFar = 0f;
        Estimated = 0f;
    }
}
