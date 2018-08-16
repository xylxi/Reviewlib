//
// Created by DMW_W on 2018/8/13.
//

#ifndef SORT_QUICKSORT_H
#define SORT_QUICKSORT_H

#include <iostream>
#include "InsertionSort.h"
using namespace std;

// 没有进行优化的partition算法
template <typename T>
int __partition(T arr[], int l, int r) {
    T e = arr[l];
    int j = l;
    for (int i = l + 1; i <= r; ++i) {
        if (arr[i] < e) {
            swap(arr[++j],arr[i]);
        }
    }
    swap(arr[l],arr[j]);
    return j;
}

template <typename T>
int __partition1(T arr[], int l, int r) {
    // 随机获取比较的种子，避免分配不平衡的状况
    srand(time(NULL));
    swap(arr[l], arr[rand() % (r - l + 1) + l]);
    T e = arr[l];
    int j = l;
    for (int i = l + 1; i <= r; ++i) {
        if (arr[i] < e) {
            swap(arr[++j],arr[i]);
        }
    }
    swap(arr[l],arr[j]);
    return j;
}

template <typename T>
int __partition2(T arr[], int l, int r) {
    srand(time(NULL));
    swap(arr[l], arr[rand() % (r - l + 1) + l]);
    T e = arr[l];
    int i = l+1;
    // arr[l+1,r) 和 arr(j...r]
    int j = r;
    while (true) {
        // 防止与参考值相等的值只分布在一边，造成两端不平衡
        while (i <= r && arr[i] < e) i++;
        while (j >= l + 1 && arr[j] > e)j--;
        if (i > j) break;
        swap(arr[i],arr[j]);
        i++;
        j--;
    }
    swap(arr[l],arr[j]);
    return j;
}

template <typename T>
void __partition3way(T arr[], int l, int r) {

    if (r <= l) {
        return ;
    }

    srand(time(NULL));
    swap(arr[l], arr[rand() % (r - l + 1) + l]);
    T e = arr[l];

    int lt = l;
    int gt = r;
    int i = l + 1;
    while (i <= gt) {
        if (arr[i] < e) {
            lt++;
            swap(arr[i],arr[lt]);
            i++;
        } else if (arr[i] > e) {
            swap(arr[i],arr[gt]);
            gt--;
        } else {
            i++;
        }
    }
    swap(arr[l],arr[lt]);
    __partition3way(arr, l,lt-1);
    __partition3way(arr, gt+1, r);
}

template <typename T>
void __quickSort(T arr[], int l, int r) {
    // 对于小规模数组, 使用插入排序进行优化
    if( r - l <= 15 ){
        insertionSort2(arr,l,r);
        return;
    }

    int p = __partition2(arr, l, r);
    __quickSort(arr,l, p-1);
    __quickSort(arr,p+1, r);
}

template <typename T>
void quickSort(T arr[], int n) {
    __quickSort(arr, 0, n - 1);
}

template <typename T>
void quickSort3(T arr[], int n) {
    __partition3way(arr, 0, n - 1);
}


#endif //SORT_QUICKSORT_H
