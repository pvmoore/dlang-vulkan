module vulkan.pipelines.raytracing_pipeline;

import vulkan.all;

private struct None { int a; }

/**
 * Ray tracing VkPipeline.
 *
 * Note: The shader binding table buffer is allocated from the context BufID.RT_SBT buffer which needs 
 * to be created before creating the pipeline. 
 * eg.
 * context.withBuffer(MemID.STAGING, BufID.RT_SBT,
 *          VK_BUFFER_USAGE_SHADER_BINDING_TABLE_BIT_KHR |
 *          VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT,
 *          2.MB);
 *
 * If the BufID.RT_SBT buffer is not host visible then a staging buffer will be sub-allocated from BufID.STAGING 
 * and used to upload the data.
 */
final class RayTracingPipeline {
public:
    VkPipeline pipeline;
    VkPipelineLayout layout;

    VkStridedDeviceAddressRegionKHR raygenStridedDeviceAddressRegion;
    VkStridedDeviceAddressRegionKHR missStridedDeviceAddressRegion;
    VkStridedDeviceAddressRegionKHR hitStridedDeviceAddressRegion;
    VkStridedDeviceAddressRegionKHR callableStridedDeviceAddressRegion;

    uint getNumShaderGroups() { return shaderGroups.length.as!uint; }

    this(VulkanContext context) {
        this.context = context;
        this.device = context.device;
        this.rtPipelineProperties = context.vk.physicalDevice.getRayTracingPipelineProperties();
    }
    void destroy() {
        if(layout) device.destroyPipelineLayout(layout);
        if(pipeline) device.destroyPipeline(pipeline);
        if(sbtBuffer) sbtBuffer.free();
    }

    auto withMaxRecursionDepth(int depth) {
        this.maxRecursionDepth = minOf(depth, rtPipelineProperties.maxRayRecursionDepth);
        return this;
    }

