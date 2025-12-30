module vulkan.renderers.Text2;

import vulkan.all;

/**
 * Text renderer (similar to Text.d but optimised for text that might be modified frequently)
 *
 *
 */
final class Text2 {
public:
    enum Align { LEFT, CENTRE, RIGHT }

    this(VulkanContext context, Font font, uint maxCharacters, uint maxSpans) {
        assert(maxCharacters > 0, "maxCharacters must be greater than 0");
        assert(maxSpans > 0, "maxSpans must be greater than 0");

        this.context        = context;
        this.font           = font;
        this.maxCharacters  = maxCharacters;
        this.charFreeList   = new FreeList(maxCharacters);
        this.spanFreeList   = new FreeList(maxSpans);
        this.spans.length   = maxSpans;

        initialise();
    }
    void destroy() {
        if(descriptors) descriptors.destroy();
        if(pipeline) pipeline.destroy();
        if(ubo) ubo.destroy();
        if(vertices) vertices.destroy();
        if(indices) indices.destroy();
        if(spanData) spanData.destroy();
        if(sampler) context.device.destroySampler(sampler);
    }
    auto camera(Camera2D camera) {
        ubo.write((u) {
            u.viewProj = camera.VP();
        });
        return this;
    }
    auto setDropShadow(RGBA colour = RGBA(0,0,0, 0.75), float2 offset = float2(-0.0025, 0.0025)) {
        this.dropShadow = true;
        ubo.write((u) {
            u.dsColour = colour;
            u.dsOffset = offset;
        });
        return this;
    }
//──────────────────────────────────────────────────────────────────────────────────────────────────    
    /** Create a new empty span */ 
    uint createSpan(Align alignment, float2 pos, float size, float rotationRadians = 0) {
        assert(spanFreeList.numFree() > 0, "Maximum spans reached");
        uint index = spanFreeList.acquire();
        spans[index].chars.length = 0;
        spans[index].alignment = alignment;

        spanData.write((s) {
            s.translation = pos;
            s.offsetToAlignment = float2(0);
            s.rotation = -rotationRadians;
            s.scale = size / font.sdf.size.as!float;
        }, index);
        return index;
    }
    uint getSpanLength(uint span) {
        return spans[span].chars.length.as!uint;
    }
    /** Move a span to a new position */
    void moveSpan(uint span, float2 pos) {
        assert(span < spans.length, "Span index out of range");
        
        spanData.write((s) {
            s.translation = pos;
        }, span);
    }
    /** Rotate a span */
    void rotateSpan(uint span, float radians) {
        assert(span < spans.length, "Span index out of range");
        
        spanData.write((s) {
            s.rotation = -radians;
        }, span);
    }
    /** Resize a span */
    void resizeSpan(uint span, float size) {
        assert(span < spans.length, "Span index out of range");
        
        spanData.write((s) {
            s.scale = size / font.sdf.size.as!float;
        }, span);
    }
    /** Colour a range of characters within a span */
    void colourSpan(uint span, uint start, uint length, float4 colour) {
        assert(span < spans.length, "Span index out of range");
        Span* s = &spans[span];
        assert(start < s.chars.length, "Start index out of range");

        length = minOf(length, s.chars.length - start).as!uint;
        if(length == 0) return;

        Vertex* ptr = vertices.map();

        foreach(ref ch; s.chars[start..start+length]) {
            ch.colour = colour;

            auto vindex = ch.vertexIndex*4;
            auto v = ptr + vindex;
            v[0].colour = colour;
            v[1].colour = colour;
            v[2].colour = colour;
            v[3].colour = colour;

            vertices.setDirtyRange(vindex, vindex + 4);
        }
    }
    /** Append text to the end of a span */
    void appendText(uint span, string text, float4 colour) {
        assert(span < spans.length, "Span index out of range");
        Span* s = &spans[span];
        auto numUsed = charFreeList.numUsed();
        uint start = s.chars.length.as!uint;
        s.chars ~= text.map!(ch => Char(ch, colour)).array();
        generateVertices(span, start);
        assert(charFreeList.numUsed() == numUsed + text.length.as!uint);
    }
    /** Replace all text in a span */
    void replaceText(uint span, string text, float4 colour) {
        assert(span < spans.length, "Span index out of range");
        Span* s = &spans[span];
        discardVertices(s.chars);
        s.chars = text.map!(ch => Char(ch, colour)).array();
        generateVertices(span, 0);
        assert(charFreeList.numUsed() == text.length);
    }
    /** Remove text from a span */
    void removeText(uint span, uint start, uint length) {
        assert(span < spans.length, "Span index out of range");
        Span* s = &spans[span];
        assert(start < s.chars.length, "Start index out of range");
        if(start+length > s.chars.length) {
            length = (s.chars.length - start).as!uint;
        }
        if(length == 0) return;

        auto end = start+length;
        auto numUsed = charFreeList.numUsed();

        discardVertices(s.chars[start..end]);

        s.chars = s.chars[0..start] ~ s.chars[end..$];
        generateVertices(span, start);
        assert(charFreeList.numUsed() == numUsed - length);
    }
    /** Update text from a span starting at 'start' index */
    void updateText(uint span, uint start, string newText, float4 colour) {
        if(newText.length == 0) return;

        assert(span < spans.length, "Span index out of range");
        Span* s = &spans[span];
        assert(start < s.chars.length, "Start index out of range");

        uint numUsed  = charFreeList.numUsed();
        int remaining = (s.chars.length - start).as!int;
        int toUpdate  = minOf(remaining, newText.length).as!int;
        int toAdd     = maxOf(0, (newText.length - remaining).as!int);

        foreach(i; 0..toUpdate) {
            s.chars[start+i].ch = newText[i];
            s.chars[start+i].colour = colour;
        }
        if(toAdd > 0) {
            s.chars ~= newText[toUpdate..$].map!(ch => Char(ch, colour)).array();
        }

        generateVertices(span, start);
        assert(charFreeList.numUsed() == numUsed + toAdd);
    }
    /** Insert text into a span at 'start' index */
    void insertText(uint span, uint start, string text, float4 colour) {
        assert(span < spans.length, "Span index out of range");
        Span* s = &spans[span];
        assert(start <= s.chars.length, "Start index out of range");

        uint numUsed = charFreeList.numUsed();

        s.chars = s.chars[0..start] ~ text.map!(ch => Char(ch, colour)).array() ~ s.chars[start..$];
        generateVertices(span, start);
        assert(charFreeList.numUsed() == numUsed + text.length);
    }
    void removeSpan(uint span) {
        assert(span < spans.length, "Span index out of range");
        Span* s = &spans[span];
        uint numUsed = charFreeList.numUsed();
        discardVertices(s.chars);
        spanFreeList.release(span);
        assert(charFreeList.numUsed() == numUsed - s.chars.length);
        s.chars.length = 0;
    }
    void clear() {
        spanFreeList.reset();
        charFreeList.reset();
        maxVertexIndex = 0;
        vertices.memset(0);
        spanData.memset(0);
    }
//──────────────────────────────────────────────────────────────────────────────────────────────────    
    void beforeRenderPass(Frame frame) {
        auto cmd = frame.resource.adhocCB;
        ubo.upload(cmd);
        vertices.upload(cmd);
        indices.upload(cmd);
        spanData.upload(cmd);
    }
    void insideRenderPass(Frame frame) {
        if(spans.length == 0) return;

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

        b.bindIndexBuffer(
            indices.getDeviceBuffer().handle,
            indices.getDeviceBuffer().offset);

        // Draw drop shadow text
        if(dropShadow) {
            pushConstants.doShadow = 1;
            b.pushConstants(
                pipeline.layout,
                VK_SHADER_STAGE_FRAGMENT_BIT,
                0,
                PushConstants.sizeof,
                &pushConstants
            );
            //b.draw(maxVertexIndex*6, 1, 0, 0); 
            b.drawIndexed(maxVertexIndex*6, 1, 0, 0, 0);
        }

        // Draw normal text
        pushConstants.doShadow = 0;
        b.pushConstants(
            pipeline.layout,
            VK_SHADER_STAGE_FRAGMENT_BIT,
            0,
            PushConstants.sizeof,
            &pushConstants
        );
        // b.draw(maxVertexIndex*6, 1, 0, 0); 
        b.drawIndexed(maxVertexIndex*6, 1, 0, 0, 0);
    }
private:
    static struct UBO { static assert((UBO.sizeof & 15) == 0);
        mat4 viewProj;
        float4 dsColour;
        float2 dsOffset;
        byte[8] _pad;
    }
    static struct PushConstants { static assert((PushConstants.sizeof & 3) == 0);
        uint doShadow;
    }
    static struct Vertex { 
        float2 pos;
        float2 uv;
        float4 colour;
        uint span;
    }
    static struct SpanData {
        float2 translation;
        float2 offsetToAlignment;
        float rotation;
        float scale;
    }

