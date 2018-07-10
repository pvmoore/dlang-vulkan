module vulkan.api.device;

import vulkan.all;

VkDevice createLogicalDevice(VkPhysicalDevice physicalDevice,
                             char*[] extensions,
                             VkPhysicalDeviceFeatures features,
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

    deviceInfo.enabledExtensionCount   = cast(uint)extensions.length;
    deviceInfo.ppEnabledExtensionNames = extensions.ptr;

    deviceInfo.pEnabledFeatures = &features;

    deviceInfo.queueCreateInfoCount = cast(uint)queues.length;
    deviceInfo.pQueueCreateInfos    = queues.ptr;

    log("   Creating device with %s queue families", queues.length);

    check(vkCreateDevice(physicalDevice, &deviceInfo, null, &device));
    return device;
}
// we can't call this destroy :(
void destroyDevice(VkDevice device) {
    vkDestroyDevice(device, null);
}
T getProcAddr(T)(VkDevice device, string procName) {
    auto a = cast(T)vkGetDeviceProcAddr(device, procName.ptr);
    assert(a);
    return a;
}