module vulkan.misc.shader_printf;
/**
 *
 */
import vulkan.all;

final class ShaderPrintf {
private:
    Vulkan vk;
    DeviceBuffer debugBuffer;
    VkDescriptorSet ds;
public:
    this(Vulkan vk) {
        this.vk = vk;
        init();
    }
    void destroy() {
        if(debugBuffer) debugBuffer.free();
    }
    DeviceBuffer getBuffer() { return debugBuffer; }
    void reset() {
        // set counter to 0
        uint* ptr = cast(uint*)debugBuffer.map();
        ptr[0] = 0;
        ptr[1] = 0;
        debugBuffer.flush();
    }

    string getDebugString() {
        char suffix ='\n';
        auto buf    = appender!(char[]);
        void* vp    = debugBuffer.map();
        float* ptr  = cast(float*)vp;
        uint len    = (cast(uint*)vp)[1];
        ptr+=2;

        //writefln("printf=%s", ptr[0..len]);

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
    void init() {
        debugBuffer = vk.memory.shared_.allocBuffer("debug", 4.MB, VBufferUsage.STORAGE);
        reset();
    }
}

