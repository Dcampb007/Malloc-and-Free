//C heap sort using malloc and free

#include<stdio.h>
#include<stdlib.h>

void printheap(int heap[], int size){
  for(int x = 0; x<size; x++){
    printf("%d ", heap[x]);
  }
  printf("\n");
}
void maxheapify(int heap[],int parent,int size){
  int child = (parent*2)+1, temp;
  while(child<size){
    if(heap[child]<heap[child+1]&&(child+1<size)){
      child++;//child refers to the larger of the two children
    }
    if(heap[parent]<heap[child]){
      temp = heap[parent];
      heap[parent] = heap[child];
      heap[child] = temp;
    }
    parent = child;
    child= (parent*2)+1;
  }
}
void heapsort(int heap[],int size){
  int temp,n = size;
  while(n>0){
    temp = heap[n-1];
    heap[n-1] = heap[0];
    heap[0]=temp;
    n-=1;
    maxheapify(heap,0,n);
    printheap(heap,n);
  }
}
void make_heap(int heap[], int size){
    for(int x = (size/2)-1; x>=0;x--){
    maxheapify(heap, x, size);
  }
}
int main(){
  int heap[] = {234,320,-34,594,3,23};
  int size = 6;
  int x=0;
  while(x<6){
    printf("Enter a non-zero number to be sorted");
    scanf("%d", &heap[x]);
    x++;
  }
  printheap(heap, size);
  make_heap(heap, size);
  heapsort(heap,size);
  printheap(heap, size);
  return 0;
}
