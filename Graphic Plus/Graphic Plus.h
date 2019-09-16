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

typedef double GMReal;
typedef char *GMString;

extern gm::CGMAPI *gmapi;

class Effect
{
public:
	Effect(void(*addFunc)(unsigned *, int *), void(*freeFunc)(), void(*reMallocFunc)(int, int), int argsNum);
	~Effect();

	bool exec(int surf, int *args);

private:
	int m_argsNum;
	int *m_args;
	void(*m_addFunc)(unsigned *, int *);
	void(*m_freeFunc)();
	void(*m_reMallocFunc)(int, int);
	int m_width, m_height;
	IDirect3DTexture8 *m_textureTemp;
};

extern "C"
{
	GRAPHICPLUS_API GMReal __graphic__init();

	void addGrayScaleKernel(unsigned *imageData, int *args);
	void freeGrayScaleKernel();
	void reMallocGrayScale(int width, int height);
	GRAPHICPLUS_API GMReal __graphic_gray_scale(GMReal surf);

	void addBoxBlurKernel(unsigned *imageData, int *args);
	void freeBoxBlurKernel();
	void reMallocBoxBlur(int width, int height);
	GRAPHICPLUS_API GMReal __graphic_box_blur(GMReal surf, GMReal level);

	void addBoxBlurMosaicKernel(unsigned *imageData, int *args);
	void freeBoxBlurMosaicKernel();
	void reMallocBoxBlurMosaic(int width, int height);
	GRAPHICPLUS_API GMReal __graphic_box_blur_mosaic(GMReal surf, GMReal level, GMReal blockWidth, GMReal blockHeight);

	GRAPHICPLUS_API GMReal __graphic_free();
}