module vulkan.api.acceleration_structure;

import vulkan.all;

/**
 * Create and return an identity (3x4) matrix
 *
 * 1  0  0  0
 * 0  1  0  0
 * 0  0  1  0
 */
VkTransformMatrixKHR identityTransformMatrix() {
    VkTransformMatrixKHR transform;

    float* fp = (&transform).as!(float*);
    fp[0..VkTransformMatrixKHR.sizeof/4] = 0.0f;

    transform.matrix[0][0] = 1;
    transform.matrix[1][1] = 1;
    transform.matrix[2][2] = 1;
    return transform;
}
/**
 *
 */
VkAccelerationStructureKHR createAccelerationStructure(
    VkDevice device,
    bool isTopLevel,
    SubBuffer buffer,
    VkAccelerationStructureCreateFlagBitsKHR flags = 0.as!VkAccelerationStructureCreateFlagBitsKHR)
{

    // enum VkAccelerationStructureCreateFlagBitsKHR {
    //     VK_ACCELERATION_STRUCTURE_CREATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT_KHR = 0x00000001,
    //     VK_ACCELERATION_STRUCTURE_CREATE_MOTION_BIT_NV = 0x00000004,
    // }
    // enum VkAccelerationStructureTypeKHR {
    //     VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR = 0,
    //     VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR = 1,
    //     VK_ACCELERATION_STRUCTURE_TYPE_GENERIC_KHR = 2,
    // }

    auto type = isTopLevel ? VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR :
                             VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR;

    throwIf(buffer.offset%256 != 0, "Buffer offset must be a multiple of 256");

    VkAccelerationStructureCreateInfoKHR info = {
        sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_KHR,
        type: type,
        createFlags: flags,         // VkAccelerationStructureCreateFlagsKHR createFlags
        buffer: buffer.handle(),    // VkBuffer buffer
        offset: buffer.offset,      // must be a multiple of 256
        size: buffer.size,          // size of acceleration structure
        deviceAddress: 0            // VkDeviceAddress deviceAddress (accelerationStructureCaptureReplay only)
    };
    VkAccelerationStructureKHR ptr;
    check(vkCreateAccelerationStructureKHR(device, &info, null, &ptr));
    return ptr;
}

/**
 *
 */
void buildAccelerationStructure(
    VkDevice device,
    VkCommandPool commandPool,
    VkQueue queue,
    VkAccelerationStructureBuildGeometryInfoKHR[] buildInfos,
    VkAccelerationStructureBuildRangeInfoKHR*[] rangeInfos)
{
    auto cmd = device.allocFrom(commandPool);
    cmd.beginOneTimeSubmit();

    vkCmdBuildAccelerationStructuresKHR(
        cmd,
        buildInfos.length.as!uint,
        buildInfos.ptr,                 // VkAccelerationStructureBuildGeometryInfoKHR*
        rangeInfos.ptr                  // VkAccelerationStructureBuildRangeInfoKHR**
    );

    cmd.end();

    auto fence = device.createFence();
    queue.submit([cmd], fence);
    device.waitFor(fence);
    device.destroyFence(fence);

    device.free(commandPool, cmd);
}

VkAccelerationStructureBuildSizesInfoKHR getRequiredSize(
    VkDevice device,
    VkAccelerationStructureBuildGeometryInfoKHR[] buildInfos,
    uint[] primitiveCounts,
    bool isOnDevice)
{
    throwIf(buildInfos.length != primitiveCounts.length);

    // enum VkAccelerationStructureBuildTypeKHR {
    //     VK_ACCELERATION_STRUCTURE_BUILD_TYPE_HOST_KHR = 0,
    //     VK_ACCELERATION_STRUCTURE_BUILD_TYPE_DEVICE_KHR = 1,
    //     VK_ACCELERATION_STRUCTURE_BUILD_TYPE_HOST_OR_DEVICE_KHR = 2,
    // }

    VkAccelerationStructureBuildTypeKHR type =
        isOnDevice ? VK_ACCELERATION_STRUCTURE_BUILD_TYPE_DEVICE_KHR :
                     VK_ACCELERATION_STRUCTURE_BUILD_TYPE_HOST_KHR;

    VkAccelerationStructureBuildSizesInfoKHR sizeInfo = {
        sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR
    };
    vkGetAccelerationStructureBuildSizesKHR(
        device,
        type,
        buildInfos.ptr,         // VkAccelerationStructureBuildGeometryInfoKHR*
        primitiveCounts.ptr,    //uint32_t* pMaxPrimitiveCounts,
        &sizeInfo
    );
    return sizeInfo;
}

/**
 * I : Index type (uint, ushort, ubyte, void)
 *
 * geometryTriangles!(Vertex,uint)(...)
 *
 * NOTE: Assumes x,y,z (float) are at the start of the vertex structure
 */
VkAccelerationStructureGeometryKHR geometryTrianglesLocal(I)(
    uint maxVertex,
    uint vertexStride,
    VkDeviceAddress vertexData,
    VkDeviceAddress indexData,
    VkDeviceAddress transformData)
