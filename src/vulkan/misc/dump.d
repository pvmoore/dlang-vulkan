module vulkan.misc.dump;

import vulkan.all;
import std.string : leftJustify;

void dump(VkPhysicalDevice pDevice) {
    {
        VkPhysicalDeviceProperties props = pDevice.getProperties();
        props.dump();

        if(vk11Enabled() && props.apiVersion >= VK_VERSION_1_1) {
            VkPhysicalDeviceVulkan11Properties props11 = pDevice.getVulkan11Properties();
            props11.dump();
        }
        if(vk12Enabled() && props.apiVersion >= VK_VERSION_1_2) {
            VkPhysicalDeviceVulkan12Properties props12 = pDevice.getVulkan12Properties();
            dump(props12);
            dump(getDriverProperties(pDevice));
            dump(getFloatControlProperties(pDevice));
        }
        if(vk13Enabled() && props.apiVersion >= VK_VERSION_1_3) {
            VkPhysicalDeviceVulkan13Properties props13 = pDevice.getVulkan13Properties();
            props13.dump();
        }
        if(vk14Enabled() && props.apiVersion >= VK_VERSION_1_4) {
            VkPhysicalDeviceVulkan14Properties props14 = pDevice.getVulkan14Properties();
            props14.dump();
        }

        props.limits.dump();
    }

    pDevice.getMemoryProperties().dump();
    pDevice.getExtensions().dump();
    pDevice.getQueueFamilies().dump();

    dumpFormatSupport(pDevice);
}

void dump(VkPhysicalDeviceProperties props) {
    log("VkPhysicalDeviceProperties {");
    log("  VendorID   :    %s", props.vendorID);
    log("  DeviceID   :    %s", props.deviceID);
    log("  Device Name:    %s", props.deviceName.ptr.fromStringz);
    log("  Device Type:    %s", props.deviceType.to!string);

    log("  Driver Version: %s", versionToString(props.driverVersion));
    log("  API Version:    %s", versionToString(props.apiVersion));
    log("}");
}
void dump(VkPhysicalDeviceVulkan11Properties props) {
    log("VkPhysicalDeviceVulkan11Properties {");
    log("  deviceUUID                        : %s", props.deviceUUID);
    log("  driverUUID                        : %s", props.driverUUID);
    log("  deviceLUID                        : %s", props.deviceLUID);
    log("  deviceNodeMask                    : %s", props.deviceNodeMask);
    log("  deviceLUIDValid                   : %s", props.deviceLUIDValid);
    log("  subgroupSize                      : %s", props.subgroupSize);
    log("  subgroupSupportedStages           : %s", toArray!VkShaderStageFlagBits(props.subgroupSupportedStages));
    log("  subgroupSupportedOperations       : %s", toArray!VkSubgroupFeatureFlagBits(props.subgroupSupportedOperations));
    log("  subgroupQuadOperationsInAllStages : %s", props.subgroupQuadOperationsInAllStages);
    log("  pointClippingBehavior             : %s", props.pointClippingBehavior);
    log("  maxMultiviewViewCount             : %s", props.maxMultiviewViewCount);
    log("  maxMultiviewInstanceIndex         : %,3d", props.maxMultiviewInstanceIndex);
    log("  protectedNoFault                  : %s", props.protectedNoFault);
    log("  maxPerSetDescriptors              : %,3d", props.maxPerSetDescriptors);
    log("  maxMemoryAllocationSize           : %,3d", props.maxMemoryAllocationSize);
    log("}");
}

