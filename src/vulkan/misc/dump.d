module vulkan.misc.dump;

import vulkan.all;

void dump(VkPhysicalDevice device) {
    log("Physical device {");
    device.getProperties().dump();
    device.getFeatures().dump();
    device.getMemoryProperties().dump();
    device.getExtensions().dump();
    device.getQueueFamilies().dump();

    void _dumpFormatSupport(string label, VFormat[] formats) {
        log("  %s format support:", label);
        foreach(f; formats) {
            VkFormatProperties p = device.getFormatProperties(f);

            if(device.isFormatSupported(f)) {
                log("    - %s : yes - optTilingFeatures:%s", f, toString!VkFormatFeatureFlagBits(p.optimalTilingFeatures, "VK_FORMAT_FEATURE_", "_BIT"));
            } else {
                log("    - %s : no", f);
            }
        }
    }

    with(VFormat) {
        _dumpFormatSupport("Standard", [
            R8G8B8A8_UNORM,
            B8G8R8A8_UNORM,
            R8G8B8_UNORM,
            B8G8R8_UNORM,
            R8_UNORM,
            R16_UINT,
            R16_SINT,
            R16_SFLOAT,
            R32_UINT,
            R32_SINT,
            R32_SFLOAT,
            R64_UINT,
            R64_SINT,
            R64_SFLOAT
            ]);

        _dumpFormatSupport("Compression", [
            BC1_RGB_UNORM_BLOCK,
            BC1_RGBA_UNORM_BLOCK,
            BC2_UNORM_BLOCK,
            BC3_UNORM_BLOCK,
            BC4_UNORM_BLOCK,
            BC5_UNORM_BLOCK,
            BC6H_UFLOAT_BLOCK,
            BC6H_SFLOAT_BLOCK,
            BC7_UNORM_BLOCK,
            ETC2_R8G8B8A1_UNORM_BLOCK,
            ETC2_R8G8B8A8_UNORM_BLOCK,
            EAC_R11_UNORM_BLOCK,
            EAC_R11_SNORM_BLOCK
            ]);

        _dumpFormatSupport("Depth/stencil", [
            // depth stencil formats
            D16_UNORM,
            D32_SFLOAT,
            S8_UINT,
            D16_UNORM_S8_UINT,
            D24_UNORM_S8_UINT,
            D32_SFLOAT_S8_UINT
        ]);
    }

    log("}");
}
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
    log("    - maxComputeWorkGroupInvocations %s", limits.maxComputeWorkGroupInvocations);

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
		    i, qf.queueCount, toString!VkQueueFlagBits(qf.queueFlags, "VK_QUEUE_", "_BIT"),
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
    log("   supportedUsageFlags = %s", toString!VkImageUsageFlagBits(capabilities.supportedUsageFlags, "VK_IMAGE_USAGE_", "_BIT"));
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
