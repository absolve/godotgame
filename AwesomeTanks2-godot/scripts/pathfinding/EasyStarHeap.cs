using System.Collections.Generic;

namespace EasyStarCs;

/// <summary>
/// 二叉最小堆 —— 对应 EasyStarJS 用的 heap 库（只用到 push / pop / updateItem / size）。
/// 节点自带 HeapIndex，UpdateItem 才能 O(log n) 地降低键值（A* 的 decrease-key）。
/// </summary>
public sealed class EasyStarHeap
{
    private readonly List<EasyStarNode> _items = new();

    public int Count => _items.Count;

    public void Clear()
    {
        for (int i = 0; i < _items.Count; i++)
        {
            _items[i].HeapIndex = -1;
        }
        _items.Clear();
    }

    public void Push(EasyStarNode node)
    {
        node.HeapIndex = _items.Count;
        _items.Add(node);
        SiftUp(node.HeapIndex);
    }

    public EasyStarNode Pop()
    {
        EasyStarNode root = _items[0];
        root.HeapIndex = -1;
        int last = _items.Count - 1;
        if (last > 0)
        {
            _items[0] = _items[last];
            _items[0].HeapIndex = 0;
        }
        _items.RemoveAt(last);
        if (_items.Count > 0)
        {
            SiftDown(0);
        }
        return root;
    }

    /// <summary>键值变化后重新定位该节点（EasyStar 的 heap.updateItem）</summary>
    public void UpdateItem(EasyStarNode node)
    {
        int i = node.HeapIndex;
        if (i < 0 || i >= _items.Count)
        {
            return;
        }
        SiftUp(i);
        SiftDown(node.HeapIndex);
    }

    private void SiftUp(int i)
    {
        while (i > 0)
        {
            int parent = (i - 1) >> 1;
            if (_items[parent].BestGuessDistance <= _items[i].BestGuessDistance)
            {
                break;
            }
            Swap(parent, i);
            i = parent;
        }
    }

    private void SiftDown(int i)
    {
        int n = _items.Count;
        while (true)
        {
            int left = (i << 1) + 1;
            int right = left + 1;
            int smallest = i;
            if (left < n && _items[left].BestGuessDistance < _items[smallest].BestGuessDistance)
            {
                smallest = left;
            }
            if (right < n && _items[right].BestGuessDistance < _items[smallest].BestGuessDistance)
            {
                smallest = right;
            }
            if (smallest == i)
            {
                return;
            }
            Swap(i, smallest);
            i = smallest;
        }
    }

    private void Swap(int a, int b)
    {
        (_items[a], _items[b]) = (_items[b], _items[a]);
        _items[a].HeapIndex = a;
        _items[b].HeapIndex = b;
    }
}
