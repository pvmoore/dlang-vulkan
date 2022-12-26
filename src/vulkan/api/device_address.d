module vulkan.api.device_address;

import vulkan.all;


VkDeviceAddress getDeviceAddress(VkDevice device, VkBuffer buffer) {
    VkBufferDeviceAddressInfo info = {
        sType: VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_INFO,
        buffer: buffer
    };
    return vkGetBufferDeviceAddressKHR(device, &info);
}
VkDeviceAddress getDeviceAddress(VkDevice device, DeviceBuffer buffer) {
    return getDeviceAddress(device, buffer.handle);
}
VkDeviceAddress getDeviceAddress(VkDevice device, SubBuffer buffer) {
    return getDeviceAddress(device, buffer.handle()) + buffer.offset;
}

VkDeviceAddress getDeviceAddress(VkDevice device, VkAccelerationStructureKHR as) {
    VkAccelerationStructureDeviceAddressInfoKHR info = {
        sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_DEVICE_ADDRESS_INFO_KHR,
        accelerationStructure: as
    };
    return vkGetAccelerationStructureDeviceAddressKHR(device, &info);
}