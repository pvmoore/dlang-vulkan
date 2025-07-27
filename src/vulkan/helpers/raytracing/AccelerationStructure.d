module vulkan.helpers.raytracing.AccelerationStructure;

import vulkan.all;

public import vulkan.helpers.raytracing.BLAS;
public import vulkan.helpers.raytracing.TLAS;

abstract class AccelerationStructure {
public:
    VkDeviceAddress deviceAddress;
    VkAccelerationStructureKHR handle;
    SubBuffer buffer;
    SubBuffer scratchBuffer;

    bool requiresBuild() {
        return !isBuilt;
    }

    this(VulkanContext context, string name) {
        this.context = context;
        this.device = context.device;
        this.name = name;

        // Get the static properties if we haven't already
        if(asProps.sType == 0) {
            this.asProps = context.vk.physicalDevice.getAccelerationStructureProperties();                                 
        }
    }
    void destroy() {
        if(handle) device.destroyAccelerationStructure(handle);
        if(buffer) buffer.free();
        if(scratchBuffer) scratchBuffer.free();
    }
    auto create(VkBuildAccelerationStructureFlagBitsKHR[] buildFlagsArray...) {
        assert(geometries.length > 0);
        assert(geometries.length == maxPrimitiveCounts.length);
        assert(geometries.length == buildRanges.length);

        this.supportedBuildFlagsArray = buildFlagsArray;

        getBuildSizes();
        createBuffers();
        createAccelerationStructure();
        return this;
    }
    /**
     * Useful build flags:
     *  VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_UPDATE_BIT_KHR 
     *  VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_COMPACTION_BIT_KHR 
	 *  VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR 
	 *  VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_BUILD_BIT_KHR 
	 *  VK_BUILD_ACCELERATION_STRUCTURE_LOW_MEMORY_BIT_KHR
     */
    auto buildAll(VkCommandBuffer cmd, VkBuildAccelerationStructureFlagBitsKHR buildFlags) {
        doBuild(cmd, buildFlags, VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR);
        return this;
    }
    void updateAll(VkCommandBuffer cmd, VkBuildAccelerationStructureFlagBitsKHR buildFlags) {
        doBuild(cmd, buildFlags, VK_BUILD_ACCELERATION_STRUCTURE_MODE_UPDATE_KHR);
    }
protected:
    static VkPhysicalDeviceAccelerationStructurePropertiesKHR asProps;

    VulkanContext context;
    VkDevice device;
    string name;
    VkAccelerationStructureTypeKHR type;

    // Geometry/instances
    VkAccelerationStructureGeometryKHR[] geometries;
    VkAccelerationStructureBuildRangeInfoKHR[] buildRanges;
    uint[] maxPrimitiveCounts;

    // Build sizes
    VkDeviceSize accelerationStructureSize;
    ulong scratchSize;

    // Buffers
    VkDeviceAddress scratchBufferDeviceAddress;

    bool isBuilt;
    VkBuildAccelerationStructureFlagBitsKHR[] supportedBuildFlagsArray;

