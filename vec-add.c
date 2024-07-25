#include <stdlib.h>

void vecAdd(float* A_h, float* B_h, float* C_h, int n) {
  for (int i = 0; i < n; ++i){
    C_h[i] = A_h[i] + B_h[i];
  }
}

int main() {
  #define VEC_SIZE 10000
  float* A = (float*) malloc(sizeof(float) * VEC_SIZE);
  float* B = (float*) malloc(sizeof(float) * VEC_SIZE);
  float* C = (float*) malloc(sizeof(float) * VEC_SIZE);

  vecAdd(A, B, C, VEC_SIZE);

  return 0;
}