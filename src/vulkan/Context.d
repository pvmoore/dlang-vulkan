module vulkan.Context;

import vulkan.all;

final class VulkanContext {
    DeviceMemory localMemory;
    DeviceMemory stagingMemory;
    DeviceBuffer localBuffer;
    DeviceBuffer stagingBuffer;
}