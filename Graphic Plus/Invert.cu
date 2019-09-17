#include "cuda_runtime.h"  
#include "device_launch_parameters.h"

static unsigned char *data = NULL;
static int N;

__global__ void Invert(unsigned char* img, bool invertTransparentPixel)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	if (invertTransparentPixel || img[4 * i + 3])
	{
		img[4 * i] = 255 - img[4 * i];
		img[4 * i + 1] = 255 - img[4 * i + 1];
		img[4 * i + 2] = 255 - img[4 * i + 2];
	}
}

extern "C" void addInvertKernel(unsigned *imageData, int *args)
{
	cudaSetDevice(0);
	N = args[0] * args[1];
	if (data == NULL)
		cudaMalloc((void**)&data, N * sizeof(unsigned));
	cudaMemcpy(data, imageData, N * sizeof(unsigned), cudaMemcpyHostToDevice);
	dim3 blockSize(args[0]);
	dim3 gridSize(args[1]);
	Invert <<<gridSize, blockSize >>> (data, bool(args[2]));
	cudaDeviceSynchronize();
	cudaMemcpy(imageData, data, N * sizeof(unsigned), cudaMemcpyDeviceToHost);
}

extern "C" void freeInvertKernel()
{
	if (data != NULL)
		cudaFree(data);
}

extern "C" void reMallocInvert(int width, int height)
{
	freeInvertKernel();

	cudaMalloc((void**)&data, width * height * sizeof(unsigned));
}