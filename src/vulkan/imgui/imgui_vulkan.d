module vulkan.imgui.imgui_vulkan;

import vulkan.all;
import core.stdc.stdlib : calloc, free;

// dear imgui: Renderer Backend for Vulkan
// This needs to be used along with a Platform Backend (e.g. GLFW, SDL, Win32, custom..)

// Implemented features:
//  [X] Renderer: Support for large meshes (64k+ vertices) with 16-bit indices.
// Missing features:
//  [ ] Renderer: User texture binding. Changes of ImTextureID aren't supported by this backend! See https://github.com/ocornut/imgui/pull/914

// You can use unmodified imgui_impl_* files in your project. See examples/ folder for examples of using this.
// Prefer including the entire imgui/ repository into your project (either as a copy or as a submodule), and only build the backends you need.
// If you are new to Dear ImGui, read documentation from the docs/ folder + read the top of imgui.cpp.
// Read online: https://github.com/ocornut/imgui/tree/master/docs

// The aim of imgui_impl_vulkan.h/.cpp is to be usable in your engine without any modification.
// IF YOU FEEL YOU NEED TO MAKE ANY CHANGE TO THIS CODE, please share them and your feedback at https://github.com/ocornut/imgui/

// Important note to the reader who wish to integrate imgui_impl_vulkan.cpp/.h in their own engine/app.
// - Common ImGui_ImplVulkan_XXX functions and structures are used to interface with imgui_impl_vulkan.cpp/.h.
//   You will use those if you want to use this rendering backend in your engine/app.
// - Helper ImGui_ImplVulkanH_XXX functions and structures are only used by this example (main.cpp) and by
//   the backend itself (imgui_impl_vulkan.cpp), but should PROBABLY NOT be used by your own engine/app code.
// Read comments in imgui_impl_vulkan.h.

// #pragma once
// #include "imgui.h"      // IMGUI_IMPL_API

// [Configuration] in order to use a custom Vulkan function loader:
// (1) You'll need to disable default Vulkan function prototypes.
//     We provide a '#define IMGUI_IMPL_VULKAN_NO_PROTOTYPES' convenience configuration flag.
//     In order to make sure this is visible from the imgui_impl_vulkan.cpp compilation unit:
//     - Add '#define IMGUI_IMPL_VULKAN_NO_PROTOTYPES' in your imconfig.h file
//     - Or as a compilation flag in your build system
//     - Or uncomment here (not recommended because you'd be modifying imgui sources!)
//     - Do not simply add it in a .cpp file!
// (2) Call ImGui_ImplVulkan_LoadFunctions() before ImGui_ImplVulkan_Init() with your custom function.
// If you have no idea what this is, leave it alone!
//#define IMGUI_IMPL_VULKAN_NO_PROTOTYPES

// Vulkan includes
// #if defined(IMGUI_IMPL_VULKAN_NO_PROTOTYPES) && !defined(VK_NO_PROTOTYPES)
// #define VK_NO_PROTOTYPES
// #endif
// #include <vulkan/vulkan.h>

alias int32_t = int;
alias uint32_t = uint;
alias intptr_t = long;
enum VK_PRESENT_MODE_MAX_ENUM_KHR = cast(VkPresentModeKHR)0x7FFFFFFF;
enum ImDrawCallback_ResetRenderState = cast(ImDrawCallback)(-1);

// Initialization data, for ImGui_ImplVulkan_Init()
// [Please zero-clear before use!]
struct ImGui_ImplVulkan_InitInfo
{
    VkInstance                      Instance;
    VkPhysicalDevice                PhysicalDevice;
    VkDevice                        Device;
    uint32_t                        QueueFamily;
    VkQueue                         Queue;
    VkPipelineCache                 PipelineCache;
    VkDescriptorPool                DescriptorPool;
    uint32_t                        Subpass;
    uint32_t                        MinImageCount;          // >= 2
    uint32_t                        ImageCount;             // >= MinImageCount
    VkSampleCountFlagBits           MSAASamples;            // >= VK_SAMPLE_COUNT_1_BIT
    VkAllocationCallbacks*          Allocator;
    void                            function(VkResult err) CheckVkResultFn;
}

// Called by user code
// bool     ImGui_ImplVulkan_Init(ImGui_ImplVulkan_InitInfo* info, VkRenderPass render_pass);
// void     ImGui_ImplVulkan_Shutdown();
// void     ImGui_ImplVulkan_NewFrame();
// void     ImGui_ImplVulkan_RenderDrawData(ImDrawData* draw_data, VkCommandBuffer command_buffer, VkPipeline pipeline = VK_NULL_HANDLE);
// bool     ImGui_ImplVulkan_CreateFontsTexture(VkCommandBuffer command_buffer);
// void     ImGui_ImplVulkan_DestroyFontUploadObjects();
// void     ImGui_ImplVulkan_SetMinImageCount(uint32_t min_image_count); // To override MinImageCount after initialization (e.g. if swap chain is recreated)

// Optional: load Vulkan functions with a custom function loader
// This is only useful with IMGUI_IMPL_VULKAN_NO_PROTOTYPES / VK_NO_PROTOTYPES
// bool     ImGui_ImplVulkan_LoadFunctions(void function(const char* function_name, void* user_data) loader_func, void* user_data = null);

//-------------------------------------------------------------------------
// Internal / Miscellaneous Vulkan Helpers
// (Used by example's main.cpp. Used by multi-viewport features. PROBABLY NOT used by your own engine/app.)
//-------------------------------------------------------------------------
// You probably do NOT need to use or care about those functions.
// Those functions only exist because:
//   1) they facilitate the readability and maintenance of the multiple main.cpp examples files.
//   2) the upcoming multi-viewport feature will need them internally.
// Generally we avoid exposing any kind of superfluous high-level helpers in the backends,
// but it is too much code to duplicate everywhere so we exceptionally expose them.
//
// Your engine/app will likely _already_ have code to setup all that stuff (swap chain, render pass, frame buffers, etc.).
// You may read this code to learn about Vulkan, but it is recommended you use you own custom tailored code to do equivalent work.
// (The ImGui_ImplVulkanH_XXX functions do not interact with any of the state used by the regular ImGui_ImplVulkan_XXX functions)
//-------------------------------------------------------------------------

// struct ImGui_ImplVulkanH_Frame;
// struct ImGui_ImplVulkanH_Window;

// Helpers
//  void                 ImGui_ImplVulkanH_CreateOrResizeWindow(VkInstance instance, VkPhysicalDevice physical_device, VkDevice device, ImGui_ImplVulkanH_Window* wnd, uint32_t queue_family, const VkAllocationCallbacks* allocator, int w, int h, uint32_t min_image_count);
//  void                 ImGui_ImplVulkanH_DestroyWindow(VkInstance instance, VkDevice device, ImGui_ImplVulkanH_Window* wnd, const VkAllocationCallbacks* allocator);
//  VkSurfaceFormatKHR   ImGui_ImplVulkanH_SelectSurfaceFormat(VkPhysicalDevice physical_device, VkSurfaceKHR surface, const VkFormat* request_formats, int request_formats_count, VkColorSpaceKHR request_color_space);
//  VkPresentModeKHR     ImGui_ImplVulkanH_SelectPresentMode(VkPhysicalDevice physical_device, VkSurfaceKHR surface, const VkPresentModeKHR* request_modes, int request_modes_count);
//  int                  ImGui_ImplVulkanH_GetMinImageCountFromPresentMode(VkPresentModeKHR present_mode);

// Helper structure to hold the data needed by one rendering frame
// (Used by example's main.cpp. Used by multi-viewport features. Probably NOT used by your own engine/app.)
// [Please zero-clear before use!]
struct ImGui_ImplVulkanH_Frame
{
    VkCommandPool       CommandPool;
    VkCommandBuffer     CommandBuffer;
    VkFence             Fence;
    VkImage             Backbuffer;
    VkImageView         BackbufferView;
    VkFramebuffer       Framebuffer;
}

struct ImGui_ImplVulkanH_FrameSemaphores
{
    VkSemaphore         ImageAcquiredSemaphore;
    VkSemaphore         RenderCompleteSemaphore;
}

// Helper structure to hold the data needed by one rendering context into one OS window
// (Used by example's main.cpp. Used by multi-viewport features. Probably NOT used by your own engine/app.)
struct ImGui_ImplVulkanH_Window
{
    int                 Width;
    int                 Height;
    VkSwapchainKHR      Swapchain;
    VkSurfaceKHR        Surface;
    VkSurfaceFormatKHR  SurfaceFormat;
    VkPresentModeKHR    PresentMode = VK_PRESENT_MODE_MAX_ENUM_KHR;
    VkRenderPass        RenderPass;
    VkPipeline          Pipeline;               // The window pipeline may uses a different VkRenderPass than the one passed in ImGui_ImplVulkan_InitInfo
    bool                ClearEnable = true;
    VkClearValue        ClearValue;
    uint32_t            FrameIndex;             // Current frame being rendered to (0 <= FrameIndex < FrameInFlightCount)
    uint32_t            ImageCount;             // Number of simultaneous in-flight frames (returned by vkGetSwapchainImagesKHR, usually derived from min_image_count)
    uint32_t            SemaphoreIndex;         // Current set of swapchain wait semaphores we're using (needs to be distinct from per frame data)
    ImGui_ImplVulkanH_Frame*            Frames;
    ImGui_ImplVulkanH_FrameSemaphores*  FrameSemaphores;
}


// imgui_impl_vulkan.cpp



// dear imgui: Renderer Backend for Vulkan
// This needs to be used along with a Platform Backend (e.g. GLFW, SDL, Win32, custom..)

// Implemented features:
//  [X] Renderer: Support for large meshes (64k+ vertices) with 16-bit indices.
// Missing features:
//  [ ] Renderer: User texture binding. Changes of ImTextureID aren't supported by this backend! See https://github.com/ocornut/imgui/pull/914

// You can use unmodified imgui_impl_* files in your project. See examples/ folder for examples of using this.
// Prefer including the entire imgui/ repository into your project (either as a copy or as a submodule), and only build the backends you need.
// If you are new to Dear ImGui, read documentation from the docs/ folder + read the top of imgui.cpp.
// Read online: https://github.com/ocornut/imgui/tree/master/docs

// The aim of imgui_impl_vulkan.h/.cpp is to be usable in your engine without any modification.
// IF YOU FEEL YOU NEED TO MAKE ANY CHANGE TO THIS CODE, please share them and your feedback at https://github.com/ocornut/imgui/

// Important note to the reader who wish to integrate imgui_impl_vulkan.cpp/.h in their own engine/app.
// - Common ImGui_ImplVulkan_XXX functions and structures are used to interface with imgui_impl_vulkan.cpp/.h.
//   You will use those if you want to use this rendering backend in your engine/app.
// - Helper ImGui_ImplVulkanH_XXX functions and structures are only used by this example (main.cpp) and by
//   the backend itself (imgui_impl_vulkan.cpp), but should PROBABLY NOT be used by your own engine/app code.
// Read comments in imgui_impl_vulkan.h.

