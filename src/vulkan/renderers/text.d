module vulkan.renderers.text;
/**
 *
 */
import vulkan.all;

private align(1) struct Vertex { align(1):
    vec4 pos;
    vec4 uvs;
    vec4 colour;
    float size;
}
private struct UBO {
    Matrix4 viewProj;
    vec4 dsColour;
    vec2 dsOffset;
    byte[8] _pad;
}
private struct PushConstants {
    bool doShadow;
    byte[3] _pad;
}
private struct TextChunk {
    string text;
    RGBA colour;
    float size;
    int x, y;
}
static assert(Vertex.sizeof==13*float.sizeof);
static assert(UBO.sizeof==24*4);
static assert(PushConstants.sizeof==4);

private final class FrameResource {
    //ulong lastUpdated; // frame this was last written to GPU
}

final class Text {
    Vulkan vk;
    VkDevice device;

    GraphicsPipeline pipeline;
    Descriptors descriptors;

    VkDescriptorSet ds;
    SubBuffer vertexBuffer, stagingBuffer, uniformBuffer;
    VkRenderPass renderPass;
    VkSampler sampler;

    Font font;
    bool dropShadow;
    uint maxCharacters;

    TextChunk[] textChunks;
    RGBA colour = WHITE;
    float size;
    bool dataChanged;
    Vertex[] vertices;

    UBO ubo;
    PushConstants pushConstants;
    FrameResource[] frameResources;

    bool unicodeAware;
    uint numCharacters;
    ulong vertexBufferOffset;
    ulong verticesNumBytes;

