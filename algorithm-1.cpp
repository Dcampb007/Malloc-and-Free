// This algorithm allocated the size of the array at the beginning, fills the elements, then outputs the elements.
// After that, this algorithm frees the whole array at once.
//NOTE: this is not an array_list or vector. trying to access memory out of range will return a non-zero number.
//NOTE: This program has been modified to use int* pointers instead of void* in FREE
// Will change upon more conversation with Dr. Bloom
#include <iostream>
#include <string>
#include <vector>
#include "heapsort-algorithm.cpp"
using namespace std;
void* Malloc(size_t size) {
    if (size == 0)
        return NULL;
    int *array;
    array = new (nothrow) int[size];
    //array[0] = 1;
    //cout << array[0];
    return array;
}
void Free(int* array) {
    array = (int*) array;
    if (array == 0)
        return;
    else {
            delete[]  array;
    }
}

void printArray(int A[], size_t size) {
    for( int i = 0; i < size; i++)
        cout << A[i] << ", ";

}
//NOTE: The 0 terminating array will never display the 0 at the end. It is in the array technically, but never displayed to the user
// while building the heap, size = array_size; for allocating space for array, size = array_size + 1
int main() {
    size_t array_size;
    cout << "Enter an array size:  ";
    cin >> array_size;
    int *array;                          //  allocating memory for the int array
    array  = (int*)Malloc(array_size+1); // Allocated 1 extra space of memory for the 0 terminating array
    int number;
    int counter = 0;
    do {
        cout << "Enter a NON ZERO numbers. Enter 0 to end your array " <<  "INDEX ";
        cout << counter << ":  ";
        cin >> number;
        *(array+counter) = number;
        counter++;
    }while( counter <= array_size && number != 0);
    
    if (counter == array_size && number != 0) {
        cout << "ACCESSING MEMORY OUTSIDE OF THE ARRAY";
        return 1;
    }
    else if( counter <= array_size) {
        int new_size = counter-1;
        heapsort(array, new_size); // counter is the new array size because the original allocated space wasn't used)
        printArray(array, new_size);
    }
    else{
        heapsort(array, array_size);
        printArray(array, array_size);
        }
    Free(array);
    return 0;
}
