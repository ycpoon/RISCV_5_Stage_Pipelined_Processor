/////////////////////////////////////////////////
// graph.c
// a bunch of linked list and graph stuff
/////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>

#define RESULT_SHOW 0
#define DEBUG_DEF 0

#include "tj_malloc.h"

#ifndef DEBUG
extern void exit();
#endif

struct queue {
    int items[40];
    int front;
    int rear;
};

struct node{
    int vertex;
    struct node* next;
};

struct node* createNode(int);

struct Graph{
    int numVertices;
    struct node** adjLists;
    int* visited;
};

struct node* createNode(int v) {
    struct node* newNode = (struct node*)tj_malloc(sizeof(struct node));
    newNode->vertex = v;
    newNode->next = NULL;
    return newNode;
}

struct Graph* createGraph(int vertices) {
    int i;
    struct Graph* graph = (struct Graph*)tj_malloc(sizeof(struct Graph));
    graph->numVertices = vertices;

    graph->adjLists = (struct node**)tj_malloc(vertices * sizeof(struct node*));
    graph->visited = (int*)tj_malloc(vertices * sizeof(int));

    for (i = 0; i < vertices; i++) {
        graph->adjLists[i] = NULL;
        graph->visited[i] = 0;
    }

    return graph;
}

void addEdge(struct Graph* graph, int src, int dest) {
    // Add edge from src to dest
    struct node* newNode = createNode(dest);
    newNode->next = graph->adjLists[src];
    graph->adjLists[src] = newNode;

    // Add edge from dest to src
    newNode = createNode(src);
    newNode->next = graph->adjLists[dest];
    graph->adjLists[dest] = newNode;
}

struct queue* createQueue() {
    struct queue* q = (struct queue*)tj_malloc(sizeof(struct queue));
    q->front = -1;
    q->rear = -1;
    return q;
}

int isEmpty(struct queue* q) {
    if(q->rear == -1)
        return 1;
    else
        return 0;
}

void enqueue(struct queue* q, int value){
    if(q->rear == 40-1){
#if (RESULT_SHOW == 1)
        printf("\nQueue is Full!!");
#endif
    } else {
        if(q->front == -1)
            q->front = 0;
        q->rear++;
        q->items[q->rear] = value;
    }
}

int dequeue(struct queue* q){
    int item;
    if(isEmpty(q)){
#if (RESULT_SHOW == 1)
        printf("Queue is empty");
#endif
        item = -1;
    }
    else{
        item = q->items[q->front];
        q->front++;
        if(q->front > q->rear){
#if (RESULT_SHOW == 1)
            printf("Resetting queue");
#endif
            q->front = q->rear = -1;
        }
    }
    return item;
}

#if (RESULT_SHOW == 1)
    void printQueue(struct queue *q) {
        int i = q->front;
        if(isEmpty(q)) {
            printf("Queue is empty");
        } else {
            printf("\nQueue contains \n");
            for(i = q->front; i < q->rear + 1; i++) {
                printf("%d ", q->items[i]);
            }
        }
    }
#endif

void bfs(struct Graph* graph, int startVertex) {
    struct queue* q = createQueue();

    graph->visited[startVertex] = 1;
    enqueue(q, startVertex);

    while(!isEmpty(q)){
#if (RESULT_SHOW == 1)
        printQueue(q);
#endif
        int currentVertex = dequeue(q);
#if (RESULT_SHOW == 1)
        printf("Visited %d\n", currentVertex);
#endif
       struct node* temp = graph->adjLists[currentVertex];

       while(temp) {
            int adjVertex = temp->vertex;
            if(graph->visited[adjVertex] == 0){
                graph->visited[adjVertex] = 1;
                enqueue(q, adjVertex);
            }
            temp = temp->next;
       }
    }
}

void bfs_test(){
    struct Graph* graph = createGraph(6);
    addEdge(graph, 0, 1);
    addEdge(graph, 0, 2);
    addEdge(graph, 1, 2);
    addEdge(graph, 1, 4);
    addEdge(graph, 1, 3);
    addEdge(graph, 2, 4);
    addEdge(graph, 3, 4);

    bfs(graph, 0);
}

