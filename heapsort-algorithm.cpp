// A heapsort constructed using
#include <iostream>
#include <string>
#include <vector>
using namespace std;
void buildHeap(int A[], int last);
void MaxHeapify(int A[], int parent, int  last);
void swap(int &child, int &parent);
void heapsort(int A[], int size);
// Function to build the heap, calls MaxHeapify
//Indexing starts at 0,
// left child = (2*parent) + 1
// right child = (2*parent) + 2
// parent = (size/2) -1
void buildHeap(int A[], int last) {
    for (int i = (last/2) - 1; i >=0; i--){
        MaxHeapify(A, i, last);
    }
}
void MaxHeapify(int A[], int parent, int  last) {
    int child = 2*parent + 1;
    while (child <= last-1) {
        // (if right child index <= last index, and A[right child] > A[left child]; child++
        if (child + 1 <= last-1 && A[child+1] > A[child])
            child++;
        if (A[child] > A[parent])
            swap(A[child], A[parent]);
        
        parent = child;
        child = 2*parent+1;
    }
}
// Swaps the elements in the array
void swap(int &child, int &parent) {
    
    int temp = child;
    child = parent;
    parent = temp;
}
// sorts the heap
void heapsort(int A[], size_t size) {
    for (unsigned int i = size; i > 0; i--) {
        int temp = A[i-1];
        A[i-1] = A[0];
        A[0] = temp;
        buildHeap(A, i-1);
    }
    
}
int main() {
    cout << "This is a heapsort algorithm from least to greatest" << endl;
    return 0;
}
