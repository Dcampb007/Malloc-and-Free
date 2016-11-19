#include <iostream>
#include <string>
#include <vector>
using namespace std;
void buildHeap(int A[], int last);
void MaxHeapify(int A[], int parent, int  last);
void swap(int &child, int &parent);

void buildHeap(int A[], int last) {
	for (int i = (last/2) - 1; i >=0; i--){
		MaxHeapify(A, i, last);
	}
}
void MaxHeapify(int A[], int parent, int  last) {
	//cout << A[parent] << endl;
	int child = 2*parent + 1;
	while (child <= last) {
		if (child + 1 <= last && A[child+1] > A[child]) 
			child++;
		if (A[child] > A[parent]) 
			swap(A[child], A[parent]);
		parent = child;
		child = 2*parent+1;
		}
	}

void swap(int &child, int &parent) {
	int temp = child;
	child = parent;
	parent = temp;
}
int main () {
	int array[5] = {1, 4, 6, 5, 3};
	buildHeap(array, 5);
	for ( int i = 0; i < 5; i++) {
		cout << array[i] << endl;
	}
	return 0;

}