    auto withDSLayouts(VkDescriptorSetLayout[] dsLayouts) {
        this.dsLayouts = dsLayouts;
        return this;
    }
    auto withPushConstantRange(T)(VkShaderStageFlags stages, uint offset = 0) {
        auto pcRange = VkPushConstantRange(
            stages,
            offset,
            T.sizeof
        );
        pcRanges ~= pcRange;
        return this;
    }
    auto withShader(T=None)(VkShaderStageFlagBits stage, VkShaderModule shader, T* specInfo=null, string entry="main") {
        throwIf(!stage.isOneOf(
            VK_SHADER_STAGE_RAYGEN_BIT_KHR,
            VK_SHADER_STAGE_MISS_BIT_KHR,
            VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR,
            VK_SHADER_STAGE_ANY_HIT_BIT_KHR,
            VK_SHADER_STAGE_INTERSECTION_BIT_KHR,
            VK_SHADER_STAGE_CALLABLE_BIT_KHR
        ), "Unsupported stage %s", stage);

        this.shaders ~= ShaderInfo(stage, shader, entry);
        if(specInfo) {
            shaders[$-1].specInfo = .specialisationInfo!T(specInfo);
        }
        return this;
    }
    auto withRaygenGroup(uint shaderIndex) {
        VkRayTracingShaderGroupCreateInfoKHR group = {
            sType: VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_KHR,
            type: VK_RAY_TRACING_SHADER_GROUP_TYPE_GENERAL_KHR,
            generalShader: shaderIndex,
            closestHitShader: VK_SHADER_UNUSED_KHR,
            anyHitShader: VK_SHADER_UNUSED_KHR,
            intersectionShader: VK_SHADER_UNUSED_KHR
        };
        shaderGroups ~= group;
        numRaygenGroups++;
        return this;
    }    
    auto withMissGroup(uint shaderIndex) {
        VkRayTracingShaderGroupCreateInfoKHR group = {
            sType: VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_KHR,
            type: VK_RAY_TRACING_SHADER_GROUP_TYPE_GENERAL_KHR,
            generalShader: shaderIndex,
            closestHitShader: VK_SHADER_UNUSED_KHR,
            anyHitShader: VK_SHADER_UNUSED_KHR,
            intersectionShader: VK_SHADER_UNUSED_KHR
        };
        shaderGroups ~= group;
        numMissGroups++;
        return this;
    }
    auto withCallableGroup(uint shaderIndex) {
        VkRayTracingShaderGroupCreateInfoKHR group = {
            sType: VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_KHR,
            type: VK_RAY_TRACING_SHADER_GROUP_TYPE_GENERAL_KHR,
            generalShader: shaderIndex,
            closestHitShader: VK_SHADER_UNUSED_KHR,
            anyHitShader: VK_SHADER_UNUSED_KHR,
            intersectionShader: VK_SHADER_UNUSED_KHR
        };
        shaderGroups ~= group;
        numCallableGroups++;
        return this;
    }
    /**
     * For closestHit, anyHit or intersection shaders
     */
    auto withHitGroup(VkRayTracingShaderGroupTypeKHR type,
                      uint closestHitIndex,
                      uint anyHitIndex,
                      uint intersectionIndex)
    {
        throwIf(!type.isOneOf(VK_RAY_TRACING_SHADER_GROUP_TYPE_TRIANGLES_HIT_GROUP_KHR,
                              VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_KHR));

        VkRayTracingShaderGroupCreateInfoKHR group = {
            sType: VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_KHR,
            type: type,
            generalShader: VK_SHADER_UNUSED_KHR,
            closestHitShader: closestHitIndex,
            anyHitShader: anyHitIndex,
            intersectionShader: intersectionIndex
        };
        shaderGroups ~= group;
        numHitGroups++;
        return this;
    }
    auto build(VkPipelineCreateFlags flags = 0) {
        throwIf(dsLayouts.length == 0);
        throwIf(shaders.length == 0);
        throwIf(shaderGroups.length == 0);

        VkPipelineShaderStageCreateInfo[] stageInfos =
            shaders.map!(it=>shaderStage(it.stage, it.shader, it.entry, it.specInfo.dataSize == 0 ? null : &it.specInfo))
                   .array;

        this.layout = createPipelineLayout(
            device,
            dsLayouts,
            pcRanges
        );

        // eg. Ray tracing specific flags
        // VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_ANY_HIT_SHADERS_BIT_KHR 
        // VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_CLOSEST_HIT_SHADERS_BIT_KHR 
        // VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_MISS_SHADERS_BIT_KHR
        // VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_INTERSECTION_SHADERS_BIT_KHR 
        // VK_PIPELINE_CREATE_RAY_TRACING_SKIP_TRIANGLES_BIT_KHR 
        // VK_PIPELINE_CREATE_RAY_TRACING_SKIP_AABBS_BIT_KHR 
        // VK_PIPELINE_CREATE_RAY_TRACING_SHADER_GROUP_HANDLE_CAPTURE_REPLAY_BIT_KHR 
        // VK_PIPELINE_CREATE_RAY_TRACING_ALLOW_MOTION_BIT_NV 

        VkRayTracingPipelineCreateInfoKHR info = {
            sType: VK_STRUCTURE_TYPE_RAY_TRACING_PIPELINE_CREATE_INFO_KHR,
            flags: flags,
            stageCount: stageInfos.length.as!uint,
            pStages: stageInfos.ptr,
            groupCount: shaderGroups.length.as!uint,
            pGroups: shaderGroups.ptr,
            maxPipelineRayRecursionDepth: maxRecursionDepth,
            pLibraryInfo: null,
            pLibraryInterface: null,
            pDynamicState: null,
            layout: layout
        };

        check(vkCreateRayTracingPipelinesKHR(
            device,
            null,           // VkDeferredOperationKHR
            null,           // VkPipelineCache
            1,
            &info,
            null,           // VkAllocationCallbacks
            &pipeline
        ));

        createSBT();

        return this;
    }
private:
    @Borrowed VulkanContext context;
    @Borrowed VkDevice device;

    static struct ShaderInfo {
        VkShaderStageFlagBits stage;
        VkShaderModule shader;
        string entry;
        VkSpecializationInfo specInfo;
    }

