module vulkan.misc.functions;

import vulkan.all;
import core.sys.windows.windows;


//private __gshared HANDLE handle;

void loadVulkan_1_1_Functions() {
    // handle = LoadLibraryA("vulkan-1.dll");
    // if(!handle) {
    //     throw new Error("Unable to load Vulkan dll");
    // }

    *(cast(void**)&vkEnumerateInstanceVersion) = vkGetInstanceProcAddr(null, "vkEnumerateInstanceVersion");

    //*(cast(void**)&vkGetPhysicalDeviceFeatures2) = GetProcAddress(handle, "vkGetPhysicalDeviceFeatures2");

    //*(cast(void**)&vkEnumerateInstanceVersion) = GetProcAddress(handle, "vkEnumerateInstanceVersion");
}

void loadVulkanInstanceFunctions(VkInstance instance) {
    // Vulkan 1.1
    *(cast(void**)&vkGetPhysicalDeviceFeatures2) = vkGetInstanceProcAddr(instance, "vkGetPhysicalDeviceFeatures2");
    *(cast(void**)&vkGetPhysicalDeviceProperties2) = vkGetInstanceProcAddr(instance, "vkGetPhysicalDeviceProperties2");
    *(cast(void**)&vkGetPhysicalDeviceFormatProperties2) = vkGetInstanceProcAddr(instance, "vkGetPhysicalDeviceFormatProperties2");
    *(cast(void**)&vkGetPhysicalDeviceImageFormatProperties2) = vkGetInstanceProcAddr(instance, "vkGetPhysicalDeviceImageFormatProperties2");
    *(cast(void**)&vkGetPhysicalDeviceQueueFamilyProperties2) = vkGetInstanceProcAddr(instance, "vkGetPhysicalDeviceQueueFamilyProperties2");
    *(cast(void**)&vkGetPhysicalDeviceMemoryProperties2) = vkGetInstanceProcAddr(instance, "vkGetPhysicalDeviceMemoryProperties2");
    *(cast(void**)&vkGetPhysicalDeviceSparseImageFormatProperties2) = vkGetInstanceProcAddr(instance, "vkGetPhysicalDeviceSparseImageFormatProperties2");






    //log("vkGetPhysicalDeviceSparseImageFormatProperties2 = %s", vkGetPhysicalDeviceSparseImageFormatProperties2);
}

void loadVulkanDeviceFunctions(VkDevice device) {

}

void unloadExtraVulkanFunctions() {
    // if(handle) {
    //     FreeLibrary(handle);
    //     handle = null;
    // }
}

//

struct VkPhysicalDeviceFeatures2 {
    VkStructureType             sType;
    void*                       pNext;
    VkPhysicalDeviceFeatures    features;
}
struct VkPhysicalDeviceProperties2 {
    VkStructureType               sType;
    void*                         pNext;
    VkPhysicalDeviceProperties    properties;
}
struct VkFormatProperties2 {
    VkStructureType       sType;
    void*                 pNext;
    VkFormatProperties    formatProperties;
}
struct VkImageFormatProperties2 {
    VkStructureType            sType;
    void*                      pNext;
    VkImageFormatProperties    imageFormatProperties;
}
struct VkPhysicalDeviceImageFormatInfo2 {
    VkStructureType       sType;
    const void*           pNext;
    VkFormat              format;
    VkImageType           type;
    VkImageTiling         tiling;
    VkImageUsageFlags     usage;
    VkImageCreateFlags    flags;
}
struct VkQueueFamilyProperties2 {
    VkStructureType            sType;
    void*                      pNext;
    VkQueueFamilyProperties    queueFamilyProperties;
}
struct VkPhysicalDeviceMemoryProperties2 {
    VkStructureType                     sType;
    void*                               pNext;
    VkPhysicalDeviceMemoryProperties    memoryProperties;
}
struct VkSparseImageFormatProperties2 {
    VkStructureType                  sType;
    void*                            pNext;
    VkSparseImageFormatProperties    properties;
}
struct VkPhysicalDeviceSparseImageFormatInfo2 {
    VkStructureType          sType;
    const void*              pNext;
    VkFormat                 format;
    VkImageType              type;
    VkSampleCountFlagBits    samples;
    VkImageUsageFlags        usage;
    VkImageTiling            tiling;
}

enum VK_MEMORY_PROPERTY_PROTECTED_BIT = cast(VkMemoryPropertyFlagBits)0x00000020;

extern(Windows) { __gshared {

// Vulkan 1.1
VkResult function(uint* pApiVersion) vkEnumerateInstanceVersion;

void function(
    VkPhysicalDevice physicalDevice,
    VkPhysicalDeviceFeatures2* pFeatures) vkGetPhysicalDeviceFeatures2;

void function(
    VkPhysicalDevice physicalDevice,
    VkPhysicalDeviceProperties2* properties) vkGetPhysicalDeviceProperties2;

void function(
    VkPhysicalDevice physicalDevice,
    VkFormat fortmat,
    VkFormatProperties2* properties ) vkGetPhysicalDeviceFormatProperties2;

void function(
    VkPhysicalDevice physicalDevice,
    VkPhysicalDeviceImageFormatInfo2* info,
    VkImageFormatProperties2* properties) vkGetPhysicalDeviceImageFormatProperties2;

void function(
    VkPhysicalDevice          physicalDevice,
    uint*                     pQueueFamilyPropertyCount,
    VkQueueFamilyProperties2* properties) vkGetPhysicalDeviceQueueFamilyProperties2;

void function(
    VkPhysicalDevice physicalDevice,
    VkPhysicalDeviceMemoryProperties2* pMemoryProperties) vkGetPhysicalDeviceMemoryProperties2;

void function(
    VkPhysicalDevice                              physicalDevice,
    const VkPhysicalDeviceSparseImageFormatInfo2* pFormatInfo,
    uint*                                         pPropertyCount,
    VkSparseImageFormatProperties2*               pProperties) vkGetPhysicalDeviceSparseImageFormatProperties2;
}}
