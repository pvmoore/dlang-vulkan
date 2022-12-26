# Vulkan Ray Tracing

[Ray Tracing Spec 1.2](https://registry.khronos.org/vulkan/specs/1.2-khr-extensions/html/chap34.html)

## Functions

vkCreateAccelerationStructureKHR
- VkDevice device
- VkAccelerationStructureCreateInfoKHR* pCreateInfo
- VkAllocationCallbacks* pAllocator
- VkAccelerationStructureKHR* pAccelerationStructure

vkCmdTraceRaysKHR
- VkCommandBuffer commandBuffer
- VkStridedDeviceAddressRegionKHR* pRaygenShaderBindingTable
- VkStridedDeviceAddressRegionKHR* pMissShaderBindingTable
- VkStridedDeviceAddressRegionKHR* pHitShaderBindingTable
- VkStridedDeviceAddressRegionKHR* pCallableShaderBindingTable
- uint32_t width
- uint32_t height
- uint32_t depth


vkCmdBuildAccelerationStructuresKHR
- VkCommandBuffer commandBuffer
- uint32_t infoCount
- VkAccelerationStructureBuildGeometryInfoKHR* pInfos
- VkAccelerationStructureBuildRangeInfoKHR** ppBuildRangeInfos

vkCmdBuildAccelerationStructuresIndirectKHR
- VkCommandBuffer commandBuffer
- uint32_t infoCount
- VkAccelerationStructureBuildGeometryInfoKHR* pInfos
- VkDeviceAddress* pIndirectDeviceAddresses
- uint32_t* pIndirectStrides
- uint32_t** ppMaxPrimitiveCounts

## Shader Extensions

- .rgen  - ray generation shader
- .rint  - ray intersection shader
- .rahit - any hit shader
- .rchit - closest hit shader
- .rmiss - miss shader
- .rcall - ray callable shader

## Shader Binding Table (SBT)

## Acceleration Structures

### Top Level Acceleration Structure (TLAS)

Holds instances which point to one of the BLAS structures.

### Bottom Level Acceleration Structure (BLAS)

Holds geometry instance data.