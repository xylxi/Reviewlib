//
// Created by DMW_W on 2018/8/29.
//

#ifndef UNIONFIND_UNIONF1_H
#define UNIONFIND_UNIONF1_H

#include <iostream>
#include <cassert>

using namespace std;

namespace UF1 {
    class UnionFind {
    private:
        int *id;
        int count;

    public:
        UnionFind(int n) {
            count = n;
            id = new int[n];
            for (int i = 0; i < n; ++i) {
                id[i] = i;
            }
        }

        ~UnionFind() {
            delete[] id;
        }

        int find(int p) {
            return id[p];
        }

        bool isConnect(int p, int q) {
            return find(p) == find(q);
        }

        void unionElements(int p, int q) {
            int pID = find(p);
            int qID = find(q);
            if (qID == pID) {
                return ;
            }
            for (int i = 0; i < count; ++i) {
                if (find(i) == pID){
                    id[i] = qID;
                }
            }
        }

    };
}

#endif //UNIONFIND_UNIONF1_H
