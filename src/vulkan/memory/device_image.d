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
        a  = ((a << 7) )  + format;
        a ^= ((a << 13) ) + type;
        return a;
    }
}

final class DeviceImage {
    VkImageView[ViewKey] views;
    DeviceMemory memory;
    VkImage handle;
    string name;
    ulong offset;
    uint width, height, depth;
    ulong size;
    VFormat format;

    this(DeviceMemory memory, string name, VkImage handle, VFormat format, ulong offset, ulong size, uint[] dimensions) {
        this.memory = memory;
        this.name   = name;
        this.handle = handle;
        this.format = format;
        this.offset = offset;
        this.size   = size;
        this.width  = dimensions[0];
        this.height = dimensions.length>1 ? dimensions[1] : 1;
        this.depth  = dimensions.length>2 ? dimensions[2] : 1;
        logMem("Creating DeviceImage [%s: %,s..%,s] (%sx%s)", memory.name,offset,offset+size,width,height,depth);
    }
    void free() {
        memory.destroy(this);
    }
    /**
     *  Note that you can only create a view with the same format as
     *  the original image unless you specify flag:
     *  VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT
     */
    VkImageView createView(VFormat format, VImageViewType type=VImageViewType._2D) {
        auto view = memory.device.createImageView(
            imageViewCreateInfo(handle, format, type)
        );
        views[ViewKey(format,type)] = view;
        return view;
    }
    /// Get first (probably only) view
    VkImageView view() {
        expect(views.values.length>0);
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

