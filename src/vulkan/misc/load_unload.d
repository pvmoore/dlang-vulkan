module vulkan.misc.load_unload;

import vulkan.all;

void loadSharedLibs(Vulkan vk) {
    verbose(__FILE__, "Loading Shared Libs");
    internalLoadGlfw();
    internalLoadVulkan(vk);
    internalLoadImgui();
}
void unloadSharedLibs(Vulkan vk) {
    verbose(__FILE__, "Unloading Shared Libs");
    internalUnloadGlfw();
    internalUnloadVulkan(vk);
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

void internalLoadVulkan(Vulkan vk) {
    VulkanLoader.load();
    vkLoadGlobalCommandFunctions();

    if(vk.vprops.vma.enabled) {
        if(!VMALoader.load()) {
            vk.vprops.vma.enabled = false;
            log(__FILE__, "Failed to load VMA shared library. Disabling VMA");
        } else {
            log(__FILE__, "Loaded VMA shared library");
        }
    }
}
void internalUnloadVulkan(Vulkan vk) {
    if(vk.vprops.vma.enabled) {
        VMALoader.unload();
    }
    VulkanLoader.unload();
}

void internalLoadImgui() {
    CImguiLoader.load();
}
void internalUnloadImgui() {
    CImguiLoader.unload();
}


