#include "cuda_runtime.h"  
#include "device_launch_parameters.h"
#include <cmath>

using std::ceilf;

static unsigned char *oriImg = NULL, *blurImg = NULL;

__global__ void MosaicSquare(
	unsigned char *const output,
	const unsigned char *const input,
	int rows,
	int cols,
	int size
	)
{
	int r = blockIdx.y * blockDim.y + threadIdx.y;
	int c = blockIdx.x * blockDim.x + threadIdx.x;
	int pos = (r * cols + c) * 4;

	if ((r >= rows) || (c >= cols))
	{
		return;
	}

	int left = (c / size) * size;
	int right = min((c / size + 1) * size, cols);
	int top = (r / size) * size;
	int bottom = min((r / size + 1) * size, rows);
	int cpos = ((top + bottom) * cols / 2 + (left + right) / 2) * 4;

	output[pos] = input[cpos];
	output[pos + 1] = input[cpos + 1];
	output[pos + 2] = input[cpos + 2];
	output[pos + 3] = 255;
};

__global__ void MosaicCircle(
	unsigned char *const output,
	const unsigned char *const input,
	int rows,
	int cols,
	int size
	)
{
	int r = blockIdx.y * blockDim.y + threadIdx.y;
	int c = blockIdx.x * blockDim.x + threadIdx.x;
	int pos = (r * cols + c) * 4;

	if ((r >= rows) || (c >= cols))
	{
		return;
	}

	int left = (c / size) * size;
	int right = min((c / size + 1) * size, cols);
	int top = (r / size) * size;
	int bottom = min((r / size + 1) * size, rows);
	int centc = (left + right) / 2;
	int centr = (top + bottom) / 2;
	int cpos = (centr * cols + centc) * 4;

	if ((r - centr) * (r - centr) + (c - centc) * (c - centc) <= (size / 2) * (size / 2))
	{
		output[pos] = input[cpos];
		output[pos + 1] = input[cpos + 1];
		output[pos + 2] = input[cpos + 2];
		output[pos + 3] = 255;
	}
	else
	{
		int num = 0, cr = 0, cc = 0;
		int red = 0, green = 0, blue = 0;
		for (int i = -8; i <= 8; i++)
		{
			for (int j = -8; j <= 8; j++)
			{
				cr = r + i;
				cc = c + j;
				if (cr < 0 || cr >= rows || cc < 0 || cc >= cols)
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
}

extern "C" void freeMosaicKernel()
{
	if (oriImg != NULL)
		cudaFree(oriImg);
	if (blurImg != NULL)
		cudaFree(blurImg);
}

extern "C" void reMallocMosaic(int width, int height)
{
	if (oriImg != NULL)
		cudaFree(oriImg);
	if (blurImg != NULL)
		cudaFree(blurImg);

	cudaMalloc((void**)&oriImg, width * height * sizeof(unsigned));
	cudaMalloc((void**)&blurImg, width * height * sizeof(unsigned));
}

extern "C" void addMosaicKernel(unsigned *imageData, int *args)
{
	cudaSetDevice(0);
	if (oriImg == NULL)
		reMallocMosaic(args[0], args[1]);

	cudaMemcpy(oriImg, imageData, args[0] * args[1] * sizeof(unsigned), cudaMemcpyHostToDevice);
	static const int BLOCK_WIDTH = 32;

	int x = static_cast<int>(ceilf(static_cast<float>(args[0]) / BLOCK_WIDTH));
	int y = static_cast<int>(ceilf(static_cast<float>(args[1]) / BLOCK_WIDTH));

	const dim3 grid(x, y, 1);
	const dim3 block(BLOCK_WIDTH, BLOCK_WIDTH, 1);

	switch (args[2])
	{
		case 0:
			MosaicSquare <<< grid, block >>> (blurImg, oriImg, args[1], args[0], args[3]);
			break;

		case 1:
			MosaicCircle <<< grid, block >>> (blurImg, oriImg, args[1], args[0], args[3]);
			break;
	}
	cudaDeviceSynchronize();

	cudaMemcpy(imageData, blurImg, args[0] * args[1] * sizeof(unsigned), cudaMemcpyDeviceToHost);
}