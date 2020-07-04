module vulkan.renderers.rectangles;
/**
 *
 */
import vulkan.all;

private struct Vertex { static assert(Vertex.sizeof==24);
    vec2 pos;
    RGBA colour;
}
private struct UBO {
    mat4 viewProj;
}

final class Rectangles {
    VulkanContext context;

    GraphicsPipeline pipeline;
    Descriptors descriptors;
    SubBuffer vertexBuffer, stagingBuffer, uniformBuffer;
    int maxRects;
    RGBA colour = WHITE;
    Vertex[] vertices;
    UBO ubo;
    bool verticesChanged = true;
    bool uboChanged = true;

    int numRects() { return cast(int)vertices.length/6; }

    this(VulkanContext context, int maxRects) {
        this.context  = context;
        this.maxRects = maxRects;
        initialise();
    }
    void destroy() {
        if(stagingBuffer) stagingBuffer.free();
        if(vertexBuffer) vertexBuffer.free();
        if(uniformBuffer) uniformBuffer.free();
        if(pipeline) pipeline.destroy();
        if(descriptors) descriptors.destroy();
    }
    auto setCamera(Camera2D camera) {
        ubo.viewProj = camera.VP;
        uboChanged = true;
        return this;
    }
    auto setColour(RGBA c) {
        this.colour = c;
        return this;
    }
    /**
     *  Vertices are assumed to be clockwise eg.
     *  1-2
     *  | |
     *  4-3
     */
    auto addRect(vec2 p1, vec2 p2, vec2 p3, vec2 p4) {
        return addRect(p1,p2,p3,p4, colour, colour, colour, colour);
    }
    auto addRect(
        vec2 p1, vec2 p2, vec2 p3, vec2 p4,
        RGBA c1, RGBA c2, RGBA c3, RGBA c4)
    {
        vertices.length+=6;
        return updateRect(
            numRects()-1,
            p1,p2,p3,p4,c1,c2,c3,c4);
    }
    auto updateRect(int index,
        vec2 p1, vec2 p2, vec2 p3, vec2 p4,
        RGBA c1, RGBA c2, RGBA c3, RGBA c4)
    {
        expect(index<numRects());
        index*=6;
        // 1-2  (124), (234)
        // |/|
        // 4-3
        vertices[index+0] = Vertex(p1, c1);
        vertices[index+1] = Vertex(p2, c2);
        vertices[index+2] = Vertex(p4, c4);

        vertices[index+3] = Vertex(p2, c2);
        vertices[index+4] = Vertex(p3, c3);
        vertices[index+5] = Vertex(p4, c4);
        verticesChanged = true;
        return this;
    }
    auto clear() {
        vertices.length = 0;
        verticesChanged = true;
        return this;
    }
    void beforeRenderPass(PerFrameResource res) {
        if(verticesChanged) {
            updateVertices(res);
        }
        if(uboChanged) {
            updateUBO(res);
        }
    }
    void insideRenderPass(PerFrameResource res) {
        if(vertices.length==0) return;

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
            [vertexBuffer.handle],  // buffers
            [vertexBuffer.offset]); // offsets
        b.draw(cast(int)vertices.length, 1, 0, 0);
    }
private:
    void initialise() {
        auto verticesBufferSize = Vertex.sizeof * 6 * maxRects;

        vertexBuffer = context.buffer(BufID.VERTEX).alloc(verticesBufferSize);
        stagingBuffer = context.buffer(BufID.STAGING).alloc(verticesBufferSize);
        uniformBuffer = context.buffer(BufID.UNIFORM).alloc(UBO.sizeof);

        descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VShaderStage.VERTEX)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
                   .add(uniformBuffer.handle, uniformBuffer.offset, UBO.sizeof)
                   .write();

        pipeline = new GraphicsPipeline(context)
            .withVertexInputState!Vertex(VPrimitiveTopology.TRIANGLE_LIST)
            .withDSLayouts(descriptors.getAllLayouts())
            .withVertexShader(context.vk.shaderCompiler.getModule("geom2d/rectangles_vert.spv"))
            .withFragmentShader(context.vk.shaderCompiler.getModule("geom2d/rectangles_frag.spv"))
            .withStdColorBlendState()
            .build();
    }
    void updateUBO(PerFrameResource res) {
        uboChanged = false;
        // lol - slow
        context.transfer().from(&ubo).to(uniformBuffer).size(UBO.sizeof);
    }
    void updateVertices(PerFrameResource res) {
        verticesChanged = false;

        const numBytes = vertices.length*Vertex.sizeof;
        auto dest = cast(Vertex*)stagingBuffer.map();
        memcpy(dest, vertices.ptr, numBytes);

        auto b = res.adhocCB;
        auto region = VkBufferCopy(
            stagingBuffer.offset,
            vertexBuffer.offset,
            numBytes
        );
        b.copyBuffer(
            stagingBuffer.handle,
            vertexBuffer.handle,
            [region]
        );
    }
}

