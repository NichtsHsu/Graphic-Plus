#include "cuda_runtime.h"  
#include "device_launch_parameters.h"

unsigned *data = NULL;
int N;

__global__ void grayScale(unsigned *img, int N)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	unsigned gray = ((img[i] & 0xFFU) + ((img[i] & 0xFF00U) >> 8) + ((img[i] & 0xFF0000U) >> 16)) / 3;
	img[i] = 0xFF000000U | gray << 16 | gray << 8 | gray;
}

extern "C" void addKernel(unsigned *imageData, int width, int height)
{
	cudaSetDevice(0);
	N = width * height;
	if(data == NULL)
		cudaMalloc((void**)&data, N * sizeof(unsigned));
	cudaMemcpy(data, imageData, N * sizeof(unsigned), cudaMemcpyHostToDevice);
	dim3 blockSize(width);
    dim3 gridSize(height);
	grayScale <<<gridSize, blockSize>>> (data, N);
	cudaThreadSynchronize();
	cudaMemcpy(imageData, data, N * sizeof(unsigned), cudaMemcpyDeviceToHost);
	cudaDeviceSynchronize();
}

extern "C" void freeKernel()
{
	if(data != NULL)
		cudaFree(data);
}

extern "C" void reMalloc(int width, int height)
{
	if(data != NULL)
		cudaFree(data);

	cudaMalloc((void**)&data, width * height * sizeof(unsigned));
}