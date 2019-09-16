#define graphic_init
// graphic_init()
{
    // Path of dll file. You should change it if the dll path is not at same as the path of gmk/exe.
    // dll��·�����������.gmk/.exeͬ·���£����޸�·����
    global.__graphicPlusDllPath = "GraphicPlus.dll"
    global.__graphic_init = external_define(global.__graphicPlusDllPath, "__graphic__init", dll_stdcall, ty_real, 0);
    global.__graphic_box_blur = external_define(global.__graphicPlusDllPath, "__graphic_box_blur", dll_stdcall, ty_real, 2, ty_real, ty_real);
    global.__graphic_box_blur_mosaic = external_define(global.__graphicPlusDllPath, "__graphic_box_blur_mosaic", dll_stdcall, ty_real, 4, ty_real, ty_real, ty_real, ty_real);
    global.__graphic_gray_scale = external_define(global.__graphicPlusDllPath, "__graphic_gray_scale", dll_stdcall, ty_real, 1, ty_real);
    global.__graphic_mosaic = external_define(global.__graphicPlusDllPath, "__graphic_mosaic", dll_stdcall, ty_real, 3, ty_real, ty_real, ty_real);
    global.__graphic_free = external_define(global.__graphicPlusDllPath, "__graphic_free", dll_stdcall, ty_real, 0);
    return external_call(global.__graphic_init);
}

#define graphic_box_blur
// graphic_box_blur(surf, level)
/* Blur a surface.
 * level : how times the blur execute.
 *      For dynamic blur, it may be frame loss when level larger than 3.
 *      For static blur, you can set level very large such as 50.
 */
/* ģ��һ�����档
 * level : ģ���Ĵ�����
 * ��̬����ģ��Ч������level����3��ʱ����ܾͻῪʼ��֡��
 * ��̬����ģ��Ч�������������level���ǳ��󣬱���50��
 */
{
    return external_call(global.__graphic_box_blur, argument0, argument1);
}

#define graphic_box_blur_mosaic
// graphic_box_blur_mosaic(surf, level, blockWidth, blockHeight)
/* Blur a surface by block.
 * level : how times the blur execute.
 *      For dynamic blur, it may be frame loss when level larger than 3.
 *      For static blur, you can set level very large such as 50.
 */
/* �Կ�״ģ�����档
 * level : ģ���Ĵ�����
 *      ��̬����ģ��Ч������level����3��ʱ����ܾͻῪʼ��֡��
 *      ��̬����ģ��Ч�������������level���ǳ��󣬱���50��
 */
{
    return external_call(global.__graphic_box_blur_mosaic, argument0, argument1, argument2, argument3);
}

#define graphic_gray_scale
// graphic_gray_scale(surf)
// Gray = (Red + Green + Blue) / 3
// �ҶȻ����㷨Ϊ��=(��+��+��)/3
{
    return external_call(global.__graphic_gray_scale, argument0);
}

#define graphic_mosaic
// graphic_mosaic(surf, type, size)
/* Make surface as mosaic.
 * type:
 *      0 -- Square
 *      1 -- Circle
 */
/* �����������˻���
 * type:
 *      0 -- ������
 *      1 -- Բ��
 */

{
    return external_call(global.__graphic_mosaic, argument0, argument1, argument2);
}

#define graphic_free
// graphic_free()
{
    ret = external_call(global.__graphic_free);
    external_free(global.__graphicPlusDllPath);
    return ret;
}

