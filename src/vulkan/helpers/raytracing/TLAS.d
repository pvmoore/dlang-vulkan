module vulkan.helpers.raytracing.TLAS;

import vulkan.all;

final class TLAS : AccelerationStructure {
public:
    this(VulkanContext context, string name, VkBuildAccelerationStructureFlagBitsKHR buildFlags) {
        super(context, name, buildFlags);
        this.type = VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR;
    }
    auto addInstances(VkGeometryFlagBitsKHR flags, VkDeviceAddress deviceAddress, uint numInstances, bool arrayOfPointers = false) {
        
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
        requiredBuildRanges ~= buildRangeInfo;
        rebuildRequired = true;
        return this;
    }
private:
}
