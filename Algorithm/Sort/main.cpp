#include <iostream>
#include "SortTestHelper.h"
#include "SelectionSort.h"
#include "InsertionSort.h"
#include "BubbleSort.h"
#include "MergeSort.h"
#import "QuickSort.h"
#include "ApplyDemo.h"

using namespace std;


int main() {
    int a[] = {5,4,3,2,1};
    int count = indexValue(a,0,4,3);
    printf("%d",count);
    return 0;
}