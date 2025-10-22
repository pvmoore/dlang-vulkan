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
        foreach(f; fonts.values) {
            f.image.free();
        }
        this.verbose("Freed %s font image%s", fonts.length, fonts.length==1 ? "" : "s");
        fonts = null;
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

        throwIf(f.sdf.getData().length > context.buffer(BufID.STAGING).size,
            "Font '%s' (size %.2f) is larger than allocated staging size of %s MBs",
            f.name, f.sdf.getData().length.as!double/1.MB, context.buffer(BufID.STAGING).size / 1.MB);

        VkFormat format = VK_FORMAT_R8_UNORM;

        // Create the image using sharing mode CONCURRENT since we will be using the transfer queue
        // to upload and the graphics queue to sample. This can be improved by using barriers to
        // pass ownership from one to the other but is a bit awkward in this case.
        auto deviceImg = context.memory(MemID.LOCAL)
                                .allocImage(f.name, [f.sdf.width, f.sdf.height], VK_IMAGE_USAGE_SAMPLED_BIT | VK_IMAGE_USAGE_TRANSFER_DST_BIT, format,
                                (info) {
                                    info.sharingMode = VK_SHARING_MODE_CONCURRENT;
                                    info.queueFamilyIndexCount = 2;
                                    info.pQueueFamilyIndices = [
                                        context.vk.getGraphicsQueueFamily(),
                                        context.vk.getTransferQueueFamily()].ptr;
                                });

        deviceImg.createView(format, VK_IMAGE_VIEW_TYPE_2D, VK_IMAGE_ASPECT_COLOR_BIT);

        allocationUsed += deviceImg.size;

        this.verbose("Used %.2f MBs", allocationUsed.to!double / 1.MB);

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
