#include <stdlib.h>
#include <stdio.h>

// Each thead performs one pa-r-wose addition
__global__ 
void vecAddKernel(float* A, float* B, float* C, int n) {
  int i = threadIdx.x + blockDim.x * blockIdx.x;
  if (i < n) {
    C[i] = A[i] + B[i];
  }
}

__global__ 
void vecRangeKernel(float* A, float start, int n, float inc) {
  int i = threadIdx.x + blockDim.x * blockIdx.x;
  if (i < n) {
    A[i] = start + inc * i;
  }
}

void vecAdd(float* A_h, float* B_h, float* C_h, int n) { // host pointers
  int size = n * sizeof(float);
  float *A_d, *B_d, *C_d; // device pointers

  // Step 1: Allocate device memory for A, B, and C
  // Copy A and B to device memory
  cudaMalloc((void**) &A_d, size);
  cudaMalloc((void**) &B_d, size);
  cudaMalloc((void**) &C_d, size);

  cudaMemcpy(A_d, A_h, size, cudaMemcpyHostToDevice);
  cudaMemcpy(B_d, B_h, size, cudaMemcpyHostToDevice);

  // Step 2: Call kernel - to launch a grid of threads
  // to perform the actual vector addition
  vecRangeKernel<<<ceil(n/256.0), 256>>>(A_d, 0, n, 2);
  vecRangeKernel<<<ceil(n/256.0), 256>>>(B_d, 1, n, 1);

  vecAddKernel<<<ceil(n/256.0), 256>>>(A_d, B_d, C_d, n);
  
  // Step 3: Copy C from the device memory
  // Free device vectors
  cudaMemcpy(C_h, C_d, size, cudaMemcpyDeviceToHost);

  cudaFree(A_d);
  cudaFree(B_d);
  cudaFree(C_d);
}

int main() {
  #define VEC_SIZE 100000

  float* A = (float*) malloc(sizeof(float) * VEC_SIZE);
  float* B = (float*) malloc(sizeof(float) * VEC_SIZE);
  float* C = (float*) malloc(sizeof(float) * VEC_SIZE);

  const int print_n = 3;
  vecAdd(A, B, C, VEC_SIZE);
  for (int i = 0; i < print_n; ++i) {
    printf("C[%d]=%.0f\n", i+1, C[i]);
  }
  printf("...\n");
  for (int i = VEC_SIZE - print_n; i < VEC_SIZE; ++i) {
    printf("C[%d]=%.0f\n", i+1, C[i]);
  }

  free(A);
  free(B);
  free(C);

  printf("Done!\n");

  return 0;
}