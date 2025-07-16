module vulkan.helpers.raytracing.AccelerationStructure;

import vulkan.all;

final class AccelerationStructure {
public:
    VkDeviceAddress deviceAddress;
    VkAccelerationStructureKHR handle;

    this(VulkanContext context, bool isTopLevel, string name) {
        this.context = context;
        this.device = context.device;
        this.isTopLevel = isTopLevel;
        this.name = name;
        this.type = isTopLevel ? VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR :
                                 VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR;

        this.asProps = context.vk.physicalDevice.getAccelerationStructureProperties();                                 
    }
    void destroy() {
        if(handle) device.destroyAccelerationStructure(handle);
    }
    auto addTriangles(VkGeometryFlagBitsKHR flags, VkAccelerationStructureGeometryTrianglesDataKHR triangles, uint maxPrimitives) {
        assert(!isTopLevel);

        // Useful flags:
        // VK_GEOMETRY_OPAQUE_BIT_KHR
        // VK_GEOMETRY_NO_DUPLICATE_ANY_HIT_INVOCATION_BIT_KHR

        VkAccelerationStructureGeometryKHR geometry = {
            sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR,
            flags: flags,
            geometryType: VK_GEOMETRY_TYPE_TRIANGLES_KHR,
            geometry: { triangles: triangles }   
        };
        VkAccelerationStructureBuildRangeInfoKHR buildRangeInfo = {
            primitiveCount: maxPrimitives,
            primitiveOffset: 0,
            firstVertex: 0,
            transformOffset: 0
        };
        geometries ~= geometry;
        buildRanges ~= buildRangeInfo;
        maxPrimitiveCounts ~= maxPrimitives;
        return this;
    }
    auto addAABBs(VkGeometryFlagBitsKHR flags, ulong deviceAddress, ulong stride, uint maxPrimitives) {
        VkAccelerationStructureGeometryAabbsDataKHR aabbs = {
            sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_AABBS_DATA_KHR,
            pNext: null,
            stride: stride,
            data: { deviceAddress: deviceAddress }
        };
        return addAABBs(flags, aabbs, maxPrimitives);
    }
    auto addAABBs(VkGeometryFlagBitsKHR flags, VkAccelerationStructureGeometryAabbsDataKHR aabbs, uint maxPrimitives) {
        assert(!isTopLevel);

        // Useful flags:
        // VK_GEOMETRY_OPAQUE_BIT_KHR
        // VK_GEOMETRY_NO_DUPLICATE_ANY_HIT_INVOCATION_BIT_KHR

        VkAccelerationStructureGeometryKHR geometry = {
            sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR,
            flags: flags,
            geometryType: VK_GEOMETRY_TYPE_AABBS_KHR,
            geometry: {  aabbs: aabbs }
        };
        VkAccelerationStructureBuildRangeInfoKHR buildRangeInfo = {
            primitiveCount: maxPrimitives,
            primitiveOffset: 0,
            firstVertex: 0,
            transformOffset: 0
        };
        geometries ~= geometry;
        buildRanges ~= buildRangeInfo;
        maxPrimitiveCounts ~= maxPrimitives;
        return this;
    }
    auto addInstances(VkGeometryFlagBitsKHR flags, VkDeviceAddress deviceAddress, uint numInstances, bool arrayOfPointers = false) {
        assert(isTopLevel);

        VkAccelerationStructureGeometryInstancesDataKHR instances = {
            sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_INSTANCES_DATA_KHR,
            arrayOfPointers: arrayOfPointers.toVkBool32(),
            data: { deviceAddress: deviceAddress }
        };

        VkAccelerationStructureGeometryKHR geometry = {
            sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR,
            geometryType: VK_GEOMETRY_TYPE_INSTANCES_KHR,
            flags: flags,
            geometry: { instances: instances }
        };
        VkAccelerationStructureBuildRangeInfoKHR buildRangeInfo = {
            primitiveCount: numInstances,
            primitiveOffset: 0,
            firstVertex: 0,
            transformOffset: 0
        };
        geometries ~= geometry;
        buildRanges ~= buildRangeInfo;
        maxPrimitiveCounts ~= numInstances;
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
        assert(geometries.length > 0);
        assert(geometries.length == maxPrimitiveCounts.length);
        assert(geometries.length == buildRanges.length);

        getBuildSizes(buildFlags);
        createBuffers();
        createAccelerationStructure();

        VkAccelerationStructureBuildRangeInfoKHR*[] rangePtrs;
        foreach(ref range; buildRanges) {
            rangePtrs ~= &range;
        }
        doBuild(cmd, buildFlags, rangePtrs);

        return this;
    }
private:
    VulkanContext context;
    VkDevice device;
    bool isTopLevel;
    string name;
    VkAccelerationStructureTypeKHR type;
    VkPhysicalDeviceAccelerationStructurePropertiesKHR asProps;

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
        vkGetAccelerationStructureBuildSizesKHR(
            context.device,
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
    void doBuild(VkCommandBuffer cmd, 
                 VkBuildAccelerationStructureFlagsKHR buildFlags, 
                 VkAccelerationStructureBuildRangeInfoKHR*[] rangePtrs) 
    in{
        assert(rangePtrs.length > 0);
    }
    do{
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

        vkCmdBuildAccelerationStructuresKHR(
            cmd,
            1,
            &buildGeometryInfo,             
            rangePtrs.ptr    
        );
    }
}
