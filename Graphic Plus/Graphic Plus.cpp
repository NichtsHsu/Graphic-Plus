// Graphic Plus.cpp : 定义 DLL 应用程序的导出函数。
//

#include "stdafx.h"
#include "Graphic Plus.h"

gm::CGMAPI *gmapi = nullptr;
extern Effect *ef_gray_scale = nullptr,
*ef_box_blur = nullptr,
*ef_box_blur_mosaic = nullptr;

Effect::Effect(void(*addFunc)(unsigned *, int *), void(*freeFunc)(), void(*reMallocFunc)(int, int), int argsNum) :
	m_addFunc(addFunc), m_freeFunc(freeFunc), m_reMallocFunc(reMallocFunc), m_argsNum(argsNum), m_args(new int[2 + argsNum]), m_textureTemp(nullptr)
{

};

Effect::~Effect()
{
	delete[] m_args;
	if (m_textureTemp != nullptr)
		m_textureTemp->Release();

	m_freeFunc();
}

bool Effect::exec(int surf, int *args)
{
	if (!gm::surface_exists(surf))
		return false;

	int texid = gm::surface_get_texture(surf);
	IDirect3DTexture8 *texture = gm::CGMAPI::GetTextureArray()[texid].texture;
	IDirect3DDevice8 *device;
	texture->GetDevice(&device);

	if (!m_width)
	{
		m_width = gm::surface_get_width(surf);
		m_height = gm::surface_get_height(surf);
	}
	else if (m_width != gm::surface_get_width(surf) || m_height != gm::surface_get_height(surf))
	{
		m_width = gm::surface_get_width(surf);
		m_height = gm::surface_get_height(surf);
		if (m_textureTemp != nullptr)
			m_textureTemp->Release();

		device->CreateTexture(m_width, m_width, 0, D3DUSAGE_DYNAMIC, D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, &m_textureTemp);
		m_reMallocFunc(m_width, m_height);
	}

	IDirect3DSurface8 *surface, *surfaceDest;
	if (m_textureTemp == nullptr)
		device->CreateTexture(m_width, m_height, 0, D3DUSAGE_DYNAMIC, D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, &m_textureTemp);
	texture->GetSurfaceLevel(0, &surface);
	m_textureTemp->GetSurfaceLevel(0, &surfaceDest);
	device->CopyRects(surface, NULL, 0, surfaceDest, NULL);
	D3DLOCKED_RECT lock;
	m_textureTemp->LockRect(0, &lock, NULL, 0);
	unsigned * imageData = reinterpret_cast<unsigned *>(lock.pBits);
	m_args[0] = m_width;
	m_args[1] = m_height;
	for (int i = 0; i < m_argsNum; i++)
		m_args[2 + i] = args[i];
	m_addFunc(imageData, m_args);
	m_textureTemp->UnlockRect(0);
	device->UpdateTexture(m_textureTemp, texture);
	return true;
}

GMReal __graphic__init()
{
	ef_gray_scale = new Effect(&addGrayScaleKernel, &freeGrayScaleKernel, &reMallocGrayScale, 0);
	ef_box_blur = new Effect(&addBoxBlurKernel, &freeBoxBlurKernel, &reMallocBoxBlur, 1);
	ef_box_blur_mosaic = new Effect(&addBoxBlurMosaicKernel, &freeBoxBlurMosaicKernel, &reMallocBoxBlurMosaic, 3);

	return GMReal(true);
}

GMReal __graphic_gray_scale(GMReal surf)
{
	return GMReal(ef_gray_scale->exec(surf, nullptr));
}

GMReal __graphic_box_blur(GMReal surf, GMReal level)
{
	int args = level;
	return GMReal(ef_box_blur->exec(surf, &args));
}
GMReal __graphic_box_blur_mosaic(GMReal surf, GMReal level, GMReal blockWidth, GMReal blockHeight)
{
	int args[] = { int(level), int(blockWidth), int(blockHeight)};
	return GMReal(ef_box_blur_mosaic->exec(surf, args));
}

GMReal __graphic_free()
{
	delete ef_gray_scale;
	delete ef_box_blur;
	delete ef_box_blur_mosaic;

	return GMReal(true);
}