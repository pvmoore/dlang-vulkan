module vulkan.api.queue;

import vulkan.all;

/// gets a queue which was created when the logical device was created.
/// See physical_device
VkQueue getQueue(VkDevice device, uint familyIndex, uint queueIndex) {
    VkQueue handle;
    vkGetDeviceQueue(
        device,
        familyIndex,
        queueIndex,
        &handle);
    return handle;
}
void submit(VkQueue queue, VkCommandBuffer[] cmdBuffers, VkFence fence) {
    queue.submit(cmdBuffers, null, null, null, fence);
}
void submit(VkQueue queue,
            VkCommandBuffer[] cmdBuffers,
            VkSemaphore[] waitSemaphores,
            VPipelineStage[] waitStages,
            VkSemaphore[] signalSemaphores,
            VkFence fence)
{
    VkSubmitInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_SUBMIT_INFO;

    info.waitSemaphoreCount = cast(uint)waitSemaphores.length;
    info.pWaitSemaphores    = waitSemaphores.ptr;
    info.pWaitDstStageMask  = cast(uint*)waitStages.ptr;

    info.signalSemaphoreCount = cast(uint)signalSemaphores.length;
    info.pSignalSemaphores    = signalSemaphores.ptr;

    info.commandBufferCount = cast(uint)cmdBuffers.length;
    info.pCommandBuffers    = cmdBuffers.ptr;

    check(vkQueueSubmit(
        queue,
        1,
        &info,
        fence
    ));
}
void submitAndWait(
    VkDevice device,
    VkQueue queue,
    VkCommandBuffer[] cmdBuffers,
    VkSemaphore[] waitSemaphores,
    VPipelineStage[] waitStages,
    VkSemaphore[] signalSemaphores)
{
    auto fence = device.createFence();
    queue.submit(cmdBuffers, waitSemaphores, waitStages, signalSemaphores, fence);
    device.waitFor(fence);
    device.destroyFence(fence);
}
void submitAndWait(VkDevice device, VkQueue queue, VkCommandBuffer cmd) {
    auto fence = device.createFence();
    queue.submit([cmd], fence);
    device.waitFor(fence);
    device.destroyFence(fence);
}
void bindSparse(VkQueue queue, VkFence fence, VkBindSparseInfo[] infos) {
    check(vkQueueBindSparse(queue, cast(uint)infos.length, infos.ptr, fence));
}
auto deviceQueueCreateInfo(uint family, float[] priorities) {
    VkDeviceQueueCreateInfo info;
    info.sType            = VkStructureType.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
    info.queueFamilyIndex = family;
    info.queueCount		  = cast(uint)priorities.length;
    info.pQueuePriorities = priorities.ptr;
    return info;
}
