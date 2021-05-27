module vulkan.renderers.text;

import vulkan.all;
import std.utf : toUTF32;

final class Text {
private:
    static struct UBO { static assert(UBO.sizeof == 96);
        mat4 viewProj;
        float4 dsColour;
        float2 dsOffset;
        byte[8] _pad;
    }
    static struct Vertex { static assert(Vertex.sizeof==13*float.sizeof);
        float4 pos;
        float4 uvs;
        float4 colour;
        float size;
    }
    static struct PushConstants { static assert(PushConstants.sizeof==4);
        bool doShadow;
        byte[3] _pad;
    }
    static struct TextChunk {
        string text;
        dstring dtext;
        Text.Formatter fmt;
        RGBA colour;
        float size;
        int x, y;
    }
    VulkanContext context;

    GraphicsPipeline pipeline;
    Descriptors descriptors;

    SubBuffer vertexBuffer, stagingBuffer;
    VkSampler sampler;

    Font font;
    const bool dropShadow;
    const uint maxCharacters;

    TextChunk[] textChunks;
    RGBA colour = WHITE;
    float size;
    bool dataChanged;

    uint[UUID] uuid2Index;

    GPUData!UBO ubo;
    GPUData!Vertex vertices;
    PushConstants pushConstants;

    uint numCharacters;

    Formatter stdFormatter;
public:
    static struct CharFormat {
        RGBA colour;
        float size;
    }
    alias Formatter = CharFormat delegate(ref TextChunk chunk, uint index);

    this(VulkanContext context, Font font, bool dropShadow, uint maxCharacters) {
        this.context        = context;
        this.font           = font;
        this.size           = font.sdf.size;
        this.dropShadow     = dropShadow;
        this.maxCharacters  = maxCharacters;
        this.dataChanged    = true;

        pushConstants.doShadow = dropShadow;

        this.stdFormatter = (ref chunk, index) {
            return CharFormat(chunk.colour, chunk.size);
        };

        initialise();
    }
    void destroy() {
        if(ubo) ubo.destroy();
        if(vertices) vertices.destroy();
        if(descriptors) descriptors.destroy();
        if(sampler) context.device.destroySampler(sampler);
        if(pipeline) pipeline.destroy();
    }
    /// Assume this is set at the start and never changed
    auto camera(Camera2D camera) {
        ubo.write((u) {
            u.viewProj = camera.VP();
        });
        return this;
    }
    /// Assume this is set at the start and never changed
    auto setDropShadowColour(RGBA c) {
        ubo.write((u) {
            u.dsColour = c;
        });
        return this;
    }
    /// Assume this is set at the start and never changed
    auto setDropShadowOffset(float2 o) {
        ubo.write((u) {
            u.dsOffset = o;
        });
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
    UUID appendText(string text, uint x=0, uint y=0) {
        return appendText(text, stdFormatter, x, y);
    }
    UUID appendText(string text, Formatter fmt, uint x=0, uint y=0) {
        TextChunk chunk;
        chunk.text = text;
        chunk.dtext = chunk.text.toUTF32();
        chunk.fmt = fmt.orElse(stdFormatter);
        chunk.colour = colour;
        chunk.size = size;
        chunk.x = x;
        chunk.y = y;

        uint index = textChunks.length.as!uint;
        UUID uuid = randomUUID();
        uuid2Index[uuid] = index;
        textChunks ~= chunk;
        dataChanged = true;
        return uuid;
    }
    Text replaceText(UUID uuid, string text, int x=int.max, int y=int.max) {
        // check to see if the text has actually changed.
        // if not then we can ignore this change
        uint index = uuid2Index[uuid];
        TextChunk* c = &textChunks[index];
        if((x==int.max || x==c.x) && (y==int.max || y==c.y) && c.text == text) {
            return this;
        }
        c.text = text;
        c.dtext = c.text.toUTF32();
        if(x!=int.max) c.x = x;
        if(y!=int.max) c.y = y;

        dataChanged = true;
        return this;
    }
    /** Replaces text of the first and only TextChunk */
    Text replaceText(string text) {
        foreach(k,v; uuid2Index) {
            if(v==0) return replaceText(k, text);
        }
        throw new Exception("Chunk not found");
    }
    Text reformatText(UUID uuid, Formatter fmt) {
        uint index = uuid2Index[uuid];
        TextChunk* c = &textChunks[index];
        c.fmt = fmt;
        dataChanged = true;
        return this;
    }
    Text moveText(UUID uuid, int x, int y) {
        uint index = uuid2Index[uuid];
        TextChunk* c = &textChunks[index];
        c.x = x;
        c.y = y;
        dataChanged = true;
        return this;
    }
    auto remove(UUID uuid) {
        uint index = uuid2Index[uuid];
        uuid2Index.remove(uuid);

        textChunks.removeAt(index);

        dataChanged = true;
        return this;
    }
    Text clear() {
        textChunks.length = 0;
        dataChanged = true;
        return this;
    }

    void beforeRenderPass(Frame frame) {
        auto res = frame.resource;
        ubo.upload(res.adhocCB);
        if(dataChanged) {
            dataChanged   = false;
            numCharacters = countCharacters();

            generateVertices();

            vertices.upload(res.adhocCB);
        }
    }
    void insideRenderPass(Frame frame) {
        if(numCharacters==0) return;

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
            0,                                      // first binding
            [vertices.getDeviceBuffer().handle],    // buffers
            [vertices.getDeviceBuffer().offset]);   // offsets

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
    void initialise() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true).initialise();

