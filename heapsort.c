//C heap sort using malloc and free and alloc
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
void make_error_msg(int x){
  switch(x){
    case 1 :
            printf ("Invalid Entry or Empty Array");
            return;
    case 2 :
            printf("No more memory available, data corrupted");
            return;
    default :
            printf("Unexpected behaviour");
            return;
  }
}

int main(){
  // int heap[] = {234,320,-34,594,3,23};
  // int size = 6;
  int i;
  int* heap;
  int size = 0;
  int x=0;
  do{
    x++;
    printf("Enter a non-zero number to be sorted");
    scanf("%d",&i);
    if(size==0){
      if(i==0){
          make_error_msg(1);
          exit(1);
       }
       else{
         heap = malloc(sizeof(int));
         if(heap==NULL){
           make_error_msg(2);
           exit(1);
         }
         heap[size]=i;
         size++;
       }
    }//end if i ==0
    else{
      if(i!=0){
        heap = realloc(heap, (size+1)*sizeof(int));
        if(heap==NULL){
          exit(1);
          return 0;
        }
        heap[size]=i;
        size++;
      }//no else for if i!=0
    }
  }while(i!=0);
  printheap(heap, size);
  make_heap(heap, size);
  heapsort(heap,size);
  printf("Sorted result is as follows:\n");
  printheap(heap, size);
  free(heap);
  return 0;
}