// CHANGELOG
// (minor and older changes stripped away, please see git history for details)
//  2021-06-29: Reorganized backend to pull data from a single structure to facilitate usage with multiple-contexts (all g_XXXX access changed to bd.XXXX).
//  2021-03-22: Vulkan: Fix mapped memory validation error when buffer sizes are not multiple of VkPhysicalDeviceLimits::nonCoherentAtomSize.
//  2021-02-18: Vulkan: Change blending equation to preserve alpha in output buffer.
//  2021-01-27: Vulkan: Added support for custom function load and IMGUI_IMPL_VULKAN_NO_PROTOTYPES by using ImGui_ImplVulkan_LoadFunctions().
//  2020-11-11: Vulkan: Added support for specifying which subpass to reference during VkPipeline creation.
//  2020-09-07: Vulkan: Added VkPipeline parameter to ImGui_ImplVulkan_RenderDrawData (default to one passed to ImGui_ImplVulkan_Init).
//  2020-05-04: Vulkan: Fixed crash if initial frame has no vertices.
//  2020-04-26: Vulkan: Fixed edge case where render callbacks wouldn't be called if the ImDrawData didn't have vertices.
//  2019-08-01: Vulkan: Added support for specifying multisample count. Set ImGui_ImplVulkan_InitInfo::MSAASamples to one of the VkSampleCountFlagBits values to use, default is non-multisampled as before.
//  2019-05-29: Vulkan: Added support for large mesh (64K+ vertices), enable ImGuiBackendFlags_RendererHasVtxOffset flag.
//  2019-04-30: Vulkan: Added support for special ImDrawCallback_ResetRenderState callback to reset render state.
//  2019-04-04: *BREAKING CHANGE*: Vulkan: Added ImageCount/MinImageCount fields in ImGui_ImplVulkan_InitInfo, required for initialization (was previously a hard #define IMGUI_VK_QUEUED_FRAMES 2). Added ImGui_ImplVulkan_SetMinImageCount().
//  2019-04-04: Vulkan: Added VkInstance argument to ImGui_ImplVulkanH_CreateWindow() optional helper.
//  2019-04-04: Vulkan: Avoid passing negative coordinates to vkCmdSetScissor, which debug validation layers do not like.
//  2019-04-01: Vulkan: Support for 32-bit index buffer (#define ImDrawIdx unsigned int).
//  2019-02-16: Vulkan: Viewport and clipping rectangles correctly using draw_data.FramebufferScale to allow retina display.
//  2018-11-30: Misc: Setting up io.BackendRendererName so it can be displayed in the About Window.
//  2018-08-25: Vulkan: Fixed mishandled VkSurfaceCapabilitiesKHR::maxImageCount=0 case.
//  2018-06-22: Inverted the parameters to ImGui_ImplVulkan_RenderDrawData() to be consistent with other backends.
//  2018-06-08: Misc: Extracted imgui_impl_vulkan.cpp/.h away from the old combined GLFW+Vulkan example.
//  2018-06-08: Vulkan: Use draw_data.DisplayPos and draw_data.DisplaySize to setup projection matrix and clipping rectangle.
//  2018-03-03: Vulkan: Various refactor, created a couple of ImGui_ImplVulkanH_XXX helper that the example can use and that viewport support will use.
//  2018-03-01: Vulkan: Renamed ImGui_ImplVulkan_Init_Info to ImGui_ImplVulkan_InitInfo and fields to match more closely Vulkan terminology.
//  2018-02-16: Misc: Obsoleted the io.RenderDrawListsFn callback, ImGui_ImplVulkan_Render() calls ImGui_ImplVulkan_RenderDrawData() itself.
//  2018-02-06: Misc: Removed call to ImGui::Shutdown() which is not available from 1.60 WIP, user needs to call CreateContext/DestroyContext themselves.
//  2017-05-15: Vulkan: Fix scissor offset being negative. Fix new Vulkan validation warnings. Set required depth member for buffer image copy.
//  2016-11-13: Vulkan: Fix validation layer warnings and errors and redeclare gl_PerVertex.
//  2016-10-18: Vulkan: Add location decorators & change to use structs as in/out in glsl, update embedded spv (produced with glslangValidator -x). Null the released resources.
//  2016-08-27: Vulkan: Fix Vulkan example for use when a depth buffer is active.

// #include "imgui_impl_vulkan.h"
// #include <stdio.h>


// Reusable buffers used for rendering 1 current in-flight frame, for ImGui_ImplVulkan_RenderDrawData()
// [Please zero-clear before use!]
struct ImGui_ImplVulkanH_FrameRenderBuffers
{
    VkDeviceMemory      VertexBufferMemory;
    VkDeviceMemory      IndexBufferMemory;
    VkDeviceSize        VertexBufferSize;
    VkDeviceSize        IndexBufferSize;
    VkBuffer            VertexBuffer;
    VkBuffer            IndexBuffer;
}

// Each viewport will hold 1 ImGui_ImplVulkanH_WindowRenderBuffers
// [Please zero-clear before use!]
struct ImGui_ImplVulkanH_WindowRenderBuffers
{
    uint32_t            Index;
    uint32_t            Count;
    ImGui_ImplVulkanH_FrameRenderBuffers*   FrameRenderBuffers;
}

// Vulkan data
struct ImGui_ImplVulkan_Data
{
    ImGui_ImplVulkan_InitInfo   VulkanInitInfo;
    VkRenderPass                RenderPass;
    VkDeviceSize                BufferMemoryAlignment = 256;
    VkPipelineCreateFlags       PipelineCreateFlags;
    VkDescriptorSetLayout       DescriptorSetLayout;
    VkPipelineLayout            PipelineLayout;
    VkDescriptorSet             DescriptorSet;
    VkPipeline                  Pipeline;
    uint32_t                    Subpass;
    VkShaderModule              ShaderModuleVert;
    VkShaderModule              ShaderModuleFrag;

    // Font data
    VkSampler                   FontSampler;
    VkDeviceMemory              FontMemory;
    VkImage                     FontImage;
    VkImageView                 FontView;
    VkDeviceMemory              UploadBufferMemory;
    VkBuffer                    UploadBuffer;

    // Render buffers
    ImGui_ImplVulkanH_WindowRenderBuffers MainWindowRenderBuffers;
}

// Forward Declarations
// bool ImGui_ImplVulkan_CreateDeviceObjects();
// void ImGui_ImplVulkan_DestroyDeviceObjects();
// void ImGui_ImplVulkanH_DestroyFrame(VkDevice device, ImGui_ImplVulkanH_Frame* fd, const VkAllocationCallbacks* allocator);
// void ImGui_ImplVulkanH_DestroyFrameSemaphores(VkDevice device, ImGui_ImplVulkanH_FrameSemaphores* fsd, const VkAllocationCallbacks* allocator);
// void ImGui_ImplVulkanH_DestroyFrameRenderBuffers(VkDevice device, ImGui_ImplVulkanH_FrameRenderBuffers* buffers, const VkAllocationCallbacks* allocator);
// void ImGui_ImplVulkanH_DestroyWindowRenderBuffers(VkDevice device, ImGui_ImplVulkanH_WindowRenderBuffers* buffers, const VkAllocationCallbacks* allocator);
// void ImGui_ImplVulkanH_CreateWindowSwapChain(VkPhysicalDevice physical_device, VkDevice device, ImGui_ImplVulkanH_Window* wd, const VkAllocationCallbacks* allocator, int w, int h, uint32_t min_image_count);
// void ImGui_ImplVulkanH_CreateWindowCommandBuffers(VkPhysicalDevice physical_device, VkDevice device, ImGui_ImplVulkanH_Window* wd, uint32_t queue_family, const VkAllocationCallbacks* allocator);

// Vulkan prototypes for use with custom loaders
// (see description of IMGUI_IMPL_VULKAN_NO_PROTOTYPES in imgui_impl_vulkan.h
// #ifdef VK_NO_PROTOTYPES
// static bool g_FunctionsLoaded = false;
// #else
// static bool g_FunctionsLoaded = true;
// #endif
// #ifdef VK_NO_PROTOTYPES
// #define IMGUI_VULKAN_FUNC_MAP(IMGUI_VULKAN_FUNC_MAP_MACRO) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkAllocateCommandBuffers) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkAllocateDescriptorSets) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkAllocateMemory) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkBindBufferMemory) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkBindImageMemory) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCmdBindDescriptorSets) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCmdBindIndexBuffer) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCmdBindPipeline) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCmdBindVertexBuffers) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCmdCopyBufferToImage) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCmdDrawIndexed) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCmdPipelineBarrier) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCmdPushConstants) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCmdSetScissor) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCmdSetViewport) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCreateBuffer) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCreateCommandPool) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCreateDescriptorSetLayout) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCreateFence) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCreateFramebuffer) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCreateGraphicsPipelines) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCreateImage) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCreateImageView) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCreatePipelineLayout) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCreateRenderPass) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCreateSampler) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCreateSemaphore) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCreateShaderModule) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkCreateSwapchainKHR) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkDestroyBuffer) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkDestroyCommandPool) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkDestroyDescriptorSetLayout) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkDestroyFence) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkDestroyFramebuffer) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkDestroyImage) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkDestroyImageView) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkDestroyPipeline) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkDestroyPipelineLayout) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkDestroyRenderPass) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkDestroySampler) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkDestroySemaphore) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkDestroyShaderModule) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkDestroySurfaceKHR) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkDestroySwapchainKHR) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkDeviceWaitIdle) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkFlushMappedMemoryRanges) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkFreeCommandBuffers) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkFreeMemory) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkGetBufferMemoryRequirements) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkGetImageMemoryRequirements) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkGetPhysicalDeviceMemoryProperties) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkGetPhysicalDeviceSurfaceCapabilitiesKHR) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkGetPhysicalDeviceSurfaceFormatsKHR) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkGetPhysicalDeviceSurfacePresentModesKHR) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkGetSwapchainImagesKHR) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkMapMemory) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkUnmapMemory) \
//     IMGUI_VULKAN_FUNC_MAP_MACRO(vkUpdateDescriptorSets)

// // Define function pointers
// #define IMGUI_VULKAN_FUNC_DEF(func) static PFN_##func func;
// IMGUI_VULKAN_FUNC_MAP(IMGUI_VULKAN_FUNC_DEF)
// #undef IMGUI_VULKAN_FUNC_DEF
// #endif // VK_NO_PROTOTYPES

//-----------------------------------------------------------------------------
// SHADERS
//-----------------------------------------------------------------------------

