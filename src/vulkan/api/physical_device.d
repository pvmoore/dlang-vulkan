module vulkan.api.physical_device;

import vulkan.all;

uint countPhysicalDevices(VkInstance instance) {
	uint deviceCount = 0;
	check(vkEnumeratePhysicalDevices(instance, &deviceCount, null));
	if(deviceCount == 0) {
		throw new Error("Couldn't detect any device with Vulkan support");
	}
	return deviceCount;
}
VkPhysicalDevice[] getPhysicalDevices(VkInstance instance) {
	uint deviceCount = countPhysicalDevices(instance);
	log("Physical devices: %s", deviceCount);
	auto physicalDevices = new VkPhysicalDevice[deviceCount];
	check(vkEnumeratePhysicalDevices(instance, &deviceCount, physicalDevices.ptr));
    return physicalDevices;
}
VkQueueFamilyProperties[] getQueueFamilies(VkPhysicalDevice pDevice) {
    VkQueueFamilyProperties[] queueFamilies;
    uint count = 0;
    vkGetPhysicalDeviceQueueFamilyProperties(pDevice, &count, null);
    queueFamilies.length = count;
    vkGetPhysicalDeviceQueueFamilyProperties(pDevice, &count, queueFamilies.ptr);
    return queueFamilies;
}
VkExtensionProperties[] getExtensions(VkPhysicalDevice pDevice) {
    VkExtensionProperties[] extensions;
    uint count;
    vkEnumerateDeviceExtensionProperties(pDevice, null, &count, null);
    extensions.length = count;
    vkEnumerateDeviceExtensionProperties(pDevice, null, &count, extensions.ptr);
    return extensions;
}
//────────────────────────────────────────────────────────────────────────────────────────────────── properties
VkPhysicalDeviceProperties getProperties(VkPhysicalDevice pDevice) {
    VkPhysicalDeviceProperties properties;
    vkGetPhysicalDeviceProperties(pDevice, &properties);
    return properties;
}
// (Vulkan 1.1)
void getProperties2(VkPhysicalDevice pDevice, void* pNext) {
    VkPhysicalDeviceProperties2 props2 = {
        sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2,
        pNext: pNext
    };
    vkGetPhysicalDeviceProperties2(pDevice, &props2);
}
VkPhysicalDeviceRayTracingPipelinePropertiesKHR getRayTracingPipelineProperties(VkPhysicalDevice pDevice) {
    VkPhysicalDeviceRayTracingPipelinePropertiesKHR rtProps = {
        sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PIPELINE_PROPERTIES_KHR
    };
    getProperties2(pDevice, &rtProps);
    return rtProps;
}
VkPhysicalDeviceAccelerationStructurePropertiesKHR getAccelerationStructureProperties(VkPhysicalDevice pDevice) {
    VkPhysicalDeviceAccelerationStructurePropertiesKHR asProps = {
        sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_PROPERTIES_KHR
    };
    getProperties2(pDevice, &asProps);
    return asProps;
}
// (Vulkan 1.1)
VkPhysicalDeviceVulkan11Properties getVulkan11Properties(VkPhysicalDevice pDevice) {
    throwIfNot(vk11Enabled());
    VkPhysicalDeviceVulkan11Properties props = {
        sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_PROPERTIES
    };
    getProperties2(pDevice, &props);
    return props;
}
// Vulkan (1.2)
VkPhysicalDeviceVulkan12Properties getVulkan12Properties(VkPhysicalDevice pDevice) {
    throwIfNot(vk12Enabled());
    VkPhysicalDeviceVulkan12Properties props = {
        sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_PROPERTIES
    };
    getProperties2(pDevice, &props);
    return props;
}
// Vulkan (1.3)
VkPhysicalDeviceVulkan13Properties getVulkan13Properties(VkPhysicalDevice pDevice) {
    throwIfNot(vk13Enabled());
    VkPhysicalDeviceVulkan13Properties props = {
        sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_3_PROPERTIES
    };
    getProperties2(pDevice, &props);
    return props;
}
// Vulkan (1.4)
VkPhysicalDeviceVulkan14Properties getVulkan14Properties(VkPhysicalDevice pDevice) {
    throwIfNot(vk14Enabled());
    VkPhysicalDeviceVulkan14Properties props = {
        sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_4_PROPERTIES
    };
    getProperties2(pDevice, &props);
    return props;
}
VkPhysicalDeviceMemoryProperties getMemoryProperties(VkPhysicalDevice pDevice) {
    VkPhysicalDeviceMemoryProperties memProperties;
    vkGetPhysicalDeviceMemoryProperties(pDevice, &memProperties);
    return memProperties;
}
VkPhysicalDeviceDriverProperties getDriverProperties(VkPhysicalDevice pDevice) {
    VkPhysicalDeviceDriverProperties driverProps = {
        sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DRIVER_PROPERTIES_KHR
    };
    getProperties2(pDevice, &driverProps);
    return driverProps;
}
VkFormatProperties getFormatProperties(VkPhysicalDevice pDevice, VkFormat format) {
    VkFormatProperties props;
    vkGetPhysicalDeviceFormatProperties(pDevice, format, &props);
    return props;
}
// (Vulkan 1.1)
VkFormatProperties2 getFormatProperties2(VkPhysicalDevice pDevice, VkFormat format) {
    throwIfNot(vk11Enabled());
    VkFormatProperties2 props = {
        sType: VK_STRUCTURE_TYPE_FORMAT_PROPERTIES_2
    };
    vkGetPhysicalDeviceFormatProperties2(pDevice, format, &props);
    return props;
}
// (Vulkan 1.3)
VkFormatProperties3 getFormatProperties3(VkPhysicalDevice pDevice, VkFormat format) {
    throwIfNot(vk13Enabled());
    VkFormatProperties3 props3 = { sType: VK_STRUCTURE_TYPE_FORMAT_PROPERTIES_3 };
    VkFormatProperties2 props = { 
        sType: VK_STRUCTURE_TYPE_FORMAT_PROPERTIES_2,
        pNext: &props3
    };
    vkGetPhysicalDeviceFormatProperties2(pDevice, format, &props);
    return props3;
}
// (Vulkan 1.2)
VkPhysicalDeviceFloatControlsProperties getFloatControlProperties(VkPhysicalDevice pDevice) {
    throwIfNot(vk12Enabled());
    VkPhysicalDeviceFloatControlsProperties props = {
        sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FLOAT_CONTROLS_PROPERTIES_KHR
    };
    getProperties2(pDevice, &props);
    return props;
}
// (Vulkan 1.1)
VkImageFormatProperties2 getImageFormatProperties(VkPhysicalDevice pDevice, 
                                                  VkFormat format,
                                                  VkImageType type,
                                                  VkImageTiling tiling,
                                                  VkImageUsageFlags usage,
                                                  VkImageCreateFlags flags) {
    throwIfNot(vk11Enabled());                                                    
    VkPhysicalDeviceImageFormatInfo2 info = {
        sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGE_FORMAT_INFO_2,
        format: format,
        type: type,
        tiling: tiling,
        usage: usage,
        flags: flags
    };
    VkImageFormatProperties2 props = {
        sType: VK_STRUCTURE_TYPE_IMAGE_FORMAT_PROPERTIES_2
    };
    vkGetPhysicalDeviceImageFormatProperties2(pDevice, &info, &props);
    return props;
}
VkSparseImageFormatProperties[] getSparseImageFormatProperties(VkPhysicalDevice pDevice,
                                                               VkFormat format,
                                                               VkImageType type,
                                                               uint samples,
                                                               VkImageUsageFlags usage,
                                                               VkImageTiling tiling)
{
    VkSparseImageFormatProperties[] properties;
    uint count;
    vkGetPhysicalDeviceSparseImageFormatProperties(pDevice, format, type, cast(VkSampleCountFlagBits)samples, usage, tiling, &count, null);
    properties.length = count;
    vkGetPhysicalDeviceSparseImageFormatProperties(pDevice, format, type, cast(VkSampleCountFlagBits)samples, usage, tiling, &count, properties.ptr);
    return properties;
}
/**
 *  The spec says if no flags are set at all then the format is not usable.
 */
