//
// Created by DMW_W on 2018/8/12.
//

#ifndef SORT_MERGESORT_H
#define SORT_MERGESORT_H

#include <iostream>
using namespace std;

// 对 arr[l...mid] 和 arr[mid + 1...l] 进行归并
template <typename T>
void __merge(T arr[], int l, int mid, int r) {
    T aux[r-l+1];
    for (int i = l; i <= r; ++i)
        aux[i-l] = arr[i];

    // 归并
    int i = l, j = mid + 1;
    for (int k = l; k <= r; ++k) {
        if (i > mid) {
            arr[k] = aux[j - l];
            j++;
        } else if ( j > r) {
            arr[k] = aux[i - l];
            i++;
        } else if (aux[i - l] < aux[j - l]) {
            arr[k] = aux[i - l];
            i++;
        } else {
            arr[k] = aux[j - l];
            j++;
        }
    }
}

// arr[l...r] 范围排序
template <typename T>
void __mergeSort(T arr[], int l, int r) {
    if (r - l <= 15) {
        insertionSort2(arr, l, r);
        return ;
    }
    // 这个代码右隐藏bug，就是l和r太多，那么就会超过 int 可以表达的范围
    int mid = (l + r ) / 2;
    __mergeSort(arr, l, mid);
    __mergeSort(arr, mid + 1, r);
    if (arr[mid] > arr[mid+1])
        __merge(arr,l , mid, r);
}

template <typename T>
void mergeSort(T arr[], int n) {
    __mergeSort(arr, 0 , n-1);
}

#endif //SORT_MERGESORT_H