// glsl_shader.vert, compiled with:
// # glslangValidator -V -x -o glsl_shader.vert.u32 glsl_shader.vert
/*
#version 450 core
layout(location = 0) in vec2 aPos;
layout(location = 1) in vec2 aUV;
layout(location = 2) in vec4 aColor;
layout(push_constant) uniform uPushConstant { vec2 uScale; vec2 uTranslate; } pc;

out gl_PerVertex { vec4 gl_Position; };
layout(location = 0) out struct { vec4 Color; vec2 UV; } Out;

void main()
{
    Out.Color = aColor;
    Out.UV = aUV;
    gl_Position = vec4(aPos * pc.uScale + pc.uTranslate, 0, 1);
}
*/
__gshared uint32_t[] __glsl_shader_vert_spv =
[
    0x07230203,0x00010000,0x00080001,0x0000002e,0x00000000,0x00020011,0x00000001,0x0006000b,
    0x00000001,0x4c534c47,0x6474732e,0x3035342e,0x00000000,0x0003000e,0x00000000,0x00000001,
    0x000a000f,0x00000000,0x00000004,0x6e69616d,0x00000000,0x0000000b,0x0000000f,0x00000015,
    0x0000001b,0x0000001c,0x00030003,0x00000002,0x000001c2,0x00040005,0x00000004,0x6e69616d,
    0x00000000,0x00030005,0x00000009,0x00000000,0x00050006,0x00000009,0x00000000,0x6f6c6f43,
    0x00000072,0x00040006,0x00000009,0x00000001,0x00005655,0x00030005,0x0000000b,0x0074754f,
    0x00040005,0x0000000f,0x6c6f4361,0x0000726f,0x00030005,0x00000015,0x00565561,0x00060005,
    0x00000019,0x505f6c67,0x65567265,0x78657472,0x00000000,0x00060006,0x00000019,0x00000000,
    0x505f6c67,0x7469736f,0x006e6f69,0x00030005,0x0000001b,0x00000000,0x00040005,0x0000001c,
    0x736f5061,0x00000000,0x00060005,0x0000001e,0x73755075,0x6e6f4368,0x6e617473,0x00000074,
    0x00050006,0x0000001e,0x00000000,0x61635375,0x0000656c,0x00060006,0x0000001e,0x00000001,
    0x61725475,0x616c736e,0x00006574,0x00030005,0x00000020,0x00006370,0x00040047,0x0000000b,
    0x0000001e,0x00000000,0x00040047,0x0000000f,0x0000001e,0x00000002,0x00040047,0x00000015,
    0x0000001e,0x00000001,0x00050048,0x00000019,0x00000000,0x0000000b,0x00000000,0x00030047,
    0x00000019,0x00000002,0x00040047,0x0000001c,0x0000001e,0x00000000,0x00050048,0x0000001e,
    0x00000000,0x00000023,0x00000000,0x00050048,0x0000001e,0x00000001,0x00000023,0x00000008,
    0x00030047,0x0000001e,0x00000002,0x00020013,0x00000002,0x00030021,0x00000003,0x00000002,
    0x00030016,0x00000006,0x00000020,0x00040017,0x00000007,0x00000006,0x00000004,0x00040017,
    0x00000008,0x00000006,0x00000002,0x0004001e,0x00000009,0x00000007,0x00000008,0x00040020,
    0x0000000a,0x00000003,0x00000009,0x0004003b,0x0000000a,0x0000000b,0x00000003,0x00040015,
    0x0000000c,0x00000020,0x00000001,0x0004002b,0x0000000c,0x0000000d,0x00000000,0x00040020,
    0x0000000e,0x00000001,0x00000007,0x0004003b,0x0000000e,0x0000000f,0x00000001,0x00040020,
    0x00000011,0x00000003,0x00000007,0x0004002b,0x0000000c,0x00000013,0x00000001,0x00040020,
    0x00000014,0x00000001,0x00000008,0x0004003b,0x00000014,0x00000015,0x00000001,0x00040020,
    0x00000017,0x00000003,0x00000008,0x0003001e,0x00000019,0x00000007,0x00040020,0x0000001a,
    0x00000003,0x00000019,0x0004003b,0x0000001a,0x0000001b,0x00000003,0x0004003b,0x00000014,
    0x0000001c,0x00000001,0x0004001e,0x0000001e,0x00000008,0x00000008,0x00040020,0x0000001f,
    0x00000009,0x0000001e,0x0004003b,0x0000001f,0x00000020,0x00000009,0x00040020,0x00000021,
    0x00000009,0x00000008,0x0004002b,0x00000006,0x00000028,0x00000000,0x0004002b,0x00000006,
    0x00000029,0x3f800000,0x00050036,0x00000002,0x00000004,0x00000000,0x00000003,0x000200f8,
    0x00000005,0x0004003d,0x00000007,0x00000010,0x0000000f,0x00050041,0x00000011,0x00000012,
    0x0000000b,0x0000000d,0x0003003e,0x00000012,0x00000010,0x0004003d,0x00000008,0x00000016,
    0x00000015,0x00050041,0x00000017,0x00000018,0x0000000b,0x00000013,0x0003003e,0x00000018,
    0x00000016,0x0004003d,0x00000008,0x0000001d,0x0000001c,0x00050041,0x00000021,0x00000022,
    0x00000020,0x0000000d,0x0004003d,0x00000008,0x00000023,0x00000022,0x00050085,0x00000008,
    0x00000024,0x0000001d,0x00000023,0x00050041,0x00000021,0x00000025,0x00000020,0x00000013,
    0x0004003d,0x00000008,0x00000026,0x00000025,0x00050081,0x00000008,0x00000027,0x00000024,
    0x00000026,0x00050051,0x00000006,0x0000002a,0x00000027,0x00000000,0x00050051,0x00000006,
    0x0000002b,0x00000027,0x00000001,0x00070050,0x00000007,0x0000002c,0x0000002a,0x0000002b,
    0x00000028,0x00000029,0x00050041,0x00000011,0x0000002d,0x0000001b,0x0000000d,0x0003003e,
    0x0000002d,0x0000002c,0x000100fd,0x00010038
];

// glsl_shader.frag, compiled with:
// # glslangValidator -V -x -o glsl_shader.frag.u32 glsl_shader.frag
/*
#version 450 core
layout(location = 0) out vec4 fColor;
layout(set=0, binding=0) uniform sampler2D sTexture;
layout(location = 0) in struct { vec4 Color; vec2 UV; } In;
void main()
{
    fColor = In.Color * texture(sTexture, In.UV.st);
}
*/
__gshared uint32_t[] __glsl_shader_frag_spv =
[
    0x07230203,0x00010000,0x00080001,0x0000001e,0x00000000,0x00020011,0x00000001,0x0006000b,
    0x00000001,0x4c534c47,0x6474732e,0x3035342e,0x00000000,0x0003000e,0x00000000,0x00000001,
    0x0007000f,0x00000004,0x00000004,0x6e69616d,0x00000000,0x00000009,0x0000000d,0x00030010,
    0x00000004,0x00000007,0x00030003,0x00000002,0x000001c2,0x00040005,0x00000004,0x6e69616d,
    0x00000000,0x00040005,0x00000009,0x6c6f4366,0x0000726f,0x00030005,0x0000000b,0x00000000,
    0x00050006,0x0000000b,0x00000000,0x6f6c6f43,0x00000072,0x00040006,0x0000000b,0x00000001,
    0x00005655,0x00030005,0x0000000d,0x00006e49,0x00050005,0x00000016,0x78655473,0x65727574,
    0x00000000,0x00040047,0x00000009,0x0000001e,0x00000000,0x00040047,0x0000000d,0x0000001e,
    0x00000000,0x00040047,0x00000016,0x00000022,0x00000000,0x00040047,0x00000016,0x00000021,
    0x00000000,0x00020013,0x00000002,0x00030021,0x00000003,0x00000002,0x00030016,0x00000006,
    0x00000020,0x00040017,0x00000007,0x00000006,0x00000004,0x00040020,0x00000008,0x00000003,
    0x00000007,0x0004003b,0x00000008,0x00000009,0x00000003,0x00040017,0x0000000a,0x00000006,
    0x00000002,0x0004001e,0x0000000b,0x00000007,0x0000000a,0x00040020,0x0000000c,0x00000001,
    0x0000000b,0x0004003b,0x0000000c,0x0000000d,0x00000001,0x00040015,0x0000000e,0x00000020,
    0x00000001,0x0004002b,0x0000000e,0x0000000f,0x00000000,0x00040020,0x00000010,0x00000001,
    0x00000007,0x00090019,0x00000013,0x00000006,0x00000001,0x00000000,0x00000000,0x00000000,
    0x00000001,0x00000000,0x0003001b,0x00000014,0x00000013,0x00040020,0x00000015,0x00000000,
    0x00000014,0x0004003b,0x00000015,0x00000016,0x00000000,0x0004002b,0x0000000e,0x00000018,
    0x00000001,0x00040020,0x00000019,0x00000001,0x0000000a,0x00050036,0x00000002,0x00000004,
    0x00000000,0x00000003,0x000200f8,0x00000005,0x00050041,0x00000010,0x00000011,0x0000000d,
    0x0000000f,0x0004003d,0x00000007,0x00000012,0x00000011,0x0004003d,0x00000014,0x00000017,
    0x00000016,0x00050041,0x00000019,0x0000001a,0x0000000d,0x00000018,0x0004003d,0x0000000a,
    0x0000001b,0x0000001a,0x00050057,0x00000007,0x0000001c,0x00000017,0x0000001b,0x00050085,
    0x00000007,0x0000001d,0x00000012,0x0000001c,0x0003003e,0x00000009,0x0000001d,0x000100fd,
    0x00010038
];

//-----------------------------------------------------------------------------
// FUNCTIONS
//-----------------------------------------------------------------------------

// Backend data stored in io.BackendRendererUserData to allow support for multiple Dear ImGui contexts
// It is STRONGLY preferred that you use docking branch with multi-viewports (== single Dear ImGui context + multiple windows) instead of multiple Dear ImGui contexts.
// FIXME: multi-context support is not tested and probably dysfunctional in this backend.
ImGui_ImplVulkan_Data* ImGui_ImplVulkan_GetBackendData()
{
    return igGetCurrentContext() ? cast(ImGui_ImplVulkan_Data*)igGetIO().BackendRendererUserData : null;
}

uint32_t ImGui_ImplVulkan_MemoryType(VkMemoryPropertyFlags properties, uint32_t type_bits)
{
    ImGui_ImplVulkan_Data* bd = ImGui_ImplVulkan_GetBackendData();
    ImGui_ImplVulkan_InitInfo* v = &bd.VulkanInitInfo;
    VkPhysicalDeviceMemoryProperties prop;
    vkGetPhysicalDeviceMemoryProperties(v.PhysicalDevice, &prop);
    for (uint32_t i = 0; i < prop.memoryTypeCount; i++)
        if ((prop.memoryTypes[i].propertyFlags & properties) == properties && type_bits & (1 << i))
            return i;
    return 0xFFFFFFFF; // Unable to find memoryType
}

void check_vk_result(VkResult err)
{
    ImGui_ImplVulkan_Data* bd = ImGui_ImplVulkan_GetBackendData();
    if (!bd)
        return;
    ImGui_ImplVulkan_InitInfo* v = &bd.VulkanInitInfo;
    if (v.CheckVkResultFn)
        v.CheckVkResultFn(err);
    check(err);
}

void CreateOrResizeBuffer(VkBuffer* buffer, VkDeviceMemory* buffer_memory, VkDeviceSize* p_buffer_size, size_t new_size, VkBufferUsageFlagBits usage)
{
    ImGui_ImplVulkan_Data* bd = ImGui_ImplVulkan_GetBackendData();
    ImGui_ImplVulkan_InitInfo* v = &bd.VulkanInitInfo;
    VkResult err;

    if (*buffer != VK_NULL_HANDLE) {
        vkDestroyBuffer(v.Device, *buffer, v.Allocator);
    }
    if (buffer_memory != VK_NULL_HANDLE)
        vkFreeMemory(v.Device, *buffer_memory, v.Allocator);

    VkDeviceSize vertex_buffer_size_aligned = ((new_size - 1) / bd.BufferMemoryAlignment + 1) * bd.BufferMemoryAlignment;
    VkBufferCreateInfo buffer_info = {};
    buffer_info.sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
    buffer_info.size = vertex_buffer_size_aligned;
    buffer_info.usage = usage;
    buffer_info.sharingMode = VkSharingMode.VK_SHARING_MODE_EXCLUSIVE;

    err = vkCreateBuffer(v.Device, &buffer_info, v.Allocator, buffer);
    check_vk_result(err);

    VkMemoryRequirements req;
    vkGetBufferMemoryRequirements(v.Device, *buffer, &req);
    bd.BufferMemoryAlignment = (bd.BufferMemoryAlignment > req.alignment) ? bd.BufferMemoryAlignment : req.alignment;
    VkMemoryAllocateInfo alloc_info = {};
    alloc_info.sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
    alloc_info.allocationSize = req.size;
    alloc_info.memoryTypeIndex = ImGui_ImplVulkan_MemoryType(VMemoryProperty.HOST_VISIBLE, req.memoryTypeBits);
    err = vkAllocateMemory(v.Device, &alloc_info, v.Allocator, buffer_memory);
    check_vk_result(err);

    err = vkBindBufferMemory(v.Device, *buffer, *buffer_memory, 0);
    check_vk_result(err);
    *p_buffer_size = req.size;
}

