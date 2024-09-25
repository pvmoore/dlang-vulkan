module vulkan.image.Images;

import vulkan.all;
import std.path : dirSeparator;

final class Images {
private:
    VulkanContext context;
    VkDevice device;
    string baseDirectory;

    ImageMeta[string] images;
    ulong allocationUsed;
public:
    this(VulkanContext context, string baseDirectory) {
        this.context = context;
        this.device = context.device;
        this.baseDirectory = toCanonicalPath(baseDirectory) ~ dirSeparator;
    }
    void destroy() {
        foreach(i; images.values) {
            i.image.free();
        }
        this.log("Freed %s image%s", images.length, images.length==1 ? "" : "s");
        images = null;
    }
    ImageMeta get(string name) {
        string fullName = baseDirectory ~ name;

        auto p = fullName in images;
        if(p) {
            return *p;
        }

        this.log("Creating image '%s'", name);
        auto image = loadImage(fullName);
        auto imgMeta = createDeviceImage([image], name);

        upload([image], imgMeta);

        images[fullName] = imgMeta;
        return imgMeta;
    }
    /**
     *  Load a cubemap where the 6 images are stored as baseDirectory/subDirectory/left.ext etc
     *  and where ext can be any loadable image type @see get()
     *  eg. getCubemap("skyboxes/", "png")
     */
    ImageMeta getCubemap(string subDirectory, string ext) {
        string cSubDirectory = toCanonicalPath(subDirectory) ~ dirSeparator;
        string key = baseDirectory ~ cSubDirectory ~ ext;

        auto p = key in images;
        if(p) {
            return *p;
        }

        this.log("Creating cubemap images '%s'", key);
        auto imageData = [
            loadImage(baseDirectory ~ cSubDirectory ~ "right." ~ ext),
            loadImage(baseDirectory ~ cSubDirectory ~ "left." ~ ext),
            loadImage(baseDirectory ~ cSubDirectory ~ "top." ~ ext),
            loadImage(baseDirectory ~ cSubDirectory ~ "bottom." ~ ext),
            loadImage(baseDirectory ~ cSubDirectory ~ "back." ~ ext),
            loadImage(baseDirectory ~ cSubDirectory ~ "front." ~ ext)
        ];

        auto imgMeta = createDeviceImage(imageData, cSubDirectory);

        upload(imageData, imgMeta);

        images[key] = imgMeta;
        return imgMeta;
    }
private:
    Image loadImage(string name) {
        return Image.read(name);
    }
    ImageMeta createDeviceImage(Image[] imgs, string name) {

        auto size = imgs.map!((it)=>it.data.length).sum();

        if(size > context.buffer(BufID.STAGING).size) {
            throw new Error("Image '%s' (size %.2f) is larger than allocated staging buffer size of %s MBs"
                .format(name, size.as!double/1.MB, context.buffer(BufID.STAGING).size));
        }

        Image img   = imgs[0];
        bool isCube = imgs.length == 6;
        VkFormat format;

        if(img.isA!DDS) {
            format = img.as!DDS.compressedFormat.as!VkFormat;
        } else if(img.isA!R32) {
            format = VK_FORMAT_R32_SFLOAT;
        } else {
            if(img.bytesPerPixel==4) {
                format = VK_FORMAT_R8G8B8A8_UNORM;
            } else if(img.bytesPerPixel==3) {
                format = VK_FORMAT_R8G8B8_UNORM;
            } else if(img.bytesPerPixel == 1) {
                format = VK_FORMAT_R8_UNORM;
            } else {
                throw new Error("Unable to determine texture format for %s".format(name));
            }
        }

        this.log("format = %s", format);

        if(!context.vk.physicalDevice.isFormatSupported(format)) {
            throw new Error("Format %s is not supported on your device".format(format));
        }

        // Assume a 2D image for sampling
        auto deviceImg = context.memory(MemID.LOCAL).allocImage(
            name,
            [img.width, img.height],
            VK_IMAGE_USAGE_SAMPLED_BIT | VK_IMAGE_USAGE_TRANSFER_DST_BIT,
            format,
            (info) {

                // cubemap
                if(isCube) {
                    info.flags       = VkImageCreateFlagBits.VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT;
                    info.arrayLayers = 6;
                }
            });

        deviceImg.createView(format,
                             imgs.length == 1
                                        ? VK_IMAGE_VIEW_TYPE_2D
                                        : VK_IMAGE_VIEW_TYPE_CUBE,
                             VK_IMAGE_ASPECT_COLOR_BIT);

        allocationUsed += deviceImg.size;

        this.log("Used %.2f MBs", allocationUsed.to!double / 1.MB);

        return ImageMeta(deviceImg, format);
    }
    void upload(Image[] imgs, ImageMeta dest) {

        auto size = imgs.map!((it)=>it.data.length).sum();

        auto staging = context.buffer(BufID.STAGING).alloc(size);

        void* ptr = staging.map();
        foreach(img; imgs) {
            memcpy(ptr, img.data.ptr, img.data.length);
            ptr += img.data.length;
        }
        staging.flush();

        dest.image.write(staging);

        staging.free();
    }
}
