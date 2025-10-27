module vulkan.image.ImageAtlas;

import vulkan.all;

/**
 * A large image divided into multiple logical UV sub-images. 
 * The sub-images are then organised into named animations which can then be accessed via a unique name.
 *
 * Todo: [1] Allow adding ImageAtlas to Descriptors
 */
final class ImageAtlas {
public:
    string name;
    uint2 size;
    ImageMeta image;

    this(VulkanContext context) {
        this.context = context;
    }
    void load(string spriteSheetPath) {
        doLoad(spriteSheetPath);
    }
    Animation getAnimation(string id) {
        return animations[id];
    }
    /** 
     *  Upload the image to the device if it hasn't already been uploaded.
     *  @return the number of bytes uploaded
     */
    ulong upload(VkCommandBuffer cmd, uint destQueueFamily = VK_QUEUE_FAMILY_IGNORED) {
        if(isUploaded) return 0;
        isUploaded = true;

        SubBuffer staging = context.buffer(BufID.STAGING).alloc(imageSrcData.length);
        staging.mapAndWrite(imageSrcData.ptr, 0, imageSrcData.length);
        image.image.write(cmd, staging.parent, staging.offset, VK_QUEUE_FAMILY_IGNORED, destQueueFamily);
        staging.free();
        return imageSrcData.length;
    }
private:
    @Borrowed VulkanContext context;
    bool isUploaded;
    ubyte[] imageSrcData;
    Animation[string] animations;

    static struct UV {
        float2 tl;
        float2 br;

        string toString() { return "UV{%s, %s}".format(tl, br); }
    }
    static struct Animation {
        string name;
        UV[] uvs;

        string toString() { return "Animation{%s, %s}".format(name, uvs); }
    }

    void loadImage(string filename) {
        Image.ReadOptions options = {
            forceRGBToRGBA: true
        };
        auto img = Image.read(filename, options);
        this.imageSrcData = img.data;
        this.size = uint2(img.width, img.height);

        // Support RGBA, RGB and R
        this.image.format = 
            img.bytesPerPixel == 4 ? VK_FORMAT_R8G8B8A8_UNORM : 
            img.bytesPerPixel == 3 ? VK_FORMAT_R8G8B8_UNORM : VK_FORMAT_R8_UNORM;
    }
    void allocDeviceImage() {
        this.image.image = context.memory(MemID.LOCAL).allocImage(
            name,
            [size.x, size.y],
            VK_IMAGE_USAGE_SAMPLED_BIT | VK_IMAGE_USAGE_TRANSFER_DST_BIT,
            image.format);

        image.image.createView(image.format, VK_IMAGE_VIEW_TYPE_2D, VK_IMAGE_ASPECT_COLOR_BIT);
    }
    /**
     *  Load the UVs from a file
     *
     * .sprite-sheet file format (JSON5):
     *
     * {
     *    image: {
     *        "name": <name of the image>,
     *        "filename": <the path to the image file>
     *    },
     *    uvs: [
     *        <list of comma separated uv values - top left, bottom right for each box>
     *    ],
     *    animations: {
     *        <animation group name>: [
     *            <list of comma separated indexes into the uvs array>
     *        ]
     *        // eg. walking: [0, 1, 2], running: [3, 4, 5]
     *    }
     * }
     */
    void doLoad(string filename) {
        import resources : JSON5, J5Array;
        auto json5 = JSON5.fromFile(filename);

        auto imageObj = json5["image"];
        auto uvsArray = json5["uvs"].as!J5Array;
        auto animationsObj = json5["animations"];

        this.name = imageObj["name"].toString();
        string imageFilename = imageObj["filename"].toString();
        auto uvs = uvsArray.extract!float;
        
        loadImage(imageFilename);
        allocDeviceImage();

        foreach(k, v; animationsObj.byKeyValue()) {
            int[] indexes = v.as!J5Array.extract!int;
            Animation anim = {
                name: k,
                uvs: indexes.map!((i) => UV(float2(uvs[i*2], uvs[i*2+1]), float2(uvs[i*2+2], uvs[i*2+3]))).array()
            };
            animations[k] = anim;
        }
    }
}