void ImGui_ImplVulkan_SetupRenderState(ImDrawData* draw_data, VkPipeline pipeline, VkCommandBuffer command_buffer, ImGui_ImplVulkanH_FrameRenderBuffers* rb, int fb_width, int fb_height)
{
    ImGui_ImplVulkan_Data* bd = ImGui_ImplVulkan_GetBackendData();

    // Bind pipeline and descriptor sets:
    {
        vkCmdBindPipeline(command_buffer, VPipelineBindPoint.GRAPHICS, pipeline);
        VkDescriptorSet[1] desc_set = [ bd.DescriptorSet ];
        vkCmdBindDescriptorSets(command_buffer, VPipelineBindPoint.GRAPHICS, bd.PipelineLayout, 0, 1,
            desc_set.ptr, 0, null);
    }

    // Bind Vertex And Index Buffer:
    if (draw_data.TotalVtxCount > 0)
    {
        VkBuffer[1] vertex_buffers = [ rb.VertexBuffer ];
        VkDeviceSize[1] vertex_offset = [0];
        vkCmdBindVertexBuffers(command_buffer, 0, 1, vertex_buffers.ptr, vertex_offset.ptr);
        vkCmdBindIndexBuffer(command_buffer, rb.IndexBuffer, 0,
            ImDrawIdx.sizeof == 2 ? VkIndexType.VK_INDEX_TYPE_UINT16 : VkIndexType.VK_INDEX_TYPE_UINT32);
    }

    // Setup viewport:
    {
        VkViewport viewport;
        viewport.x = 0;
        viewport.y = 0;
        viewport.width = cast(float)fb_width;
        viewport.height = cast(float)fb_height;
        viewport.minDepth = 0.0f;
        viewport.maxDepth = 1.0f;
        vkCmdSetViewport(command_buffer, 0, 1, &viewport);
    }

    // Setup scale and translation:
    // Our visible imgui space lies from draw_data.DisplayPps (top left) to draw_data.DisplayPos+data_data.DisplaySize (bottom right). DisplayPos is (0,0) for single viewport apps.
    {
        float[2] scale;
        scale[0] = 2.0f / draw_data.DisplaySize.x;
        scale[1] = 2.0f / draw_data.DisplaySize.y;
        float[2] translate;
        translate[0] = -1.0f - draw_data.DisplayPos.x * scale[0];
        translate[1] = -1.0f - draw_data.DisplayPos.y * scale[1];
        vkCmdPushConstants(command_buffer, bd.PipelineLayout, VShaderStage.VERTEX,
            float.sizeof * 0, float.sizeof * 2, scale.ptr);
        vkCmdPushConstants(command_buffer, bd.PipelineLayout, VShaderStage.VERTEX,
            float.sizeof * 2, float.sizeof * 2, translate.ptr);
    }
}

// Render function
void ImGui_ImplVulkan_RenderDrawData(ImDrawData* draw_data, VkCommandBuffer command_buffer, VkPipeline pipeline)
{
    // Avoid rendering when minimized, scale coordinates for retina displays (screen coordinates != framebuffer coordinates)
    int fb_width = cast(int)(draw_data.DisplaySize.x * draw_data.FramebufferScale.x);
    int fb_height = cast(int)(draw_data.DisplaySize.y * draw_data.FramebufferScale.y);
    if (fb_width <= 0 || fb_height <= 0)
        return;

    ImGui_ImplVulkan_Data* bd = ImGui_ImplVulkan_GetBackendData();
    ImGui_ImplVulkan_InitInfo* v = &bd.VulkanInitInfo;
    if (pipeline == VK_NULL_HANDLE)
        pipeline = bd.Pipeline;

    // Allocate array to store enough vertex/index buffers
    ImGui_ImplVulkanH_WindowRenderBuffers* wrb = &bd.MainWindowRenderBuffers;
    if (wrb.FrameRenderBuffers is null)
    {
        wrb.Index = 0;
        wrb.Count = v.ImageCount;
        // wrb.FrameRenderBuffers = cast(ImGui_ImplVulkanH_FrameRenderBuffers*)IM_ALLOC(sizeof(ImGui_ImplVulkanH_FrameRenderBuffers) * wrb.Count);
        // memset(wrb.FrameRenderBuffers, 0, sizeof(ImGui_ImplVulkanH_FrameRenderBuffers) * wrb.Count);

        wrb.FrameRenderBuffers = cast(ImGui_ImplVulkanH_FrameRenderBuffers*)calloc(ImGui_ImplVulkanH_FrameRenderBuffers.sizeof, wrb.Count);
    }

    vkassert(wrb.Count == v.ImageCount);
    wrb.Index = (wrb.Index + 1) % wrb.Count;
    ImGui_ImplVulkanH_FrameRenderBuffers* rb = &wrb.FrameRenderBuffers[wrb.Index];

    if (draw_data.TotalVtxCount > 0)
    {
        // Create or resize the vertex/index buffers
        size_t vertex_size = draw_data.TotalVtxCount * (ImDrawVert.sizeof);
        size_t index_size = draw_data.TotalIdxCount * (ImDrawIdx.sizeof);

        if (rb.VertexBuffer == VK_NULL_HANDLE || rb.VertexBufferSize < vertex_size) {
            CreateOrResizeBuffer(&rb.VertexBuffer, &rb.VertexBufferMemory, &rb.VertexBufferSize, vertex_size, VkBufferUsageFlagBits.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT);
        }

        if (rb.IndexBuffer == VK_NULL_HANDLE || rb.IndexBufferSize < index_size) {
            CreateOrResizeBuffer(&rb.IndexBuffer, &rb.IndexBufferMemory, &rb.IndexBufferSize, index_size, VkBufferUsageFlagBits.VK_BUFFER_USAGE_INDEX_BUFFER_BIT);
        }
        // Upload vertex/index data into a single contiguous GPU buffer
        ImDrawVert* vtx_dst = null;
        ImDrawIdx* idx_dst = null;
        VkResult err = vkMapMemory(v.Device, rb.VertexBufferMemory, 0, rb.VertexBufferSize, 0, cast(void**)(&vtx_dst));
        check_vk_result(err);

        err = vkMapMemory(v.Device, rb.IndexBufferMemory, 0, rb.IndexBufferSize, 0, cast(void**)(&idx_dst));
        check_vk_result(err);

        for (int n = 0; n < draw_data.CmdListsCount; n++)
        {
            ImDrawList* cmd_list = draw_data.CmdLists[n];


            auto src1 = cmd_list.VtxBuffer.Data;
            auto src2 = cmd_list.IdxBuffer.Data;

            memcpy(vtx_dst, src1, cmd_list.VtxBuffer.Size * (ImDrawVert.sizeof));
            memcpy(idx_dst, src2, cmd_list.IdxBuffer.Size * (ImDrawIdx.sizeof));
            vtx_dst += cmd_list.VtxBuffer.Size;
            idx_dst += cmd_list.IdxBuffer.Size;
        }

        VkMappedMemoryRange[2] range;
        range[0].sType = VkStructureType.VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE;
        range[0].memory = rb.VertexBufferMemory;
        range[0].size = VK_WHOLE_SIZE;
        range[1].sType = VkStructureType.VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE;
        range[1].memory = rb.IndexBufferMemory;
        range[1].size = VK_WHOLE_SIZE;
        err = vkFlushMappedMemoryRanges(v.Device, 2, range.ptr);
        check_vk_result(err);
        vkUnmapMemory(v.Device, rb.VertexBufferMemory);
        vkUnmapMemory(v.Device, rb.IndexBufferMemory);
    }


    // Setup desired Vulkan state
    ImGui_ImplVulkan_SetupRenderState(draw_data, pipeline, command_buffer, rb, fb_width, fb_height);

    // Will project scissor/clipping rectangles into framebuffer space
    ImVec2 clip_off = draw_data.DisplayPos;         // (0,0) unless using multi-viewports
    ImVec2 clip_scale = draw_data.FramebufferScale; // (1,1) unless using retina display which are often (2,2)

    // Render command lists
    // (Because we merged all buffers into a single one, we maintain our own offset into them)
    int global_vtx_offset = 0;
    int global_idx_offset = 0;
    for (int n = 0; n < draw_data.CmdListsCount; n++)
    {
        ImDrawList* cmd_list = draw_data.CmdLists[n];
        for (int cmd_i = 0; cmd_i < cmd_list.CmdBuffer.Size; cmd_i++)
        {
            ImDrawCmd* pcmd = cast(ImDrawCmd*)&cmd_list.CmdBuffer.Data[cmd_i];
            if (pcmd.UserCallback !is null)
            {
                // User callback, registered via ImDrawList::AddCallback()
                // (ImDrawCallback_ResetRenderState is a special callback value used by the user to request the renderer to reset render state.)
                if (pcmd.UserCallback == ImDrawCallback_ResetRenderState)
                    ImGui_ImplVulkan_SetupRenderState(draw_data, pipeline, command_buffer, rb, fb_width, fb_height);
                else
                    pcmd.UserCallback(cmd_list, pcmd);
            }
            else
            {
                // Project scissor/clipping rectangles into framebuffer space
                ImVec4 clip_rect;
                clip_rect.x = (pcmd.ClipRect.x - clip_off.x) * clip_scale.x;
                clip_rect.y = (pcmd.ClipRect.y - clip_off.y) * clip_scale.y;
                clip_rect.z = (pcmd.ClipRect.z - clip_off.x) * clip_scale.x;
                clip_rect.w = (pcmd.ClipRect.w - clip_off.y) * clip_scale.y;

                if (clip_rect.x < fb_width && clip_rect.y < fb_height && clip_rect.z >= 0.0f && clip_rect.w >= 0.0f)
                {
                    // Negative offsets are illegal for vkCmdSetScissor
                    if (clip_rect.x < 0.0f)
                        clip_rect.x = 0.0f;
                    if (clip_rect.y < 0.0f)
                        clip_rect.y = 0.0f;

                    // Apply scissor/clipping rectangle
                    VkRect2D scissor;
                    scissor.offset.x = cast(int32_t)(clip_rect.x);
                    scissor.offset.y = cast(int32_t)(clip_rect.y);
                    scissor.extent.width = cast(uint32_t)(clip_rect.z - clip_rect.x);
                    scissor.extent.height = cast(uint32_t)(clip_rect.w - clip_rect.y);
                    vkCmdSetScissor(command_buffer, 0, 1, &scissor);

                    // Draw
                    vkCmdDrawIndexed(command_buffer, pcmd.ElemCount, 1, pcmd.IdxOffset + global_idx_offset, pcmd.VtxOffset + global_vtx_offset, 0);
                }
            }
        }
        global_idx_offset += cmd_list.IdxBuffer.Size;
        global_vtx_offset += cmd_list.VtxBuffer.Size;
    }
}

