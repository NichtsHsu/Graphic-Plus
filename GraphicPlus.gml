#define graphic_init
// graphic_init()
{
    // dll��·�����������.gmk/.exeͬ·���£����޸�·����
    global.GraphicPlusDllPath = "GraphicPlus.dll"
    global.__graphic_gray_scale = external_define(global.GraphicPlusDllPath, "__graphic_gray_scale", dll_stdcall, ty_real, 1, ty_real);
    global.__graphic_free = external_define(global.GraphicPlusDllPath, "__graphic_free", dll_stdcall, ty_real, 0);
}

#define graphic_gray_scale
// graphic_gray_scale(surf)
// �ҶȻ����㷨Ϊ��=(��+��+��)/3
{
    return external_call(global.__graphic_gray_scale, argument0);
}

#define graphic_free
// graphic_free()
{
    external_call(global.__graphic_free, argument0);
    external_free(global.GraphicPlusDllPath);
}