    this(Vulkan vk,
         VkRenderPass renderPass,
         Font font,
         bool dropShadow,
         uint maxCharacters)
    {
        this.vk             = vk;
        this.device         = vk.device;
        this.font           = font;
        this.size           = font.sdf.size;
        this.dropShadow     = dropShadow;
        this.maxCharacters  = maxCharacters;
        this.renderPass     = renderPass;
        this.dataChanged    = true;
        this.textChunks.reserve(8);
        this.frameResources.reserve(3);
        this.vertices.length = maxCharacters;

        pushConstants.doShadow = dropShadow;
        ubo.dsColour = RGBA(0,0,0, 0.75);
        ubo.dsOffset = vec2(-0.0025, 0.0025);

        createFrameResources();
        createBuffers();
        createSampler();
        createDescriptorSets();
        createPipeline();
    }
    void destroy() {
        if(stagingBuffer) stagingBuffer.free();
        if(vertexBuffer) vertexBuffer.free();
        if(uniformBuffer) uniformBuffer.free();

        if(descriptors) descriptors.destroy();
        if(sampler) device.destroy(sampler);
        if(pipeline) pipeline.destroy();
    }
    auto setUnicodeAware(bool flag=true) {
        this.unicodeAware = flag;
        return this;
    }
    /// Assume this is set at the start and never changed
    auto setCamera(Camera2D cam) {
        ubo.viewProj = cam.VP;
        vk.memory.copyToDevice(uniformBuffer, &ubo);
        return this;
    }
    /// Assume this is set at the start and never changed
    auto setDropShadowColour(RGBA c) {
        ubo.dsColour = c;
        vk.memory.copyToDevice(uniformBuffer, &ubo);
        return this;
    }
    /// Assume this is set at the start and never changed
    auto setDropShadowOffset(vec2 o) {
        ubo.dsOffset = o;
        vk.memory.copyToDevice(uniformBuffer, &ubo);
        return this;
    }
    auto setColour(RGBA colour) {
        this.colour = colour;
        return this;
    }
    auto setSize(float size) {
        this.size = size;
        return this;
    }
    auto appendText(string text, uint x=0, uint y=0) {
        TextChunk chunk;
        chunk.text = text;
        chunk.colour = colour;
        chunk.size = size;
        chunk.x = x;
        chunk.y = y;
        textChunks ~= chunk;
        dataChanged = true;
        return this;
    }
    auto replaceText(int chunk, string text, int x=int.max, int y=int.max) {
        // check to see if the text has actually changed.
        // if not then we can ignore this change
        TextChunk* c = &textChunks[chunk];
        if((x==int.max || x==c.x) && (y==int.max || y==c.y) && c.text == text) {
            return this;
        }
        c.text = text;
        if(x!=int.max) c.x = x;
        if(y!=int.max) c.y = y;
        dataChanged = true;
        return this;
    }
    auto replaceText(string text) {
        return replaceText(0, text);
    }
    auto clear() {
        textChunks.length = 0;
        dataChanged = true;
        return this;
    }
    void beforeRenderPass(PerFrameResource res) {
        if(dataChanged) {
            dataChanged        = false;
            numCharacters      = countCharacters();
            verticesNumBytes   = numCharacters*Vertex.sizeof;
            vertexBufferOffset = res.index*maxCharacters*Vertex.sizeof;

            generateVertices();
            updateVertices(res.adhocCB);
//            log("render.dataChanged");
//            log("render.frameIndex=%s", frameIndex);
//            log("render.numCharacters=%s", numCharacters);
//            log("render.vertexBufferOffset=%s", vertexBufferOffset);
//            log("render.verticesNumBytes=%s", verticesNumBytes);
        }
    }
    void insideRenderPass(PerFrameResource res) {
        if(numCharacters==0) return;

        auto b = res.adhocCB;

        b.bindPipeline(pipeline);
        b.bindDescriptorSets(
            VPipelineBindPoint.GRAPHICS,
            pipeline.layout,
            0,      // first set
            [ds],   // descriptor sets
            null    // dynamicOffsets
        );
        b.bindVertexBuffers(
            0,                      // first binding
            [vertexBuffer.handle],  // buffers
            [vertexBuffer.offset + vertexBufferOffset]); // offsets

        if(dropShadow) {
            pushConstants.doShadow = true;
            b.pushConstants(
                pipeline.layout,
                VShaderStage.FRAGMENT,
                0,
                PushConstants.sizeof,
                &pushConstants
            );
            b.draw(numCharacters, 1, 0, 0); // numCharacters points
        }
        pushConstants.doShadow = false;
        b.pushConstants(
            pipeline.layout,
            VShaderStage.FRAGMENT,
            0,
            PushConstants.sizeof,
            &pushConstants
        );
        b.draw(numCharacters, 1, 0, 0); // numCharacters points
    }
private:
    void updateVertices(VkCommandBuffer b) {
        auto region = VkBufferCopy(
            stagingBuffer.offset,
            vertexBuffer.offset + vertexBufferOffset,
            verticesNumBytes
        );
        b.copyBuffer(
            stagingBuffer.handle,
            vertexBuffer.handle,
            [region]
        );
    }
    void generateVertices() {
        auto v = 0;
        foreach(ref c; textChunks) {
            auto maxY = c.size;
            float X = c.x;
            float Y = c.y;

            void generateVertex(ulong i, uint ch) {
                auto g = font.sdf.getChar(ch);
                float ratio = (c.size/cast(float)font.sdf.size);

                float x = X + g.xoffset * ratio;
                float y = Y + g.yoffset * ratio;
                float w = g.width * ratio;
                float h = g.height * ratio;

                vertices[v].pos    = vec4(x, y, w, h);
                vertices[v].uvs    = vec4(g.u, g.v, g.u2, g.v2);
                vertices[v].colour = c.colour;
                vertices[v].size   = c.size;

                int kerning = 0;
                if(i<c.text.length-1) {
                    kerning = font.sdf.getKerning(ch, c.text[i+1]);
                }

                X += (g.xadvance + kerning) * ratio;
                v++;
            }
            if(unicodeAware) {
                import std.utf : byChar, byUTF, toUTF16;
                int i=0;
                foreach(ch; c.text.toUTF16) {
                    generateVertex(i++, ch);
                }
            } else {
                foreach(i, ch; c.text) {
                    generateVertex(i, ch);
                }
            }
        }
        // write vertices to staging buffer
        void* ptr = stagingBuffer.map();
        memcpy(ptr, vertices.ptr, verticesNumBytes);
        stagingBuffer.flush();
    }
    void createFrameResources() {
        frameResources.length = vk.swapchain.numImages;
        foreach(ref r; frameResources) {
            r = new FrameResource();
        }
    }
    int countCharacters() {
        long total = 0;
        foreach(ref c; textChunks) {
            if(unicodeAware) {
                import std.utf : count;

                total += c.text.count;
            } else {
                total += c.text.length;
            }
        }
        expect(total<=maxCharacters);
        return cast(int)total;
    }
    void createSampler() {
        sampler = device.createSampler(samplerCreateInfo());
    }
    void createBuffers() {
        auto verticesSize = Vertex.sizeof *
                            maxCharacters *
                            vk.swapchain.numImages;
        auto stagingSize = Vertex.sizeof *
                           maxCharacters;
        vertexBuffer  = vk.memory.createVertexBuffer(verticesSize);
        stagingBuffer = vk.memory.createStagingBuffer(stagingSize);
        uniformBuffer = vk.memory.createUniformBuffer(ubo.sizeof);
    }
    void createDescriptorSets() {
        descriptors = new Descriptors(vk)
            .createLayout()
                .uniformBuffer(VShaderStage.GEOMETRY | VShaderStage.FRAGMENT)
                .combinedImageSampler(VShaderStage.FRAGMENT)
                .sets(1)
            .build();

        ds = descriptors
            .createSetFromLayout(0)
                .add(uniformBuffer.handle, uniformBuffer.offset, ubo.sizeof)
                .add(sampler,
                     font.image.view,
                     VImageLayout.SHADER_READ_ONLY_OPTIMAL)
                .write();
    }
    void createPipeline() {
        pipeline = new GraphicsPipeline(vk, renderPass)
            .withVertexInputState!Vertex(VPrimitiveTopology.POINT_LIST)
            .withDSLayouts(descriptors.layouts)
            .withColorBlendState([
                colorBlendAttachment((info) {
                    info.blendEnable         = VK_TRUE;
                    info.srcColorBlendFactor = VBlendFactor.SRC_ALPHA;
                    info.dstColorBlendFactor = VBlendFactor.ONE_MINUS_SRC_ALPHA;
                    info.srcAlphaBlendFactor = VBlendFactor.ONE;
                    info.dstAlphaBlendFactor = VBlendFactor.ZERO;
                    info.colorBlendOp        = VBlendOp.ADD;
                    info.alphaBlendOp        = VBlendOp.ADD;
                })
            ])
            .withVertexShader(vk.shaderCompiler.getModule("font/font1_vert.spv"))
            .withGeometryShader(vk.shaderCompiler.getModule("font/font2_geom.spv"))
            .withFragmentShader(vk.shaderCompiler.getModule("font/font3_frag.spv"))
            .withPushConstantRange!PushConstants(VShaderStage.FRAGMENT)
            .build();
    }
}
