//
// Created by DMW_W on 2018/8/12.
//

#ifndef SORT_INSERTIONSORT_H
#define SORT_INSERTIONSORT_H

#include <iostream>
using namespace std;

template <typename T>
void insertionSort(T arr[], int n) {
    for (int i = 1; i < n; ++i) {
        int tmp = arr[i];
        int j;
        for (j = i; j > 0 && tmp < arr[j - 1]; j--) {
            // 相比于选择排序来说，插入排序在每次循环中，都有提前终止的机会
            arr[j] = arr[j-1];
        }
        arr[j] = tmp;
    }
}

template <typename T>
void insertionSort2(T arr[], int l ,int r) {
    for (int i = l + 1 ; i <= r ; ++i) {
        T e = arr[i];
        int j;
        for (j = i; j > l && arr[j - 1] > e ; j--) {
            arr[j] = arr[j - 1];
        }
        arr[j] = e;
    }
}


#endif //SORT_INSERTIONSORT_H
