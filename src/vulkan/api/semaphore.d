module vulkan.api.semaphore;

import vulkan.all;

VkSemaphore createSemaphore(VkDevice device) {
    VkSemaphoreCreateInfo info = {
        sType: VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO,
        flags: 0
    };

    VkSemaphore semaphore;

    check(vkCreateSemaphore(device, &info, null, &semaphore));
    return semaphore;
}
