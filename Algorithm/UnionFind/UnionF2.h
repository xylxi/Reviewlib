//
// Created by DMW_W on 2018/8/29.
//

#ifndef UNIONFIND_UNIONF2_H
#define UNIONFIND_UNIONF2_H

#include <iostream>
#include <cassert>

using namespace std;

namespace UF2 {

    class UnionFind {

    private:
        int *parent;
        int count;

    public:

        UnionFind(int n) {
            count = n;
            parent = new int[n];
            for (int i = 0; i < n; ++i) {
                parent[i] = i;
            }
        }

        ~UnionFind() {
            delete[] parent;
        }

        // 查找过程, 查找元素p所对应的集合编号
        int find(int p) {
            while (parent[p] != p) {
                p = parent[p];
            }
            return p;
        }

        // 查看元素p和元素q是否所属一个集合
        // O(1)复杂度
        bool isConnected(int p, int q) {
            return find(p) == find(q);
        }

        // 合并元素p和元素q所属的集合
        // O(n) 复杂度
        void unionElements(int p, int q) {

            int pRoot = find(p);
            int qRoot = find(q);

            if (pRoot == qRoot)
                return;

            parent[pRoot] = qRoot;
        }

    };

}
#endif //UNIONFIND_UNIONF2_H
