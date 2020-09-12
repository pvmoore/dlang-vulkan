module vulkan.renderers.round_rectangles;

import vulkan.all;

final class RoundRectangles {
private:
    static struct Rectangle {
        vec2 pos;
        vec2 size;
        RGBA c1,c2,c3,c4;
        float radius;
    }
    static struct UBO {
        mat4 viewProj;
    }

    VulkanContext context;

    GraphicsPipeline pipeline;
    Descriptors descriptors;

    uint maxRects;
    uint numRects;
    GPUData!UBO ubo;
    GPUData!Rectangle rectangles;

    RGBA colour = WHITE;

public:
    this(VulkanContext context, uint maxRects) {
        this.context  = context;
        this.maxRects = maxRects;

        initialise();
    }
    void destroy() {
        if(ubo) ubo.destroy();
        if(rectangles) rectangles.destroy();
        if(pipeline) pipeline.destroy();
        if(descriptors) descriptors.destroy();
    }
    auto setCamera(Camera2D camera) {
        ubo.write((u) {
            u.viewProj = camera.VP();
        });
        return this;
    }
    auto setColour(RGBA c) {
        this.colour = c;
        return this;
    }
    auto addRect(vec2 pos, vec2 size, float cornerRadius) {
        return addRect(pos, size, colour, colour, colour, colour, cornerRadius);
    }
    auto addRect(vec2 pos, vec2 size,
                 RGBA c1, RGBA c2, RGBA c3, RGBA c4,
                 float cornerRadius)
    {
        expect(++numRects <= maxRects);

        rectangles.write((r) { *r = Rectangle(pos, size, c1, c2, c3, c4, cornerRadius); }, numRects-1);

        return this;
    }
    auto updateRect(uint index, vec2 pos, vec2 size,
                    RGBA c1, RGBA c2, RGBA c3, RGBA c4,
                    float cornerRadius)
    {
        expect(index<numRects);

        rectangles.write((r) { *r = Rectangle(pos, size, c1, c2, c3, c4, cornerRadius); }, index);

        return this;
    }
    auto clear() {
        rectangles.memset(0, numRects);
        return this;
    }
    void beforeRenderPass(Frame frame) {
        auto res = frame.resource;

        rectangles.upload(res.adhocCB);
        ubo.upload(res.adhocCB);
    }
    void insideRenderPass(Frame frame) {
        if(numRects==0) return;

        auto res = frame.resource;
        auto b = res.adhocCB;

        b.bindPipeline(pipeline);
        b.bindDescriptorSets(
            VPipelineBindPoint.GRAPHICS,
            pipeline.layout,
            0,                          // first set
            [descriptors.getSet(0,0)],  // descriptor sets
            null                        // dynamicOffsets
        );
        b.bindVertexBuffers(
            0,                      // first binding
            [rectangles.getDeviceBuffer().handle],  // buffers
            [rectangles.getDeviceBuffer().offset]); // offsets
        b.draw(numRects, 1, 0, 0);
    }
private:
    void initialise() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true).initialise();
        this.rectangles = new GPUData!Rectangle(context, BufID.VERTEX, true, maxRects)
            .withUploadStrategy(GPUDataUploadStrategy.RANGE)
            .initialise();

        descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VShaderStage.GEOMETRY)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
                   .add(ubo)
                   .write();

        pipeline = new GraphicsPipeline(context)
            .withVertexInputState!Rectangle(VPrimitiveTopology.POINT_LIST)
            .withDSLayouts(descriptors.getAllLayouts())
            .withStdColorBlendState()
            .withVertexShader(context.vk.shaderCompiler.getModule("geom2d/round_rectangles_vert.spv"))
            .withGeometryShader(context.vk.shaderCompiler.getModule("geom2d/round_rectangles_geom.spv"))
            .withFragmentShader(context.vk.shaderCompiler.getModule("geom2d/round_rectangles_frag.spv"))
            .build();
    }
}