in {
    static assert(is(I==uint) || is(I==ushort) || is(I==ubyte) || is(I==void));
} do {
    // VK_GEOMETRY_OPAQUE_BIT_KHR
    // VK_GEOMETRY_NO_DUPLICATE_ANY_HIT_INVOCATION_BIT_KHR

    VkAccelerationStructureGeometryKHR geom = {
        sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR,
        pNext: null,
        geometryType: VK_GEOMETRY_TYPE_TRIANGLES_KHR,       // VkGeometryTypeKHR geometryType;
        flags: VK_GEOMETRY_OPAQUE_BIT_KHR                   // VkGeometryFlagsKHR flags;
        // VkAccelerationStructureGeometryDataKHR geometry;
    };

    VkIndexType indexType = is(I==uint)   ? VK_INDEX_TYPE_UINT32 :
                            is(I==ushort) ? VK_INDEX_TYPE_UINT16 :
                            is(I==ubyte)  ? VK_INDEX_TYPE_UINT8_EXT : 0;

    VkAccelerationStructureGeometryTrianglesDataKHR triangles = {
        sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR,
        pNext: null,
        vertexFormat: VK_FORMAT_R32G32B32_SFLOAT,
        vertexStride: vertexStride,
        maxVertex: maxVertex,
        indexType: indexType,
    };
    triangles.vertexData.deviceAddress = vertexData;
    triangles.indexData.deviceAddress = indexData;
    triangles.transformData.deviceAddress = transformData;

    geom.geometry.triangles = triangles;
    return geom;
}

VkAccelerationStructureBuildGeometryInfoKHR buildGeometryInfoBLAS(VkAccelerationStructureGeometryKHR[] geometries)
{
    // VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR
    // VK_BUILD_ACCELERATION_STRUCTURE_MODE_UPDATE_KHR

    // VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_UPDATE_BIT_KHR
    // VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_COMPACTION_BIT_KHR
    // VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR
    // VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_BUILD_BIT_KHR
    // VK_BUILD_ACCELERATION_STRUCTURE_LOW_MEMORY_BIT_KHR
    // VK_BUILD_ACCELERATION_STRUCTURE_MOTION_BIT_NV

    VkAccelerationStructureBuildGeometryInfoKHR buildInfo = {
        sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR,
        pNext: null,
        type: VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR,
        flags: VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR,
        mode: VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR,
        //srcAccelerationStructure: null,           // Used when mode is UPDATE
        //dstAccelerationStructure: null,           // Build target
        geometryCount: geometries.length.as!uint,
        pGeometries: geometries.ptr,                // VkAccelerationStructureGeometryKHR*
        ppGeometries: null                          // VkAccelerationStructureGeometryKHR**
        //scratchData:                              // VkDeviceOrHostAddressKHR
    };
    return buildInfo;
}

/**
 * V : Vertex type
 * I : Index type (uint, ushort, ubyte)
 *
 * geometryTriangles!(Vertex,uint)(...)
 */
VkAccelerationStructureGeometryKHR geometryTrianglesOnHost(V,I)(
    V[] vertexData,
    I[] indexData,
    void* transformData)
in {
    static assert(is(I==uint) || is(I==ushort) || is(I==ubyte));
} do {
    // VK_GEOMETRY_OPAQUE_BIT_KHR
    // VK_GEOMETRY_NO_DUPLICATE_ANY_HIT_INVOCATION_BIT_KHR

    VkAccelerationStructureGeometryKHR geom = {
        sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR,
        pNext: null,
        geometryType: VK_GEOMETRY_TYPE_TRIANGLES_KHR,       // VkGeometryTypeKHR geometryType;
        flags: VK_GEOMETRY_OPAQUE_BIT_KHR                   // VkGeometryFlagsKHR flags;
        // VkAccelerationStructureGeometryDataKHR geometry;
    };

    VkIndexType indexType = is(I==uint) ? VK_INDEX_TYPE_UINT32 :
                            is(I==ushort) ? VK_INDEX_TYPE_UINT16 : VK_INDEX_TYPE_UINT8_EXT;

    VkAccelerationStructureGeometryTrianglesDataKHR triangles = {
        sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR,
        pNext: null,
        vertexFormat: VK_FORMAT_R32G32B32_SFLOAT,   // VkFormat vertexFormat;
        vertexStride: V.sizeof,
        maxVertex: vertexData.length.as!uint,
        indexType: indexType,
        // VkDeviceOrHostAddressConstKHR vertexData
        // VkDeviceOrHostAddressConstKHR indexData
        // VkDeviceOrHostAddressConstKHR transformData
    };
    triangles.vertexData.hostAddress = vertexData.ptr;
    triangles.indexData.hostAddress = indexData.ptr;
    triangles.transformData.hostAddress = transformData;

    geom.geometry.triangles = triangles;
    return geom;
}