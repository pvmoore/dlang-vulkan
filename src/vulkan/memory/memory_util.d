module vulkan.memory.memory_util;

import vulkan.all;

/**
 *  Possible improvements:
 *      - Use several gpu memory pools for different allocation sizes.
 *      - Use a different gpu memory pool for short lived allocations.
 *      - Use a different buffer for dynamic allocations
 *      - Have more than 1 large memory block so that the OS can switch one out if necessary
 *      - Try using shared memory to upload data.
 */

struct AllocInfo {
    ulong offset;
    ulong size;
}

/+
void copy(SubBuffer src, ulong srcOffset, SubBuffer dest, ulong dstOffset, ulong numBytes) {
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
/**
    *  Do several non-overlapping copies and block until all are completed.
    *  todo - test this
    */
void copy(SubBuffer[] src, SubBuffer[] dest) {
    uint count = cast(uint)src.length;
    auto cmdBuffers = device.allocFrom(vk.getTransferCP(), count);

    for(auto i=0;i<count;i++) {
        cmdBuffers[i].beginOneTimeSubmit();
        cmdBuffers[i].copyBuffer(src[i].handle, dest[i].handle, [VkBufferCopy(0,0, src[i].size)]);
        cmdBuffers[i].end();
    }

    auto fence = device.createFence();
    vk.getTransferQueue().submit(cmdBuffers, fence);
    device.waitFor(fence);
    device.destroy(fence);

    device.free(vk.getTransferCP(), cmdBuffers);
}
/**
 *  Blocking copy from a device buffer to a host buffer.
 */
void copyDeviceToHost_unused(DeviceBuffer deviceBuffer, ulong deviceOffset,
                        DeviceBuffer hostBuffer, ulong hostOffset,
                        ulong size)
{
    expect(deviceBuffer.memory.isLocal);
    expect(!hostBuffer.memory.isLocal);

    auto region = VkBufferCopy(
        deviceOffset,
        hostOffset,
        size
    );

    logMem("copyDeviceToHost %s bytes from %s:%,s to %s:%,s ", region.size,
        deviceBuffer.name, region.srcOffset,
        hostBuffer.name, region.dstOffset);

    auto b = device.allocFrom(vk.getTransferCP());
    b.beginOneTimeSubmit();
    b.pipelineBarrier(
        VPipelineStage.COMPUTE_SHADER,
        VPipelineStage.TRANSFER,
        0,      // dependencyFlags
        null,   // memory barriers
        [       // buffer memory barriers
            bufferMemoryBarrier(
                deviceBuffer.handle, deviceBuffer.offset, deviceBuffer.size,
                VAccess.SHADER_WRITE,
                VAccess.TRANSFER_READ
            ),
        ],
        null    // image memory barriers
    );
    b.copyBuffer(
        deviceBuffer.handle,
        hostBuffer.handle,
        [region]
    );
    b.pipelineBarrier(
        VPipelineStage.TRANSFER,
        VPipelineStage.HOST,
        0,      // dependencyFlags
        null,   // memory barriers
        [       // buffer memory barriers
            bufferMemoryBarrier(
                hostBuffer.handle, hostBuffer.offset, hostBuffer.size,
                VAccess.TRANSFER_WRITE,
                VAccess.HOST_READ
            ),
        ],
        null    // image memory barriers
    );
    b.end();
    auto fence = device.createFence();

    vk.getTransferQueue().submit([b], fence);

    device.waitFor(fence);
    device.destroyFence(fence);

    device.free(vk.getTransferCP(), b);
}
void copyHostToDevice_unused(SubBuffer hostBuffer, SubBuffer deviceBuffer) {
    expect(hostBuffer.size==deviceBuffer.size);

    auto region = VkBufferCopy(
        hostBuffer.offset,
        deviceBuffer.offset,
        hostBuffer.size
    );

    logMem("copyHostToDevice %s bytes from %s:%,s to %s:%,s ", region.size,
        hostBuffer.name, region.srcOffset,
        deviceBuffer.name, region.dstOffset);

    auto b = device.allocFrom(vk.getTransferCP());
    b.beginOneTimeSubmit();
    b.pipelineBarrier(
        VPipelineStage.HOST,
        VPipelineStage.TRANSFER,
        0,      // dependencyFlags
        null,   // memory barriers
        [       // buffer memory barriers
            bufferMemoryBarrier(
                hostBuffer.handle, hostBuffer.offset, hostBuffer.size,
                VAccess.HOST_WRITE,
                VAccess.TRANSFER_READ
            ),
        ],
        null    // image memory barriers
    );
    b.copyBuffer(
        hostBuffer.handle,
        deviceBuffer.handle,
        [region]
    );
    b.pipelineBarrier(
        VPipelineStage.TRANSFER,
        VPipelineStage.TRANSFER,
        0,      // dependencyFlags
        null,   // memory barriers
        [       // buffer memory barriers
            bufferMemoryBarrier(
                deviceBuffer.handle, deviceBuffer.offset, deviceBuffer.size,
                VAccess.TRANSFER_WRITE,
                VAccess.SHADER_READ
            ),
        ],
        null    // image memory barriers
    );
    b.end();
    auto fence = device.createFence();

    vk.getTransferQueue().submit([b], fence);

    device.waitFor(fence);
    device.destroyFence(fence);

    device.free(vk.getTransferCP(), b);
}
+/