    VkDescriptorSetLayout[] dsLayouts;
    VkPushConstantRange[] pcRanges;

    SubBuffer sbtBuffer;

    uint numRaygenGroups;
    uint numMissGroups;
    uint numHitGroups;
    uint numCallableGroups;

    ShaderInfo[] shaders;
    VkRayTracingShaderGroupCreateInfoKHR[] shaderGroups;
    uint maxRecursionDepth = 1;
    VkPhysicalDeviceRayTracingPipelinePropertiesKHR rtPipelineProperties;

    /**
      * hitGroupRecordAddress = 
      *         start + stride * (Ioffset + Roffset + (Gindex * Rstride))
      *
      * start            = VkStridedDeviceAddressRegionKHR::deviceAddress passed to vkCmdTraceRaysKHR 
      * stride           = VkStridedDeviceAddressRegionKHR::stride        passed to vkCmdTraceRaysKHR 
      * Gindex           = index of geometry in BLAS
      * Ioffset          = VkAccelerationStructureInstanceKHR::instanceShaderBindingTableRecordOffset
      * Roffset          = traceRayEXT.sbtRecordOffset parameter (this is index not bytes)
      * Rstride          = traceRayEXT.sbtRecordStride parameter (this is index not bytes)
      *
      * missRecordAddress = start + stride * missIndex
      *
      * start            = VkStridedDeviceAddressRegionKHR::deviceAddress passed to vkCmdTraceRaysKHR 
      * stride           = VkStridedDeviceAddressRegionKHR::stride        passed to vkCmdTraceRaysKHR 
      * missIndex        = traceRayEXT.missIndex parameter 
      */
    void createSBT() {
        uint sbtHandleSize = rtPipelineProperties.shaderGroupHandleSize;
        uint sbtHandleSizeAligned = getAlignedValue(sbtHandleSize, rtPipelineProperties.shaderGroupHandleAlignment).as!uint;

        uint firstGroup = 0;
		uint groupCount = shaderGroups.length.as!uint;
		uint sbtSize = groupCount * sbtHandleSizeAligned;

        this.log("handleSize        = %s bytes", sbtHandleSize);
        this.log("handleSizeAligned = %s bytes", sbtHandleSizeAligned);
        this.log("sbtSize           = %s bytes", sbtSize);

        // Fetch the shader group handles
        ubyte[] shaderHandleStorage = new ubyte[sbtSize];
		check(vkGetRayTracingShaderGroupHandlesKHR(context.device, pipeline, firstGroup, groupCount, sbtSize, shaderHandleStorage.ptr));

        this.log("shaderHandleStorage: (%s bytes)", shaderHandleStorage.length);
        foreach(i; 0..shaderHandleStorage.length / sbtHandleSizeAligned) {
            this.log("[% 3s]%s", i*sbtHandleSizeAligned, shaderHandleStorage[i*sbtHandleSizeAligned..i*sbtHandleSizeAligned+sbtHandleSizeAligned]);
        }

        uint raygenSize = numRaygenGroups * sbtHandleSizeAligned;
        uint missSize = numMissGroups * sbtHandleSizeAligned;
        uint hitSize = numHitGroups * sbtHandleSizeAligned;
        uint callableSize = numCallableGroups * sbtHandleSizeAligned;

        ubyte* raygenSrc = shaderHandleStorage.ptr;
        ubyte* missSrc = raygenSrc + raygenSize;
        ubyte* hitSrc = missSrc + missSize;
        ubyte* callableSrc = hitSrc + hitSize;

        ulong raygenDest = 0;
        ulong missDest = getAlignedValue(raygenSize, rtPipelineProperties.shaderGroupBaseAlignment);
        ulong hitDest = getAlignedValue(missDest + missSize, rtPipelineProperties.shaderGroupBaseAlignment);
        ulong callableDest = getAlignedValue(hitDest + hitSize, rtPipelineProperties.shaderGroupBaseAlignment);

        ulong bufferSize = callableDest + callableSize;

        this.log("raygen   start: %s, size: %s", raygenDest, raygenSize);
        this.log("miss     start: %s, size: %s", missDest, missSize);
        this.log("hit      start: %s, size: %s", hitDest, hitSize);
        this.log("callable start: %s, size: %s", callableDest, callableSize);

        sbtBuffer = context.buffer(BufID.RT_SBT)
                           .alloc(bufferSize, rtPipelineProperties.shaderGroupBaseAlignment);

        bool useStagingBuffer = !sbtBuffer.memory().isHostVisible();
        SubBuffer stagingBuffer;
        ubyte* dest;

        if(useStagingBuffer) {
            stagingBuffer = context.buffer(BufID.STAGING).alloc(bufferSize);
            dest = stagingBuffer.map().as!(ubyte*);
            this.log("SBT buffer is not host visible. Using staging buffer.");
        } else {
            dest = sbtBuffer.map().as!(ubyte*);
            this.log("SBT buffer is host visible. Using direct mapping.");
        }

        // Copy the handles.
        // NB. This assumes:
        //  1. The groups are contiguous. ie. miss groups are together, hit groups are together, etc.
        //  2. The handles are in this order: raygen, miss, hit, callable
        //  3. There are no gaps 

        memcpy(dest, raygenSrc, raygenSize);
        memcpy(dest + missDest, missSrc, missSize);
        memcpy(dest + hitDest, hitSrc, hitSize);
        memcpy(dest + callableDest, callableSrc, callableSize);

        this.log("raygen   = %s", dest[0..raygenSize]);
        this.log("miss     = %s", (dest+missDest)[0..missSize]);
        this.log("hit      = %s", (dest+hitDest)[0..hitSize]);
        this.log("callable = %s", (dest+callableDest)[0..callableSize]);

        if(useStagingBuffer) {
            stagingBuffer.flush();
            // Upload the data to the device
            context.transfer().from(stagingBuffer).to(sbtBuffer).size(bufferSize);
            stagingBuffer.free();
        } else {
            sbtBuffer.flush();
        }

        VkDeviceAddress deviceAddress = getDeviceAddress(context.device, sbtBuffer);

        this.raygenStridedDeviceAddressRegion = VkStridedDeviceAddressRegionKHR(
            deviceAddress,
            sbtHandleSizeAligned,
            raygenSize
        );
        this.missStridedDeviceAddressRegion = VkStridedDeviceAddressRegionKHR(
            deviceAddress + missDest,
            sbtHandleSizeAligned,
            missSize
        );
        this.hitStridedDeviceAddressRegion = VkStridedDeviceAddressRegionKHR(
            deviceAddress + hitDest,
            sbtHandleSizeAligned,
            hitSize
        );
        this.callableStridedDeviceAddressRegion = VkStridedDeviceAddressRegionKHR(
            deviceAddress + callableDest,
            sbtHandleSizeAligned,
            callableSize
        );  

        this.log("========================");
        this.log("Groups:");
        this.log("========================");
        foreach(i; 0..numRaygenGroups) {
            this.log("[%s] %-11s   raygen", i, shaderGroups[i].generalShader);
        }
        this.log("------------------------");
        foreach(i; 0..numMissGroups) {
            this.log("[%s] %-11s     miss", i, shaderGroups[i+numRaygenGroups].generalShader);
        }
        this.log("------------------------");
        foreach(i; 0..numHitGroups) {
            auto g = shaderGroups[i+numRaygenGroups+numMissGroups];
            this.log("[%s] %-3s %-3s %-3s      hit", i, 
                    g.closestHitShader == VK_SHADER_UNUSED_KHR ? "-" : "%s".format(g.closestHitShader), 
                    g.anyHitShader == VK_SHADER_UNUSED_KHR ? "-" : "%s".format(g.anyHitShader), 
                    g.intersectionShader == VK_SHADER_UNUSED_KHR ? "-" : "%s".format(g.intersectionShader));
        }
        this.log("------------------------");
        foreach(i; 0..numCallableGroups) {
            auto g = shaderGroups[i+numRaygenGroups+numMissGroups+numHitGroups];
            this.log("[%s] %-11s callable", i, g.generalShader);
        }
    }
}