void dump(VkPhysicalDeviceVulkan12Properties props) {
    log("VkPhysicalDeviceVulkan12Properties {");
    log("  driverID                                             : %s", props.driverID);
    log("  driverName                                           : %s", props.driverName.ptr.fromStringz);
    log("  driverInfo                                           : %s", props.driverInfo.ptr.fromStringz);
    log("  conformanceVersion                                   : %s", props.conformanceVersion);
    log("  denormBehaviorIndependence                           : %s", props.denormBehaviorIndependence);
    log("  roundingModeIndependence                             : %s", props.roundingModeIndependence);
    log("  shaderSignedZeroInfNanPreserveFloat16                : %s", props.shaderSignedZeroInfNanPreserveFloat16);
    log("  shaderSignedZeroInfNanPreserveFloat32                : %s", props.shaderSignedZeroInfNanPreserveFloat32);
    log("  shaderSignedZeroInfNanPreserveFloat64                : %s", props.shaderSignedZeroInfNanPreserveFloat64);
    log("  shaderDenormPreserveFloat16                          : %s", props.shaderDenormPreserveFloat16);
    log("  shaderDenormPreserveFloat32                          : %s", props.shaderDenormPreserveFloat32);
    log("  shaderDenormPreserveFloat64                          : %s", props.shaderDenormPreserveFloat64);
    log("  shaderDenormFlushToZeroFloat16                       : %s", props.shaderDenormFlushToZeroFloat16);
    log("  shaderDenormFlushToZeroFloat32                       : %s", props.shaderDenormFlushToZeroFloat32);
    log("  shaderDenormFlushToZeroFloat64                       : %s", props.shaderDenormFlushToZeroFloat64);
    log("  shaderRoundingModeRTEFloat16                         : %s", props.shaderRoundingModeRTEFloat16);
    log("  shaderRoundingModeRTEFloat32                         : %s", props.shaderRoundingModeRTEFloat32);
    log("  shaderRoundingModeRTEFloat64                         : %s", props.shaderRoundingModeRTEFloat64);
    log("  shaderRoundingModeRTZFloat16                         : %s", props.shaderRoundingModeRTZFloat16);
    log("  shaderRoundingModeRTZFloat32                         : %s", props.shaderRoundingModeRTZFloat32);
    log("  shaderRoundingModeRTZFloat64                         : %s", props.shaderRoundingModeRTZFloat64);
    log("  maxUpdateAfterBindDescriptorsInAllPools              : %,3d", props.maxUpdateAfterBindDescriptorsInAllPools);
    log("  shaderUniformBufferArrayNonUniformIndexingNative     : %s", props.shaderUniformBufferArrayNonUniformIndexingNative);
    log("  shaderSampledImageArrayNonUniformIndexingNative      : %s", props.shaderSampledImageArrayNonUniformIndexingNative);
    log("  shaderStorageBufferArrayNonUniformIndexingNative     : %s", props.shaderStorageBufferArrayNonUniformIndexingNative);
    log("  shaderStorageImageArrayNonUniformIndexingNative      : %s", props.shaderStorageImageArrayNonUniformIndexingNative);
    log("  shaderInputAttachmentArrayNonUniformIndexingNative   : %s", props.shaderInputAttachmentArrayNonUniformIndexingNative);
    log("  robustBufferAccessUpdateAfterBind                    : %s", props.robustBufferAccessUpdateAfterBind);
    log("  quadDivergentImplicitLod                             : %s", props.quadDivergentImplicitLod);
    log("  maxPerStageDescriptorUpdateAfterBindSamplers         : %,3d", props.maxPerStageDescriptorUpdateAfterBindSamplers);
    log("  maxPerStageDescriptorUpdateAfterBindUniformBuffers   : %,3d", props.maxPerStageDescriptorUpdateAfterBindUniformBuffers);
    log("  maxPerStageDescriptorUpdateAfterBindStorageBuffers   : %,3d", props.maxPerStageDescriptorUpdateAfterBindStorageBuffers);
    log("  maxPerStageDescriptorUpdateAfterBindSampledImages    : %,3d", props.maxPerStageDescriptorUpdateAfterBindSampledImages);
    log("  maxPerStageDescriptorUpdateAfterBindStorageImages    : %,3d", props.maxPerStageDescriptorUpdateAfterBindStorageImages);
    log("  maxPerStageDescriptorUpdateAfterBindInputAttachments : %,3d", props.maxPerStageDescriptorUpdateAfterBindInputAttachments);
    log("  maxPerStageUpdateAfterBindResources                  : %,3d", props.maxPerStageUpdateAfterBindResources);
    log("  maxDescriptorSetUpdateAfterBindSamplers              : %,3d", props.maxDescriptorSetUpdateAfterBindSamplers);
    log("  maxDescriptorSetUpdateAfterBindUniformBuffers        : %,3d", props.maxDescriptorSetUpdateAfterBindUniformBuffers);
    log("  maxDescriptorSetUpdateAfterBindUniformBuffersDynamic : %,3d", props.maxDescriptorSetUpdateAfterBindUniformBuffersDynamic);
    log("  maxDescriptorSetUpdateAfterBindStorageBuffers        : %,3d", props.maxDescriptorSetUpdateAfterBindStorageBuffers);
    log("  maxDescriptorSetUpdateAfterBindStorageBuffersDynamic : %,3d", props.maxDescriptorSetUpdateAfterBindStorageBuffersDynamic);
    log("  maxDescriptorSetUpdateAfterBindSampledImages         : %,3d", props.maxDescriptorSetUpdateAfterBindSampledImages);
    log("  maxDescriptorSetUpdateAfterBindStorageImages         : %,3d", props.maxDescriptorSetUpdateAfterBindStorageImages);
    log("  maxDescriptorSetUpdateAfterBindInputAttachments      : %,3d", props.maxDescriptorSetUpdateAfterBindInputAttachments);
    log("  supportedDepthResolveModes                           : %s", toArray!VkResolveModeFlagBits(props.supportedDepthResolveModes));
    log("  supportedStencilResolveModes                         : %s", toArray!VkResolveModeFlagBits(props.supportedStencilResolveModes));
    log("  independentResolveNone                               : %s", props.independentResolveNone);
    log("  independentResolve                                   : %s", props.independentResolve);
    log("  filterMinmaxSingleComponentFormats                   : %s", props.filterMinmaxSingleComponentFormats);
    log("  filterMinmaxImageComponentMapping                    : %s", props.filterMinmaxImageComponentMapping);
    log("  maxTimelineSemaphoreValueDifference                  : %,3d", props.maxTimelineSemaphoreValueDifference);
    log("  framebufferIntegerColorSampleCounts                  : %s", toArray!VkSampleCountFlagBits(props.framebufferIntegerColorSampleCounts));
    log("}");
}
void dump(VkPhysicalDeviceVulkan13Properties props) {
    log("VkPhysicalDeviceVulkan13Properties {");
    log("  minSubgroupSize ................................................................ %,3d", props.minSubgroupSize);
    log("  maxSubgroupSize ................................................................ %,3d", props.maxSubgroupSize);
    log("  maxComputeWorkgroupSubgroups ................................................... %,3d", props.maxComputeWorkgroupSubgroups);
    log("  requiredSubgroupSizeStages ..................................................... %s", toArray!VkShaderStageFlagBits(props.requiredSubgroupSizeStages));
    log("  maxInlineUniformBlockSize ...................................................... %,3d", props.maxInlineUniformBlockSize);
    log("  maxPerStageDescriptorInlineUniformBlocks ....................................... %,3d", props.maxPerStageDescriptorInlineUniformBlocks);
    log("  maxPerStageDescriptorUpdateAfterBindInlineUniformBlocks ........................ %,3d", props.maxPerStageDescriptorUpdateAfterBindInlineUniformBlocks);
    log("  maxDescriptorSetInlineUniformBlocks ............................................ %,3d", props.maxDescriptorSetInlineUniformBlocks);
    log("  maxDescriptorSetUpdateAfterBindInlineUniformBlocks ............................. %,3d", props.maxDescriptorSetUpdateAfterBindInlineUniformBlocks);
    log("  maxInlineUniformTotalSize ...................................................... %,3d", props.maxInlineUniformTotalSize);
    log("  integerDotProduct8BitUnsignedAccelerated ....................................... %s", props.integerDotProduct8BitUnsignedAccelerated);
    log("  integerDotProduct8BitSignedAccelerated ......................................... %s", props.integerDotProduct8BitSignedAccelerated);
    log("  integerDotProduct8BitMixedSignednessAccelerated ................................ %s", props.integerDotProduct8BitMixedSignednessAccelerated);
    log("  integerDotProduct4x8BitPackedUnsignedAccelerated ............................... %s", props.integerDotProduct4x8BitPackedUnsignedAccelerated);
    log("  integerDotProduct4x8BitPackedSignedAccelerated ................................. %s", props.integerDotProduct4x8BitPackedSignedAccelerated);
    log("  integerDotProduct4x8BitPackedMixedSignednessAccelerated ........................ %s", props.integerDotProduct4x8BitPackedMixedSignednessAccelerated);
    log("  integerDotProduct16BitUnsignedAccelerated ...................................... %s", props.integerDotProduct16BitUnsignedAccelerated);
    log("  integerDotProduct16BitSignedAccelerated ........................................ %s", props.integerDotProduct16BitSignedAccelerated);
    log("  integerDotProduct16BitMixedSignednessAccelerated ............................... %s", props.integerDotProduct16BitMixedSignednessAccelerated);
    log("  integerDotProduct32BitUnsignedAccelerated ...................................... %s", props.integerDotProduct32BitUnsignedAccelerated);
    log("  integerDotProduct32BitSignedAccelerated ........................................ %s", props.integerDotProduct32BitSignedAccelerated);
    log("  integerDotProduct32BitMixedSignednessAccelerated ............................... %s", props.integerDotProduct32BitMixedSignednessAccelerated);
    log("  integerDotProduct64BitUnsignedAccelerated ...................................... %s", props.integerDotProduct64BitUnsignedAccelerated);
    log("  integerDotProduct64BitSignedAccelerated ........................................ %s", props.integerDotProduct64BitSignedAccelerated);
    log("  integerDotProduct64BitMixedSignednessAccelerated ............................... %s", props.integerDotProduct64BitMixedSignednessAccelerated);
    log("  integerDotProductAccumulatingSaturating8BitUnsignedAccelerated ................. %s", props.integerDotProductAccumulatingSaturating8BitUnsignedAccelerated);
    log("  integerDotProductAccumulatingSaturating8BitSignedAccelerated ................... %s", props.integerDotProductAccumulatingSaturating8BitSignedAccelerated);
    log("  integerDotProductAccumulatingSaturating8BitMixedSignednessAccelerated .......... %s", props.integerDotProductAccumulatingSaturating8BitMixedSignednessAccelerated);
    log("  integerDotProductAccumulatingSaturating4x8BitPackedUnsignedAccelerated ......... %s", props.integerDotProductAccumulatingSaturating4x8BitPackedUnsignedAccelerated);
    log("  integerDotProductAccumulatingSaturating4x8BitPackedSignedAccelerated ........... %s", props.integerDotProductAccumulatingSaturating4x8BitPackedSignedAccelerated);
    log("  integerDotProductAccumulatingSaturating4x8BitPackedMixedSignednessAccelerated .. %s", props.integerDotProductAccumulatingSaturating4x8BitPackedMixedSignednessAccelerated);
    log("  integerDotProductAccumulatingSaturating16BitUnsignedAccelerated ................ %s", props.integerDotProductAccumulatingSaturating16BitUnsignedAccelerated);
    log("  integerDotProductAccumulatingSaturating16BitSignedAccelerated .................. %s", props.integerDotProductAccumulatingSaturating16BitSignedAccelerated);
    log("  integerDotProductAccumulatingSaturating16BitMixedSignednessAccelerated ......... %s", props.integerDotProductAccumulatingSaturating16BitMixedSignednessAccelerated);
    log("  integerDotProductAccumulatingSaturating32BitUnsignedAccelerated ................ %s", props.integerDotProductAccumulatingSaturating32BitUnsignedAccelerated);
    log("  integerDotProductAccumulatingSaturating32BitSignedAccelerated .................. %s", props.integerDotProductAccumulatingSaturating32BitSignedAccelerated);
    log("  integerDotProductAccumulatingSaturating32BitMixedSignednessAccelerated ......... %s", props.integerDotProductAccumulatingSaturating32BitMixedSignednessAccelerated);
    log("  integerDotProductAccumulatingSaturating64BitUnsignedAccelerated ................ %s", props.integerDotProductAccumulatingSaturating64BitUnsignedAccelerated);
    log("  integerDotProductAccumulatingSaturating64BitSignedAccelerated .................. %s", props.integerDotProductAccumulatingSaturating64BitSignedAccelerated);
    log("  integerDotProductAccumulatingSaturating64BitMixedSignednessAccelerated ......... %s", props.integerDotProductAccumulatingSaturating64BitMixedSignednessAccelerated);
    log("  storageTexelBufferOffsetAlignmentBytes ......................................... %,3d", props.storageTexelBufferOffsetAlignmentBytes);
    log("  storageTexelBufferOffsetSingleTexelAlignment ................................... %s", props.storageTexelBufferOffsetSingleTexelAlignment);
    log("  uniformTexelBufferOffsetAlignmentBytes ......................................... %,3d", props.uniformTexelBufferOffsetAlignmentBytes);
    log("  uniformTexelBufferOffsetSingleTexelAlignment ................................... %s", props.uniformTexelBufferOffsetSingleTexelAlignment);
    log("  maxBufferSize .................................................................. %,3d", props.maxBufferSize);
    log("}");
}
void dump(VkPhysicalDeviceVulkan14Properties props) {
    log("VkPhysicalDeviceVulkan14Properties {");
    log("  lineSubPixelPrecisionBits ......................................... %,3d", props.lineSubPixelPrecisionBits);
    log("  maxVertexAttribDivisor ............................................ %,3d", props.maxVertexAttribDivisor);
    log("  supportsNonZeroFirstInstance ...................................... %s", props.supportsNonZeroFirstInstance);
    log("  maxPushDescriptors ............................................... %,3d", props.maxPushDescriptors);
    log("  dynamicRenderingLocalReadDepthStencilAttachments ................. %s", props.dynamicRenderingLocalReadDepthStencilAttachments);
    log("  dynamicRenderingLocalReadMultisampledAttachments ................ %s", props.dynamicRenderingLocalReadMultisampledAttachments);
    log("  earlyFragmentMultisampleCoverageAfterSampleCounting .............. %s", props.earlyFragmentMultisampleCoverageAfterSampleCounting);
    log("  earlyFragmentSampleMaskTestBeforeSampleCounting ................. %s", props.earlyFragmentSampleMaskTestBeforeSampleCounting);
    log("  depthStencilSwizzleOneSupport .................................... %s", props.depthStencilSwizzleOneSupport);
    log("  polygonModePointSize ............................................. %s", props.polygonModePointSize);
    log("  nonStrictSinglePixelWideLinesUseParallelogram ................... %s", props.nonStrictSinglePixelWideLinesUseParallelogram);
    log("  nonStrictWideLinesUseParallelogram .............................. %s", props.nonStrictWideLinesUseParallelogram);
    log("  blockTexelViewCompatibleMultipleLayers .......................... %s", props.blockTexelViewCompatibleMultipleLayers);
    log("  maxCombinedImageSamplerDescriptorCount .......................... %,3d", props.maxCombinedImageSamplerDescriptorCount);
    log("  fragmentShadingRateClampCombinerInputs .......................... %s", props.fragmentShadingRateClampCombinerInputs);
    log("  defaultRobustnessStorageBuffers .................................. %s", props.defaultRobustnessStorageBuffers);
    log("  defaultRobustnessUniformBuffers .................................. %s", props.defaultRobustnessUniformBuffers);
    log("  defaultRobustnessVertexInputs .................................... %s", props.defaultRobustnessVertexInputs);
    log("  defaultRobustnessImages ......................................... %s", props.defaultRobustnessImages);
    log("  copySrcLayoutCount .............................................. %,3d", props.copySrcLayoutCount);
    log("  copyDstLayoutCount .............................................. %,3d", props.copyDstLayoutCount);
    log("  optimalTilingLayoutUUID ......................................... %s", props.optimalTilingLayoutUUID);
    log("  identicalMemoryTypeRequirements .................................. %s", props.identicalMemoryTypeRequirements);

    foreach(i; 0..props.copySrcLayoutCount) {
        log("    - copySrcLayouts[%s] : %s", i, props.pCopySrcLayouts[i]);
    }
    foreach(i; 0..props.copyDstLayoutCount) {
        log("    - copyDstLayouts[%s] : %s", i, props.pCopyDstLayouts[i]);
    }
}
void dump(VkPhysicalDeviceDriverProperties props) {
    log("VkPhysicalDeviceDriverProperties {");
    log("  driverID ................................................. %s", props.driverID);
    log("  driverName ............................................... %s", props.driverName.ptr.fromStringz);
    log("  driverInfo ............................................... %s", props.driverInfo.ptr.fromStringz);
    log("  conformanceVersion ....................................... %s", props.conformanceVersion);
    log("}");
}

