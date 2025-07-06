module vulkan.misc.load_unload;

import vulkan.all;

void loadSharedLibs() {
    internalLoadGlfw();
    internalLoadVulkan();
    internalLoadImgui();
}
void unloadSharedLibs() {
    internalUnloadGlfw();
    internalUnloadVulkan();
    internalUnloadImgui();
}

void vkLoadDeviceFunctions(VkDevice device) {
    *(cast(void**)&vkGetBufferDeviceAddressKHR) = vkGetDeviceProcAddr(device, "vkGetBufferDeviceAddressKHR");
    *(cast(void**)&vkCmdBuildAccelerationStructuresKHR) = vkGetDeviceProcAddr(device, "vkCmdBuildAccelerationStructuresKHR");
    *(cast(void**)&vkBuildAccelerationStructuresKHR) = vkGetDeviceProcAddr(device, "vkBuildAccelerationStructuresKHR");
    *(cast(void**)&vkCreateAccelerationStructureKHR) = vkGetDeviceProcAddr(device, "vkCreateAccelerationStructureKHR");
    *(cast(void**)&vkDestroyAccelerationStructureKHR) = vkGetDeviceProcAddr(device, "vkDestroyAccelerationStructureKHR");
    *(cast(void**)&vkGetAccelerationStructureBuildSizesKHR) = vkGetDeviceProcAddr(device, "vkGetAccelerationStructureBuildSizesKHR");
    *(cast(void**)&vkGetAccelerationStructureDeviceAddressKHR) = vkGetDeviceProcAddr(device, "vkGetAccelerationStructureDeviceAddressKHR");
    *(cast(void**)&vkCmdTraceRaysKHR) = vkGetDeviceProcAddr(device, "vkCmdTraceRaysKHR");
    *(cast(void**)&vkGetRayTracingShaderGroupHandlesKHR) = vkGetDeviceProcAddr(device, "vkGetRayTracingShaderGroupHandlesKHR");
    *(cast(void**)&vkCreateRayTracingPipelinesKHR) = vkGetDeviceProcAddr(device, "vkCreateRayTracingPipelinesKHR");
}

private:

void internalLoadGlfw() {
    GLFWLoader.load();
}
void internalUnloadGlfw() {
    GLFWLoader.unload();
}

void internalLoadVulkan() {
    VulkanLoader.load();
    vkLoadGlobalCommandFunctions();
}
void internalUnloadVulkan() {
    VulkanLoader.unload();
}

void internalLoadImgui() {
    CImguiLoader.load();
}
void internalUnloadImgui() {
    CImguiLoader.unload();
}