bool ImGui_ImplVulkan_CreateFontsTexture(VkCommandBuffer command_buffer)
{
    ImGuiIO* io = igGetIO();
    ImGui_ImplVulkan_Data* bd = ImGui_ImplVulkan_GetBackendData();
    ImGui_ImplVulkan_InitInfo* v = &bd.VulkanInitInfo;

    char* pixels;
    int width, height;

    // io.Fonts.GetTexDataAsRGBA32(&pixels, &width, &height);
    ImFontAtlas_GetTexDataAsRGBA32(io.Fonts, cast(ubyte**)&pixels, &width, &height, null);

    size_t upload_size = width * height * 4 * byte.sizeof;

    VkResult err;

    // Create the Image:
    {
        VkImageCreateInfo info = {};
        info.sType = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO;
        info.imageType = VkImageType.VK_IMAGE_TYPE_2D;
        info.format = VkFormat.VK_FORMAT_R8G8B8A8_UNORM;
        info.extent.width = width;
        info.extent.height = height;
        info.extent.depth = 1;
        info.mipLevels = 1;
        info.arrayLayers = 1;
        info.samples = VSampleCount._1;
        info.tiling = VImageTiling.OPTIMAL;
        info.usage = VImageUsage.SAMPLED | VImageUsage.TRANSFER_DST;
        info.sharingMode = VSharingMode.EXCLUSIVE;
        info.initialLayout = VImageLayout.UNDEFINED;
        err = vkCreateImage(v.Device, &info, v.Allocator, &bd.FontImage);
        check_vk_result(err);
        VkMemoryRequirements req;
        vkGetImageMemoryRequirements(v.Device, bd.FontImage, &req);
        VkMemoryAllocateInfo alloc_info = {};
        alloc_info.sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
        alloc_info.allocationSize = req.size;
        alloc_info.memoryTypeIndex = ImGui_ImplVulkan_MemoryType(VMemoryProperty.DEVICE_LOCAL, req.memoryTypeBits);
        err = vkAllocateMemory(v.Device, &alloc_info, v.Allocator, &bd.FontMemory);
        check_vk_result(err);
        err = vkBindImageMemory(v.Device, bd.FontImage, bd.FontMemory, 0);
        check_vk_result(err);
    }

    // Create the Image View:
    {
        VkImageViewCreateInfo info = {};
        info.sType = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
        info.image = bd.FontImage;
        info.viewType = VImageViewType._2D;
        info.format = VkFormat.VK_FORMAT_R8G8B8A8_UNORM;
        info.subresourceRange.aspectMask = VImageAspect.COLOR;
        info.subresourceRange.levelCount = 1;
        info.subresourceRange.layerCount = 1;
        err = vkCreateImageView(v.Device, &info, v.Allocator, &bd.FontView);
        check_vk_result(err);
    }

    // Update the Descriptor Set:
    {
        VkDescriptorImageInfo[1] desc_image;
        desc_image[0].sampler = bd.FontSampler;
        desc_image[0].imageView = bd.FontView;
        desc_image[0].imageLayout = VImageLayout.SHADER_READ_ONLY_OPTIMAL;
        VkWriteDescriptorSet[1] write_desc;
        write_desc[0].sType = VkStructureType.VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
        write_desc[0].dstSet = bd.DescriptorSet;
        write_desc[0].descriptorCount = 1;
        write_desc[0].descriptorType = VDescriptorType.COMBINED_IMAGE_SAMPLER;
        write_desc[0].pImageInfo = desc_image.ptr;
        vkUpdateDescriptorSets(v.Device, 1, write_desc.ptr, 0, null);
    }

    // Create the Upload Buffer:
    {
        VkBufferCreateInfo buffer_info = {};
        buffer_info.sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
        buffer_info.size = upload_size;
        buffer_info.usage = VBufferUsage.TRANSFER_SRC;
        buffer_info.sharingMode = VSharingMode.EXCLUSIVE;
        err = vkCreateBuffer(v.Device, &buffer_info, v.Allocator, &bd.UploadBuffer);
        check_vk_result(err);
        VkMemoryRequirements req;
        vkGetBufferMemoryRequirements(v.Device, bd.UploadBuffer, &req);
        bd.BufferMemoryAlignment = (bd.BufferMemoryAlignment > req.alignment) ? bd.BufferMemoryAlignment : req.alignment;
        VkMemoryAllocateInfo alloc_info = {};
        alloc_info.sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
        alloc_info.allocationSize = req.size;
        alloc_info.memoryTypeIndex = ImGui_ImplVulkan_MemoryType(VMemoryProperty.HOST_VISIBLE, req.memoryTypeBits);
        err = vkAllocateMemory(v.Device, &alloc_info, v.Allocator, &bd.UploadBufferMemory);
        check_vk_result(err);
        err = vkBindBufferMemory(v.Device, bd.UploadBuffer, bd.UploadBufferMemory, 0);
        check_vk_result(err);
    }

    // Upload to Buffer:
    {
        char* map = null;
        err = vkMapMemory(v.Device, bd.UploadBufferMemory, 0, upload_size, 0, cast(void**)(&map));
        check_vk_result(err);
        memcpy(map, pixels, upload_size);
        VkMappedMemoryRange[1] range;
        range[0].sType = VkStructureType.VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE;
        range[0].memory = bd.UploadBufferMemory;
        range[0].size = upload_size;
        err = vkFlushMappedMemoryRanges(v.Device, 1, range.ptr);
        check_vk_result(err);
        vkUnmapMemory(v.Device, bd.UploadBufferMemory);
    }

    // Copy to Image:
    {
        VkImageMemoryBarrier[1] copy_barrier;
        copy_barrier[0].sType = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
        copy_barrier[0].dstAccessMask = VAccess.TRANSFER_WRITE;
        copy_barrier[0].oldLayout = VImageLayout.UNDEFINED;
        copy_barrier[0].newLayout = VImageLayout.TRANSFER_DST_OPTIMAL;
        copy_barrier[0].srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
        copy_barrier[0].dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
        copy_barrier[0].image = bd.FontImage;
        copy_barrier[0].subresourceRange.aspectMask = VImageAspect.COLOR;
        copy_barrier[0].subresourceRange.levelCount = 1;
        copy_barrier[0].subresourceRange.layerCount = 1;
        vkCmdPipelineBarrier(command_buffer, VPipelineStage.HOST, VPipelineStage.TRANSFER, 0, 0, null, 0, null, 1, copy_barrier.ptr);

        VkBufferImageCopy region = {};
        region.imageSubresource.aspectMask = VImageAspect.COLOR;
        region.imageSubresource.layerCount = 1;
        region.imageExtent.width = width;
        region.imageExtent.height = height;
        region.imageExtent.depth = 1;
        vkCmdCopyBufferToImage(command_buffer, bd.UploadBuffer, bd.FontImage, VImageLayout.TRANSFER_DST_OPTIMAL, 1, &region);

        VkImageMemoryBarrier[1] use_barrier;
        use_barrier[0].sType = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
        use_barrier[0].srcAccessMask = VAccess.TRANSFER_WRITE;
        use_barrier[0].dstAccessMask = VAccess.SHADER_READ;
        use_barrier[0].oldLayout = VImageLayout.TRANSFER_DST_OPTIMAL;
        use_barrier[0].newLayout = VImageLayout.SHADER_READ_ONLY_OPTIMAL;
        use_barrier[0].srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
        use_barrier[0].dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
        use_barrier[0].image = bd.FontImage;
        use_barrier[0].subresourceRange.aspectMask = VImageAspect.COLOR;
        use_barrier[0].subresourceRange.levelCount = 1;
        use_barrier[0].subresourceRange.layerCount = 1;
        vkCmdPipelineBarrier(command_buffer, VPipelineStage.TRANSFER, VPipelineStage.FRAGMENT_SHADER, 0, 0, null, 0, null, 1, use_barrier.ptr);
    }

    // Store our identifier
    //io.Fonts.SetTexID(cast(ImTextureID)cast(intptr_t)bd.FontImage);
    ImFontAtlas_SetTexID(io.Fonts, cast(ImTextureID)cast(intptr_t)bd.FontImage);

    return true;
}

void ImGui_ImplVulkan_CreateShaderModules(VkDevice device, VkAllocationCallbacks* allocator)
{
    // Create the shader modules
    ImGui_ImplVulkan_Data* bd = ImGui_ImplVulkan_GetBackendData();
    if (bd.ShaderModuleVert is null)
    {
        VkShaderModuleCreateInfo vert_info = {};
        vert_info.sType = VkStructureType.VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO;
        vert_info.codeSize = __glsl_shader_vert_spv.length*uint.sizeof;
        vert_info.pCode = cast(uint32_t*)__glsl_shader_vert_spv;
        VkResult err = vkCreateShaderModule(device, &vert_info, allocator, &bd.ShaderModuleVert);
        check_vk_result(err);
    }
    if (bd.ShaderModuleFrag is null)
    {
        VkShaderModuleCreateInfo frag_info = {};
        frag_info.sType = VkStructureType.VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO;
        frag_info.codeSize = __glsl_shader_frag_spv.length*uint.sizeof;
        frag_info.pCode = cast(uint32_t*)__glsl_shader_frag_spv;
        VkResult err = vkCreateShaderModule(device, &frag_info, allocator, &bd.ShaderModuleFrag);
        check_vk_result(err);
    }
}
void ImGui_ImplVulkan_CreateFontSampler(VkDevice device, VkAllocationCallbacks* allocator)
{
    ImGui_ImplVulkan_Data* bd = ImGui_ImplVulkan_GetBackendData();
    if (bd.FontSampler)
        return;

    VkSamplerCreateInfo info = {};
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO;
    info.magFilter = VFilter.LINEAR;
    info.minFilter = VFilter.LINEAR;
    info.mipmapMode = VSamplerMipmapMode.LINEAR;
    info.addressModeU = VSamplerAddressMode.REPEAT;
    info.addressModeV = VSamplerAddressMode.REPEAT;
    info.addressModeW = VSamplerAddressMode.REPEAT;
    info.minLod = -1000;
    info.maxLod = 1000;
    info.maxAnisotropy = 1.0f;
    VkResult err = vkCreateSampler(device, &info, allocator, &bd.FontSampler);
    check_vk_result(err);
}
void ImGui_ImplVulkan_CreateDescriptorSetLayout(VkDevice device, VkAllocationCallbacks* allocator)
{
    ImGui_ImplVulkan_Data* bd = ImGui_ImplVulkan_GetBackendData();
    if (bd.DescriptorSetLayout)
        return;

    ImGui_ImplVulkan_CreateFontSampler(device, allocator);
    VkSampler[1] sampler = [ bd.FontSampler ];
    VkDescriptorSetLayoutBinding[1] binding;
    binding[0].descriptorType = VDescriptorType.COMBINED_IMAGE_SAMPLER;
    binding[0].descriptorCount = 1;
    binding[0].stageFlags = VShaderStage.FRAGMENT;
    binding[0].pImmutableSamplers = sampler.ptr;
    VkDescriptorSetLayoutCreateInfo info = {};
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO;
    info.bindingCount = 1;
    info.pBindings = binding.ptr;
    VkResult err = vkCreateDescriptorSetLayout(device, &info, allocator, &bd.DescriptorSetLayout);
    check_vk_result(err);
}
void ImGui_ImplVulkan_CreatePipelineLayout(VkDevice device, VkAllocationCallbacks* allocator)
{
    ImGui_ImplVulkan_Data* bd = ImGui_ImplVulkan_GetBackendData();
    if (bd.PipelineLayout)
        return;

    // Constants: we are using 'vec2 offset' and 'vec2 scale' instead of a full 3d projection matrix
    ImGui_ImplVulkan_CreateDescriptorSetLayout(device, allocator);
    VkPushConstantRange[1] push_constants;
    push_constants[0].stageFlags = VShaderStage.VERTEX;
    push_constants[0].offset = (float.sizeof) * 0;
    push_constants[0].size = (float.sizeof) * 4;
    VkDescriptorSetLayout[1] set_layout = [ bd.DescriptorSetLayout ];
    VkPipelineLayoutCreateInfo layout_info = {};
    layout_info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO;
    layout_info.setLayoutCount = 1;
    layout_info.pSetLayouts = set_layout.ptr;
    layout_info.pushConstantRangeCount = 1;
    layout_info.pPushConstantRanges = push_constants.ptr;
    VkResult  err = vkCreatePipelineLayout(device, &layout_info, allocator, &bd.PipelineLayout);
    check_vk_result(err);
}

