module vulkan.helpers.Transfer;

import vulkan.all;

/**
 *  context.transfer().from(src).to(dest).size(100);
 *  context.transfer().from(src, 100).to(dest, 10).size(1000);
 */
final class Transfer {
public:
    this(VulkanContext context) {
        this.context = context;
        this.device = context.device;
        this.transferCP = context.vk.getTransferCP();
        this.transferQueue = context.vk.getTransferQueue();
    }

    auto from(DeviceBuffer buffer, ulong offset = 0) {
        return new TransferState(this, Location.fromBuffer(buffer, offset));
    }
    auto from(SubBuffer buffer, ulong offset = 0) {
        return new TransferState(this, Location.fromBuffer(buffer.parent, buffer.offset + offset));
    }
    auto from(void* ptr, ulong offset = 0) {
        return new TransferState(this, Location.fromData(ptr, offset));
    }

    void blockingCopy(DeviceBuffer src, ulong srcOffset, DeviceBuffer dest, ulong destOffset, ulong size) {
        auto cmd = device.allocFrom(transferCP);
        cmd.beginOneTimeSubmit();

        copy(cmd, src, srcOffset, dest, destOffset, size, AccessAndStageMasks(
            VkAccessFlagBits.VK_ACCESS_MEMORY_READ_BIT,
            VkAccessFlagBits.VK_ACCESS_MEMORY_READ_BIT,
            VkPipelineStageFlagBits.VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT,
            VkPipelineStageFlagBits.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT
        ));

        cmd.end();

        auto fence = device.createFence();
        transferQueue.submit([cmd], fence);
        device.waitFor(fence);
        device.destroyFence(fence);

        device.free(transferCP, cmd);
    }
    void copy(VkCommandBuffer cmd, SubBuffer src, SubBuffer dest, 
                                   AccessAndStageMasks accessAndStageMasks) {
        throwIf(src.size != dest.size);
        copy(cmd, src.parent, src.offset, dest.parent, dest.offset, src.size, accessAndStageMasks);
    }
    void copy(VkCommandBuffer cmd, DeviceBuffer src, ulong srcOffset,
                                   DeviceBuffer dest, ulong destOffset, ulong size,
                                   AccessAndStageMasks accessAndStageMasks)
    {
        debug {
            this.log("copy %s bytes from %s@%,s to %s@%,s src = 0x%x dest = 0x%x",
                size,
                src.name, srcOffset,
                dest.name, destOffset,
                src.handle, dest.handle);
        }

        cmd.beforeTransferBarrier(accessAndStageMasks);     

        cmd.copyBuffer(src.handle, srcOffset, dest.handle, destOffset, size);

        cmd.afterTransferBarrier(accessAndStageMasks);
    }
private:
    VulkanContext context;
    VkCommandPool transferCP;
    VkQueue transferQueue;
    VkDevice device;

    void go(TransferState state) {

        if(state.src.isHostVisible() && state.dest.isHostVisible()) {
            hostToHost(state);

        } else if(state.src.isHostVisible() && !state.dest.isHostVisible()) {
            hostToDevice(state);

        } else if(!state.src.isHostVisible() && state.dest.isHostVisible()) {
            deviceToHost(state);

        } else {
            deviceToDevice(state);
        }
    }
    /**
     *  Memcpy
     */
    void hostToHost(TransferState state) {

        void* srcPtr = state.src.isPtr
            ? state.src.data
            : state.src.buffer.mapForReading();

        void* destPtr = state.dest.isPtr
            ? state.dest.data
            : state.dest.buffer.map();

        memcpy(destPtr + state.dest.offset,
               srcPtr + state.src.offset,
               state._size);

        if(state.dest.isBuffer) state.dest.buffer.flush(state.dest.offset, state._size);
    }
    /**
     *  Upload via staging
     */
    void hostToDevice(TransferState state) {
        throwIf(!state.dest.isBuffer);

        SubBuffer stagingSub;
        DeviceBuffer srcBuffer;
        ulong srcOffset;

        if(state.src.isPtr()) {

            stagingSub = context.buffer(BufID.STAGING).alloc(state._size);
            srcBuffer = stagingSub.parent;
            srcOffset = stagingSub.offset;

            void* ptr = stagingSub.map();
            memcpy(ptr, state.src.data + state.src.offset, state._size);
            stagingSub.flush();

        } else {
            srcBuffer = state.src.buffer;
            srcOffset = state.src.offset;
        }

        blockingCopy(srcBuffer, srcOffset, state.dest.buffer, state.dest.offset, state._size);

        if(stagingSub) stagingSub.free();
    }
    /**
     *  Download via staging
     */
    void deviceToHost(TransferState state) {
        throwIf(!state.src.isBuffer);

        SubBuffer stagingSub;
        DeviceBuffer destBuffer;
        ulong destOffset;

        if(state.dest.isPtr()) {
            stagingSub = context.buffer(BufID.STAGING_DOWN).alloc(state._size);
            destBuffer = stagingSub.parent;
            destOffset = stagingSub.offset;
        } else {
            destBuffer = state.dest.buffer;
            destOffset = state.dest.offset;
        }

        blockingCopy(state.src.buffer, state.src.offset, destBuffer, destOffset, state._size);

        // Copy data to dest ptr
        if(stagingSub) {

            void* ptr = destBuffer.mapForReading();
            memcpy(state.dest.data, ptr + destOffset, state._size);

            stagingSub.free();
        }
    }
    /**
     *  Device buffer copy
     */
    void deviceToDevice(TransferState state) {
        throwIf(!state.src.isBuffer);
        throwIf(!state.dest.isBuffer);

        blockingCopy(state.src.buffer, state.src.offset, state.dest.buffer, state.dest.offset, state._size);
    }
}

// #################################################################################################

struct Location {
    DeviceBuffer buffer;
    void* data;
    ulong offset;
    bool isBuffer;

    bool isSet()         { return (data !is null) || (buffer !is null); }
    bool isPtr()         { return !isBuffer; }
    bool isHostVisible() { return isPtr() || buffer.memory.isHostVisible(); }

    static Location fromBuffer(DeviceBuffer b, ulong offset) {
        return Location(b, null, offset, true);
    }
    static Location fromData(void* data, ulong offset) {
        return Location(null, data, offset, false);
    }
}

// #################################################################################################

final class TransferState {
private:
    Transfer transfer;
    Location src, dest;
    ulong _size;
public:
    this(Transfer transfer, Location src) {
        this.transfer = transfer;
        this.src = src;
    }
    override string toString() {
        return "TransferState(%s, %s, %s)".format(src, dest, _size);
    }

    auto to(DeviceBuffer buffer, ulong offset = 0) {
        this.dest = Location.fromBuffer(buffer, offset);
        return this;
    }
    auto to(SubBuffer buffer, ulong offset = 0) {
        this.dest = Location.fromBuffer(buffer.parent, buffer.offset + offset);
        return this;
    }
    auto to(void* ptr, ulong offset = 0) {
        this.dest = Location.fromData(ptr, offset);
        return this;
    }
    void size(ulong size) {
        this._size = size;

        if(_size==0) throw new Error("Transfer size is 0");
        if(!src.isSet()) throw new Error("Transfer src is not set");
        if(!dest.isSet()) throw new Error("Transfer dest is not set");

        transfer.go(this);
    }
}
