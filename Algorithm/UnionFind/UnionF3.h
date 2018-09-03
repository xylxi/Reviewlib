//
// Created by DMW_W on 2018/8/29.
//

#ifndef UNIONFIND_UNIONF3_H
#define UNIONFIND_UNIONF3_H

#include <cassert>

using namespace std;

// 我们的第三版Union-Find
namespace UF3 {

    class UnionFind {

    private:
        int *parent; // parent[i]表示第i个元素所指向的父节点
        int *sz;     // sz[i]表示以i为根的集合中元素个数
        int count;   // 数据个数

    public:
        UnionFind(int count) {
            parent = new int[count];
            sz = new int[count];
            this->count = count;
            for (int i = 0; i < count; i++) {
                parent[i] = i;
                sz[i] = 1;
            }
        }

        // 析构函数
        ~UnionFind() {
            delete[] parent;
            delete[] sz;
        }

        // 查找过程, 查找元素p所对应的集合编号
        // O(h)复杂度, h为树的高度
        int find(int p) {
            while (parent[p] != p)
                p = parent[p];
            return p;
        }

        // 查看元素p和元素q是否所属一个集合
        // O(h)复杂度, h为树的高度
        bool isConnected(int p, int q) {
            return find(p) == find(q);
        }

        // 合并元素p和元素q所属的集合
        // O(h)复杂度, h为树的高度
        void unionElements(int p, int q) {
            int pRoot = find(p);
            int qRoot = find(q);
            if (pRoot == qRoot)
                return;;
            if (sz[pRoot] < sz[qRoot]) {
                parent[pRoot] = qRoot;
                sz[qRoot] += sz[pRoot];
            } else {
                parent[qRoot] = pRoot;
                sz[pRoot] += sz[qRoot];
            }
        }
    };
}

#endif //UNIONFIND_UNIONF3_H
