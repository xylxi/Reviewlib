#include <iostream>
#include "HeapDemo.h"

int main() {

    MaxHeap<int> maxheap = MaxHeap<int>(100);
    int data[7];
    srand(time(NULL));
    for( int i = 0 ; i < 7 ; i ++ ){
        int d = rand()%100;
        data[i] = d;
        maxheap.insert( d );
    }
    maxheap.testPrint();
    for (int i = 0 ; i < 7 ; i++) {
        cout<< maxheap.extractMax()<< " ";
    }

    heapSort(data,7);
    for (int j = 0; j < 7; ++j) {
        cout<< data[j] << " ";
    }

    MaxHeap<int> maxheap2 = MaxHeap<int>(data, 7);
    maxheap2.testPrint();
//    for (int i = 0 ; i < 7 ; i++) {
//        cout<< maxheap2.extractMax()<<endl;
//    }

    return 0;
}