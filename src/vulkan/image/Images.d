module vulkan.image.Images;

import vulkan.all;

final class Images {
private:
    VulkanContext context;
    VkDevice device;
    string name;
    ImageMeta[string] images;
    string baseDirectory;
    ulong allocationUsed;
public:
    static struct Args {
        string baseDirectory;
    }
    /**
     *  new Images(vk, "name", (args) { baseDirectory = ""; } );
     */
    this(VulkanContext context, string baseDirectory) {
        this.context = context;
        this.device = context.device;
        this.baseDirectory = toCanonicalPath(baseDirectory) ~ "/";
}
    void destroy() {
        this.log("Destroying");
        foreach(k,v; images) {
            //this.log("Destroying image %s", k);
            //v.destroy();
        }
        foreach(i; images.values) {
            i.image.free();
        }
        this.log("Freed %s images", images.length);
    }
    ImageMeta get(string name) {
        string fullName = baseDirectory ~ name;

        auto p = fullName in images;
        if(p) {
            return *p;
        }
        this.log("Creating image '%s'", name);
        auto image = loadImage(fullName);
        auto imgMeta = createDeviceImage(image, name);

        upload(image, imgMeta);

        images[fullName] = imgMeta;
        return imgMeta;
    }
private:
    Image loadImage(string name) {
        import std.path : extension;
        import std.string : toLower;

        auto ext = extension(name);
        switch(ext.toLower()) {
            case ".bmp":
                return BMP.read(name);
            case ".png":
                return PNG.read(name);
            case ".r32":
                return R32.read(name);
            case ".dds":
                return DDS.read(name);
            default:
                throw new Error("Unable to handle image type: %s".format(ext));
        }
    }
    ImageMeta createDeviceImage(Image img, string name) {

        if(img.data.length > context.buffer(BufID.STAGING).size) {
            throw new Error("Image '%s' (size %.2f) is larger than allocated staging buffer size of %s MBs"
                .format(name, img.data.length.as!double/1.MB, context.buffer(BufID.STAGING).size));
        }

        VFormat format;
        if(img.isA!DDS) {
            format = img.as!DDS.compressedFormat.as!VFormat;
        } else if(img.isA!R32) {
            format = VFormat.R32_SFLOAT;
        } else {
            if(img.bytesPerPixel==4) {
                format = VFormat.R8G8B8A8_UNORM;
            } else if(img.bytesPerPixel==3) {
                format = VFormat.R8G8B8_UNORM;
            } else if(img.bytesPerPixel == 1) {
                format = VFormat.R8_UNORM;
            } else {
                throw new Error("Unable to determine texture format for %s".format(name));
            }
        }

        this.log("format = %s", format);

        if(!context.vk.physicalDevice.isFormatSupported(format)) {
            throw new Error("Format %s is not supported on your device".format(format));
        }

        // Assume a 2D image for sampling
        auto deviceImg = context.memory(MemID.LOCAL).allocImage(name, [img.width, img.height], VImageUsage.SAMPLED | VImageUsage.TRANSFER_DST, format);

        deviceImg.createView(format);

        allocationUsed += deviceImg.size;

        this.log("Used %.2f MBs", allocationUsed.to!double / 1.MB);

        return ImageMeta(deviceImg, format);
    }
    void upload(Image src, ImageMeta dest) {

        auto staging = context.buffer(BufID.STAGING).alloc(src.data.length);

        void* ptr = staging.map();
        memcpy(ptr, src.data.ptr, src.data.length);
        staging.flush();

        dest.image.write(staging);

        staging.free();
    }
}