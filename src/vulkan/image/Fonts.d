module vulkan.image.Fonts;

import vulkan.all;

final class Fonts {
private:
    Vulkan vk;
    VkDevice device;
    DeviceMemory deviceMemory, stagingUpMemory;
    DeviceBuffer stagingBuffer;

    Font[string] fonts;
    ulong allocationUsed;
public:
    this(Vulkan vk) {
        this.vk = vk;
        this.device = vk.device;

        this.deviceMemory = vk.memory.allocDeviceMemory("Fonts_device", 1.MB, VMemoryProperty.DEVICE_LOCAL, VMemoryProperty.HOST_VISIBLE);
        this.stagingUpMemory = vk.memory.allocDeviceMemory("Fonts_staging", 1.MB, VMemoryProperty.HOST_VISIBLE, VMemoryProperty.DEVICE_LOCAL | VMemoryProperty.HOST_CACHED);
        this.stagingBuffer = stagingUpMemory.allocBuffer("Fonts_staging", 1.MB, VBufferUsage.TRANSFER_SRC);

    }
    void destroy() {
        this.log("Destroying");

        foreach(f; fonts.values) {
            f.image.free();
        }
        this.log("Freed %s font images", fonts.length);

        if(stagingBuffer) stagingBuffer.free();
        if(deviceMemory) deviceMemory.destroy();
        if(stagingUpMemory) stagingUpMemory.destroy();
    }
    Font get(string name) {
        auto p = name in fonts;
        if(p) return *p;

        Font f  = new Font;
        f.name  = name;
        f.sdf   = new SDFFont(vk.vprops.fontDirectory, name);
        f.image = createDeviceImage(f);

        upload(f);

        fonts[name] = f;
        return f;
    }
private:
    DeviceImage createDeviceImage(Font f) {

        if(f.sdf.getData().length > 1.MB) {
            throw new Error("Font '%s' (size %.2f) is larger than allocated staging size of %s MBs"
                .format(f.name, f.sdf.getData().length.as!double/1.MB, 1));
        }

        VFormat format = VFormat.R8_UNORM;

        auto deviceImg = deviceMemory.allocImage(f.name, [f.sdf.width, f.sdf.height], VImageUsage.SAMPLED | VImageUsage.TRANSFER_DST, format);

        deviceImg.createView(format);

        allocationUsed += deviceImg.size;

        this.log("Used %.2f MBs", allocationUsed.to!double / 1.MB);

        return deviceImg;
    }
    void upload(Font f) {
        void* ptr = stagingBuffer.map();
        memcpy(ptr, f.sdf.getData().ptr, f.sdf.getData().length);
        stagingBuffer.flush();

        f.image.write(stagingBuffer, 0);
    }
}