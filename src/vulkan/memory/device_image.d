module vulkan.memory.device_image;
/**
 *
 */
import vulkan.all;

private struct ViewKey {
    VFormat format;
    VImageViewType type;

    bool opEquals(inout ViewKey o) const {
		return format==o.format && type==o.type;
	}
	size_t toHash() const nothrow @trusted {
        size_t a = 5381;
        a  = (a << 7)  + format;
        a ^= (a << 13) + type;
        return a;
    }
}

final class DeviceImage {
    VkImageView[ViewKey] views;
    Vulkan vk;
    DeviceMemory memory;
    VkImage handle;
    string name;
    ulong offset;
    uint width, height, depth;
    ulong size;
    VFormat format;
    VkImageCreateInfo createInfo;

    this(Vulkan vk,
         DeviceMemory memory,
         string name,
         VkImage handle,
         VFormat format,
         ulong offset,
         ulong size,
         uint[] dimensions,
         VkImageCreateInfo createInfo)
    {
        this.vk         = vk;
        this.memory     = memory;
        this.name       = name;
        this.handle     = handle;
        this.format     = format;
        this.offset     = offset;
        this.size       = size;
        this.width      = dimensions[0];
        this.height     = dimensions.length>1 ? dimensions[1] : 1;
        this.depth      = dimensions.length>2 ? dimensions[2] : 1;
        this.createInfo = createInfo;

        version(LOG_MEM)
            this.log("Creating DeviceImage [%s: %,s..%,s] (%s x %s x %s)", memory.name, offset, offset+size, width, height, depth);
    }
    void free() {
        memory.destroy(this);
    }
    /**
     *  Note that you can only create a view with the same format as
     *  the original image unless you specify flag:
     *  VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT
     */
    VkImageView createView(VFormat format, VImageViewType type, VImageAspect aspectMask) {
        VkImageViewCreateInfo info;
        info.build(handle, format, type)
            .build(aspectMask);

        auto view = vk.device.createImageView(info);

        views[ViewKey(format,type)] = view;
        return view;
    }
    /// Get first (probably only) view
    VkImageView view() {
        vkassert(views.values.length>0);
        return views.values[0];
    }
    VkImageView view(VFormat format, VImageViewType type) {
        auto key = ViewKey(format,type);
        auto p   = key in views;
        if(p) return *p;
        throw new Error("View %s not found".format(key));
    }
    VkImageView[] getViews() {
        return views.values;
    }

    /** Blocking write data to the image */
    void write(SubBuffer buffer) {
        write(buffer.parent, buffer.offset);
    }
     /** Blocking write data to the image */
    void write(DeviceBuffer buffer, ulong offset = 0) {
        auto cmd = vk.device.allocFrom(vk.getTransferCP());
        cmd.beginOneTimeSubmit();

        write(cmd, buffer, offset);

        cmd.end();

        auto fence = vk.device.createFence();

        vk.getTransferQueue().submit([cmd], fence);

        vk.device.waitFor(fence);
        vk.device.destroyFence(fence);

        vk.device.free(vk.getTransferCP(), cmd);
    }
     /** Write data to the image */
    void write(VkCommandBuffer cmd, DeviceBuffer buffer, ulong offset = 0) {
        auto aspect    = VImageAspect.COLOR;
        // change dest image layout from VImageLayout.UNDEFINED
        // to VImageLayout.TRANSFER_DST_OPTIMAL
        cmd.setImageLayout(
            handle,
            aspect,
            VImageLayout.UNDEFINED,
            VImageLayout.TRANSFER_DST_OPTIMAL
        );

        auto layerCount = createInfo.arrayLayers;

        auto region = VkBufferImageCopy();
        region.bufferOffset      = offset;
        region.bufferRowLength   = 0;//dest.width*3;
        region.bufferImageHeight = 0;//dest.height;
        region.imageSubresource  = VkImageSubresourceLayers(aspect, 0,0, layerCount);
        region.imageOffset       = VkOffset3D(0,0,0);
        region.imageExtent       = VkExtent3D(width, height, 1);

        // copy the staging buffer to the GPU image
        cmd.copyBufferToImage(
            buffer.handle,
            handle, VImageLayout.TRANSFER_DST_OPTIMAL,
            [region]
        );

        // change the GPU image layout from VImageLayout.TRANSFER_DST_OPTIMAL
        // to VImageLayout.SHADER_READ_ONLY_OPTIMAL
        cmd.setImageLayout(
            handle,
            aspect,
            VImageLayout.TRANSFER_DST_OPTIMAL,
            VImageLayout.SHADER_READ_ONLY_OPTIMAL
        );
    }
}

final class DeviceImageSnapshot {
    string name;
    double size;

    this(DeviceImage i) {
        name = i.name;
        size = cast(double)i.size / 1.MB;
    }

    override string toString() {
        return "DeviceImage '%s' %.1f MB".format(
            name,
            size
        );
    }
}

