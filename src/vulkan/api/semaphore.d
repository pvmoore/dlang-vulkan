module vulkan.api.semaphore;
/**
 *
 */
import vulkan.all;

VkSemaphore createSemaphore(VkDevice device) {
    VkSemaphore semaphore;
    VkSemaphoreCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO;
    info.flags = 0;
    check(vkCreateSemaphore(device, &info, null, &semaphore));
    return semaphore;
}
void destroy(VkDevice device, VkSemaphore semaphore) {
    vkDestroySemaphore(device, semaphore, null);
}

