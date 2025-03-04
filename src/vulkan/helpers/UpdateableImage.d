module vulkan.helpers.UpdateableImage;

import vulkan.all;

/**
 * DeviceImage that can be updated via a staging buffer.
 *
 * TODO - may need more than 1 StagingBuffer which is switched after upload is called.
 */
final class UpdateableImage(VkFormat FMT) {
private:
         static if(FMT==VK_FORMAT_R8_UNORM)            alias T = ubyte;
    else static if(FMT==VK_FORMAT_R32_SFLOAT)          alias T = float;
    else static if(FMT==VK_FORMAT_R8G8B8_UNORM)        alias T = RGBb;
    else static if(FMT==VK_FORMAT_R32G32B32_SFLOAT)    alias T = float3;
    else static if(FMT==VK_FORMAT_R8G8B8A8_UNORM)      alias T = RGBAb;
    else static if(FMT==VK_FORMAT_R32G32B32A32_SFLOAT) alias T = float4;
    else static assert(false, "Format %s not yet implemented".format(FMT));

    __gshared static uint ids = 0;

    uint id;
    VulkanContext context;
    VkImageUsageFlags usage;
    VkImageLayout layout;
    uint4[] dirtyRanges; // start(x,y) -> end(x,y)
    SubBuffer stagingBuffer;
    VkImageLayout prevLayout;
    VkPipelineStageFlags stageFlags;
public:
    uint width;
    uint height;
    VkFormat format;
    DeviceImage image;

    ImageMeta getImageMeta() {
        return ImageMeta(image, FMT);
    }
    /**
     *  @usage image usage eg. STORAGE or SAMPLED
     *  @layout image layout eg. GENERAL or SHADER_READ_ONLY_OPTIMAL
     *  @stageFlags eg. VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT or VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT
     */
    this(VulkanContext context, uint width, uint height, 
         VkImageUsageFlags usage, VkImageLayout layout, VkPipelineStageFlags stageFlags) 
    {
        this.id             = ++ids;
        this.context        = context;
        this.width          = width;
        this.height         = height;
        this.format         = FMT;
        this.usage          = usage | VK_IMAGE_USAGE_TRANSFER_DST_BIT;
        this.layout         = layout;
        this.stageFlags     = stageFlags;
        this.dirtyRanges   ~= uint4(0, 0, width, height);
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
        throwIfNot(topLeftEle.x < bottomRightEle.x);
        throwIfNot(topLeftEle.y < bottomRightEle.y);
        throwIfNot(bottomRightEle.x <= width);
        throwIfNot(bottomRightEle.y <= height);

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
                imageSubresource:  VkImageSubresourceLayers(VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1),
                imageOffset:       offset,
                imageExtent:       extent
            };
            regions ~= region;
        }
        dirtyRanges.length = 0;

        WholeImageBarrierData barrierData = {
            image: image.handle,
            aspectMask: VK_IMAGE_ASPECT_COLOR_BIT,
            srcLayout: prevLayout,
            dstLayout: VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
            srcAccessMask: VK_ACCESS_SHADER_READ_BIT,
            dstAccessMask: VK_ACCESS_TRANSFER_WRITE_BIT,
            srcStageFlags: stageFlags,
            dstStageFlags: VK_PIPELINE_STAGE_TRANSFER_BIT
        };

        // Convert device image to transfer optimal
        cmd.imageBarrier(barrierData);

        // copy the regions in the staging buffer to the device image
        cmd.copyBufferToImage(
            stagingBuffer.handle,
            image.handle,
            VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
            regions
        );

        barrierData.srcLayout = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
        barrierData.dstLayout = layout;
        barrierData.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
        barrierData.dstAccessMask = VK_ACCESS_SHADER_READ_BIT;
        barrierData.srcStageFlags = VK_PIPELINE_STAGE_TRANSFER_BIT;
        barrierData.dstStageFlags = stageFlags;

        // change the device image layout to desired layout
        cmd.imageBarrier(barrierData);

        prevLayout = layout;
    }
private:
    void initialise() {
        this.prevLayout = VK_IMAGE_LAYOUT_UNDEFINED;
        this.image = context.memory(MemID.LOCAL).allocImage(
            "UpdateableImage_%s".format(id),
            [width, height],
            usage,
            FMT
        );
        this.stagingBuffer = context.buffer(BufID.STAGING).alloc(image.size);
    }
}
