module vulkan.helpers.UpdateableImage;

import vulkan.all;

/**
 * DeviceImage that can be updated via a staging buffer.
 *
 * TODO - may need more than 1 StagingBuffer which is switched after upload is called.
 */
final class UpdateableImage(VFormat FMT) {
private:
         static if(FMT==VFormat.R8_UNORM)            alias T = ubyte;
    else static if(FMT==VFormat.R32_SFLOAT)          alias T = float;
    else static if(FMT==VFormat.R8G8B8_UNORM)        alias T = RGBb;
    else static if(FMT==VFormat.R32G32B32_SFLOAT)    alias T = float3;
    else static if(FMT==VFormat.R8G8B8A8_UNORM)      alias T = RGBAb;
    else static if(FMT==VFormat.R32G32B32A32_SFLOAT) alias T = float4;
    else static assert(false, "Format %s not yet implemented".format(FMT));

    __gshared static uint ids = 0;

    uint id;
    VulkanContext context;
    uint width, height;
    VImageUsage usage;
    VImageLayout layout;
    uint4[] dirtyRanges; // start(x,y) -> end(x,y)
    SubBuffer stagingBuffer;
    VImageLayout prevLayout;
public:
    DeviceImage image;

    ImageMeta getImageMeta() {
        return ImageMeta(image, FMT);
    }
    /**
     *  @usage image usage eg. STORAGE or SAMPLED
     *  @layout image layout eg. GENERAL or SHADER_READ_ONLY_OPTIMAL
     */
    this(VulkanContext context, uint width, uint height, VImageUsage usage, VImageLayout layout) {
        this.id           = ++ids;
        this.context      = context;
        this.width        = width;
        this.height       = height;
        this.usage        = usage | VImageUsage.TRANSFER_DST;
        this.layout       = layout;
        this.dirtyRanges ~= uint4(0, 0, width, height);

        this.initialise();
    }
    void destroy() {
        if(image) image.free();
        if(stagingBuffer) stagingBuffer.free();
    }
    T* map() {
        return cast(T*)stagingBuffer.map();
    }
    void clear(T value) {
        setDirty();
        map()[0..width*height] = value;
    }
    /**
     *  Set the whole region dirty.
     */
    void setDirty() {
        this.dirtyRanges.length = 1;
        this.dirtyRanges[0] = uint4(0, 0, width, height);
    }
    /**
     *  Assumes the image origin is top-left.
     *
     *  For a 10x10 pixel block, range: (0,0) -> (10,10)
     */
    void setDirtyRegion(uint2 topLeftEle, uint2 bottomRightEle) {
        assert(topLeftEle.x < bottomRightEle.x);
        assert(topLeftEle.y < bottomRightEle.y);
        assert(bottomRightEle.x <= width);
        assert(bottomRightEle.y <= height);

        // offset must be a multiple of 4
        topLeftEle &= ~3;

        dirtyRanges ~= uint4(topLeftEle, bottomRightEle);
    }
    void upload(VkCommandBuffer cmd) {
        if(dirtyRanges.length==0) return;

        VkBufferImageCopy[] regions;

        //this.log("upload %s", dirtyRanges);

        foreach(r; dirtyRanges) {
            VkOffset3D offset = {
                x: r.x,
                y: r.y,
                z: 0
            };
            VkExtent3D extent = {
                width:  r.z-r.x,
                height: r.w-r.y,
                depth:  1
            };

            VkBufferImageCopy region = {
                bufferOffset:      stagingBuffer.offset + (r.x + r.y*width) * T.sizeof,
                bufferRowLength:   width,
                bufferImageHeight: height,
                imageSubresource:  VkImageSubresourceLayers(VImageAspect.COLOR, 0, 0, 1),
                imageOffset:       offset,
                imageExtent:       extent
            };
            regions ~= region;
        }
        dirtyRanges.length = 0;

        // Convert device image to transfer optimal
        cmd.setImageLayout(
            image.handle,
            VImageAspect.COLOR,
            prevLayout,
            VImageLayout.TRANSFER_DST_OPTIMAL
        );

        // copy the regions in the staging buffer to the device image
        cmd.copyBufferToImage(
            stagingBuffer.handle,
            image.handle,
            VImageLayout.TRANSFER_DST_OPTIMAL,
            regions
        );

        // change the device image layout to desired layout
        cmd.setImageLayout(
            image.handle,
            VImageAspect.COLOR,
            VImageLayout.TRANSFER_DST_OPTIMAL,
            layout
        );

        prevLayout = layout;
    }
private:
    void initialise() {
        this.prevLayout = VImageLayout.UNDEFINED;
        this.image = context.memory(MemID.LOCAL).allocImage(
            "UpdateableImage_%s".format(id),
            [width, height],
            usage,
            FMT
        );
        this.stagingBuffer = context.buffer(BufID.STAGING).alloc(image.size);
    }
}
