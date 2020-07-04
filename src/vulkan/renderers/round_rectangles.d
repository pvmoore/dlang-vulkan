module vulkan.renderers.round_rectangles;
/**
 *
 */
import vulkan.all;

private struct Vertex {
    vec2 pos;
    vec2 size;
    RGBA c1,c2,c3,c4;
    float radius;
}
private struct UBO {
    mat4 viewProj;
}

final class RoundRectangles {
    VulkanContext context;

    GraphicsPipeline pipeline;
    Descriptors descriptors;
    SubBuffer vertexBuffer, stagingBuffer, uniformBuffer;

    int maxRects;
    Vertex[] vertices;
    RGBA colour = WHITE;
    UBO ubo;
    bool verticesChanged = true;
    bool uboChanged = true;

    int numRects() { return cast(int)vertices.length; }

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
    auto addRect(vec2 pos, vec2 size, float cornerRadius) {
        return addRect(pos, size, colour, colour, colour, colour, cornerRadius);
    }
    auto addRect(
        vec2 pos, vec2 size,
        RGBA c1, RGBA c2, RGBA c3, RGBA c4,
        float cornerRadius)
    {
        vertices ~= Vertex(pos, size, c1, c2, c3, c4, cornerRadius);
        verticesChanged = true;
        expect(vertices.length<=maxRects);
        return this;
    }
    auto updateRect(int index,
        vec2 pos, vec2 size,
        RGBA c1, RGBA c2, RGBA c3, RGBA c4,
        float cornerRadius)
    {
        expect(index<vertices.length);
        vertices[index] = Vertex(pos, size, c1, c2, c3, c4, cornerRadius);
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
        auto verticesBufferSize = Vertex.sizeof * maxRects;

        vertexBuffer = context.buffer(BufID.VERTEX).alloc(verticesBufferSize);
        stagingBuffer = context.buffer(BufID.STAGING).alloc(verticesBufferSize);
        uniformBuffer = context.buffer(BufID.UNIFORM).alloc(UBO.sizeof);

        descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VShaderStage.GEOMETRY)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
                   .add(uniformBuffer.handle, uniformBuffer.offset, UBO.sizeof)
                   .write();

        pipeline = new GraphicsPipeline(context)
            .withVertexInputState!Vertex(VPrimitiveTopology.POINT_LIST)
            .withDSLayouts(descriptors.getAllLayouts())
            .withStdColorBlendState()
            .withVertexShader(context.vk.shaderCompiler.getModule("geom2d/round_rectangles_vert.spv"))
            .withGeometryShader(context.vk.shaderCompiler.getModule("geom2d/round_rectangles_geom.spv"))
            .withFragmentShader(context.vk.shaderCompiler.getModule("geom2d/round_rectangles_frag.spv"))
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



