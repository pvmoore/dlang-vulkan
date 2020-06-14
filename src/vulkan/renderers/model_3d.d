module vulkan.renderers.model_3d;

import vulkan.all;

final class Model3D {
private:
    VulkanContext context;
    ModelData data;
    bool modelChanged, ubo0Changed, ubo1Changed;
    UBO0 ubo0;
    UBO1 ubo1;
    SubBuffer ubo0Buffer, ubo1Buffer, vertexBuffer;
    SubBuffer stagingUbo0Buffer, stagingUbo1Buffer, stagingVertexBuffer;
    VkDescriptorSet descriptorSet, debugDS;
    VkSampler sampler;
    Vertex[] vertices;
    float3 _scale, _translation;
    float3 rotation;

    Descriptors descriptors;
    GraphicsPipeline pipeline;
    ShaderPrintf shaderPrintf;

    static struct Vertex { static assert(Vertex.sizeof == 12*4);
        vec3 vertexPosition_modelspace;
        vec3 vertexNormal_modelspace;
        vec2 vertexUV;
        vec4 vertexColour;
    }
    static struct UBO0 { static assert(UBO0.sizeof == 64*4 + 16);
        mat4 viewProj;
        mat4 view;
        mat4 invView;
        mat4 model;
        vec3 lightPosition_worldspace;
        float _pad1;
    }
    static struct UBO1 { static assert(UBO1.sizeof==16);
        float shineDamping;
        float reflectivity;
        float _pad1;
        float _pad2;
    }
public:
    this(VulkanContext context) {
        this.context = context;
        this.data = data;
        this.modelChanged = true;
        this.ubo0Changed = true;
        this.ubo1Changed = true;

        this._scale = float3(1);
        this.rotation = float3(0);
        this._translation = float3(0);
        this.ubo0.model = mat4.identity();

        this.ubo1.shineDamping = 10f;
        this.ubo1.reflectivity = 1f;
        initialise();
    }
    void destroy() {
        if(sampler) context.device.destroySampler(sampler);
        if(descriptors) descriptors.destroy();
        if(pipeline) pipeline.destroy();
        if(stagingUbo0Buffer) stagingUbo0Buffer.free();
        if(stagingUbo1Buffer) stagingUbo1Buffer.free();
        if(stagingVertexBuffer) stagingVertexBuffer.free();
        if(ubo0Buffer) ubo0Buffer.free();
        if(ubo1Buffer) ubo1Buffer.free();
        if(vertexBuffer) vertexBuffer.free();
        if(shaderPrintf) shaderPrintf.destroy();
    }
    auto modelData(ModelData data) {
        this.data = data;
        this.modelChanged = true;
        return this;
    }
    auto scale(float3 s) {
        this._scale = s;
        ubo0Changed = true;
        return this;
    }
    auto rotate(Angle!float x, Angle!float y, Angle!float z) {
        this.rotation = float3(x.radians, y.radians, z.radians);
        ubo0Changed = true;
        return this;
    }
    auto translate(float3 pos) {
        this._translation = pos;
        ubo0Changed = true;
        return;
    }
    auto lightPosition(float3 pos) {
        ubo0.lightPosition_worldspace = pos;
        ubo0Changed = true;
        return this;
    }
    auto camera(Camera3D camera) {
        ubo0.viewProj = camera.VP();
        ubo0.view     = camera.V();
        ubo0.invView  = camera.V().inversed();
        ubo0Changed = true;
        return this;
    }
    void beforeRenderPass(PerFrameResource res) {
        if(modelChanged) {
            uploadData(res.adhocCB);
        }
        if(ubo0Changed) {
            uploadUBO0(res.adhocCB);
        }
        if(ubo1Changed) {
            uploadUBO1(res.adhocCB);
        }
    }
    void insideRenderPass(PerFrameResource res) {
        if(vertices.length==0) return;

        auto b = res.adhocCB;

        b.bindPipeline(pipeline);
        b.bindDescriptorSets(
            VPipelineBindPoint.GRAPHICS,
            pipeline.layout,
            0,                  // first set
            [descriptorSet],    // descriptor sets
            null                // dynamicOffsets
        );
        if(shaderPrintf) {
            b.bindDescriptorSets(
                VPipelineBindPoint.GRAPHICS,
                pipeline.layout,
                1,
                [debugDS],
                null
            );
        }

        b.bindVertexBuffers(
            0,                      // first binding
            [vertexBuffer.handle],  // buffers
            [vertexBuffer.offset]); // offsets
        b.draw(cast(int)vertices.length, 1, 0, 0);

        if(shaderPrintf) {
            log("\nShader debug output:");
            log("===========================");
            log("%s", shaderPrintf.getDebugString());
            log("\n===========================\n");
        }
    }
private:
    void initialise() {
        this.stagingUbo0Buffer = context.buffer(BufID.STAGING).alloc(UBO0.sizeof);
        this.stagingUbo1Buffer = context.buffer(BufID.STAGING).alloc(UBO1.sizeof);
        this.ubo0Buffer        = context.buffer(BufID.UNIFORM).alloc(UBO0.sizeof);
        this.ubo1Buffer        = context.buffer(BufID.UNIFORM).alloc(UBO1.sizeof);

        //shaderPrintf = new ShaderPrintf(context);

        createSampler();
        createDescriptors();
        createPipeline();
    }
    void createSampler() {
        sampler = context.device.createSampler(samplerCreateInfo());
    }
    void createDescriptors() {
        /**
         * Bindings:
         *    0     vert uniform buffer .. UBO0
         *    1     frag uniform buffer .. UBO1
         *    2     sampler
         */
        this.descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VShaderStage.VERTEX)
                .uniformBuffer(VShaderStage.FRAGMENT)
                .combinedImageSampler(VShaderStage.FRAGMENT)
                .sets(1);

