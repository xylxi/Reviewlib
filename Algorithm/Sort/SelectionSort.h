//
// Created by DMW_W on 2018/8/12.
//

#ifndef SORT_SELECTIONSORT_H
#define SORT_SELECTIONSORT_H
#include <iostream>
using namespace std;

void selectionSort (int *arr,int n) {
    for (int i = 0 ; i < n - 1 ; i++) {
        int minIndex = i;
        for (int j = i + 1; j < n; ++j) {
            if (arr[j] < arr[minIndex]) minIndex = j;
        }
        swap(arr[i], arr[minIndex]);
    }
}


#endif //SORT_SELECTIONSORT_H
