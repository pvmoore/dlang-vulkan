module vulkan.generators.VkRandomBuffer;

import vulkan.all;

private __gshared uint ids = 0;

final class VkRandomBuffer {
private:
    const uint id;
    string name;
    uint numValues;
    @Borrowed VulkanContext context;
    DeviceBuffer buffer;
public:
    DeviceBuffer getBuffer() {
        return buffer;
    }
    uint numBytes() {
        return numValues * float.sizeof.as!uint;
    }

    this(VulkanContext context, uint numValues, float minValue = 0, float maxValue = 1, uint seed = unpredictableSeed) {
        this.id = ids++;
        this.context = context;
        this.numValues = numValues;
        this.name = "RandomImage%s".format(id);

        createBuffer();
        uploadData(seed, minValue, maxValue);
    }
    void destroy() {
        //if(buffer) buffer.free();
    }
private:
    void createBuffer() {
        auto usage = VBufferUsage.STORAGE | VBufferUsage.TRANSFER_DST;
        this.buffer = context.memory(MemID.LOCAL).allocBuffer(name, numBytes(), usage);
    }
    void uploadData(uint seed, float minValue, float maxValue) {
        Mt19937 rng;
        rng.seed(seed);

        float[] data = new float[numValues];

        foreach(i; 0..numValues) {
            data[i] = uniform(minValue, maxValue);
        }

        context.transfer().from(data.ptr).to(buffer).size(numBytes());
    }
}