void ImGui_ImplVulkan_CreatePipeline(VkDevice device, VkAllocationCallbacks* allocator, VkPipelineCache pipelineCache, VkRenderPass renderPass, VkSampleCountFlagBits MSAASamples, VkPipeline* pipeline, uint32_t subpass)
{
    ImGui_ImplVulkan_Data* bd = ImGui_ImplVulkan_GetBackendData();
    ImGui_ImplVulkan_CreateShaderModules(device, allocator);

    VkPipelineShaderStageCreateInfo[2] stage;
    stage[0].sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
    stage[0].stage = VShaderStage.VERTEX;
    stage[0].module_ = bd.ShaderModuleVert;
    stage[0].pName = "main".ptr;
    stage[1].sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
    stage[1].stage = VShaderStage.FRAGMENT;
    stage[1].module_ = bd.ShaderModuleFrag;
    stage[1].pName = "main".ptr;

    VkVertexInputBindingDescription[1] binding_desc;
    binding_desc[0].stride = (ImDrawVert.sizeof);
    binding_desc[0].inputRate = VkVertexInputRate.VK_VERTEX_INPUT_RATE_VERTEX;

    VkVertexInputAttributeDescription[3] attribute_desc;
    attribute_desc[0].location = 0;
    attribute_desc[0].binding = binding_desc[0].binding;
    attribute_desc[0].format = VkFormat.VK_FORMAT_R32G32_SFLOAT;
    attribute_desc[0].offset = ImDrawVert.pos.offsetof;
    attribute_desc[1].location = 1;
    attribute_desc[1].binding = binding_desc[0].binding;
    attribute_desc[1].format = VkFormat.VK_FORMAT_R32G32_SFLOAT;
    attribute_desc[1].offset = ImDrawVert.uv.offsetof;
    attribute_desc[2].location = 2;
    attribute_desc[2].binding = binding_desc[0].binding;
    attribute_desc[2].format = VkFormat.VK_FORMAT_R8G8B8A8_UNORM;
    attribute_desc[2].offset = ImDrawVert.col.offsetof;

    VkPipelineVertexInputStateCreateInfo vertex_info = {};
    vertex_info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO;
    vertex_info.vertexBindingDescriptionCount = 1;
    vertex_info.pVertexBindingDescriptions = binding_desc.ptr;
    vertex_info.vertexAttributeDescriptionCount = 3;
    vertex_info.pVertexAttributeDescriptions = attribute_desc.ptr;

    VkPipelineInputAssemblyStateCreateInfo ia_info = {};
    ia_info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO;
    ia_info.topology = VPrimitiveTopology.TRIANGLE_LIST;

    VkPipelineViewportStateCreateInfo viewport_info = {};
    viewport_info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO;
    viewport_info.viewportCount = 1;
    viewport_info.scissorCount = 1;

    VkPipelineRasterizationStateCreateInfo raster_info;
    raster_info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO;
    raster_info.polygonMode = VkPolygonMode.VK_POLYGON_MODE_FILL;
    raster_info.cullMode = VkCullModeFlagBits.VK_CULL_MODE_NONE;
    raster_info.frontFace = VkFrontFace.VK_FRONT_FACE_COUNTER_CLOCKWISE;
    raster_info.lineWidth = 1.0f;
    raster_info.depthBiasClamp = 0;

    VkPipelineMultisampleStateCreateInfo ms_info = {};
    ms_info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO;
    ms_info.rasterizationSamples = (MSAASamples != 0) ? MSAASamples : VSampleCount._1;

    VkPipelineColorBlendAttachmentState[1] color_attachment;
    color_attachment[0].blendEnable = VK_TRUE;
    color_attachment[0].srcColorBlendFactor = VBlendFactor.SRC_ALPHA;
    color_attachment[0].dstColorBlendFactor = VBlendFactor.ONE_MINUS_SRC_ALPHA;
    color_attachment[0].colorBlendOp = VBlendOp.ADD;
    color_attachment[0].srcAlphaBlendFactor = VBlendFactor.ONE;
    color_attachment[0].dstAlphaBlendFactor = VBlendFactor.ONE_MINUS_SRC_ALPHA;
    color_attachment[0].alphaBlendOp = VBlendOp.ADD;
    color_attachment[0].colorWriteMask =
        VkColorComponentFlagBits.VK_COLOR_COMPONENT_R_BIT |
        VkColorComponentFlagBits.VK_COLOR_COMPONENT_G_BIT |
        VkColorComponentFlagBits.VK_COLOR_COMPONENT_B_BIT |
        VkColorComponentFlagBits.VK_COLOR_COMPONENT_A_BIT;

    VkPipelineDepthStencilStateCreateInfo depth_info = {};
    depth_info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO;

    VkPipelineColorBlendStateCreateInfo blend_info = {};
    blend_info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO;
    blend_info.attachmentCount = 1;
    blend_info.pAttachments = color_attachment.ptr;

    VkDynamicState[2] dynamic_states = [ VkDynamicState.VK_DYNAMIC_STATE_VIEWPORT, VkDynamicState.VK_DYNAMIC_STATE_SCISSOR ];
    VkPipelineDynamicStateCreateInfo dynamic_state = {};
    dynamic_state.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO;
    dynamic_state.dynamicStateCount = cast(uint32_t)dynamic_states.length;
    dynamic_state.pDynamicStates = dynamic_states.ptr;

    ImGui_ImplVulkan_CreatePipelineLayout(device, allocator);

    VkGraphicsPipelineCreateInfo info = {};
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO;
    info.flags = bd.PipelineCreateFlags;
    info.stageCount = 2;
    info.pStages = stage.ptr;
    info.pVertexInputState = &vertex_info;
    info.pInputAssemblyState = &ia_info;
    info.pViewportState = &viewport_info;
    info.pRasterizationState = &raster_info;
    info.pMultisampleState = &ms_info;
    info.pDepthStencilState = &depth_info;
    info.pColorBlendState = &blend_info;
    info.pDynamicState = &dynamic_state;
    info.layout = bd.PipelineLayout;
    info.renderPass = renderPass;
    info.subpass = subpass;
    VkResult err = vkCreateGraphicsPipelines(device, pipelineCache, 1, &info, allocator, pipeline);
    check_vk_result(err);
}
bool ImGui_ImplVulkan_CreateDeviceObjects()
{
    ImGui_ImplVulkan_Data* bd = ImGui_ImplVulkan_GetBackendData();

    ImGui_ImplVulkan_InitInfo* v = &bd.VulkanInitInfo;
    VkResult err;

    if (!bd.FontSampler)
    {
        VkSamplerCreateInfo info = {};
        info.sType = VkStructureType.VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO;
        info.magFilter = VFilter.LINEAR;
        info.minFilter = VFilter.LINEAR;
        info.mipmapMode = VSamplerMipmapMode.LINEAR;
        info.addressModeU = VSamplerAddressMode.REPEAT;
        info.addressModeV = VSamplerAddressMode.REPEAT;
        info.addressModeW = VSamplerAddressMode.REPEAT;
        info.minLod = -1000;
        info.maxLod = 1000;
        info.maxAnisotropy = 1.0f;
        err = vkCreateSampler(v.Device, &info, v.Allocator, &bd.FontSampler);
        check_vk_result(err);
    }

    if (!bd.DescriptorSetLayout)
    {
        VkSampler[1] sampler = [ bd.FontSampler ];
        VkDescriptorSetLayoutBinding[1] binding;
        binding[0].descriptorType = VDescriptorType.COMBINED_IMAGE_SAMPLER;
        binding[0].descriptorCount = 1;
        binding[0].stageFlags = VShaderStage.FRAGMENT;
        binding[0].pImmutableSamplers = sampler.ptr;

        VkDescriptorSetLayoutCreateInfo info;
        info.sType = VkStructureType.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO;
        info.bindingCount = 1;
        info.pBindings = binding.ptr;
        err = vkCreateDescriptorSetLayout(v.Device, &info, v.Allocator, &bd.DescriptorSetLayout);
        check_vk_result(err);
    }

    // Create Descriptor Set:
    {
        VkDescriptorSetAllocateInfo alloc_info;
        alloc_info.sType = VkStructureType.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO;
        alloc_info.descriptorPool = v.DescriptorPool;
        alloc_info.descriptorSetCount = 1;
        alloc_info.pSetLayouts = &bd.DescriptorSetLayout;
        err = vkAllocateDescriptorSets(v.Device, &alloc_info, &bd.DescriptorSet);
        check_vk_result(err);
    }

    if (!bd.PipelineLayout)
    {
        // Constants: we are using 'vec2 offset' and 'vec2 scale' instead of a full 3d projection matrix
        VkPushConstantRange[1] push_constants;
        push_constants[0].stageFlags = VShaderStage.VERTEX;
        push_constants[0].offset = float.sizeof * 0;
        push_constants[0].size = float.sizeof * 4;
        VkDescriptorSetLayout[1] set_layout = [ bd.DescriptorSetLayout ];
        VkPipelineLayoutCreateInfo layout_info = {};
        layout_info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO;
        layout_info.setLayoutCount = 1;
        layout_info.pSetLayouts = set_layout.ptr;
        layout_info.pushConstantRangeCount = 1;
        layout_info.pPushConstantRanges = push_constants.ptr;
        err = vkCreatePipelineLayout(v.Device, &layout_info, v.Allocator, &bd.PipelineLayout);
        check_vk_result(err);
    }

    ImGui_ImplVulkan_CreatePipeline(v.Device, v.Allocator, v.PipelineCache, bd.RenderPass, v.MSAASamples, &bd.Pipeline, bd.Subpass);

    return true;
}
void ImGui_ImplVulkan_DestroyFontUploadObjects()
{
    ImGui_ImplVulkan_Data* bd = ImGui_ImplVulkan_GetBackendData();
    ImGui_ImplVulkan_InitInfo* v = &bd.VulkanInitInfo;
    if (bd.UploadBuffer)
    {
        vkDestroyBuffer(v.Device, bd.UploadBuffer, v.Allocator);
        bd.UploadBuffer = VK_NULL_HANDLE;
    }
    if (bd.UploadBufferMemory)
    {
        vkFreeMemory(v.Device, bd.UploadBufferMemory, v.Allocator);
        bd.UploadBufferMemory = VK_NULL_HANDLE;
    }
}

void ImGui_ImplVulkan_DestroyDeviceObjects()
{
    ImGui_ImplVulkan_Data* bd = ImGui_ImplVulkan_GetBackendData();
    ImGui_ImplVulkan_InitInfo* v = &bd.VulkanInitInfo;
    ImGui_ImplVulkanH_DestroyWindowRenderBuffers(v.Device, &bd.MainWindowRenderBuffers, v.Allocator);
    ImGui_ImplVulkan_DestroyFontUploadObjects();

    if (bd.ShaderModuleVert)     { vkDestroyShaderModule(v.Device, bd.ShaderModuleVert, v.Allocator); bd.ShaderModuleVert = VK_NULL_HANDLE; }
    if (bd.ShaderModuleFrag)     { vkDestroyShaderModule(v.Device, bd.ShaderModuleFrag, v.Allocator); bd.ShaderModuleFrag = VK_NULL_HANDLE; }
    if (bd.FontView)             { vkDestroyImageView(v.Device, bd.FontView, v.Allocator); bd.FontView = VK_NULL_HANDLE; }
    if (bd.FontImage)            { vkDestroyImage(v.Device, bd.FontImage, v.Allocator); bd.FontImage = VK_NULL_HANDLE; }
    if (bd.FontMemory)           { vkFreeMemory(v.Device, bd.FontMemory, v.Allocator); bd.FontMemory = VK_NULL_HANDLE; }
    if (bd.FontSampler)          { vkDestroySampler(v.Device, bd.FontSampler, v.Allocator); bd.FontSampler = VK_NULL_HANDLE; }
    if (bd.DescriptorSetLayout)  { vkDestroyDescriptorSetLayout(v.Device, bd.DescriptorSetLayout, v.Allocator); bd.DescriptorSetLayout = VK_NULL_HANDLE; }
    if (bd.PipelineLayout)       { vkDestroyPipelineLayout(v.Device, bd.PipelineLayout, v.Allocator); bd.PipelineLayout = VK_NULL_HANDLE; }
    if (bd.Pipeline)             { vkDestroyPipeline(v.Device, bd.Pipeline, v.Allocator); bd.Pipeline = VK_NULL_HANDLE; }
}

bool ImGui_ImplVulkan_LoadFunctions(void function(const (char)* function_name, void* user_data) loader_func, void* user_data)
{
    // Load function pointers
    // You can use the default Vulkan loader using:
    //      ImGui_ImplVulkan_LoadFunctions([](const char* function_name, void*) { return vkGetInstanceProcAddr(your_vk_isntance, function_name); });
    // But this would be equivalent to not setting VK_NO_PROTOTYPES.
// #ifdef VK_NO_PROTOTYPES
// #define IMGUI_VULKAN_FUNC_LOAD(func) \
//     func = reinterpret_cast<decltype(func)>(loader_func(#func, user_data)); \
//     if (func == NULL)   \
//         return false;
//     IMGUI_VULKAN_FUNC_MAP(IMGUI_VULKAN_FUNC_LOAD)
// #undef IMGUI_VULKAN_FUNC_LOAD
// #else
//     IM_UNUSED(loader_func);
//     IM_UNUSED(user_data);
// #endif
//    g_FunctionsLoaded = true;
    return true;
}

