module vulkan.misc.dump;

import vulkan.all;

void dump(VkPhysicalDevice device) {
    log("Physical device {");
    device.getProperties().dump();
    device.getFeatures().dump();
    device.getMemoryProperties().dump();
    device.getExtensions().dump();
    device.getQueueFamilies().dump();
    log("}");
}
//void dump(VPhysicalDevice physicalDevice) {
//	log("Physical device {");
//    physicalDevice.properties.dump();
//	//physicalDevice.properties.limits.dump();
//	physicalDevice.features.dump();
//	physicalDevice.memProperties.dump();
//	physicalDevice.dumpExtensions();
//	//physicalDevice.dumpLayers();
//	physicalDevice.dumpQueueFamilies();
//	log("}");
//}
void dump(VkPhysicalDeviceProperties props) {
    log("  VendorID   :    %s", props.vendorID);
    log("  DeviceID   :    %s", props.deviceID);
    log("  Device Name:    %s", props.deviceName.ptr.fromStringz);
    log("  Device Type:    %s", props.deviceType.to!string);

    log("  Driver Version: %s", versionToString(props.driverVersion));
    log("  API Version:    %s", versionToString(props.apiVersion));

    props.limits.dump();
}
void dump(VkPhysicalDeviceLimits limits) {
	log("  Limits:");
	log("    - maxImageDimension1D ......... %s", limits.maxImageDimension1D);
	log("    - maxImageDimension2D ......... %s", limits.maxImageDimension2D);
	log("    - maxImageDimension3D ......... %s", limits.maxImageDimension3D);
	log("    - maxComputeSharedMemorySize .. %s", limits.maxComputeSharedMemorySize);
	log("    - maxComputeWorkGroupCount .... [%s,%s,%s]",
	    limits.maxComputeWorkGroupCount[0],
	    limits.maxComputeWorkGroupCount[1],
	    limits.maxComputeWorkGroupCount[2]);
    log("    - maxComputeWorkGroupSize ..... [%s,%s,%s]",
        limits.maxComputeWorkGroupSize[0],
        limits.maxComputeWorkGroupSize[1],
        limits.maxComputeWorkGroupSize[2]);

    log("    - maxUniformBufferRange ....... %s", limits.maxUniformBufferRange);
    log("    - maxStorageBufferRange ....... %s", limits.maxStorageBufferRange);

    log("    - timestampComputeAndGraphics . %s", 1==limits.timestampComputeAndGraphics);
    log("    - timestampPeriod ............. %s", limits.timestampPeriod);
    log("    - discreteQueuePriorities ..... %s", limits.discreteQueuePriorities);
    log("    - maxPushConstantsSize ........ %s", limits.maxPushConstantsSize);
    log("    - maxSamplerAllocationCount ... %s", limits.maxSamplerAllocationCount);
    log("    - bufferImageGranularity ...... %s", limits.bufferImageGranularity);

    log("    - maxBoundDescriptorSets ...... %s", limits.maxBoundDescriptorSets);

    log("    - minUniformBufferOffsetAlignment %s", limits.minUniformBufferOffsetAlignment);

    log("    - minStorageBufferOffsetAlignment %s", limits.minStorageBufferOffsetAlignment);
    log("    - minMemoryMapAlignment ....... %s", limits.minMemoryMapAlignment);
    log("    - maxMemoryAllocationCount .... %s", limits.maxMemoryAllocationCount);

    log("    - maxDescriptorSetSamplers .... %s", limits.maxDescriptorSetSamplers);
    log("    - maxDescriptorSetStorageBuffers %s", limits.maxDescriptorSetStorageBuffers);
    log("    - maxSamplerAnisotropy ......... %s", limits.maxSamplerAnisotropy);
    log("    - maxViewports ................. %s", limits.maxViewports);
    log("    - maxViewportDimensions [x,y] .. %s", limits.maxViewportDimensions);

    log("    - maxFramebufferWidth ......... %s", limits.maxFramebufferWidth);
    log("    - maxFramebufferHeight ........ %s", limits.maxFramebufferHeight);

    log("    - optimalBufferCopyOffsetAlignment %s", limits.optimalBufferCopyOffsetAlignment);
}
void dump(VkPhysicalDeviceFeatures features) {
	log("  Features:");
	log("    - geometryShader     .. %s", features.geometryShader==1);
    log("    - tessellationShader .. %s", features.tessellationShader==1);
    log("    - shaderFloat64 ....... %s", features.shaderFloat64==1);
    log("    - shaderInt64 ......... %s", features.shaderInt64==1);
    log("    - shaderInt16 ......... %s", features.shaderInt16==1);
    log("    - samplerAnisotropy ... %s", features.samplerAnisotropy==1);
}
void dump(VkPhysicalDeviceMemoryProperties p) {
	log("  Memory properties:");
	for(auto i=0; i<p.memoryTypeCount; i++) {
		auto mt = p.memoryTypes[i];
		log("    - Type[%2s]: (0x%x) heap:%s isLocal=%s hostVisible=%s hostCoherent=%s hostCached=%s lazyAlloc=%s protected=%s",
			i,
            mt.propertyFlags,
			mt.heapIndex,
			cast(bool)(mt.propertyFlags&VkMemoryPropertyFlagBits.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
			cast(bool)(mt.propertyFlags&VkMemoryPropertyFlagBits.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
			cast(bool)(mt.propertyFlags&VkMemoryPropertyFlagBits.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
			cast(bool)(mt.propertyFlags&VkMemoryPropertyFlagBits.VK_MEMORY_PROPERTY_HOST_CACHED_BIT),
			cast(bool)(mt.propertyFlags&VkMemoryPropertyFlagBits.VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT),
            cast(bool)(mt.propertyFlags&VK_MEMORY_PROPERTY_PROTECTED_BIT)
		);
	}
	for(auto i=0; i<p.memoryHeapCount; i++) {
		auto mh = p.memoryHeaps[i];
		log("    - Heap[%s]: size: %s islocal=%s",
		    i,
			mh.size.sizeToString(),
			cast(bool)(mh.flags & VkMemoryHeapFlagBits.VK_MEMORY_HEAP_DEVICE_LOCAL_BIT)
		);
	}
}
void dump(VkQueueFamilyProperties[] queueFamilies) {
	log("  Queue families: %s", queueFamilies.length);

    foreach(i, qf; queueFamilies) {
		log("    [%s] QueueCount:%s flags:%s timestampValidBits:%s minImageTransferGranularity:%s",
		    i, qf.queueCount, toArray!VkQueueFlagBits(qf.queueFlags),
		    qf.timestampValidBits, qf.minImageTransferGranularity);
	}
}
void dump(VkExtensionProperties[] extensions) {
	log("  Device extensions: %s", extensions.length);
	foreach(i, e; extensions) {
		log("    [%s] name:'%s' specVersion:%s",
		    i, e.extensionName.ptr.fromStringz, e.specVersion);
	}
}
// https://www.khronos.org/registry/vulkan/specs/1.0/man/html/vkEnumerateInstanceExtensionProperties.html
void dumpInstanceExtensions() {
	uint count;
	vkEnumerateInstanceExtensionProperties(null, &count, null);
	log("Instance extensions: %s", count);
	if(count>0) {
		scope auto array = new VkExtensionProperties[count];
		vkEnumerateInstanceExtensionProperties(null, &count, array.ptr);
		foreach(i, p; array) {
			log("  [%s] extensionName:'%s' specVersion:%s",
			    i,
			    p.extensionName.ptr.fromStringz,
			    p.specVersion);
		}
	}
}
// https://www.khronos.org/registry/vulkan/specs/1.0/man/html/vkEnumerateInstanceLayerProperties.html
void dumpInstanceLayers() {
    uint count;
    vkEnumerateInstanceLayerProperties(&count, null);
    log("Instance layers: %s", count);
    if(count>0) {
        scope array = new VkLayerProperties[count];
        vkEnumerateInstanceLayerProperties(&count, array.ptr);
        foreach(i, l; array) {
            log("  [%s] layer name:'%s' desc:'%s' specVersion:%s implVersion:%s",
                i,
                l.layerName.ptr.fromStringz,
                l.description.ptr.fromStringz,
                versionToString(l.specVersion),
                l.implementationVersion);
        }
    }
}
void dump(VkSurfaceCapabilitiesKHR capabilities) {
    log("Surface capabilities:");
    log("   minImageCount  = %s", capabilities.minImageCount);
    log("   maxImageCount  = %s", capabilities.maxImageCount);
    log("   currentExtent  = %s", capabilities.currentExtent);
    log("   minImageExtent = %s", capabilities.minImageExtent);
    log("   maxImageExtent = %s", capabilities.maxImageExtent);
    log("   maxImageArrayLayers = %s", capabilities.maxImageArrayLayers);
    log("   supportedTransforms = %s", toArray!VkSurfaceTransformFlagBitsKHR(capabilities.supportedTransforms));
    log("   currentTransform = %s", toArray!VkSurfaceTransformFlagBitsKHR(capabilities.currentTransform));
    log("   supportedCompositeAlpha = %s", capabilities.supportedCompositeAlpha);
    log("   supportedUsageFlags = %s", toArray!VkImageUsageFlagBits(capabilities.supportedUsageFlags));
}
void dump(VkPresentModeKHR[] presentModes) {
    log("Present modes:");
    foreach(i, pm; presentModes) {
        log("   [%s] %s", i, pm.to!string);
    }
}
void dump(ref VkMemoryRequirements m, string name=null) {
    log("Memory requirements %s", name ? "("~name~"):" : ":");
    log("   size:%s, alignment:%s memoryTypeBits:%s", m.size, m.alignment, m.memoryTypeBits);
}
