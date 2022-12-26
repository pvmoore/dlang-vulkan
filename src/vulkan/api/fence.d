module vulkan.api.fence;

import vulkan.all;

VkFence createFence(VkDevice device, bool signalled = false) {
    VkFence fence;
    VkFenceCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
    info.pNext = null;
    with(VkFenceCreateFlagBits) {
        info.flags = 0;
        if(signalled) info.flags |= VK_FENCE_CREATE_SIGNALED_BIT;
    }
    check(vkCreateFence(device, &info, null, &fence));
    return fence;
}
void reset(VkDevice device, VkFence fence) {
    vkResetFences(device, 1, &fence);
}
void reset(VkDevice device, VkFence[] fences) {
    vkResetFences(device, cast(uint)fences.length, fences.ptr);
}
bool isSignalled(VkDevice device, VkFence fence) {
    return VkResult.VK_SUCCESS==vkGetFenceStatus(device, fence);
}
bool waitFor(VkDevice device, VkFence fence, ulong timeoutNanos = ulong.max) {
    return device.waitFor([fence], true, timeoutNanos);
}
/**
 *  Returns true   - all fences are signalled (or 1 was signalled if waitForAll is false)
 *          false  - timeout occurred
 */
bool waitFor(VkDevice device, VkFence[] fences, bool waitForAll, ulong timeoutNanos = ulong.max) {
    auto r = vkWaitForFences(device, cast(uint)fences.length, fences.ptr, waitForAll.toVkBool32, timeoutNanos);
    if(r!=VkResult.VK_SUCCESS) {
        log("waitFor result = %s", r);
    }
    return VkResult.VK_SUCCESS==r;
}