bool ImGui_ImplVulkan_Init(ImGui_ImplVulkan_InitInfo* info, VkRenderPass render_pass)
{
    //IM_ASSERT(g_FunctionsLoaded && "Need to call ImGui_ImplVulkan_LoadFunctions() if IMGUI_IMPL_VULKAN_NO_PROTOTYPES or VK_NO_PROTOTYPES are set!");

    ImGuiIO* io = igGetIO();
    vkassert(io.BackendRendererUserData is null, "Already initialized a renderer backend!");

    // Setup backend capabilities flags
    ImGui_ImplVulkan_Data* bd = cast(ImGui_ImplVulkan_Data*)calloc(ImGui_ImplVulkan_Data.sizeof, 1);
    io.BackendRendererUserData = cast(void*)bd;

    io.BackendRendererName = "imgui_impl_vulkan";
    io.BackendFlags |= ImGuiBackendFlags_RendererHasVtxOffset;  // We can honor the ImDrawCmd::VtxOffset field, allowing for large meshes.

    vkassert(info.Instance != VK_NULL_HANDLE);
    vkassert(info.PhysicalDevice != VK_NULL_HANDLE);
    vkassert(info.Device != VK_NULL_HANDLE);
    vkassert(info.Queue != VK_NULL_HANDLE);
    vkassert(info.DescriptorPool != VK_NULL_HANDLE);
    vkassert(info.MinImageCount >= 2);
    vkassert(info.ImageCount >= info.MinImageCount);
    vkassert(render_pass != VK_NULL_HANDLE);

    bd.VulkanInitInfo = *info;
    bd.RenderPass = render_pass;
    bd.Subpass = info.Subpass;

    ImGui_ImplVulkan_CreateDeviceObjects();

    return true;
}

void ImGui_ImplVulkan_Shutdown()
{
    ImGuiIO* io = igGetIO();
    ImGui_ImplVulkan_Data* bd = ImGui_ImplVulkan_GetBackendData();

    ImGui_ImplVulkan_DestroyDeviceObjects();
    io.BackendRendererName = null;
    io.BackendRendererUserData = null;
    free(bd);
}

void ImGui_ImplVulkan_NewFrame()
{
    ImGui_ImplVulkan_Data* bd = ImGui_ImplVulkan_GetBackendData();
    vkassert(bd !is null, "Did you call ImGui_ImplVulkan_Init()?");
    //IM_UNUSED(bd);
}

void ImGui_ImplVulkan_SetMinImageCount(uint32_t min_image_count)
{
    ImGui_ImplVulkan_Data* bd = ImGui_ImplVulkan_GetBackendData();
    vkassert(min_image_count >= 2);
    if (bd.VulkanInitInfo.MinImageCount == min_image_count)
        return;

    ImGui_ImplVulkan_InitInfo* v = &bd.VulkanInitInfo;
    VkResult err = vkDeviceWaitIdle(v.Device);
    check_vk_result(err);
    ImGui_ImplVulkanH_DestroyWindowRenderBuffers(v.Device, &bd.MainWindowRenderBuffers, v.Allocator);
    bd.VulkanInitInfo.MinImageCount = min_image_count;
}

//-------------------------------------------------------------------------
// Internal / Miscellaneous Vulkan Helpers
// (Used by example's main.cpp. Used by multi-viewport features. PROBABLY NOT used by your own app.)
//-------------------------------------------------------------------------
// You probably do NOT need to use or care about those functions.
// Those functions only exist because:
//   1) they facilitate the readability and maintenance of the multiple main.cpp examples files.
//   2) the upcoming multi-viewport feature will need them internally.
// Generally we avoid exposing any kind of superfluous high-level helpers in the backends,
// but it is too much code to duplicate everywhere so we exceptionally expose them.
//
// Your engine/app will likely _already_ have code to setup all that stuff (swap chain, render pass, frame buffers, etc.).
// You may read this code to learn about Vulkan, but it is recommended you use you own custom tailored code to do equivalent work.
// (The ImGui_ImplVulkanH_XXX functions do not interact with any of the state used by the regular ImGui_ImplVulkan_XXX functions)
//-------------------------------------------------------------------------

VkSurfaceFormatKHR ImGui_ImplVulkanH_SelectSurfaceFormat(VkPhysicalDevice physical_device, VkSurfaceKHR surface, VkFormat* request_formats, int request_formats_count, VkColorSpaceKHR request_color_space)
{
    //assert(g_FunctionsLoaded, "Need to call ImGui_ImplVulkan_LoadFunctions() if IMGUI_IMPL_VULKAN_NO_PROTOTYPES or VK_NO_PROTOTYPES are set!");
    vkassert(request_formats !is null);
    vkassert(request_formats_count > 0);

    // Per Spec Format and View Format are expected to be the same unless VK_IMAGE_CREATE_MUTABLE_BIT was set at image creation
    // Assuming that the default behavior is without setting this bit, there is no need for separate Swapchain image and image view format
    // Additionally several new color spaces were introduced with Vulkan Spec v1.0.40,
    // hence we must make sure that a format with the mostly available color space, VK_COLOR_SPACE_SRGB_NONLINEAR_KHR, is found and used.
    uint32_t avail_count;
    vkGetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &avail_count, null);
    ImVector!VkSurfaceFormatKHR avail_format;
    avail_format.resize(cast(int)avail_count);
    vkGetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &avail_count, cast(VkSurfaceFormatKHR*)avail_format.Data);

    // First check if only one format, VK_FORMAT_UNDEFINED, is available, which would imply that any format is available
    if (avail_count == 1)
    {
        if (avail_format.Data[0].format == VkFormat.VK_FORMAT_UNDEFINED)
        {
            VkSurfaceFormatKHR ret;
            ret.format = request_formats[0];
            ret.colorSpace = request_color_space;
            return ret;
        }
        else
        {
            // No point in searching another format
            return avail_format.Data[0];
        }
    }
    else
    {
        // Request several formats, the first found will be used
        for (int request_i = 0; request_i < request_formats_count; request_i++)
            for (uint32_t avail_i = 0; avail_i < avail_count; avail_i++)
                if (avail_format.Data[avail_i].format == request_formats[request_i] && avail_format.Data[avail_i].colorSpace == request_color_space)
                    return avail_format.Data[avail_i];

        // If none of the requested image formats could be found, use the first available
        return avail_format.Data[0];
    }
}

VkPresentModeKHR ImGui_ImplVulkanH_SelectPresentMode(VkPhysicalDevice physical_device, VkSurfaceKHR surface, VkPresentModeKHR* request_modes, int request_modes_count)
{
    //assert(g_FunctionsLoaded, "Need to call ImGui_ImplVulkan_LoadFunctions() if IMGUI_IMPL_VULKAN_NO_PROTOTYPES or VK_NO_PROTOTYPES are set!");
    vkassert(request_modes !is null);
    vkassert(request_modes_count > 0);

    // Request a certain mode and confirm that it is available. If not use VK_PRESENT_MODE_FIFO_KHR which is mandatory
    uint32_t avail_count = 0;
    vkGetPhysicalDeviceSurfacePresentModesKHR(physical_device, surface, &avail_count, null);
    ImVector!VkPresentModeKHR avail_modes;
    avail_modes.resize(cast(int)avail_count);
    vkGetPhysicalDeviceSurfacePresentModesKHR(physical_device, surface, &avail_count, cast(VkPresentModeKHR*)avail_modes.Data);
    //for (uint32_t avail_i = 0; avail_i < avail_count; avail_i++)
    //    printf("[vulkan] avail_modes[%d] = %d\n", avail_i, avail_modes[avail_i]);

    for (int request_i = 0; request_i < request_modes_count; request_i++)
        for (uint32_t avail_i = 0; avail_i < avail_count; avail_i++)
            if (request_modes[request_i] == avail_modes.Data[avail_i])
                return request_modes[request_i];

    return VkPresentModeKHR.VK_PRESENT_MODE_FIFO_KHR; // Always available
}

