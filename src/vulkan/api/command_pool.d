module vulkan.api.command_pool;

import vulkan.all;

/**
 *  Recommendations:
 *      Use a separate command pool per thread.
 */

VkCommandPool createCommandPool(VkDevice device,
                                uint queueFamily,
                                VkCommandPoolCreateFlags flags = 0)
{
    VkCommandPool pool;
    VkCommandPoolCreateInfo info;

    info.sType            = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO;
    info.queueFamilyIndex = queueFamily;

    // VK_COMMAND_POOL_CREATE_TRANSIENT_BIT
    // VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT
    // VK_COMMAND_POOL_CREATE_PROTECTED_BIT
    info.flags = flags;

    check(vkCreateCommandPool(
        device,
        &info,
        null,
        &pool));

    return pool;
}
void reset(VkDevice device, VkCommandPool pool, bool releaseResources) {
    VkCommandPoolResetFlags flags;
    with(VkCommandPoolResetFlagBits) {
        if(releaseResources) {
            flags |= VK_COMMAND_POOL_RESET_RELEASE_RESOURCES_BIT;
        }
    }
    check(vkResetCommandPool(device, pool, flags));
}

