module vulkan.image.Fonts;

import vulkan.all;

final class Fonts {
private:
    VulkanContext context;
    VkDevice device;
    string fontDirectory;

    Font[string] fonts;
    ulong allocationUsed;
public:
    this(VulkanContext context, string fontDirectory) {
        this.context = context;
        this.device = context.device;
        this.fontDirectory = fontDirectory;
    }
    void destroy() {
        this.log("Destroying");

        foreach(f; fonts.values) {
            f.image.free();
        }
        this.log("Freed %s font images", fonts.length);
    }
    Font get(string name) {
        auto p = name in fonts;
        if(p) return *p;

        Font f  = new Font;
        f.name  = name;
        f.sdf   = new SDFFont(fontDirectory, name);
        f.image = createDeviceImage(f);

        upload(f);

        fonts[name] = f;
        return f;
    }
private:
    DeviceImage createDeviceImage(Font f) {

        if(f.sdf.getData().length > context.buffer(BufID.STAGING).size) {
            throw new Error("Font '%s' (size %.2f) is larger than allocated staging size of %s MBs"
                .format(f.name, f.sdf.getData().length.as!double/1.MB, context.buffer(BufID.STAGING).size / 1.MB));
        }

        VFormat format = VFormat.R8_UNORM;

        auto deviceImg = context.memory(MemID.LOCAL).allocImage(f.name, [f.sdf.width, f.sdf.height], VImageUsage.SAMPLED | VImageUsage.TRANSFER_DST, format);

        deviceImg.createView(format, VImageViewType._2D, VImageAspect.COLOR);

        allocationUsed += deviceImg.size;

        this.log("Used %.2f MBs", allocationUsed.to!double / 1.MB);

        return deviceImg;
    }
    void upload(Font f) {

        auto data = f.sdf.getData();

        auto staging = context.buffer(BufID.STAGING).alloc(data.length);

        void* ptr = staging.map();
        memcpy(ptr, data.ptr, data.length);
        staging.flush();

        f.image.write(staging);

        staging.free();
    }
}