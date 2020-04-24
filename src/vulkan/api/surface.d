module vulkan.api.surface;

import vulkan.all;

VkSurfaceKHR createSurface(VkInstance instance, HINSTANCE hInstance, HWND hwnd) {
    VkSurfaceKHR surface;
    VkWin32SurfaceCreateInfoKHR surfaceCreateInfo;
    surfaceCreateInfo.sType		= VkStructureType.VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR;
    surfaceCreateInfo.pNext		= null;
    surfaceCreateInfo.hinstance = hInstance;
    surfaceCreateInfo.hwnd		= hwnd;

    check(vkCreateWin32SurfaceKHR(instance, &surfaceCreateInfo, null, &surface));
    return surface;
}
bool canPresent(VkPhysicalDevice pDevice, VkSurfaceKHR surface, uint queueFamilyIndex) {
    uint canPresent;
    vkGetPhysicalDeviceSurfaceSupportKHR(
        pDevice,
        queueFamilyIndex,
        surface,
        &canPresent);
    return canPresent==1;
}
VkSurfaceCapabilitiesKHR getCapabilities(VkPhysicalDevice pDevice, VkSurfaceKHR surface) {
    VkSurfaceCapabilitiesKHR caps;
    check(vkGetPhysicalDeviceSurfaceCapabilitiesKHR(
        pDevice,
        surface,
        &caps
    ));
    caps.dump();
    return caps;
}
VkPresentModeKHR[] getPresentModes(VkPhysicalDevice pDevice, VkSurfaceKHR surface) {
    VkPresentModeKHR[] presentModes;
    uint count;
    check(vkGetPhysicalDeviceSurfacePresentModesKHR(
            pDevice,
            surface,
            &count,
            null
    ));
    presentModes.length = count;

    check(vkGetPhysicalDeviceSurfacePresentModesKHR(
            pDevice,
            surface,
            &count,
            presentModes.ptr
    ));

    return presentModes;
}
VkSurfaceFormatKHR[] getFormats(VkPhysicalDevice pDevice, VkSurfaceKHR surface) {
    VkSurfaceFormatKHR[] formats;
    VkFormat colorFormat;
    VkColorSpaceKHR colorSpace;
    uint formatCount = 0;

    vkGetPhysicalDeviceSurfaceFormatsKHR(pDevice, surface, &formatCount, null);
    formats.length = formatCount;
    vkGetPhysicalDeviceSurfaceFormatsKHR(pDevice, surface, &formatCount, formats.ptr);

    return formats;
}
