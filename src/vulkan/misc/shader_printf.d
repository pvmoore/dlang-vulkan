module vulkan.misc.shader_printf;
/**
 *
 */
import vulkan.all;

final class ShaderPrintf {
private:
    enum BUFFER_SIZE = 4.MB;
    Vulkan vk;
    DeviceBuffer debugBuffer, statsBuffer;
    SubBuffer stagingDebugBuffer, stagingStatsBuffer;
    ubyte[] initBuffer;
    bool useSharedMemory;

    static struct Stats {
        uint flags;
        uint length;
    }
    Stats stats;
public:
    this(Vulkan vk) {
        this.vk = vk;
        initialise();
    }
    void destroy() {
        if(debugBuffer) debugBuffer.free();
        if(statsBuffer) statsBuffer.free();
    }
    DeviceBuffer getDeviceBuffer() {
        return debugBuffer;
    }
    void createLayout(Descriptors d) {
        d.createLayout()
         .storageBuffer(VShaderStage.COMPUTE)
         .storageBuffer(VShaderStage.COMPUTE)
         .sets(1);
    }
    VkDescriptorSet createDescriptorSet(Descriptors d, uint layoutNumber = 1) {
        return d.createSetFromLayout(layoutNumber)
            .add(debugBuffer.handle, 0, VK_WHOLE_SIZE)
            .add(statsBuffer.handle, 0, VK_WHOLE_SIZE)
            .write();
    }
    void reset() {
        stats.flags  = 0;
        stats.length = 0;
        if(useSharedMemory) {
            Stats* ptr = cast(Stats*)statsBuffer.map();
            *ptr = stats;
            stagingStatsBuffer.flush();
        } else {
            vk.memory.copyToDevice(statsBuffer, &stats);
        }
    }
    string getDebugString() {
        char suffix ='\n';
        auto buf    = appender!(char[]);

        auto ptr  = getData();
        uint len  = stats.length;

        //log("flags  = %s", stats.flags);
        //log("length = %s", stats.length);

    lp: for(int i = 0; i<len; ) {
            uint type       = cast(int)ptr[i++];
            uint components = cast(uint)ptr[i++];

            //writefln("type=%s components=%s", type, components);

            switch(type) {
                case 0 : // char
                    buf ~= cast(char)ptr[i++];
                    break;
                case 1 : // uint
                    buf ~= "%08x".format((cast(uint)ptr[i++]));
                    while(--components) {
                        buf ~= ", " ~ "%08x".format(cast(uint)ptr[i++]);
                    }
                    break;
                case 2 : // int
                    buf ~= "%s".format((cast(int)ptr[i++]));
                    while(--components) {
                        buf ~= ", " ~ "%s".format(cast(int)ptr[i++]);
                    }
                    break;
                case 3 : // float
                    buf ~= "%f".format(ptr[i++]);
                    while(--components) {
                        buf ~= ", " ~ "%f".format(ptr[i++]);
                    }
                    break;
                case 4 : // ulong
                    ulong v = (cast(ulong)ptr[i++] << 32) | cast(ulong)ptr[i++];
                    buf ~= "%016x".format(v);
                    break;
                case 5 : // long
                    long v = (cast(long)ptr[i++] << 32) | cast(long)ptr[i++];
                    buf ~= "%s".format(v);
                    break;
                case 6: // matrix
                    mat4 temp;
                    int cols = cast(int)ptr[i++];
                    int rows = cast(int)ptr[i++];
                    // copy to temp
                    for(int j=0; j<rows*cols; j++) {
                        int c = j/rows;
                        int r = j%rows;
                        temp[c][r] = ptr[i++];
                    }
                    for(auto r=0; r<rows; r++) {
                        for(auto c=0; c<cols; c++) {
                            if(c>0) buf ~= ",";
                            buf ~= " %f".format(temp[c][r]);
                        }
                        buf ~= "\n";
                    }
                    break;
                case 7: // set suffix
                    suffix = cast(char)ptr[i++];
                    continue lp;
                default :
                    break;
            }
            if(suffix!=0)
                buf ~= suffix;
        }
        return cast(string)buf.data;
    }
private:
    void initialise() {
        if(vk.memory.sharedMemoryAvailable()) {
            useSharedMemory    = true;
            debugBuffer        = vk.memory.shared_.allocBuffer("debug", BUFFER_SIZE, VBufferUsage.STORAGE | VBufferUsage.TRANSFER_SRC | VBufferUsage.TRANSFER_DST);
            statsBuffer        = vk.memory.shared_.allocBuffer("printf2", BUFFER_SIZE, VBufferUsage.STORAGE | VBufferUsage.TRANSFER_SRC | VBufferUsage.TRANSFER_DST);
        } else {
            debugBuffer        = vk.memory.local.allocBuffer("debug", BUFFER_SIZE, VBufferUsage.STORAGE | VBufferUsage.TRANSFER_SRC | VBufferUsage.TRANSFER_DST);
            stagingDebugBuffer = vk.memory.createStagingBuffer(BUFFER_SIZE);
            initBuffer.length  = BUFFER_SIZE;

            statsBuffer        = vk.memory.local.allocBuffer("printf2", Stats.sizeof, VBufferUsage.STORAGE | VBufferUsage.TRANSFER_SRC | VBufferUsage.TRANSFER_DST);
            stagingStatsBuffer = vk.memory.createStagingBuffer(Stats.sizeof);
        }
        log("ShaderPrintf using shared memory = %s", useSharedMemory);
        reset();
    }
    float* getData() {

        /* Get the flags and length */


        if(useSharedMemory) {
            /* Using shared memory */

            Stats* p = cast(Stats*)statsBuffer.mapForReading();
            stats    = *p;

            return cast(float*)debugBuffer.mapForReading();
        }

        /* Using staging buffer */
        vk.memory.copyDeviceToHost(debugBuffer, 0, stagingDebugBuffer.parent, stagingDebugBuffer.offset, BUFFER_SIZE);
        vk.memory.copyDeviceToHost(statsBuffer, 0, stagingStatsBuffer.parent, stagingStatsBuffer.offset, Stats.sizeof);
        //stats = vk.memory.copyToHost!Stats(statsBuffer)[0];

        Stats* p = cast(Stats*)stagingStatsBuffer.mapForReading();
        stats    = *p;

        return cast(float*)stagingDebugBuffer.mapForReading();
    }
}