        this.vertices = new GPUData!Vertex(context, BufID.VERTEX, true, maxCharacters)
            .withUploadStrategy(GPUDataUploadStrategy.RANGE)
            .initialise();

        ubo.write((u) {
            u.dsColour = RGBA(0,0,0, 0.75);
            u.dsOffset = vec2(-0.0025, 0.0025);
        });

        createSampler();
        createDescriptorSets();
        createPipeline();
    }
    void generateVertices() {
        auto v = 0;
        foreach(ref c; textChunks) {
            float X = c.x;
            float Y = c.y;

            void _generateVertex(uint i, uint ch) {
                auto g = font.sdf.getChar(ch);
                float ratio = (c.size/cast(float)font.sdf.size);

                float x = X + g.xoffset * ratio;
                float y = Y + g.yoffset * ratio;
                float w = g.width * ratio;
                float h = g.height * ratio;

                auto f = c.fmt(c, i);

                vertices.write((vert) {
                    vert.pos    = vec4(x, y, w, h);
                    vert.uvs    = vec4(g.u, g.v, g.u2, g.v2);
                    vert.colour = f.colour;
                    vert.size   = f.size;
                }, v);

                int kerning = 0;
                if(i<c.text.length-1) {
                    kerning = font.sdf.getKerning(ch, c.text[i+1]);
                }

                X += (g.xadvance + kerning) * ratio;
                v++;
            }
            foreach(i, ch; c.dtext) {
                _generateVertex(i.as!uint, ch);
            }
        }
    }
    int countCharacters() {
        long total = 0;
        foreach(ref c; textChunks) {
            total += c.dtext.length;
        }
        _assert(total<=maxCharacters, "%s > %s".format(total, maxCharacters));
        return cast(int)total;
    }
    void createSampler() {
        sampler = context.device.createSampler(samplerCreateInfo());
    }
    void createDescriptorSets() {
        descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VShaderStage.GEOMETRY | VShaderStage.FRAGMENT)
                .combinedImageSampler(VShaderStage.FRAGMENT)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
                   .add(ubo)
                   .add(sampler,
                        font.image.view,
                        VImageLayout.SHADER_READ_ONLY_OPTIMAL)
                   .write();
    }
    void createPipeline() {
        pipeline = new GraphicsPipeline(context)
            .withVertexInputState!Vertex(VPrimitiveTopology.POINT_LIST)
            .withDSLayouts(descriptors.getAllLayouts())
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
            .withVertexShader(context.vk.shaderCompiler.getModule("font/font1_vert.spv"))
            .withGeometryShader(context.vk.shaderCompiler.getModule("font/font2_geom.spv"))
            .withFragmentShader(context.vk.shaderCompiler.getModule("font/font3_frag.spv"))
            .withPushConstantRange!PushConstants(VShaderStage.FRAGMENT)
            .build();
    }
}
