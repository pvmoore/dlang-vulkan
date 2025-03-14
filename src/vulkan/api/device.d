module vulkan.api.device;

import vulkan.all;

VkDevice createLogicalDevice(IVulkanApplication application,
                             VkPhysicalDevice physicalDevice,
                             VulkanProperties vprops,
                             VkDeviceQueueCreateInfo[] queues)
{
    immutable(char)*[] extensions = vprops.deviceExtensions;

    if(vprops.enableShaderPrintf) {
        throwIf(!vprops.isV11orHigher(), "Shader printf requires Vulkan 1.1 or later");
        extensions ~= "VK_KHR_shader_non_semantic_info".ptr;
    }

    VkDevice device;
    VkDeviceCreateInfo deviceInfo;
    deviceInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
    deviceInfo.pNext = null;
    deviceInfo.flags = 0;

    // device layers are deprecated
    deviceInfo.enabledLayerCount = 0;
    deviceInfo.ppEnabledLayerNames = null;

    deviceInfo.enabledExtensionCount   = cast(uint)extensions.length;
    deviceInfo.ppEnabledExtensionNames = extensions.ptr;

    // Enable features:
    // https://github.com/KhronosGroup/Vulkan-Guide/blob/master/chapters/enabling_features.adoc
    DeviceFeatures features = new DeviceFeatures(physicalDevice, vprops);

    // Allow the application to enable/disable features
    application.selectFeatures(features);

    if(vprops.isV10()) {
        log("Using API v1.0 style device features");
        deviceInfo.pEnabledFeatures = features.getV10FeaturesPtr();
    } else {
        deviceInfo.pNext = features.getFeatures2Ptr();
        deviceInfo.pEnabledFeatures = null;
    }

    deviceInfo.queueCreateInfoCount = cast(uint)queues.length;
    deviceInfo.pQueueCreateInfos    = queues.ptr;

    log("Creating device with %s queue families", queues.length);

    log("Enabling device extensions:");
    foreach(ext; extensions) {
        log("  %s", fromStringz(ext));
    }

    check(vkCreateDevice(physicalDevice, &deviceInfo, null, &device));
    return device;
}

T getProcAddr(T)(VkDevice device, string procName) {
    auto a = cast(T)vkGetDeviceProcAddr(device, procName.ptr);
    throwIf(a is null);
    return a;
}

// Device destroy functions

void destroyDevice(VkDevice device) {
    vkDestroyDevice(device, null);
}
void destroyBuffer(VkDevice device, VkBuffer buffer) {
    vkDestroyBuffer(device, buffer, null);
}
void destroyBufferView(VkDevice device, VkBufferView view) {
    vkDestroyBufferView(device, view, null);
}
void destroyCommandPool(VkDevice device, VkCommandPool pool) {
    vkDestroyCommandPool(device, pool, null);
}
void destroyDescriptorPool(VkDevice device, VkDescriptorPool pool) {
    vkDestroyDescriptorPool(device, pool, null);
}
void destroyDescriptorSetLayout(VkDevice device, VkDescriptorSetLayout layout) {
    vkDestroyDescriptorSetLayout(device, layout, null);
}
void destroyEvent(VkDevice device, VkEvent event) {
    vkDestroyEvent(device, event, null);
}
void destroyFence(VkDevice device, VkFence fence) {
    vkDestroyFence(device, fence, null);
}
void destroyFrameBuffer(VkDevice device, VkFramebuffer frameBuffer) {
    vkDestroyFramebuffer(device, frameBuffer, null);
}
void destroyImage(VkDevice device, VkImage image) {
    vkDestroyImage(device, image, null);
}
void destroyImageView(VkDevice device, VkImageView view) {
    vkDestroyImageView(device, view, null);
}
void destroyPipeline(VkDevice device, VkPipeline pipeline) {
    vkDestroyPipeline(device, pipeline, null);
}
void destroyPipelineLayout(VkDevice device, VkPipelineLayout layout) {
    vkDestroyPipelineLayout(device, layout, null);
}
void destroyQueryPool(VkDevice device, VkQueryPool pool) {
    vkDestroyQueryPool(device, pool, null);
}
void destroyRenderPass(VkDevice device, VkRenderPass renderPass) {
    vkDestroyRenderPass(device, renderPass, null);
}
void destroySampler(VkDevice device, VkSampler sampler) {
    vkDestroySampler(device, sampler, null);
}
void destroySemaphore(VkDevice device, VkSemaphore semaphore) {
    vkDestroySemaphore(device, semaphore, null);
}
void destroyShaderModule(VkDevice device, VkShaderModule shaderModule) {
    vkDestroyShaderModule(device, shaderModule, null);
}
void destroySurfaceKHR(VkInstance instance, VkSurfaceKHR surface) {
    vkDestroySurfaceKHR(instance, surface, null);
}
void destroyAccelerationStructure(VkDevice device, VkAccelerationStructureKHR as) {
    vkDestroyAccelerationStructureKHR(device, as, null);
}
