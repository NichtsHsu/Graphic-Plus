// Graphic Plus.cpp : 定义 DLL 应用程序的导出函数。
//

#include "stdafx.h"
#include "Graphic Plus.h"

gm::CGMAPI *gmapi = nullptr;
int width = 0, height = 0;
IDirect3DTexture8 *textureDest = nullptr;

GMReal __graphic_gray_scale(GMReal surf)
{
	if (!gm::surface_exists(surf))
		return GMReal(false);

	int texid = gm::surface_get_texture(surf);
	IDirect3DTexture8 *texture = gm::CGMAPI::GetTextureArray()[texid].texture;
	IDirect3DDevice8 *device;
	texture->GetDevice(&device);

	if (!::width)
	{
		::width = gm::surface_get_width(surf);
		::height = gm::surface_get_height(surf);
	}
	else if (::width != gm::surface_get_width(surf) || ::height != gm::surface_get_height(surf))
	{
		::width = gm::surface_get_width(surf);
		::height = gm::surface_get_height(surf);
		reShape(device, ::width, ::height);
	}

	IDirect3DSurface8 *surface, *surfaceDest;
	if(textureDest == nullptr)
		device->CreateTexture(::width, ::height, 0, D3DUSAGE_DYNAMIC, D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, &textureDest);
	texture->GetSurfaceLevel(0, &surface);
	textureDest->GetSurfaceLevel(0, &surfaceDest);
	device->CopyRects(surface, NULL, 0, surfaceDest, NULL);
	D3DLOCKED_RECT lock;
	textureDest->LockRect(0, &lock, NULL, 0);
	unsigned * imageData = reinterpret_cast<unsigned *>(lock.pBits);
	addKernel(imageData, ::width, ::height);
	textureDest->UnlockRect(0);
	device->UpdateTexture(textureDest, texture);
	return GMReal(true);
}

void reShape(IDirect3DDevice8 *device, int width, int height)
{
	if (textureDest != nullptr)
		textureDest->Release();

	device->CreateTexture(width, width, 0, D3DUSAGE_DYNAMIC, D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, &textureDest);
	reMalloc(width, height);
}

GMReal __graphic_free()
{
	if (textureDest != nullptr)
		textureDest->Release();

	return GMReal(true);
}