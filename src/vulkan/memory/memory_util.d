module vulkan.memory.memory_util;

import vulkan.all;

/+
void copy(VkDevice device, SubBuffer src, SubBuffer dest) {
    expect(src.size==dest.size);
    copy(device, src, dest, 0, 0, src.size);
}
void copy(VkDevice device, SubBuffer src, SubBuffer dest, ulong srcOffset, ulong dstOffset, ulong numBytes) {
    expect(src.size==dest.size);

    auto region = VkBufferCopy(
        src.offset + srcOffset,
        dest.offset + dstOffset,
        numBytes
    );

    logMem("Copy %s bytes from %s:%,s to %s:%,s ", region.size,
        src.name, region.srcOffset,
        dest.name, region.dstOffset);

    auto b = device.allocFrom(vk.getTransferCP());
    b.beginOneTimeSubmit();
    b.copyBuffer(
        src.handle,
        dest.handle,
        [region]
    );
    // b.pipelineBarrier(
    //     VPipelineStage.TRANSFER,
    //     VPipelineStage.TOP_OF_PIPE,
    //     0,      // dependencyFlags
    //     null,   // memory barriers
    //     [       // buffer memory barriers
    //         bufferMemoryBarrier(
    //             dest.handle, 0, dest.size,
    //             VAccess.MEMORY_WRITE,
    //             VAccess.MEMORY_READ,
    //             vk.queueFamily.transfer,
    //             vk.queueFamily.graphics
    //         ),
    //     ],
    //     null    // image memory barriers
    // );
    b.end();
    auto fence = device.createFence();

    vk.getTransferQueue().submit([b], fence);

    device.waitFor(fence);
    device.destroyFence(fence);

    device.free(vk.getTransferCP(), b);
}
+/