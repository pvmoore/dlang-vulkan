module vulkan.helpers.raytracing.AccelerationStructure;

import vulkan.all;

public import vulkan.helpers.raytracing.BLAS;
public import vulkan.helpers.raytracing.TLAS;

abstract class AccelerationStructure {
public:
    VkDeviceAddress deviceAddress;
    VkAccelerationStructureKHR handle;

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
        assert(geometries.length > 0);
        assert(geometries.length == maxPrimitiveCounts.length);
        assert(geometries.length == buildRanges.length);

        getBuildSizes(buildFlags);
        createBuffers();
        createAccelerationStructure();

        doBuild(cmd, buildFlags);

        return this;
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
	VkDeviceSize updateScratchSize;
	VkDeviceSize buildScratchSize;

    // Buffers
    SubBuffer buffer;
    SubBuffer scratchBuffer;
    VkDeviceAddress scratchBufferDeviceAddress;

    void getBuildSizes(VkBuildAccelerationStructureFlagsKHR buildFlags) {
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

        // Note to future me:
        // If this call crashes for no reason then it might be due to one of the instance layers.
        // Try disabling the layers using the vkconfig-gui.exe to see if that fixes it.
        // Possibly related to enabling the VK_LAYER_LUNARG_api_dump layer ??
        vkGetAccelerationStructureBuildSizesKHR(
            device,
            VK_ACCELERATION_STRUCTURE_BUILD_TYPE_DEVICE_KHR,
            &buildGeometryInfo,
            maxPrimitiveCounts.ptr,
            &buildSizes);

        this.accelerationStructureSize = buildSizes.accelerationStructureSize;
        this.updateScratchSize = buildSizes.updateScratchSize;
        this.buildScratchSize = buildSizes.buildScratchSize;    
    }
    void createBuffers() {
        this.buffer = context.buffer(BufID.RT_ACCELERATION)
                             .alloc(accelerationStructureSize, 256);

        this.scratchBuffer = context.buffer(BufID.RT_SCRATCH)
                                    .alloc(buildScratchSize, asProps.minAccelerationStructureScratchOffsetAlignment);

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
    void doBuild(VkCommandBuffer cmd, VkBuildAccelerationStructureFlagsKHR buildFlags) {
        VkAccelerationStructureBuildGeometryInfoKHR buildGeometryInfo = {
            sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR,
            type: type,
            flags: buildFlags,
            mode: VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR,
            dstAccelerationStructure: handle,
            geometryCount: geometries.length.as!int,
            pGeometries: geometries.ptr,
            scratchData: { deviceAddress: scratchBufferDeviceAddress }
        };

        // We are building a single acceleration structure from multiple geometries.
        // The ppBuildRangeInfos is an array of pointers to arrays of VkAccelerationStructureBuildRangeInfoKHR structs,
        // one for each array of geometries.
        //
        // Example with 2 acceleration structures:
        //   rangePtr[0] = accelerationStructure 0 { geometry[0] range, geometry[1] range }
        //   rangePtr[1] = accelerationStructure 1 { geometry[2] range, geometry[3] range }
        //
        VkAccelerationStructureBuildRangeInfoKHR*[] rangePtrs = [ buildRanges.ptr ];

        vkCmdBuildAccelerationStructuresKHR(
            cmd,
            1,
            &buildGeometryInfo,             
            rangePtrs.ptr    
        );
    }
}
