#include "cuda_runtime.h"  
#include "device_launch_parameters.h"
#include <cmath>

using std::ceilf;

static unsigned char *oriImg = NULL, *blurImg = NULL;

__global__ void BoxBlurMosaic(
	unsigned char *const output,
	const unsigned char *const input,
	int rows,
	int cols,
	int blockWidth,
	int blockHieght
	)
{
	int r = blockIdx.y * blockDim.y + threadIdx.y;
	int c = blockIdx.x * blockDim.x + threadIdx.x;
	int pos = (r * cols + c) * 4;

	if ((r >= rows) || (c >= cols))
	{
		return;
	}

	int left = (c / blockWidth) * blockWidth;
	int right = min((c / blockWidth + 1) * blockWidth, cols);
	int top = (r / blockHieght) * blockHieght;
	int bottom = min((r / blockHieght + 1) * blockHieght, rows);
	int num = 0, cr = 0, cc = 0, cpos;
	int red = 0, green = 0, blue = 0;
	for (int i = -2; i <= 2; i++)
	{
		for (int j = -2; j <= 2; j++)
		{
			cr = r + i;
			cc = c + j;
			if (cr < top || cr >= bottom || cc < left || cc >= right)
				continue;
			cpos = (cr * cols + cc) * 4;
			red += input[cpos];
			green += input[cpos + 1];
			blue += input[cpos + 2];
			num++;
		}
	}

	output[pos] = red / num;
	output[pos + 1] = green / num;
	output[pos + 2] = blue / num;
	output[pos + 3] = 255;
}

extern "C" void freeBoxBlurMosaicKernel()
{
	if (oriImg != NULL)
		cudaFree(oriImg);
	if (blurImg != NULL)
		cudaFree(blurImg);
}

extern "C" void reMallocBoxBlurMosaic(int width, int height)
{
	if (oriImg != NULL)
		cudaFree(oriImg);
	if (blurImg != NULL)
		cudaFree(blurImg);

	cudaMalloc((void**)&oriImg, width * height * sizeof(unsigned));
	cudaMalloc((void**)&blurImg, width * height * sizeof(unsigned));
}

extern "C" void addBoxBlurMosaicKernel(unsigned *imageData, int *args)
{
	cudaSetDevice(0);
	if (oriImg == NULL)
		reMallocBoxBlurMosaic(args[0], args[1]);

	cudaMemcpy(oriImg, imageData, args[0] * args[1] * sizeof(unsigned), cudaMemcpyHostToDevice);
	static const int BLOCK_WIDTH = 32;

	int x = static_cast<int>(ceilf(static_cast<float>(args[0]) / BLOCK_WIDTH));
	int y = static_cast<int>(ceilf(static_cast<float>(args[1]) / BLOCK_WIDTH));

	const dim3 grid(x, y, 1);
	const dim3 block(BLOCK_WIDTH, BLOCK_WIDTH, 1);

	for (int i = 0; i < args[2]; i++)
	{
		BoxBlurMosaic <<< grid, block >>>(blurImg, oriImg, args[1], args[0], args[3], args[4]);
		cudaMemcpy(oriImg, blurImg, args[0] * args[1] * sizeof(unsigned), cudaMemcpyDeviceToDevice);
		cudaDeviceSynchronize();
	}

	cudaMemcpy(imageData, blurImg, args[0] * args[1] * sizeof(unsigned), cudaMemcpyDeviceToHost);
}