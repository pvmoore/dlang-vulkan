module vulkan.renderers.Text;

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
        uint group;
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
    uint group;
    bool dataChanged;

    uint[uint] renderId2Index;

    GPUData!UBO ubo;
    GPUData!Vertex vertices;
    PushConstants pushConstants;

    uint numCharacters;

    Formatter stdFormatter;

    Sequence!uint ids;
    Sequence!uint groupIds;
    Set!uint enabledGroups;
    uint maxCreatedGroup;
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
        this.enabledGroups  = new Set!uint;

        // Default group 0 is enabled
        enabledGroups.add(0);

        // Movge the group ids sequence to 1
        this.groupIds.next();

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
    Text camera(Camera2D camera) {
        ubo.write((u) {
            u.viewProj = camera.VP();
        });
        return this;
    }
    /// Assume this is set at the start and never changed
    Text setDropShadowColour(RGBA c) {
        ubo.write((u) {
            u.dsColour = c;
        });
        return this;
    }
    /// Assume this is set at the start and never changed
    Text setDropShadowOffset(float2 o) {
        ubo.write((u) {
            u.dsOffset = o;
        });
        return this;
    }
    Text setColour(RGBA colour) {
        this.colour = colour;
        return this;
    }
    Text setSize(float size) {
        this.size = size;
        return this;
    }

    // ╔─────────────────────────────────╗
    // │ Creation functions              │
    // ╚─────────────────────────────────╝
    uint add(string text, uint x, uint y) {
        return add(text, stdFormatter, x, y);
    }
    uint add(string text, Formatter fmt, uint x, uint y) {
        TextChunk chunk;
        chunk.group = group;
        chunk.text = text;
        chunk.dtext = chunk.text.toUTF32();
        chunk.fmt = fmt.orElse(stdFormatter);
        chunk.colour = colour;
        chunk.size = size;
        chunk.x = x;
        chunk.y = y;

        auto index = textChunks.length.as!uint;
        auto uuid = ids.next();
        renderId2Index[uuid] = index;
        textChunks ~= chunk;
        dataChanged = true;
        return uuid;
    }

    // ╔───────────────────────────────────────╗
    // │ Modification functions (single item)  │
    // ╚───────────────────────────────────────╝
    Text replace(uint uuid, string text) {
        // check to see if the text has actually changed.
        // if not then we can ignore this change
        uint index = renderId2Index[uuid];
        TextChunk* c = &textChunks[index];
        if(c.text == text) {
            return this;
        }
        c.text = text;
        c.dtext = c.text.toUTF32();

        dataChanged = true;
        return this;
    }
    Text reformat(uint uuid, Formatter fmt) {
        uint index = renderId2Index[uuid];
        TextChunk* c = &textChunks[index];
        c.fmt = fmt;
        dataChanged = true;
        return this;
    }
    Text moveTo(uint uuid, int x, int y) {
        uint index = renderId2Index[uuid];
        TextChunk* c = &textChunks[index];
        c.x = x;
        c.y = y;
        dataChanged = true;
        return this;
    }
    Text remove(uint uuid) {
        uint index = renderId2Index[uuid];
        renderId2Index.remove(uuid);

        textChunks.removeAt(index);

        dataChanged = true;
        return this;
    }
    Text clear() {
        textChunks.length = 0;
        dataChanged = true;
        return this;
    }
    // ╔─────────────────────────────────╗
    // │ Group functions                 │
    // ╚─────────────────────────────────╝
    uint createGroup() {
        this.maxCreatedGroup = groupIds.next();
        return maxCreatedGroup;
    }
    Text setGroup(uint groupId) {
        vkassert(groupId <= maxCreatedGroup);
        this.group = groupId;
        return this;
    }
    Text unsetGroup() {
        // 0 is the default group
        this.group = 0;
        return this;
    }
    Text enableGroup(uint groupId, bool enable) {
        vkassert(groupId <= maxCreatedGroup);
        auto isCurrentlyEnabled = enabledGroups.contains(groupId);
        if(enable) {
            if(isCurrentlyEnabled) return this;
            enabledGroups.add(groupId);
        } else {
            if(!isCurrentlyEnabled) return this;
            enabledGroups.remove(groupId);
        }
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
            VK_PIPELINE_BIND_POINT_GRAPHICS,
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
                VK_SHADER_STAGE_FRAGMENT_BIT,
                0,
                PushConstants.sizeof,
                &pushConstants
            );
            b.draw(numCharacters, 1, 0, 0); // numCharacters points
        }
        pushConstants.doShadow = false;
        b.pushConstants(
            pipeline.layout,
            VK_SHADER_STAGE_FRAGMENT_BIT,
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
            if(!enabledGroups.contains(c.group)) continue;

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
        vkassert(total<=maxCharacters, "%s > %s".format(total, maxCharacters));
        return cast(int)total;
    }
    void createSampler() {
        sampler = context.device.createSampler(samplerCreateInfo());
    }
    void createDescriptorSets() {
        descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VK_SHADER_STAGE_GEOMETRY_BIT | VK_SHADER_STAGE_FRAGMENT_BIT)
                .combinedImageSampler(VK_SHADER_STAGE_FRAGMENT_BIT)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
                   .add(ubo)
                   .add(sampler,
                        font.image.view,
                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)
                   .write();
    }
    void createPipeline() {
        pipeline = new GraphicsPipeline(context)
            .withVertexInputState!Vertex(VK_PRIMITIVE_TOPOLOGY_POINT_LIST)
            .withDSLayouts(descriptors.getAllLayouts())
            .withColorBlendState([
                colorBlendAttachment((info) {
                    info.blendEnable         = VK_TRUE;
                    info.srcColorBlendFactor = VK_BLEND_FACTOR_SRC_ALPHA;
                    info.dstColorBlendFactor = VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA;
                    info.srcAlphaBlendFactor = VK_BLEND_FACTOR_ONE;
                    info.dstAlphaBlendFactor = VK_BLEND_FACTOR_ZERO;
                    info.colorBlendOp        = VK_BLEND_OP_ADD;
                    info.alphaBlendOp        = VK_BLEND_OP_ADD;
                })
            ])
            .withVertexShader(context.vk.shaderCompiler.getModule("font/font1_vert.spv"))
            .withGeometryShader(context.vk.shaderCompiler.getModule("font/font2_geom.spv"))
            .withFragmentShader(context.vk.shaderCompiler.getModule("font/font3_frag.spv"))
            .withPushConstantRange!PushConstants(VK_SHADER_STAGE_FRAGMENT_BIT)
            .build();
    }
}
