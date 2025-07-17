module vulkan.helpers.raytracing.BLAS;

import vulkan.all;

final class BLAS : AccelerationStructure {
public:
    this(VulkanContext context, string name) {
        super(context, name);
        this.type = VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR;
    }
    auto addTriangles(VkGeometryFlagBitsKHR flags, VkAccelerationStructureGeometryTrianglesDataKHR triangles, uint maxPrimitives) {

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
private:
}
