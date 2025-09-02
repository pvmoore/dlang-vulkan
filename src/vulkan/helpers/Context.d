module vulkan.helpers.Context;

import vulkan.all;


enum MemID : string {
    LOCAL        = "MEM_LOCAL",
    SHARED       = "MEM_SHARED",
    STAGING      = "MEM_STAGING_UP",
    STAGING_DOWN = "MEM_STAGING_DN"
}
enum BufID : string {
    VERTEX          = "VERTEX",
    INDEX           = "INDEX",
    UNIFORM         = "UNIFORM",
    STORAGE         = "STORAGE",
    
    STAGING         = "STAGING_UP",
    STAGING_DOWN    = "STAGING_DN",

    RT_ACCELERATION = "RT_ACCELERATION",
    RT_SCRATCH      = "RT_SCRATCH",
    RT_SBT          = "RT_SBT",
    RT_VERTICES     = "RT_VERTICES",
    RT_INDEXES      = "RT_INDICES",
    RT_TRANSFORMS   = "RT_TRANSFORMS",
    RT_INSTANCES    = "RT_INSTANCES",
}

final class VulkanContext {
private:
    DeviceMemory[string] memories;
    DeviceBuffer[string] buffers;
    Fonts _fonts;
    Images _images;
    Transfer _transfer;
    InfoBuilder infoBuilder;
public:
    @Borrowed Vulkan vk;
    @Borrowed VkDevice device;
    @Borrowed VkRenderPass renderPass;
    VkPipelineCache pipelineCache;

    Fonts fonts() { throwIf(_fonts is null, "Fonts has not been added to context"); return _fonts; }
    Images images() { throwIf(_images is null, "Images has not been added to context"); return _images; }
    ShaderCompiler shaders() { return vk.shaderCompiler; }
    Transfer transfer() { return _transfer; }
    InfoBuilder build() { return infoBuilder; }
    VulkanProperties vprops() { return vk.vprops; }
    Swapchain swapchain() { return vk.swapchain; }

    this(Vulkan vk) {
        this.vk = vk;
        this.device = vk.device;
        this._transfer = new Transfer(this);
        this.infoBuilder = new InfoBuilder(this);
        this.pipelineCache = createPipelineCache(device);
    }
    void destroy() {
        if(_fonts) _fonts.destroy();
        if(_images) _images.destroy();
        if(pipelineCache) destroyPipelineCache(device, pipelineCache);

        foreach(m; memories.values()) {
            m.destroy();
        }
    }
    override string toString() {
        auto buf = new StringBuffer().add("VulkanContext(\n");
        foreach(k,v; memories) {
            buf.add("\t[%s %s]\n", k, v.size.sizeToString());

            foreach(k2, v2; buffers) {
                if(v2.memory is v) {
                    buf.add("\t\t%s %s\n", k2, v2.size.sizeToString());
                }
            }
        }
        return buf.add(")").toString();
    }
    auto withMemory(MemID id, DeviceMemory mem) {
        if(mem is null) return this;
        throwIf((id in memories) !is null, "Memory ID '%s' already added to context".format(id));

        memories[id] = mem;
        return this;
    }
    auto withBuffer(MemID mem, BufID buf, VkBufferUsageFlags usage, ulong size) {
        throwIf((buf in buffers) !is null, "Buffer ID '%s' already added to context".format(buf));

        auto m = mem in memories;
        throwIf(m is null, "Memory ID '%s' not found in context".format(mem));

        DeviceBuffer buffer = m.allocBuffer(buf, size, usage);

        buffers[buf] = buffer;
        return this;
    }
    auto withFonts(string fontDirectory) {
        this._fonts = new Fonts(this, fontDirectory);
        return this;
    }
    auto withImages(string baseDirectory) {
        this._images = new Images(this, baseDirectory);
        return this;
    }
    auto withRenderPass(VkRenderPass renderPass) {
        this.renderPass = renderPass;
        return this;
    }

    bool hasMemory(MemID id) {
        return (id in memories) !is null;
    }
    bool hasMemory(string id) {
        return hasMemory(id.as!MemID);
    }
    bool hasBuffer(BufID id) {
        return (id in buffers) !is null;
    }

    /**
     *  Return the buffer with given BufID
     */
    DeviceBuffer buffer(BufID id) {
        auto b = id in buffers;
        throwIf(b is null, "Buffer ID '%s' not found in context", id);
        return *b;
    }
    DeviceBuffer buffer(string id) {
        return buffer(id.as!BufID);
    }
    /**
     *  Return the memory with given MemID
     */
    DeviceMemory memory(MemID id) {
        auto ptr =  id in memories;
        throwIf(ptr is null, "Memory ID '%s' not found in context", id);
        return *ptr;
    }

    DeviceMemorySnapshot[] takeMemorySnapshot() {
        DeviceMemorySnapshot[] snaps;
        foreach(m; memories.values()) {
            snaps ~= new DeviceMemorySnapshot(m);
        }
        return snaps;
    }
    void dumpMemory() {
        string buf;
        foreach(s; takeMemorySnapshot()) {
            buf ~= "\n%s".format(s);
        }
        this.verbose(buf);
    }
}
