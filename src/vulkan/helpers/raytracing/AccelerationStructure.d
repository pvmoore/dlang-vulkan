module vulkan.helpers.raytracing.AccelerationStructure;

import vulkan.all;

public import vulkan.helpers.raytracing.BLAS;
public import vulkan.helpers.raytracing.TLAS;

/**
 *  Represents a single acceleration structure.
 *
 *
 * Useful build flags:
 *   VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_UPDATE_BIT_KHR 
 *   VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_COMPACTION_BIT_KHR 
 *   VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR 
 *   VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_BUILD_BIT_KHR 
 *   VK_BUILD_ACCELERATION_STRUCTURE_LOW_MEMORY_BIT_KHR
 */
abstract class AccelerationStructure {
public:
    VkDeviceAddress deviceAddress;
    VkAccelerationStructureKHR handle;
    SubBuffer buffer;
    SubBuffer scratchBuffer;

    final bool isUpdatable() { return (buildFlags & VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_UPDATE_BIT_KHR) != 0; }

    this(VulkanContext context, string name, VkBuildAccelerationStructureFlagBitsKHR buildFlags) {
        this.context = context;
        this.device = context.device;
        this.name = name;
        this.buildFlags = buildFlags;

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
    auto create() {
        throwIf(geometries.length == 0);
        throwIf(geometries.length != buildRanges.length);

        getBuildSizes();
        createBuffers();
        createAccelerationStructure();
        return this;
    }
    /**
     * Mark a range of geometries as requiring an update/rebuild.
     * This assumes that all primitives within the affected geometries are included
     * ie. the granularity is per geometry and not ranges of primitives.
     * Note that if rebuild is true then all modified geometries will do a full rebuild when 'update'
     * is called, not just the ones specified in the current call.
     */
    void setGeometriesModified(bool rebuild) {
        setGeometriesModified(rebuild, 0, buildRanges.length.as!uint);
    } 
    void setGeometriesModified(bool rebuild, uint geometryIndex, uint numGeometries) in {
        throwIf(geometryIndex > buildRanges.length);
        throwIfNot(geometryIndex + numGeometries <= buildRanges.length);
        throwIfNot(isUpdatable(), "Acceleration structure is not updatable");
    } do {
        // This is allowed but is a no-op
        if(numGeometries == 0) return;

        rebuildRequired |= rebuild;
        updateRequired = true;

        foreach(i; geometryIndex..geometryIndex + numGeometries) {
            requiredBuildRanges[i].primitiveCount = buildRanges[i].primitiveCount;
        }
    }      
    /**
     * Update or build all modified geometries (This is a no-op if no geometries are modified)
     */
    void update(VkCommandBuffer cmd) {
        doBuild(cmd);
    }
protected:
    static VkPhysicalDeviceAccelerationStructurePropertiesKHR asProps;

    VulkanContext context;
    VkDevice device;
    string name;
    VkAccelerationStructureTypeKHR type;
    VkBuildAccelerationStructureFlagBitsKHR buildFlags;

    // Geometry/instances
    VkAccelerationStructureGeometryKHR[] geometries;
    VkAccelerationStructureBuildRangeInfoKHR[] buildRanges;

    // Build sizes
    VkDeviceSize accelerationStructureSize;
    ulong scratchSize;

    // Buffers
    VkDeviceAddress scratchBufferDeviceAddress;

    // Build/update state
    bool updateRequired = false;
    bool rebuildRequired = true;
    VkAccelerationStructureBuildRangeInfoKHR[] requiredBuildRanges;

    void getBuildSizes() {
        VkAccelerationStructureBuildGeometryInfoKHR buildGeometryInfo = {
            sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR,
            type: type,
            flags: buildFlags,
            geometryCount: geometries.length.as!int,
            pGeometries: geometries.ptr
        };

        VkAccelerationStructureBuildSizesInfoKHR buildSizes = {
            sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR
        };

        uint[] maxPrimitiveCounts = buildRanges.map!((r) => r.primitiveCount).array;

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

        this.accelerationStructureSize = buildSizes.accelerationStructureSize;
        
        // Take the larger of build/update scratch size and use that
        this.scratchSize = maxOf(buildSizes.updateScratchSize, buildSizes.buildScratchSize);    

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
    void doBuild(VkCommandBuffer cmd) {
        throwIf(handle is null, "Handle is null. Did you call create() ?");

        if(!updateRequired && !rebuildRequired) {
            return;
        }

        auto mode = rebuildRequired ? VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR 
                                    : VK_BUILD_ACCELERATION_STRUCTURE_MODE_UPDATE_KHR;

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

        if(mode == VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR) {
            this.log("%s Rebuild", name);
        }

        // We are building a single acceleration structure from multiple geometries.
        // The ppBuildRangeInfos is an array of pointers to arrays of VkAccelerationStructureBuildRangeInfoKHR structs,
        // one for each array of geometries.
        //
        // Example with 2 acceleration structures:
        //    rangePtr[0] -> [ geometry[0] range, geometry[1] range, ... ] 
        //    rangePtr[0] -> [ geometry[1] range, geometry[2] range, ... ] 
        //
        VkAccelerationStructureBuildRangeInfoKHR*[] rangePtrs = [ requiredBuildRanges.ptr ];

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
            ],      // buffer barriers
            null    // image barriers
        );

        foreach(ref br; requiredBuildRanges) {
            br.primitiveCount = 0;
        }
        updateRequired = false;
        rebuildRequired = false;
    }
}
