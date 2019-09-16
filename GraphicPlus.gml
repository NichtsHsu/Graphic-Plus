#define graphic_init
// graphic_init()
{
    // Path of dll file. You should change it if the dll path is not at same as the path of gmk/exe.
    // dll的路径。如果不在.gmk/.exe同路径下，请修改路径。
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
/* 模糊一个表面。
 * level : 模糊的次数。
 * 动态生成模糊效果，当level大于3的时候可能就会开始掉帧。
 * 静态生成模糊效果，你可以设置level到非常大，比如50。
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
/* 以块状模糊表面。
 * level : 模糊的次数。
 *      动态生成模糊效果，当level大于3的时候可能就会开始掉帧。
 *      静态生成模糊效果，你可以设置level到非常大，比如50。
 */
{
    return external_call(global.__graphic_box_blur_mosaic, argument0, argument1, argument2, argument3);
}

#define graphic_gray_scale
// graphic_gray_scale(surf)
// Gray = (Red + Green + Blue) / 3
// 灰度化，算法为灰=(红+绿+蓝)/3
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
/* 将表面马赛克化。
 * type:
 *      0 -- 正方形
 *      1 -- 圆形
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

