//
// Created by DMW_W on 2018/8/14.
//

#ifndef SORT_APPLYDEMO_H
#define SORT_APPLYDEMO_H

#include <iostream>
using namespace std;

/**
 * 1. 求逆序对
 */

int __merge(int arr[], int l, int mid, int r) {
    int *aux = new int[r-l+1];
    for( int i = l ; i <= r ; i ++ )
        aux[i-l] = arr[i];

    int count = 0;
    int j = l, k = mid+1;
    for (int i = l; i <= r; i++) {
        if (j > mid) {
            arr[i] = aux[k-l];
            k++;
        } else if (k > r) {
            arr[i] = aux[j-l];
            j++;
        } else if (aux[j-l] <= aux[k-l]) {
            arr[i] = aux[j-l];
            j++;
        } else {
            arr[i] = aux[k-l];
            k++;
            count += (mid - j + 1);
        }
    }
    delete[] aux;
    return count;
}

int __mergeSort(int arr[], int l, int r) {
    if (r <= l) {
        return 0;
    }
    int mid = l + (r - l) / 2;
    int count1 = __mergeSort(arr, l, mid);
    int count2 = __mergeSort(arr, mid+1,r);
    return count1 + count2 + __merge(arr, l, mid, r);
}

int nxd(int arr[], int n) {
    int count = __mergeSort(arr, 0 , n - 1);
    for (int i = 0; i < n; ++i) {
        printf("%d ",arr[i]);
    }
    printf("\n");
    return count;
}

/**
 * 2. 求数组中第 index 大的元素
 */

// partition 过程, 和快排的partition一样
// 思考: 双路快排和三路快排的思想能不能用在selection算法中? :)不能，因为
int __partition( int arr[], int l, int r ){
    int p = rand()%(r-l+1) + l;
    swap( arr[l] , arr[p] );

    int j = l; //[l+1...j] < p ; [lt+1..i) > p
    for( int i = l + 1 ; i <= r ; i ++ )
        if( arr[i] < arr[l] )
            swap(arr[i], arr[++j]);

    swap(arr[l], arr[j]);

    return j;
}

int indexValue(int arr[], int l, int r, int k) {
    if( l == r )
        return arr[l];

    // partition之后, arr[p]的正确位置就在索引p上
    int p = __partition( arr, l, r );

    if( k == p )    // 如果 k == p, 直接返回arr[p]
        return arr[p];
    else if( k < p )    // 如果 k < p, 只需要在arr[l...p-1]中找第k小元素即可
        return indexValue( arr, l, p-1, k);
    else // 如果 k > p, 则需要在arr[p+1...r]中找第k-p-1小元素
        // 注意: 由于我们传入__selection的依然是arr, 而不是arr[p+1...r],
        //       所以传入的最后一个参数依然是k, 而不是k-p-1
        return indexValue( arr, p+1, r, k );


}


#endif //SORT_APPLYDEMO_H