    @Borrowed VulkanContext context;
    @Borrowed Font font;
    const uint maxCharacters;
    GraphicsPipeline pipeline;
    Descriptors descriptors;
    VkSampler sampler;

    GPUData!UBO ubo;
    GPUData!Vertex vertices;
    GPUData!ushort indices;
    GPUData!SpanData spanData;
    PushConstants pushConstants;

    Span[] spans;
    uint maxVertexIndex;
    FreeList charFreeList;
    FreeList spanFreeList;
    bool dropShadow;

    void initialise() {
        createBuffers();
        createSampler();
        createDescriptorSets();
        createPipeline();
    }
    void createBuffers() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true)
            .initialise();

        this.vertices = new GPUData!Vertex(context, BufID.VERTEX, true, maxCharacters*4)
            .withUploadStrategy(GPUDataUploadStrategy.RANGE)
            .initialise();

        this.indices = new GPUData!ushort(context, BufID.INDEX, true, maxCharacters*6)
            .withUploadStrategy(GPUDataUploadStrategy.RANGE)
            .initialise();

        this.spanData = new GPUData!SpanData(context, BufID.STORAGE, true, spans.length.as!uint)
            .withUploadStrategy(GPUDataUploadStrategy.RANGE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_VERTEX_SHADER_BIT,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_VERTEX_SHADER_BIT
            ))
            .initialise();

        ubo.write((u) {
            u.viewProj = mat4.identity;
            u.dsColour = RGBA(0,0,0, 0.75);
            u.dsOffset = float2(-0.0025, 0.0025);
        });

        ushort* idx = indices.map();
        foreach(i; 0..maxCharacters) {
            //  0----1  
            //  |A  /|  
            //  |  / |  
            //  | /  |  
            //  |/  B|  
            //  3----2  
            // 
            //  (0,1,3), (1,2,3)

            *idx++ = (i*4 + 0).as!ushort;
            *idx++ = (i*4 + 1).as!ushort;
            *idx++ = (i*4 + 3).as!ushort;
            *idx++ = (i*4 + 1).as!ushort;
            *idx++ = (i*4 + 2).as!ushort;
            *idx++ = (i*4 + 3).as!ushort;
        }
        indices.setDirtyRange();
    }
    void createSampler() {
        sampler = context.device.createSampler(samplerCreateInfo());
    }
    void createDescriptorSets() {
        // Bindings:
        //   0 - UBO
        //   1 - sampler
        //   2 - spanData
        descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT)
                .combinedImageSampler(VK_SHADER_STAGE_FRAGMENT_BIT)
                .storageBuffer(VK_SHADER_STAGE_VERTEX_BIT)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
                   .add(ubo)
                   .add(sampler, font.image.view, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)
                   .add(spanData)
                   .write();
    }
    void createPipeline() {

        auto shader = context.shaders.getModule("vulkan/text/text2.slang");

        pipeline = new GraphicsPipeline(context)
            .withVertexInputState!Vertex(VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST)
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
            .withVertexShader(shader, null, "vsmain")
            .withFragmentShader(shader, null, "fsmain")
            .withPushConstantRange!PushConstants(VK_SHADER_STAGE_FRAGMENT_BIT)
            .build();
    }
    void setSpanDataOffsets(SpanData* spanData, Span* span) {
        float width = span.getWidth();

        float2 toAlignment = float2(0);

        final switch(span.alignment) {
            case Align.LEFT: 
                toAlignment = float2(0, 0);
                break;
            case Align.CENTRE: 
                toAlignment = float2(-width/2, 0);
                break;
            case Align.RIGHT: 
                toAlignment = float2(-width, 0);
                break;
        }
        spanData.offsetToAlignment = toAlignment;
    }
    uint allocateVerticesForChar() {
        assert(charFreeList.numFree() > 0, "Max characters reached (%s)".format(maxCharacters));
        uint index = charFreeList.acquire();
        this.maxVertexIndex = maxOf(maxVertexIndex, index+1);
        return index;
    }
    void generateVertices(uint spanIndex, uint start) {
        assert(spanIndex < spans.length);

        if(start >= spans[spanIndex].chars.length) return;

        Span* span = &spans[spanIndex];

        // Generate/update from start index to the end of the char array
        // (x positions will likely have changed for all subsequent chars)
        foreach(i, ref ch; span.chars[start..$]) {
            // Allocate a new vertex if necessary
            if(ch.vertexIndex == uint.max) {
                ch.vertexIndex = allocateVerticesForChar();
            }
            updateVerticesForChar(spanIndex, start+i.as!uint);
        }

        // Update spanData offsetToAlignment
        spanData.write((s) {
            setSpanDataOffsets(s, span);
        }, spanIndex);
    }
    void discardVertices(Char[] range) {
        foreach(ref ch; range) {
            auto i = ch.vertexIndex;
            assert(i != uint.max);

            ch.vertexIndex = uint.max;

            vertices.memset(i*4, 4);
            charFreeList.release(i);
        }
    }
    void updateVerticesForChar(uint spanIndex, uint charIndex) {
        assert(spanIndex < spans.length);
        assert(charIndex < spans[spanIndex].chars.length);

        Span* span = &spans[spanIndex];
        Char* ch = &span.chars[charIndex];
        auto glyph  = font.sdf.getChar(ch.ch);
        assert(ch.vertexIndex != uint.max);

        float x = span.getXAtIndex(charIndex, font.sdf);
        float y = glyph.yoffset;
        float w = glyph.width;
        float h = glyph.height;

        ch.x = x;
        ch.w = w;

        //  0----1  (u,v)-----
        //  |A  /|    |      |
        //  |  / |    |      |
        //  | /  |    |      |
        //  |/  B|    |      |
        //  3----2    -----(u2,v2)
        // 
        //  (0,1,3), (1,2,3)

        uint vindex = ch.vertexIndex*4;
        Vertex* v = vertices.map() + vindex;

        // 0
        v.pos = float2(x, y);
        v.uv = float2(glyph.u, glyph.v);
        v.colour = ch.colour;
        v.span = spanIndex;
        v++;

        // 1
        v.pos = float2(x+w, y);
        v.uv = float2(glyph.u2, glyph.v);
        v.colour = ch.colour;
        v.span = spanIndex;
        v++;

        // 2
        v.pos = float2(x+w, y+h);
        v.uv = float2(glyph.u2, glyph.v2);
        v.colour = ch.colour;
        v.span = spanIndex;
        v++;

        // 3
        v.pos = float2(x, y+h);
        v.uv = float2(glyph.u, glyph.v2);
        v.colour = ch.colour;
        v.span = spanIndex;
        v++;

        vertices.setDirtyRange(vindex, vindex + 4);
    }
}