    void getBuildSizes() {
        // Take the largest buffer size of all possible build flags so that we don't need to recreate
        // either the bufferes or the acceleration structure
        foreach(flags; supportedBuildFlagsArray) {
            VkAccelerationStructureBuildGeometryInfoKHR buildGeometryInfo = {
                sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR,
                type: type,
                flags: flags,
                geometryCount: geometries.length.as!int,
                pGeometries: geometries.ptr
            };

            VkAccelerationStructureBuildSizesInfoKHR buildSizes = {
                sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR
            };

            // Note to future me:
            // If this call crashes for no reason then it might be due to one of the instance layers.
            // Try disabling the layers using the vkconfig-gui.exe to see if that fixes it.
            // Possibly related to enabling the VK_LAYER_LUNARG_api_dump layer ??
            vkGetAccelerationStructureBuildSizesKHR(
                device,
                VK_ACCELERATION_STRUCTURE_BUILD_TYPE_DEVICE_KHR,
                &buildGeometryInfo,
                maxPrimitiveCounts.ptr,
                &buildSizes
            );

            this.log("['%s'] buildSizes.accelerationStructureSize : %s", name, buildSizes.accelerationStructureSize);
            this.log("['%s'] buildSizes.buildScratchSize          : %s", name, buildSizes.buildScratchSize);
            this.log("['%s'] buildSizes.updateScratchSize         : %s", name, buildSizes.updateScratchSize);

            this.accelerationStructureSize = maxOf(accelerationStructureSize, buildSizes.accelerationStructureSize);
            
            // Take the larger of build/update scratch size and use that
            this.scratchSize = maxOf(scratchSize, buildSizes.updateScratchSize, buildSizes.buildScratchSize);    
        }

        this.log("['%s'] accelerationStructureSize = %s", name, accelerationStructureSize);
        this.log("['%s'] scratchSize               = %s", name, scratchSize);
    }
    void createBuffers() {
        this.buffer = context.buffer(BufID.RT_ACCELERATION)
                             .alloc(accelerationStructureSize, 256);

        this.scratchBuffer = context.buffer(BufID.RT_SCRATCH)
                                    .alloc(scratchSize, asProps.minAccelerationStructureScratchOffsetAlignment);

        this.scratchBufferDeviceAddress = getDeviceAddress(device, scratchBuffer);  
    }
    void createAccelerationStructure() {
        VkAccelerationStructureCreateInfoKHR createInfo = {
            sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_KHR,
		    buffer: buffer.handle(),
            offset: buffer.offset,
		    size: accelerationStructureSize,
		    type: type
        };

		check(vkCreateAccelerationStructureKHR(context.device, &createInfo, null, &handle));

        deviceAddress = getDeviceAddress(device, handle); 
    }
    void doBuild(VkCommandBuffer cmd,
                 VkBuildAccelerationStructureFlagBitsKHR buildFlags, 
                 VkBuildAccelerationStructureModeKHR mode) {
        throwIf(handle is null, "Handle is null. Did you call create() ?");
        throwIf(supportedBuildFlagsArray.find(buildFlags) is null, "Unsupported build flags %s", buildFlags);

        VkAccelerationStructureBuildGeometryInfoKHR buildGeometryInfo = {
            sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR,
            type: type,
            flags: buildFlags,
            mode: mode,
            dstAccelerationStructure: handle,
            geometryCount: geometries.length.as!int,
            pGeometries: geometries.ptr,
            scratchData: { deviceAddress: scratchBufferDeviceAddress }
        };

        if(mode == VK_BUILD_ACCELERATION_STRUCTURE_MODE_UPDATE_KHR) {
            buildGeometryInfo.srcAccelerationStructure = handle;
        }

        // We are building a single acceleration structure from multiple geometries.
        // The ppBuildRangeInfos is an array of pointers to arrays of VkAccelerationStructureBuildRangeInfoKHR structs,
        // one for each array of geometries.
        //
        // Example with 2 acceleration structures:
        //    rangePtr[0] -> [ geometry[0] range, geometry[1] range, ... ] 
        //    rangePtr[0] -> [ geometry[1] range, geometry[2] range, ... ] 
        //
        VkAccelerationStructureBuildRangeInfoKHR*[] rangePtrs = [ buildRanges.ptr ];

        // Add a buffer barrier between the ray tracing shader and the BLAS update
        cmd.pipelineBarrier(
            VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
            VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR,
            0,      // dependency flags
            null,   // memory barriers
            [
                bufferMemoryBarrier(
                    buffer.handle,
                    buffer.offset,
                    buffer.size, 
                    VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR,
                    VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR 
                ),
                bufferMemoryBarrier(
                    scratchBuffer.handle,
                    scratchBuffer.offset,
                    scratchBuffer.size, 
                    VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR,
                    VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR 
                )
            ],   
            null    // image barriers
        );

        vkCmdBuildAccelerationStructuresKHR(
            cmd,
            1,
            &buildGeometryInfo,             
            rangePtrs.ptr    
        );

        // Add a buffer barrier between the BLAS update and the ray tracing shader
        cmd.pipelineBarrier(
            VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR,
            VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
            0,      // dependency flags
            null,   // memory barriers
            [
                bufferMemoryBarrier(
                    buffer.handle,
                    buffer.offset,
                    buffer.size, 
                    VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR, 
                    VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR
                ),
                bufferMemoryBarrier(
                    scratchBuffer.handle,
                    scratchBuffer.offset,
                    scratchBuffer.size, 
                    VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR, 
                    VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR
                )
            ],   // buffer barriers
            null    // image barriers
        );

        isBuilt = true;
    }
}
