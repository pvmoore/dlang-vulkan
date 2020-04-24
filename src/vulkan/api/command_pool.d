module vulkan.api.command_pool;
/**
 * https://www.khronos.org/registry/vulkan/specs/1.0/man/html/vkCreateCommandPool.html
 * https://www.khronos.org/registry/vulkan/specs/1.0/man/html/VkCommandPoolCreateInfo.html
 *
 *  Recommendations:
 *      Use a separate command pool per thread.
 *
 */
import vulkan.all;

VkCommandPool createCommandPool(
    VkDevice device,
    uint queueFamily,
    VkCommandPoolCreateFlags flags=0)
{
    VkCommandPool pool;
    VkCommandPoolCreateInfo info;

    info.sType            = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO;
    info.queueFamilyIndex = queueFamily;

    // VkCommandPoolCreateFlagBits.VK_COMMAND_POOL_CREATE_TRANSIENT_BIT;
    // VkCommandPoolCreateFlagBits.VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
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