        if(shaderPrintf) {
            shaderPrintf.createLayout(descriptors, VShaderStage.VERTEX | VShaderStage.FRAGMENT);
        }

        descriptors.build();

        auto img = context.images().get("dds/brick.dds");

        this.descriptorSet = descriptors
           .createSetFromLayout(0)
               .add(ubo0Buffer.handle, ubo0Buffer.offset, UBO0.sizeof)
               .add(ubo1Buffer.handle, ubo1Buffer.offset, UBO1.sizeof)
               .add(sampler,
                    img.image.view(img.format, VImageViewType._2D),
                    VImageLayout.SHADER_READ_ONLY_OPTIMAL)
               .write();

        if(shaderPrintf) {
            debugDS = shaderPrintf.createDescriptorSet(descriptors, 1);
        }
    }
    void createPipeline() {
        this.pipeline = new GraphicsPipeline(context)
            .withVertexInputState!Vertex(VPrimitiveTopology.TRIANGLE_LIST)
            .withDSLayouts(descriptors.layouts)
            .withVertexShader(context.vk.shaderCompiler.getModule("model3d/model3d_vert.spv"))
            .withFragmentShader(context.vk.shaderCompiler.getModule("model3d/model3d_frag.spv"))
            .withRasterisationState( (info) {
                 info.cullMode = VkCullModeFlagBits.VK_CULL_MODE_BACK_BIT;
                 info.frontFace = VkFrontFace.VK_FRONT_FACE_COUNTER_CLOCKWISE;
            })
            .withDepthStencilState( (info) {
                info.depthTestEnable = true;
                info.depthWriteEnable = true;
                info.depthCompareOp = VkCompareOp.VK_COMPARE_OP_GREATER_OR_EQUAL;

                info.stencilTestEnable = false;
            })
            .build();
    }
    void uploadUBO0(VkCommandBuffer b) {

        auto scale = mat4.scale(_scale);
        auto rot   = mat4.rotate(rotation.x.radians, rotation.y.radians, rotation.z.radians);

        ubo0.model = rot * scale;

        stagingUbo0Buffer.mapAndWrite(&ubo0, 0, UBO0.sizeof);

        b.copyBuffer(stagingUbo0Buffer, ubo0Buffer);
        this.ubo0Changed = false;
    }
    void uploadUBO1(VkCommandBuffer b) {
        stagingUbo1Buffer.mapAndWrite(&ubo1, 0, UBO1.sizeof);

        b.copyBuffer(stagingUbo1Buffer, ubo1Buffer);
        this.ubo1Changed = false;
    }
    void uploadData(VkCommandBuffer b) {
        if(vertexBuffer) {
            stagingVertexBuffer.free();
            vertexBuffer.free();
        }

        vertices = null;
        vertices.reserve(data.faces.length*3);

        foreach(ref f; data.faces) {
            Vertex v0 = {
                vertexPosition_modelspace: data.vertex(f, 0),
                vertexColour: data.colour(f, 0)
            };
            Vertex v1 = {
                vertexPosition_modelspace: data.vertex(f, 1),
                vertexColour: data.colour(f, 1)
            };
            Vertex v2 = {
                vertexPosition_modelspace: data.vertex(f, 2),
                vertexColour: data.colour(f, 2)
            };

            if(f.hasNormals()) {
                v0.vertexNormal_modelspace = data.normal(f, 0);
                v1.vertexNormal_modelspace = data.normal(f, 1);
                v2.vertexNormal_modelspace = data.normal(f, 2);
            }
            if(f.hasUvs()) {
                v0.vertexUV = data.uv(f, 0);
                v1.vertexUV = data.uv(f, 1);
                v2.vertexUV = data.uv(f, 2);
            }

            vertices ~= v0;
            vertices ~= v1;
            vertices ~= v2;
        }

        auto size = Vertex.sizeof * vertices.length;

        this.log("#vertices = %s size = %s", vertices.length, size);

        vertexBuffer = context.buffer(BufID.VERTEX).alloc(size);
        stagingVertexBuffer = context.buffer(BufID.STAGING).alloc(size);

        stagingVertexBuffer.mapAndWrite(vertices.ptr, 0, size);

        b.copyBuffer(stagingVertexBuffer, vertexBuffer);

        this.modelChanged = false;
    }
}