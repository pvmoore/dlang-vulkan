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

/**
 *  Blocking copy of data from host to device.
 */
void copyHostToDeviceSync(T)(VulkanContext context, T* dataItem, SubBuffer destBuffer, ulong destOffset = 0) {
    copyHostToDeviceSync(context, dataItem, T.sizeof, destBuffer.parent, destBuffer.offset + destOffset);
}
void copyHostToDeviceSync(VulkanContext context, void* data, ulong numBytes, SubBuffer destBuffer, ulong destOffset = 0) {
    copyHostToDeviceSync(context, data, numBytes, destBuffer.parent, destBuffer.offset + destOffset);
}
void copyHostToDeviceSync(VulkanContext context, void* data, ulong numBytes, DeviceBuffer destBuffer, ulong destOffset = 0) {

    version(LOG_MEM) {
        StopWatch w; w.start();
    }

    SubBuffer src = context.buffer(BufID.STAGING).alloc(numBytes);

    void* ptr = src.map();
    memcpy(ptr, data, numBytes);
    src.flush();

    context.copySync(src.parent, src.offset, destBuffer, destOffset, numBytes);

    src.free();

    version(LOG_MEM) {
        w.stop();
        log("copyHostToDeviceSync: Took %.3f ms to copy %s bytes", w.peek().total!"nsecs"/1_000_000.0, numBytes);
    }
}

/**
 *  Blocking buffer copy.
 */
void copySync(VulkanContext context,
              SubBuffer srcBuffer, ulong srcOffset,
              SubBuffer destBuffer, ulong destOffset,
              ulong size)
{
    copySync(context, srcBuffer.parent, srcBuffer.offset+srcOffset,
                      destBuffer.parent, destBuffer.offset+destOffset,
                      size);
}
void copySync(VulkanContext context,
              DeviceBuffer srcBuffer, ulong srcOffset,
              DeviceBuffer destBuffer, ulong destOffset,
              ulong size)
{
    auto device = context.device;
    auto vk = context.vk;

    VkBufferCopy region = {
        srcOffset: srcOffset,
        dstOffset: destOffset,
        size: size
    };

    version(LOG_MEM)
        log("copySync %s bytes from %s@%,s to %s@%,s ", region.size,
            srcBuffer.name, region.srcOffset,
            destBuffer.name, region.dstOffset);

    auto b = device.allocFrom(vk.getTransferCP());
    b.beginOneTimeSubmit();

    b.copyBuffer(
        srcBuffer.handle,
        destBuffer.handle,
        [region]
    );

    b.end();

    auto fence = device.createFence();
    vk.getTransferQueue().submit([b], fence);
    device.waitFor(fence);
    device.destroyFence(fence);

    device.free(vk.getTransferCP(), b);
}

/+

/**
    *  Copy data to a buffer on the GPU
    *  via a staging buffer in host memory.
    */
void copyToDevice(SubBuffer dest, void* data) {
    copyToDevice(dest, data, 0, dest.size);
}
void copyToDevice(SubBuffer dest, void* data, ulong dstOffset, ulong numBytes) {
    StopWatch w; w.start();

    // create staging subbuffer as transfer source
    SubBuffer src = createStagingBuffer(dest.size);

    // memcpy the data to staging subbuffer
    void* ptr = staging.map(src);
    memcpy(ptr+dstOffset, data, numBytes);
    staging.flush(src);

    // copy from staging to dest
    copy(src, dstOffset, dest, dstOffset, numBytes);

    src.free();

    w.stop();
    logMem("copyToDevice: Took %.3f ms to copy %s bytes", w.peek().total!"nsecs"/1000000.0, dest.size);
}
void copy(SubBuffer src, SubBuffer dest) {
    expect(src.size==dest.size);
    copy(src, 0, dest, 0, src.size);
}
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
    *  Blocking copy between two DeviceBuffers.
    *  No barriers are used.
    */
void copy(DeviceBuffer srcBuffer, ulong srcOffset,
            DeviceBuffer destBuffer, ulong destOffset,
            ulong size)
{
    auto region = VkBufferCopy(
        srcOffset,
        destOffset,
        size
    );

    logMem("copy %s bytes from %s:%,s to %s:%,s ", region.size,
        srcBuffer.name, region.srcOffset,
        destBuffer.name, region.dstOffset);

    auto b = device.allocFrom(vk.getTransferCP());
    b.beginOneTimeSubmit();

    b.copyBuffer(
        srcBuffer.handle,
        destBuffer.handle,
        [region]
    );

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
*  Blocking copy of data to a DeviceBuffer.
*  Assumes data size (bytes)==destDB.size.
*/
void copyToDevice(DeviceBuffer destDB, void* data) {
    expect(destDB.memory.isLocal);

    auto dest = new SubBuffer(destDB, 0, destDB.size, destDB.usage, AllocInfo(0, destDB.size));
    auto src  = createStagingBuffer(destDB.size);

    // memcpy the data to staging subbuffer
    void* ptr = src.map();
    memcpy(ptr, data, destDB.size);
    src.flush();

    copy(src, dest);
    src.free();
}
/**
    *  Blocking copy of device data to host.
    */
T[] copyToHost(T)(DeviceBuffer buffer) {
    return copyToHost!T(new SubBuffer(buffer, 0, buffer.size, buffer.usage));
}
T[] copyToHost(T)(DeviceBuffer buffer, ulong offset, ulong size) {
    return copyToHost!T(new SubBuffer(buffer, offset, size, buffer.usage));
}
T[] copyToHost(T)(SubBuffer deviceBuffer) {
    expect(deviceBuffer.memory.isLocal);

    auto size  = deviceBuffer.size;
    auto stage = createStagingBuffer(size);

    copy(deviceBuffer, stage);

    T[] data = new T[size/T.sizeof];

    void* ptr = stage.mapForReading();
    memcpy(data.ptr, ptr, size);
    stage.free();

    return data;
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