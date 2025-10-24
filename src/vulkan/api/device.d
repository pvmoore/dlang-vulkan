module vulkan.api.device;

import vulkan.all;

VkDevice createLogicalDevice(IVulkanApplication application,
                             VkPhysicalDevice physicalDevice,
                             VulkanProperties vprops,
                             FeaturesAndExtensions featuresAndExtensions,
                             VkDeviceQueueCreateInfo[] queues)
{
    VkDevice device;
    VkDeviceCreateInfo deviceInfo;
    deviceInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
    deviceInfo.pNext = null;
    deviceInfo.flags = 0;

    // device layers are deprecated
    deviceInfo.enabledLayerCount = 0;
    deviceInfo.ppEnabledLayerNames = null;

    deviceInfo.enabledExtensionCount   = featuresAndExtensions.getExtensionsCount();
    deviceInfo.ppEnabledExtensionNames = featuresAndExtensions.getExtensionsPP();

    if(vprops.isV10()) {
        verbose(__FILE__, "Using API v1.0 style device features");
        deviceInfo.pEnabledFeatures = featuresAndExtensions.getV1FeaturesPtr();
    } else {
        deviceInfo.pNext = featuresAndExtensions.getFeaturesPP();
        deviceInfo.pEnabledFeatures = null;
    }

    deviceInfo.queueCreateInfoCount = queues.length.as!uint;
    deviceInfo.pQueueCreateInfos    = queues.ptr;

    verbose(__FILE__, "Creating queues:");
    foreach(q; queues) {
        verbose(__FILE__, "  family:%s count:%s", q.queueFamilyIndex, q.queueCount);
    }
    verbose(__FILE__, "Enabling %s device extensions", featuresAndExtensions.getExtensionsCount());
    foreach(ext; featuresAndExtensions.getEnabledExtensionNames()) {
        verbose(__FILE__, "  %s", ext);
    }
    verbose(__FILE__, "Enabling %s device features", featuresAndExtensions.getEnabledFeatureNames().length);
    foreach(f; featuresAndExtensions.getEnabledFeatureNames()) {
        verbose(__FILE__, "  %s", f);
    }

    check(vkCreateDevice(physicalDevice, &deviceInfo, null, &device));

    verbose(__FILE__, "Device created successfully");
    return device;
}

T getProcAddr(T)(VkDevice device, string procName) {
    auto a = cast(T)vkGetDeviceProcAddr(device, procName.ptr);
    throwIf(a is null);
    return a;
}

// Device destroy functions

void destroyDevice(VkDevice device) {
    verbose(__FILE__, "Destroying device");
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
