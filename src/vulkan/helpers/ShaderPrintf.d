module vulkan.helpers.ShaderPrintf;
/**
 *
 *
 *  Requires the following in the shader:
 *  =====================================
 *
 *  layout(set=1, binding=0, std430) writeonly buffer PRINTF_BUFFER {
 *      float buf[];
 *  } printf;
 *
 *  layout(set=1, binding=1, std430) buffer PRINTF_STATS {
 *      uint buf[];
 *  } printf_stats;
 *
 *  #include "_printf.inc"
 *
 */
import vulkan.all;

final class ShaderPrintf {
private:
    enum : BufID {
        DEBUG_BUFFER_ID      = "printf_debug".as!BufID,
        STATS_BUFFER_ID      = "printf_stats".as!BufID,
        DEBUG_STAGING_BUF_ID = "printf_debug_staging".as!BufID,
        STATS_STAGING_BUF_ID = "printf_stats_staging".as!BufID
    }
    enum BUFFER_SIZE = 4.MB;

    VulkanContext context;
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
    this(VulkanContext context) {
        this.context = context;
        initialise();
    }
    void destroy() {
        //if(debugBuffer) debugBuffer.free();
        //if(statsBuffer) statsBuffer.free();
    }
    DeviceBuffer getDeviceBuffer() {
        return debugBuffer;
    }
    /**
     *  @param stages eg. VShaderStage.COMPUTE | VShaderStage.FRAGMENT
     */
    void createLayout(Descriptors d, VkShaderStageFlags stages) {
        d.createLayout()
         .storageBuffer(stages)
         .storageBuffer(stages)
         .sets(1);
    }
    void createDescriptorSet(Descriptors d, uint layoutNumber = 1) {
        d.createSetFromLayout(layoutNumber)
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
            statsBuffer.flush();
        } else {

            auto ptr = stagingStatsBuffer.map();
            memset(ptr, 0, Stats.sizeof);
            stagingStatsBuffer.flush();

            context.transfer().from(stagingStatsBuffer).to(statsBuffer).size(Stats.sizeof);

            // context.copySync(stagingStatsBuffer.parent, stagingStatsBuffer.offset,
            //                  statsBuffer, 0, statsBuffer.size);
        }
    }
    string getDebugString() {
        char suffix ='\n';
        auto buf    = appender!(char[]);

        auto ptr  = getData();
        uint len  = stats.length;

        //this.log("flags  = %s", stats.flags);
        //this.log("length = %s", stats.length);

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

                    this.log("matrix = %s", ptr[i..i+16]);

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

        if(context.hasMemory(MemID.SHARED)) {
            useSharedMemory = true;

            context.withBuffer(MemID.SHARED, DEBUG_BUFFER_ID, VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, BUFFER_SIZE);
            context.withBuffer(MemID.SHARED, STATS_BUFFER_ID, VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, BUFFER_SIZE);

            debugBuffer = context.buffer(DEBUG_BUFFER_ID);
            statsBuffer = context.buffer(STATS_BUFFER_ID);
        } else {
            context.withBuffer(MemID.LOCAL, DEBUG_BUFFER_ID, VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, BUFFER_SIZE)
                   .withBuffer(MemID.LOCAL, STATS_BUFFER_ID, VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, Stats.sizeof)
                   .withBuffer(MemID.STAGING, DEBUG_STAGING_BUF_ID, VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, BUFFER_SIZE)
                   .withBuffer(MemID.STAGING, STATS_STAGING_BUF_ID, VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, Stats.sizeof);

            debugBuffer = context.buffer(DEBUG_BUFFER_ID);
            statsBuffer = context.buffer(STATS_BUFFER_ID);

            stagingDebugBuffer = context.buffer(DEBUG_STAGING_BUF_ID).alloc(BUFFER_SIZE);
            stagingStatsBuffer = context.buffer(STATS_STAGING_BUF_ID).alloc(Stats.sizeof);

            initBuffer.length  = BUFFER_SIZE;
        }

        this.log("ShaderPrintf using shared memory = %s", useSharedMemory);
        reset();
    }
    float* getData() {

        if(useSharedMemory) {
            /* Using shared memory */

            Stats* p = cast(Stats*)statsBuffer.mapForReading();
            stats    = *p;

            return cast(float*)debugBuffer.mapForReading();
        }

        /* Using staging buffer */
        context.transfer().from(debugBuffer).to(stagingDebugBuffer).size(BUFFER_SIZE);
        context.transfer().from(statsBuffer).to(stagingStatsBuffer).size(Stats.sizeof);

        //context.copySync(debugBuffer, 0, stagingDebugBuffer.parent, stagingDebugBuffer.offset, debugBuffer.size);
        //context.copySync(statsBuffer, 0, stagingStatsBuffer.parent, stagingStatsBuffer.offset, statsBuffer.size);

        Stats* p = cast(Stats*)stagingStatsBuffer.mapForReading();
        stats    = *p;

        return cast(float*)stagingDebugBuffer.mapForReading();
    }
}

