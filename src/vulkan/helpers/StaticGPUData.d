module vulkan.helpers.StaticGPUData;

import vulkan.all;

private __gshared uint ids = 0;

final class StaticGPUData(T) {
private:
    const uint id;
    string name;
    uint numValues;
    @Borrowed VulkanContext context;
    DeviceBuffer buffer;
    VBufferUsage usage;
public:
    DeviceBuffer getBuffer() {
        return buffer;
    }
    uint numBytes() {
        return numValues * T.sizeof.as!uint;
    }

    this(VulkanContext context, uint numValues, VBufferUsage usage = VBufferUsage.NONE) {
        this.id = ids++;
        this.context = context;
        this.numValues = numValues;
        this.usage = VBufferUsage.STORAGE | VBufferUsage.TRANSFER_DST | usage;
        this.name = "StaticGPUData%s".format(id);

        createBuffer();
    }
    void destroy() {
        if(buffer) buffer.destroy();
    }
    auto uploadData(T[] data) {
        context.transfer().from(data.ptr).to(buffer).size(numBytes());
        return this;
    }
private:
    void createBuffer() {
        this.buffer = context.memory(MemID.LOCAL).allocBuffer(name, numBytes(), usage);
    }
}