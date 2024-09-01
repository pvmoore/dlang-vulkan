module vulkan.imgui.all;

public:

import vulkan.imgui.imgui_glfw;
import vulkan.imgui.imgui_memory_editor;
import vulkan.imgui.imgui_overloads;
import vulkan.imgui.imgui_impl_vulkan_h;
import vulkan.imgui.imgui_impl_vulkan;

enum IMGUI_VERSION     = "1.91.0";
enum IMGUI_VERSION_NUM = 19100; 

enum IM_COL32_R_SHIFT =  0;
enum IM_COL32_G_SHIFT =  8;
enum IM_COL32_B_SHIFT =  16;
enum IM_COL32_A_SHIFT =  24;
enum IM_COL32_A_MASK  =  0xFF000000;

uint IM_COL32(uint R, uint G, uint B, uint A) {
    return (((A)<<IM_COL32_A_SHIFT) | ((B)<<IM_COL32_B_SHIFT) | ((G)<<IM_COL32_G_SHIFT) | ((R)<<IM_COL32_R_SHIFT));
}

enum IM_COL32_WHITE       = IM_COL32(255,255,255,255);  // Opaque white = 0xFFFFFFFF
enum IM_COL32_BLACK       = IM_COL32(0,0,0,255);        // Opaque black
enum IM_COL32_BLACK_TRANS = IM_COL32(0,0,0,0);          // Transparent black = 0x00000000