//──────────────────────────────────────────────────────────────────────────────────────────────────
private:

struct Span {
    Char[] chars;
    Text2.Align alignment;

    float getWidth() {
        if(chars.length == 0) return 0;

        Char lastChar = chars[$-1];
        return (lastChar.x + lastChar.w) - chars[0].x;
    }
    float getHeight(SDFFont sdf) {
        float h = 0;
        foreach(ch; chars) {
            auto glyph = sdf.getChar(ch.ch);
            h = max(h, glyph.height);
        }
        return h;
    }
    float getXAtIndex(uint charIndex, SDFFont sdf) {
        assert(charIndex < chars.length);

        Char current = chars[charIndex];
        auto glyph = sdf.getChar(current.ch);

        float x = glyph.xoffset;

        if(charIndex > 0) {
            Char prev = chars[charIndex-1];
            auto prevGlyph = sdf.getChar(prev.ch);

            float k = sdf.getKerning(prev.ch, current.ch);

            x += (prev.x - prevGlyph.xoffset) + prevGlyph.xadvance + k;
        }
        return x;
    }

    string toString() {
        return "Span(align:%s, chars:\"%s\")".format(alignment, chars.map!(ch => ch.ch).array());
    }
}

struct Char {
    dchar ch;
    float4 colour;
    uint vertexIndex = uint.max;
    float x;
    float w;

    string toString() {
        return "Char('%s' %s, x:%s, colour:%s, vertex:%s)".format(ch, ch.as!uint, x, colour, vertexIndex == uint.max ? -1 : vertexIndex.as!int);
    }
}
