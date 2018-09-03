//
// Created by DMW_W on 2018/8/29.
//

#ifndef UNIONFIND_UNIONF4_H
#define UNIONFIND_UNIONF4_H

#include <cassert>

using namespace std;

// 我们的第四版Union-Find
namespace UF4{

    class UnionFind{

    private:
        int* rank;   // rank[i]表示以i为根的集合所表示的树的层数
        int* parent; // parent[i]表示第i个元素所指向的父节点
        int count;   // 数据个数

    public:
        // 构造函数
        UnionFind(int count){
            parent = new int[count];
            rank = new int[count];
            this->count = count;
            for( int i = 0 ; i < count ; i ++ ){
                parent[i] = i;
                rank[i] = 1;
            }
        }

        // 析构函数
        ~UnionFind(){
            delete[] parent;
            delete[] rank;
        }

        // 查找过程, 查找元素p所对应的集合编号
        // O(h)复杂度, h为树的高度
        // 路径压缩
        int find(int p){
            assert( p >= 0 && p < count );

            // path compression 1
            while( p != parent[p] ){
                parent[p] = parent[parent[p]];
                p = parent[p];
            }
            return p;

            // path compression 2, 递归算法
//            if( p != parent[p] )
//                parent[p] = find( parent[p] );
//            return parent[p];
        }

        // 查看元素p和元素q是否所属一个集合
        // O(h)复杂度, h为树的高度
        bool isConnected( int p , int q ){
            return find(p) == find(q);
        }

        void unionElements(int p, int q) {
            int pRoot = find(p);
            int qRoot = find(qRoot);
            if (pRoot == qRoot)
                return;
            if (rank[pRoot] < rank[qRoot]) {
                parent[pRoot] = qRoot;
            } else if (rank[pRoot] > rank[qRoot]) {
                parent[qRoot] = pRoot;
            } else {
                parent[qRoot] = pRoot;
                rank[qRoot] += 1;
            }
        }

    };
 }
#endif //UNIONFIND_UNIONF4_H
