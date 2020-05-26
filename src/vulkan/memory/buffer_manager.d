module vulkan.memory.buffer_manager;
/**
 *
 *
 * Usage:
 *      auto bm = BufferManager.perFrame(vk, 10000);
 *      // when data changes
 *      bm.write!float(data, offset);
 *      // in beforeRenderPass
 *      bm.update(res);
 *
 *
 */
import vulkan.all;
/+
final class BufferManager2 {
private:
    Strategy strategy;
public:
    static auto immediate(Vulkan vk, ulong sizeBytes) {
        auto b = new BufferManager;

        return b;
    }
    static auto perFrame(Vulkan vk, ulong sizeBytes) {
        auto b = new BufferManager;

        return b;
    }
    void write(T)(T[] data, ulong offset=0) {

    }
    void update(PerFrameResource res) {

    }
private:

}
//--------------------------------------------------------------
private interface Strategy {

}
private final class Immediate : Strategy {

}
private final class PerFrame : Strategy {

}
+/