#include "cuda_runtime.h"  
#include "device_launch_parameters.h"

static unsigned *data = NULL;
static int N;

__global__ void grayScale(unsigned *img)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	unsigned gray = ((img[i] & 0xFFU) + ((img[i] & 0xFF00U) >> 8) + ((img[i] & 0xFF0000U) >> 16)) / 3;
	img[i] = 0xFF000000U | gray << 16 | gray << 8 | gray;
}

extern "C" void addGrayScaleKernel(unsigned *imageData, int *args)
{
	cudaSetDevice(0);
	N = args[0] * args[1];
	if(data == NULL)
		cudaMalloc((void**)&data, N * sizeof(unsigned));
	cudaMemcpy(data, imageData, N * sizeof(unsigned), cudaMemcpyHostToDevice);
	dim3 blockSize(args[0]);
    dim3 gridSize(args[1]);
	grayScale<<<gridSize, blockSize>>> (data);
	cudaDeviceSynchronize();
	cudaMemcpy(imageData, data, N * sizeof(unsigned), cudaMemcpyDeviceToHost);
}

extern "C" void freeGrayScaleKernel()
{
	if(data != NULL)
		cudaFree(data);
}

extern "C" void reMallocGrayScale(int width, int height)
{
	freeGrayScaleKernel();

	cudaMalloc((void**)&data, width * height * sizeof(unsigned));
}