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
VkPhysicalDeviceProperties getProperties(VkPhysicalDevice pDevice) {
    VkPhysicalDeviceProperties properties;
    vkGetPhysicalDeviceProperties(pDevice, &properties);
    return properties;
}
VkPhysicalDeviceFeatures getFeatures(VkPhysicalDevice pDevice) {
    VkPhysicalDeviceFeatures features;
    vkGetPhysicalDeviceFeatures(pDevice, &features);
    return features;
}
auto getFeatures2(VkPhysicalDevice pDevice) {
    VkPhysicalDeviceFeatures2 features;
    vkGetPhysicalDeviceFeatures2(pDevice, &features);
    return features;
}
VkPhysicalDeviceMemoryProperties getMemoryProperties(VkPhysicalDevice pDevice) {
    VkPhysicalDeviceMemoryProperties memProperties;
    vkGetPhysicalDeviceMemoryProperties(pDevice, &memProperties);
    return memProperties;
}
auto getFormatProperties(VkPhysicalDevice pDevice, VkFormat format) {
    VkFormatProperties props;
    vkGetPhysicalDeviceFormatProperties(pDevice, format, &props);
    return props;
}
auto getSparseImageFormatProperties(
    VkPhysicalDevice pDevice,
    VkFormat format,
    VkImageType type,
    uint samples,
    VkImageUsageFlags usage,
    VkImageTiling tiling)
{
    VkSparseImageFormatProperties[] properties;
    uint count;
    vkGetPhysicalDeviceSparseImageFormatProperties(
        pDevice, format, type, cast(VkSampleCountFlagBits)samples, usage, tiling, &count, null);
    properties.length = count;
    vkGetPhysicalDeviceSparseImageFormatProperties(
            pDevice, format, type, cast(VkSampleCountFlagBits)samples, usage, tiling, &count, properties.ptr);
    return properties;
}
VkPhysicalDevice selectBestPhysicalDevice(VkInstance instance, uint requiredAPIVersion, immutable(char)*[] requiredExtensions) {
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

    if(!supportsRequiredExtensions()) {
        throw new Error("No Vulkan device found with required extensions");
    }
    if(!supportsRequiredAPIVersion()) {
        throw new Error("No Vulkan device found which supports API version %s".format(versionToString(requiredAPIVersion)));
    }

    // bool isDiscreteGPU     = props.deviceType==VkPhysicalDeviceType.VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU;
    // bool isIntegratedGPU   = props.deviceType==VkPhysicalDeviceType.VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU;
    // bool geometryShader    = features.geometryShader==1;
    // bool tesselationShader = features.tessellationShader==1;
    // uint maxImageDim2D     = props.limits.maxImageDimension2D;

    //log("Physical device is discrete GPU: %s", isDiscreteGPU);
    //log("Physical device is integrated GPU: %s", isIntegratedGPU);
    return physicalDevice;
}
/**
 *  The spec says if no flags are set at all then the format is not usable.
 */
bool isFormatSupported(VkPhysicalDevice pDevice, VFormat format) {
    auto fp = pDevice.getFormatProperties(format);
    return fp.linearTilingFeatures!=0 ||
           fp.optimalTilingFeatures!=0 ||
           fp.bufferFeatures!=0;
}
