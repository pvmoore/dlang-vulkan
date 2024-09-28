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
    Vulkan vk;
    VkDevice device;
    VkRenderPass renderPass;
    bool verboseLogging = false;
    Fonts fonts() { if(!_fonts) throw new Error("Fonts has not been added to context"); return _fonts; }
    Images images() { if(!_images) throw new Error("Images has not been added to context"); return _images; }
    ShaderCompiler shaders() { return vk.shaderCompiler; }
    Transfer transfer() { return _transfer; }
    InfoBuilder build() { return infoBuilder; }

    this(Vulkan vk) {
        this.vk = vk;
        this.device = vk.device;
        this._transfer = new Transfer(this);
        this.infoBuilder = new InfoBuilder(this);
    }
    void destroy() {
        if(_fonts) _fonts.destroy();
        if(_images) _images.destroy();

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
        if(id in memories) throw new Error("Memory ID '%s' already added to context".format(id));

        memories[id] = mem;
        return this;
    }
    auto withBuffer(MemID mem, BufID buf, VkBufferUsageFlags usage, ulong size) {
        if(buf in buffers) throw new Error("Buffer ID '%s' already added to context".format(buf));

        auto m = mem in memories;
        if(!m) throw new Error("Memory ID '%s' not found in context".format(mem));

        buffers[buf] = m.allocBuffer(buf, size, usage);
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
    /**
     *  Return the buffer with given BufID
     */
    DeviceBuffer buffer(BufID id) {
        auto b = id in buffers;
        if(!b) throw new Error("Buffer ID '%s' not found in context".format(id));
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
        if(!ptr) throw new Error("Memory ID '%s' not found in context".format(id));
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
        this.log(buf);
    }
}