bool isFormatSupported(VkPhysicalDevice pDevice, VkFormat format) {
    auto fp = pDevice.getFormatProperties(format);
    return fp.linearTilingFeatures!=0 ||
           fp.optimalTilingFeatures!=0 ||
           fp.bufferFeatures!=0;
}
//────────────────────────────────────────────────────────────────────────────────────────────────── features
VkPhysicalDeviceFeatures getFeatures(VkPhysicalDevice pDevice) {
    VkPhysicalDeviceFeatures features;
    vkGetPhysicalDeviceFeatures(pDevice, &features);
    return features;
}
// auto getFeatures2(VkPhysicalDevice pDevice) {
//     VkPhysicalDeviceFeatures2 features;
//     vkGetPhysicalDeviceFeatures2(pDevice, &features);
//     return features;
// }
VkPhysicalDevice selectBestPhysicalDevice(VkInstance instance,
                                          uint requiredAPIVersion,
                                          immutable(char)*[] requiredExtensions)
{
    VkPhysicalDevice physicalDevice;
    VkPhysicalDeviceProperties props;
    VkPhysicalDeviceFeatures features;
    VkExtensionProperties[] extensions;

    VkPhysicalDevice[] devices = getPhysicalDevices(instance);
    devices.each!(it=>it.dump());

    bool supportsRequiredAPIVersion() {
        return props.apiVersion >= requiredAPIVersion;
    }
    bool supportsRequiredExtensions() {
        auto set = new Set!(string);
        foreach(e; extensions) {
            set.add(cast(string)e.extensionName.ptr.fromStringz.dup);
        }
        foreach(r; requiredExtensions) {
            string s = cast(string)r.fromStringz;
            if(!set.contains(s)) {
                return false;
            }
        }
        return true;
    }
    void switchToDevice(VkPhysicalDevice d) {
        physicalDevice = d;
        props          = physicalDevice.getProperties();
        features       = physicalDevice.getFeatures();
        extensions     = physicalDevice.getExtensions();
    }

    if(devices.length==0) {
        throw new Error("No Vulkan devices found");
    }
    if(devices.length==1) {
        switchToDevice(devices[0]);
    } else {
        // For now just pick one of the
        // discrete GPUs in the system
        VkPhysicalDevice preferredDevice = devices[0];
        foreach(d; devices) {
            switchToDevice(d);
            if(!supportsRequiredExtensions()) continue;
            if(!supportsRequiredAPIVersion()) continue;
            if(props.deviceType==VkPhysicalDeviceType.VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU) {
                preferredDevice = d;
                break;
            }
        }
        switchToDevice(preferredDevice);
    }

    throwIf(!supportsRequiredExtensions(), "No Vulkan device found with required extensions");
    throwIf(!supportsRequiredAPIVersion(), "No Vulkan device found which supports API version %s", versionToString(requiredAPIVersion));

    // bool isDiscreteGPU     = props.deviceType==VkPhysicalDeviceType.VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU;
    // bool isIntegratedGPU   = props.deviceType==VkPhysicalDeviceType.VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU;
    // bool geometryShader    = features.geometryShader==1;
    // bool tesselationShader = features.tessellationShader==1;
    // uint maxImageDim2D     = props.limits.maxImageDimension2D;

    //log("Physical device is discrete GPU: %s", isDiscreteGPU);
    //log("Physical device is integrated GPU: %s", isIntegratedGPU);
    return physicalDevice;
}
