// 下列 ifdef 块是创建使从 DLL 导出更简单的
// 宏的标准方法。此 DLL 中的所有文件都是用命令行上定义的 GRAPHICPLUS_EXPORTS
// 符号编译的。在使用此 DLL 的
// 任何项目上不应定义此符号。这样，源文件中包含此文件的任何其他项目都会将
// GRAPHICPLUS_API 函数视为是从 DLL 导入的，而此 DLL 则将用此宏定义的
// 符号视为是被导出的。
#ifdef GRAPHICPLUS_EXPORTS
#define GRAPHICPLUS_API __declspec(dllexport)
#else
#define GRAPHICPLUS_API __declspec(dllimport)
#endif

#include "Gmapi.h"
#include <d3d8.h>
#pragma comment (lib, "d3d8.lib")
#include <d3dx8.h>
#pragma comment (lib, "d3dx8.lib")
#include <omp.h>

typedef double GMReal;
typedef char *GMString;

extern gm::CGMAPI *gmapi;
extern int width, height;
extern IDirect3DTexture8 *textureDest;

extern "C"
{
	void addKernel(unsigned *imageData, int width, int height);
	void freeKernel();
	void reMalloc(int width, int height);
	GRAPHICPLUS_API GMReal __graphic_gray_scale(GMReal surf);
	GRAPHICPLUS_API GMReal __graphic_free();
}

void reShape(IDirect3DDevice8 *device, int width, int height);