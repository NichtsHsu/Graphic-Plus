#define graphic_init
// graphic_init()
{
    // dll的路径。如果不在.gmk/.exe同路径下，请修改路径。
    global.GraphicPlusDllPath = "GraphicPlus.dll"
    global.__graphic_gray_scale = external_define(global.GraphicPlusDllPath, "__graphic_gray_scale", dll_stdcall, ty_real, 1, ty_real);
    global.__graphic_free = external_define(global.GraphicPlusDllPath, "__graphic_free", dll_stdcall, ty_real, 0);
}

#define graphic_gray_scale
// graphic_gray_scale(surf)
// 灰度化，算法为灰=(红+绿+蓝)/3
{
    return external_call(global.__graphic_gray_scale, argument0);
}

#define graphic_free
// graphic_free()
{
    external_call(global.__graphic_free, argument0);
    external_free(global.GraphicPlusDllPath);
}

