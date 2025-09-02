module vulkan.misc.dump;

import vulkan.all;
import std.string : leftJustify;

void dump(VkPhysicalDevice pDevice) {
    {
        VkPhysicalDeviceProperties props = pDevice.getProperties();
        props.dump();

        if(vk11Enabled() && props.apiVersion >= VK_API_VERSION_1_1) {
            VkPhysicalDeviceVulkan11Properties props11 = pDevice.getVulkan11Properties();
            props11.dump();
        }
        if(vk12Enabled() && props.apiVersion >= VK_API_VERSION_1_2) {
            VkPhysicalDeviceVulkan12Properties props12 = pDevice.getVulkan12Properties();
            dump(props12);
            dump(getDriverProperties(pDevice));
            dump(getFloatControlProperties(pDevice));
        }
        if(vk13Enabled() && props.apiVersion >= VK_API_VERSION_1_3) {
            VkPhysicalDeviceVulkan13Properties props13 = pDevice.getVulkan13Properties();
            props13.dump();
        }
        if(vk14Enabled() && props.apiVersion >= VK_API_VERSION_1_4) {
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
    verbose(__FILE__, "VkPhysicalDeviceProperties {");
    verbose(__FILE__, "  VendorID   :    %s", props.vendorID);
    verbose(__FILE__, "  DeviceID   :    %s", props.deviceID);
    verbose(__FILE__, "  Device Name:    %s", props.deviceName.ptr.fromStringz);
    verbose(__FILE__, "  Device Type:    %s", props.deviceType.to!string);

    verbose(__FILE__, "  Driver Version: %s", versionToString(props.driverVersion));
    verbose(__FILE__, "  API Version:    %s", versionToString(props.apiVersion));
    verbose(__FILE__, "}");
}
void dump(VkPhysicalDeviceVulkan11Properties props) {
    verbose(__FILE__, "VkPhysicalDeviceVulkan11Properties {");
    verbose(__FILE__, "  deviceUUID                        : %s", props.deviceUUID);
    verbose(__FILE__, "  driverUUID                        : %s", props.driverUUID);
    verbose(__FILE__, "  deviceLUID                        : %s", props.deviceLUID);
    verbose(__FILE__, "  deviceNodeMask                    : %s", props.deviceNodeMask);
    verbose(__FILE__, "  deviceLUIDValid                   : %s", props.deviceLUIDValid);
    verbose(__FILE__, "  subgroupSize                      : %s", props.subgroupSize);
    verbose(__FILE__, "  subgroupSupportedStages           : %s", toArray!VkShaderStageFlagBits(props.subgroupSupportedStages));
    verbose(__FILE__, "  subgroupSupportedOperations       : %s", toArray!VkSubgroupFeatureFlagBits(props.subgroupSupportedOperations));
    verbose(__FILE__, "  subgroupQuadOperationsInAllStages : %s", props.subgroupQuadOperationsInAllStages);
    verbose(__FILE__, "  pointClippingBehavior             : %s", props.pointClippingBehavior);
    verbose(__FILE__, "  maxMultiviewViewCount             : %s", props.maxMultiviewViewCount);
    verbose(__FILE__, "  maxMultiviewInstanceIndex         : %,3d", props.maxMultiviewInstanceIndex);
    verbose(__FILE__, "  protectedNoFault                  : %s", props.protectedNoFault);
    verbose(__FILE__, "  maxPerSetDescriptors              : %,3d", props.maxPerSetDescriptors);
    verbose(__FILE__, "  maxMemoryAllocationSize           : %,3d", props.maxMemoryAllocationSize);
    verbose(__FILE__, "}");
}

void dump(VkPhysicalDeviceVulkan12Properties props) {
    verbose(__FILE__, "VkPhysicalDeviceVulkan12Properties {");
    verbose(__FILE__, "  driverID                                             : %s", props.driverID);
    verbose(__FILE__, "  driverName                                           : %s", props.driverName.ptr.fromStringz);
    verbose(__FILE__, "  driverInfo                                           : %s", props.driverInfo.ptr.fromStringz);
    verbose(__FILE__, "  conformanceVersion                                   : %s", props.conformanceVersion);
    verbose(__FILE__, "  denormBehaviorIndependence                           : %s", props.denormBehaviorIndependence);
    verbose(__FILE__, "  roundingModeIndependence                             : %s", props.roundingModeIndependence);
    verbose(__FILE__, "  shaderSignedZeroInfNanPreserveFloat16                : %s", props.shaderSignedZeroInfNanPreserveFloat16);
    verbose(__FILE__, "  shaderSignedZeroInfNanPreserveFloat32                : %s", props.shaderSignedZeroInfNanPreserveFloat32);
    verbose(__FILE__, "  shaderSignedZeroInfNanPreserveFloat64                : %s", props.shaderSignedZeroInfNanPreserveFloat64);
    verbose(__FILE__, "  shaderDenormPreserveFloat16                          : %s", props.shaderDenormPreserveFloat16);
    verbose(__FILE__, "  shaderDenormPreserveFloat32                          : %s", props.shaderDenormPreserveFloat32);
    verbose(__FILE__, "  shaderDenormPreserveFloat64                          : %s", props.shaderDenormPreserveFloat64);
    verbose(__FILE__, "  shaderDenormFlushToZeroFloat16                       : %s", props.shaderDenormFlushToZeroFloat16);
    verbose(__FILE__, "  shaderDenormFlushToZeroFloat32                       : %s", props.shaderDenormFlushToZeroFloat32);
    verbose(__FILE__, "  shaderDenormFlushToZeroFloat64                       : %s", props.shaderDenormFlushToZeroFloat64);
    verbose(__FILE__, "  shaderRoundingModeRTEFloat16                         : %s", props.shaderRoundingModeRTEFloat16);
    verbose(__FILE__, "  shaderRoundingModeRTEFloat32                         : %s", props.shaderRoundingModeRTEFloat32);
    verbose(__FILE__, "  shaderRoundingModeRTEFloat64                         : %s", props.shaderRoundingModeRTEFloat64);
    verbose(__FILE__, "  shaderRoundingModeRTZFloat16                         : %s", props.shaderRoundingModeRTZFloat16);
    verbose(__FILE__, "  shaderRoundingModeRTZFloat32                         : %s", props.shaderRoundingModeRTZFloat32);
    verbose(__FILE__, "  shaderRoundingModeRTZFloat64                         : %s", props.shaderRoundingModeRTZFloat64);
    verbose(__FILE__, "  maxUpdateAfterBindDescriptorsInAllPools              : %,3d", props.maxUpdateAfterBindDescriptorsInAllPools);
    verbose(__FILE__, "  shaderUniformBufferArrayNonUniformIndexingNative     : %s", props.shaderUniformBufferArrayNonUniformIndexingNative);
    verbose(__FILE__, "  shaderSampledImageArrayNonUniformIndexingNative      : %s", props.shaderSampledImageArrayNonUniformIndexingNative);
    verbose(__FILE__, "  shaderStorageBufferArrayNonUniformIndexingNative     : %s", props.shaderStorageBufferArrayNonUniformIndexingNative);
    verbose(__FILE__, "  shaderStorageImageArrayNonUniformIndexingNative      : %s", props.shaderStorageImageArrayNonUniformIndexingNative);
    verbose(__FILE__, "  shaderInputAttachmentArrayNonUniformIndexingNative   : %s", props.shaderInputAttachmentArrayNonUniformIndexingNative);
    verbose(__FILE__, "  robustBufferAccessUpdateAfterBind                    : %s", props.robustBufferAccessUpdateAfterBind);
    verbose(__FILE__, "  quadDivergentImplicitLod                             : %s", props.quadDivergentImplicitLod);
    verbose(__FILE__, "  maxPerStageDescriptorUpdateAfterBindSamplers         : %,3d", props.maxPerStageDescriptorUpdateAfterBindSamplers);
    verbose(__FILE__, "  maxPerStageDescriptorUpdateAfterBindUniformBuffers   : %,3d", props.maxPerStageDescriptorUpdateAfterBindUniformBuffers);
    verbose(__FILE__, "  maxPerStageDescriptorUpdateAfterBindStorageBuffers   : %,3d", props.maxPerStageDescriptorUpdateAfterBindStorageBuffers);
    verbose(__FILE__, "  maxPerStageDescriptorUpdateAfterBindSampledImages    : %,3d", props.maxPerStageDescriptorUpdateAfterBindSampledImages);
    verbose(__FILE__, "  maxPerStageDescriptorUpdateAfterBindStorageImages    : %,3d", props.maxPerStageDescriptorUpdateAfterBindStorageImages);
    verbose(__FILE__, "  maxPerStageDescriptorUpdateAfterBindInputAttachments : %,3d", props.maxPerStageDescriptorUpdateAfterBindInputAttachments);
    verbose(__FILE__, "  maxPerStageUpdateAfterBindResources                  : %,3d", props.maxPerStageUpdateAfterBindResources);
    verbose(__FILE__, "  maxDescriptorSetUpdateAfterBindSamplers              : %,3d", props.maxDescriptorSetUpdateAfterBindSamplers);
    verbose(__FILE__, "  maxDescriptorSetUpdateAfterBindUniformBuffers        : %,3d", props.maxDescriptorSetUpdateAfterBindUniformBuffers);
    verbose(__FILE__, "  maxDescriptorSetUpdateAfterBindUniformBuffersDynamic : %,3d", props.maxDescriptorSetUpdateAfterBindUniformBuffersDynamic);
    verbose(__FILE__, "  maxDescriptorSetUpdateAfterBindStorageBuffers        : %,3d", props.maxDescriptorSetUpdateAfterBindStorageBuffers);
    verbose(__FILE__, "  maxDescriptorSetUpdateAfterBindStorageBuffersDynamic : %,3d", props.maxDescriptorSetUpdateAfterBindStorageBuffersDynamic);
    verbose(__FILE__, "  maxDescriptorSetUpdateAfterBindSampledImages         : %,3d", props.maxDescriptorSetUpdateAfterBindSampledImages);
    verbose(__FILE__, "  maxDescriptorSetUpdateAfterBindStorageImages         : %,3d", props.maxDescriptorSetUpdateAfterBindStorageImages);
    verbose(__FILE__, "  maxDescriptorSetUpdateAfterBindInputAttachments      : %,3d", props.maxDescriptorSetUpdateAfterBindInputAttachments);
    verbose(__FILE__, "  supportedDepthResolveModes                           : %s", toArray!VkResolveModeFlagBits(props.supportedDepthResolveModes));
    verbose(__FILE__, "  supportedStencilResolveModes                         : %s", toArray!VkResolveModeFlagBits(props.supportedStencilResolveModes));
    verbose(__FILE__, "  independentResolveNone                               : %s", props.independentResolveNone);
    verbose(__FILE__, "  independentResolve                                   : %s", props.independentResolve);
    verbose(__FILE__, "  filterMinmaxSingleComponentFormats                   : %s", props.filterMinmaxSingleComponentFormats);
    verbose(__FILE__, "  filterMinmaxImageComponentMapping                    : %s", props.filterMinmaxImageComponentMapping);
    verbose(__FILE__, "  maxTimelineSemaphoreValueDifference                  : %,3d", props.maxTimelineSemaphoreValueDifference);
    verbose(__FILE__, "  framebufferIntegerColorSampleCounts                  : %s", toArray!VkSampleCountFlagBits(props.framebufferIntegerColorSampleCounts));
    verbose(__FILE__, "}");
}
void dump(VkPhysicalDeviceVulkan13Properties props) {
    verbose(__FILE__, "VkPhysicalDeviceVulkan13Properties {");
    verbose(__FILE__, "  minSubgroupSize ................................................................ %,3d", props.minSubgroupSize);
    verbose(__FILE__, "  maxSubgroupSize ................................................................ %,3d", props.maxSubgroupSize);
    verbose(__FILE__, "  maxComputeWorkgroupSubgroups ................................................... %,3d", props.maxComputeWorkgroupSubgroups);
    verbose(__FILE__, "  requiredSubgroupSizeStages ..................................................... %s", toArray!VkShaderStageFlagBits(props.requiredSubgroupSizeStages));
    verbose(__FILE__, "  maxInlineUniformBlockSize ...................................................... %,3d", props.maxInlineUniformBlockSize);
    verbose(__FILE__, "  maxPerStageDescriptorInlineUniformBlocks ....................................... %,3d", props.maxPerStageDescriptorInlineUniformBlocks);
    verbose(__FILE__, "  maxPerStageDescriptorUpdateAfterBindInlineUniformBlocks ........................ %,3d", props.maxPerStageDescriptorUpdateAfterBindInlineUniformBlocks);
    verbose(__FILE__, "  maxDescriptorSetInlineUniformBlocks ............................................ %,3d", props.maxDescriptorSetInlineUniformBlocks);
    verbose(__FILE__, "  maxDescriptorSetUpdateAfterBindInlineUniformBlocks ............................. %,3d", props.maxDescriptorSetUpdateAfterBindInlineUniformBlocks);
    verbose(__FILE__, "  maxInlineUniformTotalSize ...................................................... %,3d", props.maxInlineUniformTotalSize);
    verbose(__FILE__, "  integerDotProduct8BitUnsignedAccelerated ....................................... %s", props.integerDotProduct8BitUnsignedAccelerated);
    verbose(__FILE__, "  integerDotProduct8BitSignedAccelerated ......................................... %s", props.integerDotProduct8BitSignedAccelerated);
    verbose(__FILE__, "  integerDotProduct8BitMixedSignednessAccelerated ................................ %s", props.integerDotProduct8BitMixedSignednessAccelerated);
    verbose(__FILE__, "  integerDotProduct4x8BitPackedUnsignedAccelerated ............................... %s", props.integerDotProduct4x8BitPackedUnsignedAccelerated);
    verbose(__FILE__, "  integerDotProduct4x8BitPackedSignedAccelerated ................................. %s", props.integerDotProduct4x8BitPackedSignedAccelerated);
    verbose(__FILE__, "  integerDotProduct4x8BitPackedMixedSignednessAccelerated ........................ %s", props.integerDotProduct4x8BitPackedMixedSignednessAccelerated);
    verbose(__FILE__, "  integerDotProduct16BitUnsignedAccelerated ...................................... %s", props.integerDotProduct16BitUnsignedAccelerated);
    verbose(__FILE__, "  integerDotProduct16BitSignedAccelerated ........................................ %s", props.integerDotProduct16BitSignedAccelerated);
    verbose(__FILE__, "  integerDotProduct16BitMixedSignednessAccelerated ............................... %s", props.integerDotProduct16BitMixedSignednessAccelerated);
    verbose(__FILE__, "  integerDotProduct32BitUnsignedAccelerated ...................................... %s", props.integerDotProduct32BitUnsignedAccelerated);
    verbose(__FILE__, "  integerDotProduct32BitSignedAccelerated ........................................ %s", props.integerDotProduct32BitSignedAccelerated);
    verbose(__FILE__, "  integerDotProduct32BitMixedSignednessAccelerated ............................... %s", props.integerDotProduct32BitMixedSignednessAccelerated);
    verbose(__FILE__, "  integerDotProduct64BitUnsignedAccelerated ...................................... %s", props.integerDotProduct64BitUnsignedAccelerated);
    verbose(__FILE__, "  integerDotProduct64BitSignedAccelerated ........................................ %s", props.integerDotProduct64BitSignedAccelerated);
    verbose(__FILE__, "  integerDotProduct64BitMixedSignednessAccelerated ............................... %s", props.integerDotProduct64BitMixedSignednessAccelerated);
    verbose(__FILE__, "  integerDotProductAccumulatingSaturating8BitUnsignedAccelerated ................. %s", props.integerDotProductAccumulatingSaturating8BitUnsignedAccelerated);
    verbose(__FILE__, "  integerDotProductAccumulatingSaturating8BitSignedAccelerated ................... %s", props.integerDotProductAccumulatingSaturating8BitSignedAccelerated);
    verbose(__FILE__, "  integerDotProductAccumulatingSaturating8BitMixedSignednessAccelerated .......... %s", props.integerDotProductAccumulatingSaturating8BitMixedSignednessAccelerated);
    verbose(__FILE__, "  integerDotProductAccumulatingSaturating4x8BitPackedUnsignedAccelerated ......... %s", props.integerDotProductAccumulatingSaturating4x8BitPackedUnsignedAccelerated);
    verbose(__FILE__, "  integerDotProductAccumulatingSaturating4x8BitPackedSignedAccelerated ........... %s", props.integerDotProductAccumulatingSaturating4x8BitPackedSignedAccelerated);
    verbose(__FILE__, "  integerDotProductAccumulatingSaturating4x8BitPackedMixedSignednessAccelerated .. %s", props.integerDotProductAccumulatingSaturating4x8BitPackedMixedSignednessAccelerated);
    verbose(__FILE__, "  integerDotProductAccumulatingSaturating16BitUnsignedAccelerated ................ %s", props.integerDotProductAccumulatingSaturating16BitUnsignedAccelerated);
    verbose(__FILE__, "  integerDotProductAccumulatingSaturating16BitSignedAccelerated .................. %s", props.integerDotProductAccumulatingSaturating16BitSignedAccelerated);
    verbose(__FILE__, "  integerDotProductAccumulatingSaturating16BitMixedSignednessAccelerated ......... %s", props.integerDotProductAccumulatingSaturating16BitMixedSignednessAccelerated);
    verbose(__FILE__, "  integerDotProductAccumulatingSaturating32BitUnsignedAccelerated ................ %s", props.integerDotProductAccumulatingSaturating32BitUnsignedAccelerated);
    verbose(__FILE__, "  integerDotProductAccumulatingSaturating32BitSignedAccelerated .................. %s", props.integerDotProductAccumulatingSaturating32BitSignedAccelerated);
    verbose(__FILE__, "  integerDotProductAccumulatingSaturating32BitMixedSignednessAccelerated ......... %s", props.integerDotProductAccumulatingSaturating32BitMixedSignednessAccelerated);
    verbose(__FILE__, "  integerDotProductAccumulatingSaturating64BitUnsignedAccelerated ................ %s", props.integerDotProductAccumulatingSaturating64BitUnsignedAccelerated);
    verbose(__FILE__, "  integerDotProductAccumulatingSaturating64BitSignedAccelerated .................. %s", props.integerDotProductAccumulatingSaturating64BitSignedAccelerated);
    verbose(__FILE__, "  integerDotProductAccumulatingSaturating64BitMixedSignednessAccelerated ......... %s", props.integerDotProductAccumulatingSaturating64BitMixedSignednessAccelerated);
    verbose(__FILE__, "  storageTexelBufferOffsetAlignmentBytes ......................................... %,3d", props.storageTexelBufferOffsetAlignmentBytes);
    verbose(__FILE__, "  storageTexelBufferOffsetSingleTexelAlignment ................................... %s", props.storageTexelBufferOffsetSingleTexelAlignment);
    verbose(__FILE__, "  uniformTexelBufferOffsetAlignmentBytes ......................................... %,3d", props.uniformTexelBufferOffsetAlignmentBytes);
    verbose(__FILE__, "  uniformTexelBufferOffsetSingleTexelAlignment ................................... %s", props.uniformTexelBufferOffsetSingleTexelAlignment);
    verbose(__FILE__, "  maxBufferSize .................................................................. %,3d", props.maxBufferSize);
    verbose(__FILE__, "}");
}
void dump(VkPhysicalDeviceVulkan14Properties props) {
    verbose(__FILE__, "VkPhysicalDeviceVulkan14Properties {");
    verbose(__FILE__, "  lineSubPixelPrecisionBits ......................................... %,3d", props.lineSubPixelPrecisionBits);
    verbose(__FILE__, "  maxVertexAttribDivisor ............................................ %,3d", props.maxVertexAttribDivisor);
    verbose(__FILE__, "  supportsNonZeroFirstInstance ...................................... %s", props.supportsNonZeroFirstInstance);
    verbose(__FILE__, "  maxPushDescriptors ............................................... %,3d", props.maxPushDescriptors);
    verbose(__FILE__, "  dynamicRenderingLocalReadDepthStencilAttachments ................. %s", props.dynamicRenderingLocalReadDepthStencilAttachments);
    verbose(__FILE__, "  dynamicRenderingLocalReadMultisampledAttachments ................ %s", props.dynamicRenderingLocalReadMultisampledAttachments);
    verbose(__FILE__, "  earlyFragmentMultisampleCoverageAfterSampleCounting .............. %s", props.earlyFragmentMultisampleCoverageAfterSampleCounting);
    verbose(__FILE__, "  earlyFragmentSampleMaskTestBeforeSampleCounting ................. %s", props.earlyFragmentSampleMaskTestBeforeSampleCounting);
    verbose(__FILE__, "  depthStencilSwizzleOneSupport .................................... %s", props.depthStencilSwizzleOneSupport);
    verbose(__FILE__, "  polygonModePointSize ............................................. %s", props.polygonModePointSize);
    verbose(__FILE__, "  nonStrictSinglePixelWideLinesUseParallelogram ................... %s", props.nonStrictSinglePixelWideLinesUseParallelogram);
    verbose(__FILE__, "  nonStrictWideLinesUseParallelogram .............................. %s", props.nonStrictWideLinesUseParallelogram);
    verbose(__FILE__, "  blockTexelViewCompatibleMultipleLayers .......................... %s", props.blockTexelViewCompatibleMultipleLayers);
    verbose(__FILE__, "  maxCombinedImageSamplerDescriptorCount .......................... %,3d", props.maxCombinedImageSamplerDescriptorCount);
    verbose(__FILE__, "  fragmentShadingRateClampCombinerInputs .......................... %s", props.fragmentShadingRateClampCombinerInputs);
    verbose(__FILE__, "  defaultRobustnessStorageBuffers .................................. %s", props.defaultRobustnessStorageBuffers);
    verbose(__FILE__, "  defaultRobustnessUniformBuffers .................................. %s", props.defaultRobustnessUniformBuffers);
    verbose(__FILE__, "  defaultRobustnessVertexInputs .................................... %s", props.defaultRobustnessVertexInputs);
    verbose(__FILE__, "  defaultRobustnessImages ......................................... %s", props.defaultRobustnessImages);
    verbose(__FILE__, "  copySrcLayoutCount .............................................. %,3d", props.copySrcLayoutCount);
    verbose(__FILE__, "  copyDstLayoutCount .............................................. %,3d", props.copyDstLayoutCount);
    verbose(__FILE__, "  optimalTilingLayoutUUID ......................................... %s", props.optimalTilingLayoutUUID);
    verbose(__FILE__, "  identicalMemoryTypeRequirements .................................. %s", props.identicalMemoryTypeRequirements);

    foreach(i; 0..props.copySrcLayoutCount) {
        verbose(__FILE__, "    - copySrcLayouts[%s] : %s", i, props.pCopySrcLayouts[i]);
    }
    foreach(i; 0..props.copyDstLayoutCount) {
        verbose(__FILE__, "    - copyDstLayouts[%s] : %s", i, props.pCopyDstLayouts[i]);
    }
}
void dump(VkPhysicalDeviceDriverProperties props) {
    verbose(__FILE__, "VkPhysicalDeviceDriverProperties {");
    verbose(__FILE__, "  driverID ................................................. %s", props.driverID);
    verbose(__FILE__, "  driverName ............................................... %s", props.driverName.ptr.fromStringz);
    verbose(__FILE__, "  driverInfo ............................................... %s", props.driverInfo.ptr.fromStringz);
    verbose(__FILE__, "  conformanceVersion ....................................... %s", props.conformanceVersion);
    verbose(__FILE__, "}");
}

void dump(VkPhysicalDeviceRayTracingPipelineFeaturesKHR f) {
    verbose(__FILE__, "VkPhysicalDeviceRayTracingPipelineFeaturesKHR {");
    verbose(__FILE__, "   rayTracingPipeline                                    : %s", f.rayTracingPipeline);
	verbose(__FILE__, "   rayTracingPipelineShaderGroupHandleCaptureReplay      : %s", f.rayTracingPipelineShaderGroupHandleCaptureReplay);
	verbose(__FILE__, "   rayTracingPipelineShaderGroupHandleCaptureReplayMixed : %s", f.rayTracingPipelineShaderGroupHandleCaptureReplayMixed);
	verbose(__FILE__, "   rayTracingPipelineTraceRaysIndirect                   : %s", f.rayTracingPipelineTraceRaysIndirect);
	verbose(__FILE__, "   rayTraversalPrimitiveCulling                          : %s", f.rayTraversalPrimitiveCulling);
    verbose(__FILE__, "}");
}

void dump(VkPhysicalDeviceLimits limits) {
	verbose(__FILE__, "VkPhysicalDeviceLimits {");
	verbose(__FILE__, "  maxImageDimension1D ............... %s", limits.maxImageDimension1D);
	verbose(__FILE__, "  maxImageDimension2D ............... %s", limits.maxImageDimension2D);
	verbose(__FILE__, "  maxImageDimension3D ............... %s", limits.maxImageDimension3D);
	verbose(__FILE__, "  maxComputeSharedMemorySize ........ %s", limits.maxComputeSharedMemorySize);
	verbose(__FILE__, "  maxComputeWorkGroupCount .......... [%s,%s,%s]", limits.maxComputeWorkGroupCount[0], limits.maxComputeWorkGroupCount[1], limits.maxComputeWorkGroupCount[2]);
    verbose(__FILE__, "  maxComputeWorkGroupSize ........... [%s,%s,%s]", limits.maxComputeWorkGroupSize[0], limits.maxComputeWorkGroupSize[1], limits.maxComputeWorkGroupSize[2]);
    verbose(__FILE__, "  maxComputeWorkGroupInvocations .... %s", limits.maxComputeWorkGroupInvocations);
    verbose(__FILE__, "  maxUniformBufferRange ............. %s", limits.maxUniformBufferRange);
    verbose(__FILE__, "  maxStorageBufferRange ............. %s", limits.maxStorageBufferRange);
    verbose(__FILE__, "  timestampComputeAndGraphics ....... %s", 1==limits.timestampComputeAndGraphics);
    verbose(__FILE__, "  timestampPeriod ................... %s", limits.timestampPeriod);
    verbose(__FILE__, "  discreteQueuePriorities ........... %s", limits.discreteQueuePriorities);
    verbose(__FILE__, "  maxPushConstantsSize .............. %s", limits.maxPushConstantsSize);
    verbose(__FILE__, "  maxSamplerAllocationCount ......... %s", limits.maxSamplerAllocationCount);
    verbose(__FILE__, "  bufferImageGranularity ............ %s", limits.bufferImageGranularity);
    verbose(__FILE__, "  maxBoundDescriptorSets ............ %s", limits.maxBoundDescriptorSets);
    verbose(__FILE__, "  minUniformBufferOffsetAlignment ... %s", limits.minUniformBufferOffsetAlignment);
    verbose(__FILE__, "  minStorageBufferOffsetAlignment ... %s", limits.minStorageBufferOffsetAlignment);
    verbose(__FILE__, "  minMemoryMapAlignment ............. %s", limits.minMemoryMapAlignment);
    verbose(__FILE__, "  maxMemoryAllocationCount .......... %s", limits.maxMemoryAllocationCount);
    verbose(__FILE__, "  maxDescriptorSetSamplers .......... %s", limits.maxDescriptorSetSamplers);
    verbose(__FILE__, "  maxDescriptorSetStorageBuffers .... %s", limits.maxDescriptorSetStorageBuffers);
    verbose(__FILE__, "  maxSamplerAnisotropy .............. %s", limits.maxSamplerAnisotropy);
    verbose(__FILE__, "  maxViewports ...................... %s", limits.maxViewports);
    verbose(__FILE__, "  maxViewportDimensions [x,y] ....... %s", limits.maxViewportDimensions);
    verbose(__FILE__, "  maxFramebufferWidth ............... %s", limits.maxFramebufferWidth);
    verbose(__FILE__, "  maxFramebufferHeight .............. %s", limits.maxFramebufferHeight);
    verbose(__FILE__, "  optimalBufferCopyOffsetAlignment .. %s", limits.optimalBufferCopyOffsetAlignment);
    verbose(__FILE__, "  nonCoherentAtomSize ............... %s", limits.nonCoherentAtomSize);
    verbose(__FILE__, "}");
}
void dump(VkPhysicalDeviceMemoryProperties p) {
	verbose(__FILE__, "VkPhysicalDeviceMemoryProperties {");
    verbose(__FILE__, "  Types:");
	for(auto i=0; i<p.memoryTypeCount; i++) {
		auto mt = p.memoryTypes[i];
		verbose(__FILE__, "    [%2s]: heap:%s (flags=0x%x) isLocal=%s hostVisible=%s hostCoherent=%s hostCached=%s lazyAlloc=%s protected=%s",
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
    verbose(__FILE__, "  Heaps:");
	for(auto i=0; i<p.memoryHeapCount; i++) {
		auto mh = p.memoryHeaps[i];
		verbose(__FILE__, "    [%s]: size: %s islocal=%s",
		    i,
			mh.size.sizeToString(),
			cast(bool)(mh.flags & VkMemoryHeapFlagBits.VK_MEMORY_HEAP_DEVICE_LOCAL_BIT)
		);
	}
    verbose(__FILE__, "}");
}
void dump(VkQueueFamilyProperties[] queueFamilies) {
	verbose(__FILE__, "Number of Queue families: %s", queueFamilies.length);

    foreach(i, qf; queueFamilies) {
		verbose(__FILE__, "  [%s] QueueCount:%s flags:%s timestampValidBits:%s minImageTransferGranularity:%s",
		    i, qf.queueCount, toString!VkQueueFlagBits(qf.queueFlags, "VK_QUEUE_", "_BIT"),
		    qf.timestampValidBits, qf.minImageTransferGranularity);
	}
}
void dump(VkExtensionProperties[] extensions) {
	verbose(__FILE__, "Device extensions: %s", extensions.length);
	foreach(i, e; extensions) {
		verbose(__FILE__, "  [%s] name: '%s' specVersion:%s",
		    i, e.extensionName.ptr.fromStringz, e.specVersion);
	}
}
void dump(VkSurfaceCapabilitiesKHR capabilities) {
    verbose(__FILE__, "VkSurfaceCapabilitiesKHR:");
    verbose(__FILE__, "   minImageCount  = %s", capabilities.minImageCount);
    verbose(__FILE__, "   maxImageCount  = %s", capabilities.maxImageCount);
    verbose(__FILE__, "   currentExtent  = %s", capabilities.currentExtent);
    verbose(__FILE__, "   minImageExtent = %s", capabilities.minImageExtent);
    verbose(__FILE__, "   maxImageExtent = %s", capabilities.maxImageExtent);
    verbose(__FILE__, "   maxImageArrayLayers = %s", capabilities.maxImageArrayLayers);
    verbose(__FILE__, "   supportedTransforms = %s", toString!VkSurfaceTransformFlagBitsKHR(capabilities.supportedTransforms, "VK_SURFACE_TRANSFORM_", "_BIT_KHR"));
    verbose(__FILE__, "   currentTransform = %s", toString!VkSurfaceTransformFlagBitsKHR(capabilities.currentTransform, "VK_SURFACE_TRANSFORM_", "_BIT_KHR"));
    verbose(__FILE__, "   supportedCompositeAlpha = %s", capabilities.supportedCompositeAlpha);
    verbose(__FILE__, "   supportedUsageFlags = %s", toString!VkImageUsageFlagBits(capabilities.supportedUsageFlags, "VK_IMAGE_USAGE_", "_BIT"));
}
void dump(VkPresentModeKHR[] presentModes) {
    verbose(__FILE__, "Present modes:");
    foreach(i, pm; presentModes) {
        verbose(__FILE__, "   [%s] %s", i, pm.to!string);
    }
}
void dump(ref VkMemoryRequirements m, string name=null) {
    verbose(__FILE__, "Memory requirements %s", name ? "("~name~"):" : ":");
    verbose(__FILE__, "   size:%s, alignment:%s memoryTypeBits:%s", m.size, m.alignment, m.memoryTypeBits);
}

void dump(VkPhysicalDeviceFloatControlsProperties props) {
    auto len = getAllProperties!VkPhysicalDeviceFloatControlsProperties()
        .map!(it=>it.length)
        .maxElement() + 2;

    void logProperty(string name)() {
        verbose(__FILE__, "  %s %s", name.leftJustify(len), __traits(getMember, props, name));
    }

    verbose(__FILE__, "VkPhysicalDeviceFloatControlsProperties {");
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
    verbose(__FILE__, "}");
}
void dumpFormatSupport(VkPhysicalDevice pDevice) {
    import std.string : leftJustify;
    
    void _dumpFormatSupport(string label, VkFormat[] formats) {
        verbose(__FILE__, "%s image format support:", label);
        foreach(f; formats) {
            VkFormatProperties p = pDevice.getFormatProperties(f);

            if(vk13Enabled()) {
                VkFormatProperties3 props3 = pDevice.getFormatProperties3(f);
                verbose(__FILE__, "props3 = %s", props3);

                // todo - turn these flags into an enum
            }

            if(pDevice.isFormatSupported(f)) {
                verbose(__FILE__, "  '%s' : yes", f);
                verbose(__FILE__, "    - optTilingFeatures    : %s", toString!VkFormatFeatureFlagBits(p.optimalTilingFeatures, "VK_FORMAT_FEATURE_", "_BIT"));
                verbose(__FILE__, "    - linearTilingFeatures : %s", toString!VkFormatFeatureFlagBits(p.linearTilingFeatures, "VK_FORMAT_FEATURE_", "_BIT"));
                verbose(__FILE__, "    - bufferFeatures       : %s", toString!VkFormatFeatureFlagBits(p.bufferFeatures, "VK_FORMAT_FEATURE_", "_BIT"));
            } else {
                verbose(__FILE__, "  '%s' : no", f);
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
    verbose(__FILE__, "%s%s {", prefixStr, typeof(f).stringof);

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
            verbose(__FILE__, "  %s %,3d", s, value);
        } else static if(isEnum!type) {
            if(bitCount(value) <= 1) {
                verbose(__FILE__, "  %s %s", s, value);
            } else {
                verbose(__FILE__, "  %s %s", s, toArray!type(value)); 
            }
        } else {
            verbose(__FILE__, "  %s %s", s, value);
        }
    }
    verbose(__FILE__, "}");
}