void ImGui_ImplVulkanH_CreateWindowCommandBuffers(VkPhysicalDevice physical_device, VkDevice device, ImGui_ImplVulkanH_Window* wd, uint32_t queue_family, VkAllocationCallbacks* allocator)
{
    vkassert(physical_device != VK_NULL_HANDLE && device != VK_NULL_HANDLE);
    // (void)physical_device;
    // (void)allocator;

    // Create Command Buffers
    VkResult err;
    for (uint32_t i = 0; i < wd.ImageCount; i++)
    {
        ImGui_ImplVulkanH_Frame* fd = &wd.Frames[i];
        ImGui_ImplVulkanH_FrameSemaphores* fsd = &wd.FrameSemaphores[i];
        {
            VkCommandPoolCreateInfo info = {};
            info.sType = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO;
            info.flags = VCommandPoolCreate.RESET_COMMAND_BUFFER;
            info.queueFamilyIndex = queue_family;
            err = vkCreateCommandPool(device, &info, allocator, &fd.CommandPool);
            check_vk_result(err);
        }
        {
            VkCommandBufferAllocateInfo info = {};
            info.sType = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
            info.commandPool = fd.CommandPool;
            info.level = VkCommandBufferLevel.VK_COMMAND_BUFFER_LEVEL_PRIMARY;
            info.commandBufferCount = 1;
            err = vkAllocateCommandBuffers(device, &info, &fd.CommandBuffer);
            check_vk_result(err);
        }
        {
            VkFenceCreateInfo info = {};
            info.sType = VkStructureType.VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
            info.flags = VkFenceCreateFlagBits.VK_FENCE_CREATE_SIGNALED_BIT;
            err = vkCreateFence(device, &info, allocator, &fd.Fence);
            check_vk_result(err);
        }
        {
            VkSemaphoreCreateInfo info = {};
            info.sType = VkStructureType.VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO;
            err = vkCreateSemaphore(device, &info, allocator, &fsd.ImageAcquiredSemaphore);
            check_vk_result(err);
            err = vkCreateSemaphore(device, &info, allocator, &fsd.RenderCompleteSemaphore);
            check_vk_result(err);
        }
    }
}
int ImGui_ImplVulkanH_GetMinImageCountFromPresentMode(VkPresentModeKHR present_mode)
{
    if (present_mode == VkPresentModeKHR.VK_PRESENT_MODE_MAILBOX_KHR)
        return 3;
    if (present_mode == VkPresentModeKHR.VK_PRESENT_MODE_FIFO_KHR || present_mode == VkPresentModeKHR.VK_PRESENT_MODE_FIFO_RELAXED_KHR)
        return 2;
    if (present_mode == VkPresentModeKHR.VK_PRESENT_MODE_IMMEDIATE_KHR)
        return 1;
    assert(false);
}
// Also destroy old swap chain and in-flight frames data, if any.
/*
void ImGui_ImplVulkanH_CreateWindowSwapChain(VkPhysicalDevice physical_device, VkDevice device, ImGui_ImplVulkanH_Window* wd, VkAllocationCallbacks* allocator, int w, int h, uint32_t min_image_count)
{
    VkResult err;
    VkSwapchainKHR old_swapchain = wd.Swapchain;
    wd.Swapchain = null;
    err = vkDeviceWaitIdle(device);
    check_vk_result(err);

    // We don't use ImGui_ImplVulkanH_DestroyWindow() because we want to preserve the old swapchain to create the new one.
    // Destroy old Framebuffer
    for (uint32_t i = 0; i < wd.ImageCount; i++)
    {
        ImGui_ImplVulkanH_DestroyFrame(device, &wd.Frames[i], allocator);
        ImGui_ImplVulkanH_DestroyFrameSemaphores(device, &wd.FrameSemaphores[i], allocator);
    }

    //IM_FREE(wd.Frames);           // GC
    //IM_FREE(wd.FrameSemaphores);  // GC
    wd.Frames = null;
    wd.FrameSemaphores = null;
    wd.ImageCount = 0;
    if (wd.RenderPass)
        vkDestroyRenderPass(device, wd.RenderPass, allocator);
    if (wd.Pipeline)
        vkDestroyPipeline(device, wd.Pipeline, allocator);

    // If min image count was not specified, request different count of images dependent on selected present mode
    if (min_image_count == 0)
        min_image_count = ImGui_ImplVulkanH_GetMinImageCountFromPresentMode(wd.PresentMode);

    // Create Swapchain
    {
        VkSwapchainCreateInfoKHR info = {};
        info.sType = VkStructureType.VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR;
        info.surface = wd.Surface;
        info.minImageCount = min_image_count;
        info.imageFormat = wd.SurfaceFormat.format;
        info.imageColorSpace = wd.SurfaceFormat.colorSpace;
        info.imageArrayLayers = 1;
        info.imageUsage = VImageUsage.COLOR_ATTACHMENT;
        info.imageSharingMode = VSharingMode.EXCLUSIVE;           // Assume that graphics family == present family
        info.preTransform = VkSurfaceTransformFlagBitsKHR.VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR;
        info.compositeAlpha = VkCompositeAlphaFlagBitsKHR.VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR;
        info.presentMode = wd.PresentMode;
        info.clipped = VK_TRUE;
        info.oldSwapchain = old_swapchain;
        VkSurfaceCapabilitiesKHR cap;
        err = vkGetPhysicalDeviceSurfaceCapabilitiesKHR(physical_device, wd.Surface, &cap);
        check_vk_result(err);
        if (info.minImageCount < cap.minImageCount)
            info.minImageCount = cap.minImageCount;
        else if (cap.maxImageCount != 0 && info.minImageCount > cap.maxImageCount)
            info.minImageCount = cap.maxImageCount;

        if (cap.currentExtent.width == 0xffffffff)
        {
            info.imageExtent.width = wd.Width = w;
            info.imageExtent.height = wd.Height = h;
        }
        else
        {
            info.imageExtent.width = wd.Width = cap.currentExtent.width;
            info.imageExtent.height = wd.Height = cap.currentExtent.height;
        }
        err = vkCreateSwapchainKHR(device, &info, allocator, &wd.Swapchain);
        check_vk_result(err);
        err = vkGetSwapchainImagesKHR(device, wd.Swapchain, &wd.ImageCount, null);
        check_vk_result(err);

        VkImage[16] backbuffers;
        vkassert(wd.ImageCount >= min_image_count);
        vkassert(wd.ImageCount < backbuffers.length);

        err = vkGetSwapchainImagesKHR(device, wd.Swapchain, &wd.ImageCount, backbuffers.ptr);
        check_vk_result(err);

        vkassert(wd.Frames is null);

        // BIG NOTE:
        // If ImGui_ImplVulkanH_Window* is created using new then these can be new too
        // otherwise they should be calloc/free

        //wd.Frames = (ImGui_ImplVulkanH_Frame*)IM_ALLOC(sizeof(ImGui_ImplVulkanH_Frame) * wd.ImageCount);
        wd.Frames = new ImGui_ImplVulkanH_Frame[wd.ImageCount].ptr;

        //wd.FrameSemaphores = (ImGui_ImplVulkanH_FrameSemaphores*)IM_ALLOC(sizeof(ImGui_ImplVulkanH_FrameSemaphores) * wd.ImageCount);
        wd.FrameSemaphores = new ImGui_ImplVulkanH_FrameSemaphores[wd.ImageCount].ptr;

        //memset(wd.Frames, 0, sizeof(wd.Frames[0]) * wd.ImageCount);
        //memset(wd.FrameSemaphores, 0, sizeof(wd.FrameSemaphores[0]) * wd.ImageCount);

        for (uint32_t i = 0; i < wd.ImageCount; i++)
            wd.Frames[i].Backbuffer = backbuffers[i];
    }
    if (old_swapchain)
        vkDestroySwapchainKHR(device, old_swapchain, allocator);

    // Create the Render Pass
    {
        VkAttachmentDescription attachment = {};
        attachment.format = wd.SurfaceFormat.format;
        attachment.samples = VSampleCount._1;
        attachment.loadOp = wd.ClearEnable ? VAttachmentLoadOp.CLEAR : VAttachmentLoadOp.DONT_CARE;
        attachment.storeOp = VAttachmentStoreOp.STORE;
        attachment.stencilLoadOp = VAttachmentLoadOp.DONT_CARE;
        attachment.stencilStoreOp = VAttachmentStoreOp.DONT_CARE;
        attachment.initialLayout = VImageLayout.UNDEFINED;
        attachment.finalLayout = VImageLayout.PRESENT_SRC_KHR;
        VkAttachmentReference color_attachment = {};
        color_attachment.attachment = 0;
        color_attachment.layout = VImageLayout.COLOR_ATTACHMENT_OPTIMAL;
        VkSubpassDescription subpass = {};
        subpass.pipelineBindPoint = VPipelineBindPoint.GRAPHICS;
        subpass.colorAttachmentCount = 1;
        subpass.pColorAttachments = &color_attachment;
        VkSubpassDependency dependency = {};
        dependency.srcSubpass = VK_SUBPASS_EXTERNAL;
        dependency.dstSubpass = 0;
        dependency.srcStageMask = VPipelineStage.COLOR_ATTACHMENT_OUTPUT;
        dependency.dstStageMask = VPipelineStage.COLOR_ATTACHMENT_OUTPUT;
        dependency.srcAccessMask = 0;
        dependency.dstAccessMask = VAccess.COLOR_ATTACHMENT_WRITE;
        VkRenderPassCreateInfo info = {};
        info.sType = VkStructureType.VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;
        info.attachmentCount = 1;
        info.pAttachments = &attachment;
        info.subpassCount = 1;
        info.pSubpasses = &subpass;
        info.dependencyCount = 1;
        info.pDependencies = &dependency;
        err = vkCreateRenderPass(device, &info, allocator, &wd.RenderPass);
        check_vk_result(err);

        // We do not create a pipeline by default as this is also used by examples' main.cpp,
        // but secondary viewport in multi-viewport mode may want to create one with:
        //ImGui_ImplVulkan_CreatePipeline(device, allocator, VK_NULL_HANDLE, wd.RenderPass, VK_SAMPLE_COUNT_1_BIT, &wd.Pipeline, bd.Subpass);
    }

    // Create The Image Views
    {
        VkImageViewCreateInfo info = {};
        info.sType = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
        info.viewType = VImageViewType._2D;
        info.format = wd.SurfaceFormat.format;
        info.components.r = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_R;
        info.components.g = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_G;
        info.components.b = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_B;
        info.components.a = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_A;
        VkImageSubresourceRange image_range = { VImageAspect.COLOR, 0, 1, 0, 1 };
        info.subresourceRange = image_range;
        for (uint32_t i = 0; i < wd.ImageCount; i++)
        {
            ImGui_ImplVulkanH_Frame* fd = &wd.Frames[i];
            info.image = fd.Backbuffer;
            err = vkCreateImageView(device, &info, allocator, &fd.BackbufferView);
            check_vk_result(err);
        }
    }

    // Create Framebuffer
    {
        VkImageView[1] attachment;
        VkFramebufferCreateInfo info = {};
        info.sType = VkStructureType.VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO;
        info.renderPass = wd.RenderPass;
        info.attachmentCount = 1;
        info.pAttachments = attachment.ptr;
        info.width = wd.Width;
        info.height = wd.Height;
        info.layers = 1;
        for (uint32_t i = 0; i < wd.ImageCount; i++)
        {
            ImGui_ImplVulkanH_Frame* fd = &wd.Frames[i];
            attachment[0] = fd.BackbufferView;
            err = vkCreateFramebuffer(device, &info, allocator, &fd.Framebuffer);
            check_vk_result(err);
        }
    }
}
// Create or resize window
void ImGui_ImplVulkanH_CreateOrResizeWindow(VkInstance instance, VkPhysicalDevice physical_device, VkDevice device, ImGui_ImplVulkanH_Window* wd, uint32_t queue_family, VkAllocationCallbacks* allocator, int width, int height, uint32_t min_image_count)
{
    //assert(g_FunctionsLoaded, "Need to call ImGui_ImplVulkan_LoadFunctions() if IMGUI_IMPL_VULKAN_NO_PROTOTYPES or VK_NO_PROTOTYPES are set!");
    //(void)instance;
    ImGui_ImplVulkanH_CreateWindowSwapChain(physical_device, device, wd, allocator, width, height, min_image_count);
    ImGui_ImplVulkanH_CreateWindowCommandBuffers(physical_device, device, wd, queue_family, allocator);
}

void ImGui_ImplVulkanH_DestroyWindow(VkInstance instance, VkDevice device, ImGui_ImplVulkanH_Window* wd, VkAllocationCallbacks* allocator)
{
    vkDeviceWaitIdle(device); // FIXME: We could wait on the Queue if we had the queue in wd. (otherwise VulkanH functions can't use globals)
    //vkQueueWaitIdle(bd.Queue);

    for (uint32_t i = 0; i < wd.ImageCount; i++)
    {
        ImGui_ImplVulkanH_DestroyFrame(device, &wd.Frames[i], allocator);
        ImGui_ImplVulkanH_DestroyFrameSemaphores(device, &wd.FrameSemaphores[i], allocator);
    }
    // IM_FREE(wd.Frames);          //
    // IM_FREE(wd.FrameSemaphores); //
    wd.Frames = null;               //
    wd.FrameSemaphores = null;      //

    vkDestroyPipeline(device, wd.Pipeline, allocator);
    vkDestroyRenderPass(device, wd.RenderPass, allocator);
    vkDestroySwapchainKHR(device, wd.Swapchain, allocator);
    vkDestroySurfaceKHR(instance, wd.Surface, allocator);

    *wd = ImGui_ImplVulkanH_Window();
}
*/
void ImGui_ImplVulkanH_DestroyFrame(VkDevice device, ImGui_ImplVulkanH_Frame* fd, VkAllocationCallbacks* allocator)
{
    vkDestroyFence(device, fd.Fence, allocator);
    vkFreeCommandBuffers(device, fd.CommandPool, 1, &fd.CommandBuffer);
    vkDestroyCommandPool(device, fd.CommandPool, allocator);
    fd.Fence = VK_NULL_HANDLE;
    fd.CommandBuffer = VK_NULL_HANDLE;
    fd.CommandPool = VK_NULL_HANDLE;

    vkDestroyImageView(device, fd.BackbufferView, allocator);
    vkDestroyFramebuffer(device, fd.Framebuffer, allocator);
}

void ImGui_ImplVulkanH_DestroyFrameSemaphores(VkDevice device, ImGui_ImplVulkanH_FrameSemaphores* fsd, VkAllocationCallbacks* allocator)
{
    vkDestroySemaphore(device, fsd.ImageAcquiredSemaphore, allocator);
    vkDestroySemaphore(device, fsd.RenderCompleteSemaphore, allocator);
    fsd.ImageAcquiredSemaphore = fsd.RenderCompleteSemaphore = VK_NULL_HANDLE;
}
void ImGui_ImplVulkanH_DestroyFrameRenderBuffers(VkDevice device, ImGui_ImplVulkanH_FrameRenderBuffers* buffers, VkAllocationCallbacks* allocator)
{
    if (buffers.VertexBuffer) { vkDestroyBuffer(device, buffers.VertexBuffer, allocator); buffers.VertexBuffer = VK_NULL_HANDLE; }
    if (buffers.VertexBufferMemory) { vkFreeMemory(device, buffers.VertexBufferMemory, allocator); buffers.VertexBufferMemory = VK_NULL_HANDLE; }
    if (buffers.IndexBuffer) { vkDestroyBuffer(device, buffers.IndexBuffer, allocator); buffers.IndexBuffer = VK_NULL_HANDLE; }
    if (buffers.IndexBufferMemory) { vkFreeMemory(device, buffers.IndexBufferMemory, allocator); buffers.IndexBufferMemory = VK_NULL_HANDLE; }
    buffers.VertexBufferSize = 0;
    buffers.IndexBufferSize = 0;
}

void ImGui_ImplVulkanH_DestroyWindowRenderBuffers(VkDevice device, ImGui_ImplVulkanH_WindowRenderBuffers* buffers, VkAllocationCallbacks* allocator)
{
    for (uint32_t n = 0; n < buffers.Count; n++)
        ImGui_ImplVulkanH_DestroyFrameRenderBuffers(device, &buffers.FrameRenderBuffers[n], allocator);
    free(buffers.FrameRenderBuffers);
    buffers.FrameRenderBuffers = null;
    buffers.Index = 0;
    buffers.Count = 0;
}
