module vulkan.memory.device_image;

import vulkan.all;

private struct ViewKey {
    VkFormat format;
    VkImageViewType type;

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
    VkFormat format;
    VkImageCreateInfo createInfo;

    this(Vulkan vk,
         DeviceMemory memory,
         string name,
         VkImage handle,
         VkFormat format,
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

        debug this.log("Creating DeviceImage '%s' [%s: %,s..%,s] (%s x %s x %s) handle: 0x%x", name, memory.name, offset, offset+size, width, height, depth, handle);
    }
    void free() {
        memory.destroy(this);
    }
    /**
     *  Note that you can only create a view with the same format as
     *  the original image unless you specify flag:
     *  VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT
     */
    VkImageView createView(VkFormat format, VkImageViewType type, VkImageAspectFlags aspectMask) {
        VkImageViewCreateInfo info;
        info.build(handle, format, type)
            .build(aspectMask);

        auto view = vk.device.createImageView(info);

        views[ViewKey(format,type)] = view;
        return view;
    }
    /// Get first (probably only) view
    VkImageView view() {
        throwIf(views.values.length == 0);
        return views.values[0];
    }
    VkImageView view(VkFormat format, VkImageViewType type) {
        auto key = ViewKey(format,type);
        auto p   = key in views;
        if(p) return *p;
        throw new Error("View %s not found".format(key));
    }
    VkImageView[] getViews() {
        return views.values;
    }

    /** Blocking write data to the image */
    void write(SubBuffer buffer, uint toQueueFamily = VK_QUEUE_FAMILY_IGNORED) {
        write(buffer.parent, buffer.offset, toQueueFamily);
    }
     /** Blocking write data to the image */
    void write(DeviceBuffer buffer, ulong offset, uint toQueueFamily = VK_QUEUE_FAMILY_IGNORED) {
        auto cmd = vk.device.allocFrom(vk.getTransferCP());
        setObjectDebugName!VK_OBJECT_TYPE_COMMAND_BUFFER(vk.device, cmd, "DeviceImage.write '%s'".format(name));
        cmd.beginOneTimeSubmit();

        write(cmd, buffer, offset, vk.getTransferQueueFamily().index, toQueueFamily);

        cmd.end();

        auto fence = vk.device.createFence();

        vk.getTransferQueue().submit([cmd], fence);

        vk.device.waitFor(fence);
        vk.device.destroyFence(fence);

        vk.device.free(vk.getTransferCP(), cmd);
    }
     /** Write data to the image */
    void write(VkCommandBuffer cmd, 
               DeviceBuffer buffer, 
               ulong offset, 
               uint fromQueueFamily = VK_QUEUE_FAMILY_IGNORED, 
               uint toQueueFamily = VK_QUEUE_FAMILY_IGNORED) 
    {
        debug this.log("write buffer: %s", buffer.name);

        auto aspect  = VK_IMAGE_ASPECT_COLOR_BIT;
        // change dest image layout from VK_IMAGE_LAYOUT_UNDEFINED
        // to VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL
        cmd.setImageLayout(
            handle,
            aspect,
            VK_IMAGE_LAYOUT_UNDEFINED,
            VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL
        );

        auto layerCount = createInfo.arrayLayers;

        VkBufferImageCopy region = {
            bufferOffset:      offset,
            bufferRowLength:   0,   //dest.width*3;
            bufferImageHeight: 0,   //dest.height;
            imageSubresource:  VkImageSubresourceLayers(aspect, 0,0, layerCount),
            imageOffset:       VkOffset3D(0,0,0),
            imageExtent:       VkExtent3D(width, height, 1)
        };

        // copy the staging buffer to the GPU image
        cmd.copyBufferToImage(
            buffer.handle,
            handle, 
            VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
            [region]
        );

        // change the GPU image layout from VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL
        // to VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL

        // Transfer ownership if both 'from' and 'to' are provided
        if(fromQueueFamily == VK_QUEUE_FAMILY_IGNORED || toQueueFamily == VK_QUEUE_FAMILY_IGNORED) {
            fromQueueFamily = toQueueFamily = VK_QUEUE_FAMILY_IGNORED;
        } 

        cmd.setImageLayout(
            handle,
            aspect,
            VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
            VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
            fromQueueFamily,     
            toQueueFamily                  
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