struct Node {
    int data;
    struct Node *next;
};

void insertAtTheBegin(struct Node **start_ref, int data) {
    struct Node *ptr1 = (struct Node*)tj_malloc(sizeof(struct Node));
    ptr1->data = data;
    ptr1->next = *start_ref;
    *start_ref = ptr1;
}

void swap(struct Node *a, struct Node *b) {
    int temp = a->data;
    a->data = b->data;
    b->data = temp;
}

void bubbleSort(struct Node *start) {
    int swapped, i;
    struct Node *ptr1;
    struct Node *lptr = NULL;

    if (start == NULL)
        return;

    do{
        swapped = 0;
        ptr1 = start;

        while (ptr1->next != lptr){
            if (ptr1->data > ptr1->next->data){
                swap(ptr1, ptr1->next);
                swapped = 1;
            }
            ptr1 = ptr1->next;
        }
        lptr = ptr1;
    }
    while (swapped);
}

void link_list() {
    int arr[] = {12, 56, 2, 11, 1, 90};
    int list_size, i;

    struct Node *start = NULL;

    for (i = 0; i< 6; i++)
        insertAtTheBegin(&start, arr[i]);

    bubbleSort(start);
}


struct Vertex {
   bool visited;
};


int stack[5];
int top = -1;


struct Vertex* lstVertices[5];

int adjMatrix[5][5];

int vertexCount = 0;


void push(int item) {
   stack[++top] = item;
}

int pop() {
   return stack[top--];
}

int peek() {
   return stack[top];
}

bool isStackEmpty() {
   return top == -1;
}


void addVertex() {
   struct Vertex* vertex = (struct Vertex*)tj_malloc(sizeof(struct Vertex));
   vertex->visited = false;
   lstVertices[vertexCount++] = vertex;
}

void addEdge_DFS(int start,int end) {
   adjMatrix[start][end] = 1;
   adjMatrix[end][start] = 1;
}

int getAdjUnvisitedVertex(int vertexIndex) {
   int i;

   for(i = 0; i < vertexCount; i++) {
      if(adjMatrix[vertexIndex][i] == 1 && lstVertices[i]->visited == false) {
         return i;
      }
   }

   return -1;
}

void depthFirstSearch() {
   int i;

   lstVertices[0]->visited = true;


   push(0);

   while(!isStackEmpty()) {
      int unvisitedVertex = getAdjUnvisitedVertex(peek());

      if(unvisitedVertex == -1) {
         pop();
      } else {
         lstVertices[unvisitedVertex]->visited = true;
         push(unvisitedVertex);
      }
   }

   for(i = 0;i < vertexCount;i++) {
      lstVertices[i]->visited = false;
   }
}

void DFS_test() {
   int i, j;

   for(i = 0; i < 5; i++) {   // set adjacency {
      for(j = 0; j < 5; j++) // matrix to 0
         adjMatrix[i][j] = 0;
   }

   addVertex();   // 0
   addVertex();   // 1
   addVertex();   // 2
   addVertex();   // 3
   addVertex();   // 4

   addEdge_DFS(0, 1);    // S - A
   addEdge_DFS(0, 2);    // S - B
   addEdge_DFS(0, 3);    // S - C
   addEdge_DFS(1, 4);    // A - D
   addEdge_DFS(2, 4);    // B - D
   addEdge_DFS(3, 4);    // C - D

   depthFirstSearch();

}

int towers(int num, char frompeg, char topeg, char auxpeg){
    if (num == 1){
        return 0;
    }
    towers(num - 1, frompeg, auxpeg, topeg);
    towers(num - 1, auxpeg, topeg, frompeg);
    return 0;
}

void towers_test(){
    towers(5, 'A', 'C', 'B');
}

int main(){

    bfs_test();

    link_list();

    DFS_test();

    towers_test();

    return 0;
}