void dump(VkPhysicalDeviceRayTracingPipelineFeaturesKHR f) {
    log("VkPhysicalDeviceRayTracingPipelineFeaturesKHR {");
    log("   rayTracingPipeline                                    : %s", f.rayTracingPipeline);
	log("   rayTracingPipelineShaderGroupHandleCaptureReplay      : %s", f.rayTracingPipelineShaderGroupHandleCaptureReplay);
	log("   rayTracingPipelineShaderGroupHandleCaptureReplayMixed : %s", f.rayTracingPipelineShaderGroupHandleCaptureReplayMixed);
	log("   rayTracingPipelineTraceRaysIndirect                   : %s", f.rayTracingPipelineTraceRaysIndirect);
	log("   rayTraversalPrimitiveCulling                          : %s", f.rayTraversalPrimitiveCulling);
    log("}");
}

void dump(VkPhysicalDeviceLimits limits) {
	log("VkPhysicalDeviceLimits {");
	log("  maxImageDimension1D ............... %s", limits.maxImageDimension1D);
	log("  maxImageDimension2D ............... %s", limits.maxImageDimension2D);
	log("  maxImageDimension3D ............... %s", limits.maxImageDimension3D);
	log("  maxComputeSharedMemorySize ........ %s", limits.maxComputeSharedMemorySize);
	log("  maxComputeWorkGroupCount .......... [%s,%s,%s]", limits.maxComputeWorkGroupCount[0], limits.maxComputeWorkGroupCount[1], limits.maxComputeWorkGroupCount[2]);
    log("  maxComputeWorkGroupSize ........... [%s,%s,%s]", limits.maxComputeWorkGroupSize[0], limits.maxComputeWorkGroupSize[1], limits.maxComputeWorkGroupSize[2]);
    log("  maxComputeWorkGroupInvocations .... %s", limits.maxComputeWorkGroupInvocations);
    log("  maxUniformBufferRange ............. %s", limits.maxUniformBufferRange);
    log("  maxStorageBufferRange ............. %s", limits.maxStorageBufferRange);
    log("  timestampComputeAndGraphics ....... %s", 1==limits.timestampComputeAndGraphics);
    log("  timestampPeriod ................... %s", limits.timestampPeriod);
    log("  discreteQueuePriorities ........... %s", limits.discreteQueuePriorities);
    log("  maxPushConstantsSize .............. %s", limits.maxPushConstantsSize);
    log("  maxSamplerAllocationCount ......... %s", limits.maxSamplerAllocationCount);
    log("  bufferImageGranularity ............ %s", limits.bufferImageGranularity);
    log("  maxBoundDescriptorSets ............ %s", limits.maxBoundDescriptorSets);
    log("  minUniformBufferOffsetAlignment ... %s", limits.minUniformBufferOffsetAlignment);
    log("  minStorageBufferOffsetAlignment ... %s", limits.minStorageBufferOffsetAlignment);
    log("  minMemoryMapAlignment ............. %s", limits.minMemoryMapAlignment);
    log("  maxMemoryAllocationCount .......... %s", limits.maxMemoryAllocationCount);
    log("  maxDescriptorSetSamplers .......... %s", limits.maxDescriptorSetSamplers);
    log("  maxDescriptorSetStorageBuffers .... %s", limits.maxDescriptorSetStorageBuffers);
    log("  maxSamplerAnisotropy .............. %s", limits.maxSamplerAnisotropy);
    log("  maxViewports ...................... %s", limits.maxViewports);
    log("  maxViewportDimensions [x,y] ....... %s", limits.maxViewportDimensions);
    log("  maxFramebufferWidth ............... %s", limits.maxFramebufferWidth);
    log("  maxFramebufferHeight .............. %s", limits.maxFramebufferHeight);
    log("  optimalBufferCopyOffsetAlignment .. %s", limits.optimalBufferCopyOffsetAlignment);
    log("  nonCoherentAtomSize ............... %s", limits.nonCoherentAtomSize);
    log("}");
}
void dump(VkPhysicalDeviceMemoryProperties p) {
	log("VkPhysicalDeviceMemoryProperties {");
    log("  Types:");
	for(auto i=0; i<p.memoryTypeCount; i++) {
		auto mt = p.memoryTypes[i];
		log("    [%2s]: heap:%s (flags=0x%x) isLocal=%s hostVisible=%s hostCoherent=%s hostCached=%s lazyAlloc=%s protected=%s",
			i,
            mt.heapIndex,
            mt.propertyFlags,
			cast(bool)(mt.propertyFlags&VkMemoryPropertyFlagBits.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
			cast(bool)(mt.propertyFlags&VkMemoryPropertyFlagBits.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
			cast(bool)(mt.propertyFlags&VkMemoryPropertyFlagBits.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
			cast(bool)(mt.propertyFlags&VkMemoryPropertyFlagBits.VK_MEMORY_PROPERTY_HOST_CACHED_BIT),
			cast(bool)(mt.propertyFlags&VkMemoryPropertyFlagBits.VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT),
            cast(bool)(mt.propertyFlags&VK_MEMORY_PROPERTY_PROTECTED_BIT)
		);
	}
    log("  Heaps:");
	for(auto i=0; i<p.memoryHeapCount; i++) {
		auto mh = p.memoryHeaps[i];
		log("    [%s]: size: %s islocal=%s",
		    i,
			mh.size.sizeToString(),
			cast(bool)(mh.flags & VkMemoryHeapFlagBits.VK_MEMORY_HEAP_DEVICE_LOCAL_BIT)
		);
	}
    log("}");
}
void dump(VkQueueFamilyProperties[] queueFamilies) {
	log("Number of Queue families: %s", queueFamilies.length);

    foreach(i, qf; queueFamilies) {
		log("  [%s] QueueCount:%s flags:%s timestampValidBits:%s minImageTransferGranularity:%s",
		    i, qf.queueCount, toString!VkQueueFlagBits(qf.queueFlags, "VK_QUEUE_", "_BIT"),
		    qf.timestampValidBits, qf.minImageTransferGranularity);
	}
}
void dump(VkExtensionProperties[] extensions) {
	log("Device extensions: %s", extensions.length);
	foreach(i, e; extensions) {
		log("  [%s] name: '%s' specVersion:%s",
		    i, e.extensionName.ptr.fromStringz, e.specVersion);
	}
}
void dump(VkSurfaceCapabilitiesKHR capabilities) {
    log("VkSurfaceCapabilitiesKHR:");
    log("   minImageCount  = %s", capabilities.minImageCount);
    log("   maxImageCount  = %s", capabilities.maxImageCount);
    log("   currentExtent  = %s", capabilities.currentExtent);
    log("   minImageExtent = %s", capabilities.minImageExtent);
    log("   maxImageExtent = %s", capabilities.maxImageExtent);
    log("   maxImageArrayLayers = %s", capabilities.maxImageArrayLayers);
    log("   supportedTransforms = %s", toString!VkSurfaceTransformFlagBitsKHR(capabilities.supportedTransforms, "VK_SURFACE_TRANSFORM_", "_BIT_KHR"));
    log("   currentTransform = %s", toString!VkSurfaceTransformFlagBitsKHR(capabilities.currentTransform, "VK_SURFACE_TRANSFORM_", "_BIT_KHR"));
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

void dump(VkPhysicalDeviceFloatControlsProperties props) {
    auto len = getAllProperties!VkPhysicalDeviceFloatControlsProperties()
        .map!(it=>it.length)
        .maxElement() + 2;

    void logProperty(string name)() {
        log("  %s %s", name.leftJustify(len), __traits(getMember, props, name));
    }

    log("VkPhysicalDeviceFloatControlsProperties {");
    logProperty!"denormBehaviorIndependence";
    logProperty!"roundingModeIndependence";
    logProperty!"shaderSignedZeroInfNanPreserveFloat16";
    logProperty!"shaderSignedZeroInfNanPreserveFloat32";
    logProperty!"shaderSignedZeroInfNanPreserveFloat64";
    logProperty!"shaderDenormPreserveFloat16";
    logProperty!"shaderDenormPreserveFloat32";
    logProperty!"shaderDenormPreserveFloat64";
    logProperty!"shaderDenormFlushToZeroFloat16";
    logProperty!"shaderDenormFlushToZeroFloat32";
    logProperty!"shaderDenormFlushToZeroFloat64";
    logProperty!"shaderRoundingModeRTEFloat16";
    logProperty!"shaderRoundingModeRTEFloat32";
    logProperty!"shaderRoundingModeRTEFloat64";
    logProperty!"shaderRoundingModeRTZFloat16";
    logProperty!"shaderRoundingModeRTZFloat32";
    logProperty!"shaderRoundingModeRTZFloat64";
    log("}");
}
void dumpFormatSupport(VkPhysicalDevice pDevice) {
    import std.string : leftJustify;
    
    void _dumpFormatSupport(string label, VkFormat[] formats) {
        log("%s image format support:", label);
        foreach(f; formats) {
            VkFormatProperties p = pDevice.getFormatProperties(f);

            if(vk13Enabled()) {
                VkFormatProperties3 props3 = pDevice.getFormatProperties3(f);
                log("props3 = %s", props3);

                // todo - turn these flags into an enum
            }

            if(pDevice.isFormatSupported(f)) {
                log("  '%s' : yes", f);
                log("    - optTilingFeatures    : %s", toString!VkFormatFeatureFlagBits(p.optimalTilingFeatures, "VK_FORMAT_FEATURE_", "_BIT"));
                log("    - linearTilingFeatures : %s", toString!VkFormatFeatureFlagBits(p.linearTilingFeatures, "VK_FORMAT_FEATURE_", "_BIT"));
                log("    - bufferFeatures       : %s", toString!VkFormatFeatureFlagBits(p.bufferFeatures, "VK_FORMAT_FEATURE_", "_BIT"));
            } else {
                log("  '%s' : no", f);
            }
        }
    }

    with(VkFormat) {
        _dumpFormatSupport("Standard", [
            VK_FORMAT_A8_UNORM,
            VK_FORMAT_R8_UNORM,
            VK_FORMAT_R16_UINT,
            VK_FORMAT_R16_SINT,
            VK_FORMAT_R32_UINT,
            VK_FORMAT_R32_SINT,
            VK_FORMAT_R64_UINT,
            VK_FORMAT_R64_SINT,
            VK_FORMAT_R8G8_UNORM,
	        VK_FORMAT_R8G8_SNORM,
            VK_FORMAT_R8G8B8_UNORM,
            VK_FORMAT_B8G8R8_UNORM,
            VK_FORMAT_R8G8B8A8_UNORM,
            VK_FORMAT_B8G8R8A8_UNORM
            ]);
        _dumpFormatSupport("HDR", [
            VK_FORMAT_R16_SFLOAT,
            VK_FORMAT_R32_SFLOAT,
            VK_FORMAT_R64_SFLOAT,
            VK_FORMAT_R16G16_SFLOAT,
            VK_FORMAT_R32G32_SFLOAT,
            VK_FORMAT_R64G64_SFLOAT,
            VK_FORMAT_R16G16B16_SFLOAT,
            VK_FORMAT_R32G32B32_SFLOAT,
            VK_FORMAT_R64G64B64_SFLOAT,
            VK_FORMAT_R16G16B16A16_SFLOAT,
            VK_FORMAT_R32G32B32A32_SFLOAT,
            VK_FORMAT_R64G64B64A64_SFLOAT
        ]);    
        _dumpFormatSupport("Compression", [
            VK_FORMAT_BC1_RGB_UNORM_BLOCK,
            VK_FORMAT_BC1_RGBA_UNORM_BLOCK,
            VK_FORMAT_BC2_UNORM_BLOCK,
            VK_FORMAT_BC3_UNORM_BLOCK,
            VK_FORMAT_BC4_UNORM_BLOCK,
            VK_FORMAT_BC5_UNORM_BLOCK,
            VK_FORMAT_BC6H_UFLOAT_BLOCK,
            VK_FORMAT_BC6H_SFLOAT_BLOCK,
            VK_FORMAT_BC7_UNORM_BLOCK,
            VK_FORMAT_BC7_SRGB_BLOCK,
            VK_FORMAT_ETC2_R8G8B8_UNORM_BLOCK,
            VK_FORMAT_ETC2_R8G8B8A1_UNORM_BLOCK,
            VK_FORMAT_ETC2_R8G8B8A8_UNORM_BLOCK,
            VK_FORMAT_EAC_R11_UNORM_BLOCK,
            VK_FORMAT_EAC_R11_SNORM_BLOCK,
            VK_FORMAT_ASTC_4x4_UNORM_BLOCK
            ]);

        _dumpFormatSupport("Depth/stencil", [
            // depth stencil formats
            VK_FORMAT_D16_UNORM,
            VK_FORMAT_D32_SFLOAT,
            VK_FORMAT_S8_UINT,
            VK_FORMAT_D16_UNORM_S8_UINT,
            VK_FORMAT_D24_UNORM_S8_UINT,
            VK_FORMAT_D32_SFLOAT_S8_UINT
        ]);
    }
}
void dumpStructure(T)(T f, string prefix = null) {
    string prefixStr = prefix ? "%s = ".format(prefix) : "";
    log("%s%s {", prefixStr, typeof(f).stringof);

    auto maxPropertyLength = getAllProperties!T().map!(it=>it.length).maxElement() + 2;
    string s;

    import std.traits : fullyQualifiedName;

    foreach(name; __traits(allMembers, typeof(f))) {
        alias type = typeof(__traits(getMember, f, name));
        auto typeString = "%s".format(typeid(type).stringof);
        auto value = __traits(getMember, f, name);

        if(name == "sType" || name == "pNext") continue;

        s = name ~ " " ~ (".".repeat(maxPropertyLength-name.length));

        static if(isInteger!type) {
            log("  %s %,3d", s, value);
        } else static if(isEnum!type) {
            if(bitCount(value) <= 1) {
                log("  %s %s", s, value);
            } else {
                log("  %s %s", s, toArray!type(value)); 
            }
        } else {
            log("  %s %s", s, value);
        }
    }
    log("}");
}
