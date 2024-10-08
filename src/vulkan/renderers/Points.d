module vulkan.renderers.Points;

import vulkan.all;

/**
 * Multiple variable sized dots
 *
 *
 */
final class Points {
private:
    static struct UBO {
        mat4 viewProj;
    }
    static struct Vertex { align(1): static assert(Vertex.sizeof == 8*4);
        float2 pos;
        float size;
        float enabled;
        float4 colour;
    }
    @Borrowed VulkanContext context;
    Descriptors descriptors;
    GraphicsPipeline pipeline;
    GPUData!UBO ubo;
    GPUData!Vertex vertices;

    uint[] freeList;
    uint nextFree;
    uint numAllocated;
    float4 currentColour;
    float currentSize;
    const uint maxPoints;
public:
    this(VulkanContext context, uint maxPoints) {
        this.context = context;
        this.maxPoints = maxPoints;

        this.currentColour = float4(1,1,1,1);
        this.currentSize = 1;
        this.freeList.length = maxPoints;

        foreach(i; 0..maxPoints) {
            freeList[i] = i+1;
        }
        this.nextFree = 0;
        this.numAllocated = 0;
        initialise();
    }
    void destroy() {
        if(ubo) ubo.destroy();
        if(vertices) vertices.destroy();
        if(pipeline) pipeline.destroy();
        if(descriptors) descriptors.destroy();
    }
    auto camera(Camera2D cam) {
        ubo.write((u) { u.viewProj = cam.VP(); });
        return this;
    }
    auto colour(float4 c) {
        this.currentColour = c;
        return this;
    }
    auto size(float s) {
        this.currentSize = s;
        return this;
    }
    uint add(float2 pos) {
        return add(pos, currentSize, currentColour);
    }
    uint add(float2 pos, float size, float4 colour) {
        uint i = getNextFree();

        numAllocated++;

        vertices.write((v) {
            v.pos = pos;
            v.size = size;
            v.enabled = 1;
            v.colour = colour;
        }, i);

        return i;
    }
    void remove(uint index) {
        vertices.write((v) {
            v.enabled = 0;
        }, index);

        numAllocated--;
        freeList[index] = nextFree;
        nextFree = index;
    }

    auto setEnabled(uint index, bool enabled) {
        vertices.write((v) {
            v.enabled = enabled ? 1 : 0;
        }, index);
        return this;
    }
    auto setPos(uint index, float2 pos) {
        vertices.write((v) {
            v.pos = pos;
        }, index);
        return this;
    }
    auto setSize(uint index, float s) {
        vertices.write((v) {
            v.size = s;
        }, index);
        return this;
    }
    auto setColour(uint index, float4 c) {
        vertices.write((v) {
            v.colour = c;
        }, index);
        return this;
    }

    void beforeRenderPass(Frame frame) {
        auto cmd = frame.resource.adhocCB;
        ubo.upload(cmd);
        vertices.upload(cmd);
    }
    void insideRenderPass(Frame frame) {
        if(numAllocated==0) return;

        auto res = frame.resource;
        auto b = res.adhocCB;

        b.bindPipeline(pipeline);
        b.bindDescriptorSets(
            VK_PIPELINE_BIND_POINT_GRAPHICS,
            pipeline.layout,
            0,      // first set
            [descriptors.getSet(0,0)],
            null    // dynamic offsets
        );
        b.bindVertexBuffers(
            0,                           // first binding
            [vertices.getDeviceBuffer().handle],  // buffers
            [vertices.getDeviceBuffer().offset]); // offsets

        b.draw(maxPoints, 1, 0, 0);
    }
private:
    void initialise() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true).initialise();
        this.vertices = new GPUData!Vertex(context, BufID.VERTEX, true, maxPoints).initialise();

        this.vertices.memset(0, maxPoints);

        createDescriptors();
        createPipeline();
    }
    void createDescriptors() {
        /**
         * Bindings:
         *    0     uniform buffer
         */
        this.descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VK_SHADER_STAGE_GEOMETRY_BIT)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
            .add(ubo)
            .write();
    }
    void createPipeline() {
        this.pipeline = new GraphicsPipeline(context)
            .withVertexInputState!Vertex(VK_PRIMITIVE_TOPOLOGY_POINT_LIST)
            .withDSLayouts(descriptors.getAllLayouts())
            .withVertexShader(context.shaders.getModule("vulkan/points/Points.vert"))
            .withGeometryShader(context.shaders.getModule("vulkan/points/Points.geom"))
            .withFragmentShader(context.shaders.getModule("vulkan/points/Points.frag"))
            .withStdColorBlendState()
            .build();
    }
    uint getNextFree() {
        if(numAllocated==maxPoints) throw new Exception("No free Points found");

        uint i = nextFree;
        nextFree = freeList[i];
        return i;
    }
}
