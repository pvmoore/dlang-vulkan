module vulkan.image.Images;

import vulkan.all;

final class Images {
private:
    Vulkan vk;
    VkDevice device;
    string name;
    Args args;
    DeviceMemory deviceMemory, stagingUpMemory;
    DeviceBuffer stagingBuffer;
    ImageMeta[string] images;
    string baseDirectory;
    ulong allocationUsed;
public:
    static struct Args {
        ulong stagingAllocSizeMB = 8;  // size of largest image
        ulong deviceAllocSizeMB  = 32; // device space for all images
        string baseDirectory;
    }
    /**
     *  new Images(vk, "name", (args) { deviceAllocSize = 32.MB; } );
     */
    this(Vulkan vk, string name, void delegate(Args*) argsDelegate) {
        this.vk = vk;
        this.device = device;
        this.name = name;

        argsDelegate(&args);

        args.baseDirectory = (args.baseDirectory is null) ? null : toCanonicalPath(args.baseDirectory) ~ "/";

        this.deviceMemory = vk.memory.allocDeviceMemory("Images_device_"~name, args.deviceAllocSizeMB*1.MB, VMemoryProperty.DEVICE_LOCAL, VMemoryProperty.HOST_VISIBLE);
        this.stagingUpMemory = vk.memory.allocDeviceMemory("Images_staging_"~name, args.stagingAllocSizeMB*1.MB, VMemoryProperty.HOST_VISIBLE, VMemoryProperty.DEVICE_LOCAL | VMemoryProperty.HOST_CACHED);
        this.stagingBuffer = stagingUpMemory.allocBuffer("Images_staging_"~name, args.stagingAllocSizeMB*1.MB, VBufferUsage.TRANSFER_SRC);
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

        if(stagingBuffer) stagingBuffer.free();
        if(deviceMemory) deviceMemory.destroy();
        if(stagingUpMemory) stagingUpMemory.destroy();
    }
    ImageMeta get(string name) {
        string fullName = (args.baseDirectory is null) ? name : args.baseDirectory ~ name;

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
            case ".dds":
                return DDS.read(name);
            default:
                throw new Error("Unable to handle image type: %s".format(ext));
        }
    }
    ImageMeta createDeviceImage(Image img, string name) {

        if(img.data.length > args.stagingAllocSizeMB*1.MB) {
            throw new Error("Image '%s' (size %.2f) is larger than allocated staging size of %s MBs"
                .format(name, img.data.length.as!double/1.MB, args.stagingAllocSizeMB));
        }

        VFormat format;
        if(img.isA!DDS) {
            format = img.as!DDS.compressedFormat.as!VFormat;
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

        if(!vk.physicalDevice.isFormatSupported(format)) {
            throw new Error("Format %s is not supported on your device".format(format));
        }

        // Assume a 2D image for sampling
        auto deviceImg = deviceMemory.allocImage(name, [img.width, img.height], VImageUsage.SAMPLED | VImageUsage.TRANSFER_DST, format);

        deviceImg.createView(format);

        allocationUsed += deviceImg.size;

        this.log("Used %.2f MBs", allocationUsed.to!double / 1.MB);

        return ImageMeta(deviceImg, format);
    }
    void upload(Image src, ImageMeta dest) {

        void* ptr = stagingBuffer.map();
        memcpy(ptr, src.data.ptr, src.data.length);
        stagingBuffer.flush();

        vk.memory.copy(stagingBuffer, 0, dest.image);
    }
}