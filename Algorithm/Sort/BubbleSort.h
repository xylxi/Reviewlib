//
// Created by DMW_W on 2018/8/12.
//

#ifndef SORT_BUBBLESORT_H
#define SORT_BUBBLESORT_H

#include <iostream>
using namespace std;

void bubbleSort(int *arr, int n) {

    for (int i = 1 ; i < n ; i++) {
        for (int j = 0; j < n - i; ++j) {
            if (arr[j] > arr[j+1]) {
                swap(arr[j], arr[j+1]);
            }
        }
    }

}

void bubbleSort2(int *arr, int n) {
    for (int i = 1 ; i < n ; i++) {
        int max = arr[0];
        // 记录当前可以放入元素的位置
        int tmp = 0;
        for (int j = 0; j < n - i; ++j) {
            if (max > arr[j+1]) {
                arr[j] = arr[j+1];
            } else {
                arr[j] = max;
                max = arr[j+1];
            }
            tmp = j+1;
        }
    }
}

#endif //SORT_BUBBLESORT_H
