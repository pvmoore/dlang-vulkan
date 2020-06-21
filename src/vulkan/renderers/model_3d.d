module vulkan.renderers.model_3d;

import vulkan.all;

final class Model3D(uint MAX_VERTICES = 20000) {
private:
    VulkanContext context;
    ModelData data;
    VkSampler sampler;
    Descriptors descriptors;
    GraphicsPipeline pipeline;

    GPUData!UBO0 ubo0;
    GPUData!UBO1 ubo1;
    GPUData!(Vertex, MAX_VERTICES) verts;

    uint numVertices;
    float3 _scale, _translation, rotation;

    static struct Vertex { static assert(Vertex.sizeof == 12*4);
        vec3 vertexPosition_modelspace;
        vec3 vertexNormal_modelspace;
        vec2 vertexUV;
        vec4 vertexColour;
    }
    static struct UBO0 { static assert(UBO0.sizeof == 64*4 + 16 && UBO0.sizeof%16==0);
        mat4 viewProj;
        mat4 view;
        mat4 invView;
        mat4 model;
        vec3 lightPosition_worldspace;
        float _pad1;
    }
    static struct UBO1 { static assert(UBO1.sizeof==16 && UBO1.sizeof%16==0);
        float shineDamping;
        float reflectivity;
        float _pad1;
        float _pad2;
    }
public:
    this(VulkanContext context) {
        this.context = context;
        this._scale = float3(1);
        this.rotation = float3(0);
        this._translation = float3(0);

        initialise();
    }
    void destroy() {
        if(ubo0) ubo0.destroy();
        if(ubo1) ubo1.destroy();
        if(verts) verts.destroy();
        if(sampler) context.device.destroySampler(sampler);
        if(descriptors) descriptors.destroy();
        if(pipeline) pipeline.destroy();
    }
    auto modelData(ModelData data) {
        this.data = data;
        verts.setStaleWrite();
        return this;
    }
    auto scale(float3 s) {
        this._scale = s;
        ubo0.setStaleWrite();
        return this;
    }
    auto rotate(Angle!float x, Angle!float y, Angle!float z) {
        this.rotation = float3(x.radians, y.radians, z.radians);
        ubo0.setStaleWrite();
        return this;
    }
    auto translate(float3 pos) {
        this._translation = pos;
        ubo0.setStaleWrite();
        return;
    }
    auto lightPosition(float3 pos) {
        ubo0.write((u) {
            u.lightPosition_worldspace = pos;
        });
        return this;
    }
    auto camera(Camera3D camera) {
        ubo0.write((u) {
            u.viewProj = camera.VP();
            u.view     = camera.V();
            u.invView  = camera.V().inversed();
        });
        return this;
    }
    void beforeRenderPass(PerFrameResource res) {
        uploadData(res.adhocCB);
        uploadUBO0(res.adhocCB);
        uploadUBO1(res.adhocCB);
    }
    void insideRenderPass(PerFrameResource res) {
        if(numVertices==0) return;

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
            0,                          // first binding
            [verts.upBuffer.handle],    // buffers
            [verts.upBuffer.offset]);   // offsets
        b.draw(numVertices, 1, 0, 0);
    }
private:

    void initialise() {
        this.ubo0  = new GPUData!UBO0(context, BufID.UNIFORM, true, false);
        this.ubo1  = new GPUData!UBO1(context, BufID.UNIFORM, true, false);
        this.verts = new GPUData!(Vertex, MAX_VERTICES)(context, BufID.VERTEX, true, false);

        ubo0.write((u) {
            u.model = mat4.identity();
        });

        ubo1.write((u) {
            u.shineDamping = 10f;
            u.reflectivity = 1f;
        });

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

        descriptors.build();

        auto img = context.images().get("dds/brick.dds");

        descriptors.createSetFromLayout(0)
                   .add(ubo0, true)
                   .add(ubo1, true)
                   .add(sampler, img.image.view(img.format, VImageViewType._2D), VImageLayout.SHADER_READ_ONLY_OPTIMAL)
                   .write();
    }
    void createPipeline() {
        this.pipeline = new GraphicsPipeline(context, true)
            .withVertexInputState!Vertex(VPrimitiveTopology.TRIANGLE_LIST)
            .withDSLayouts(descriptors.getAllLayouts())
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
        if(ubo0.isStaleWrite()) {
            auto scale = mat4.scale(_scale);
            auto rot   = mat4.rotate(rotation.x.radians, rotation.y.radians, rotation.z.radians);

            ubo0.write((u) {
                u.model = rot * scale;
            });

            ubo0.upload(b);
        }
    }
    void uploadUBO1(VkCommandBuffer b) {
        ubo1.upload(b);
    }
    void uploadData(VkCommandBuffer b) {
        if(!verts.isStaleWrite()) return;

        Vertex[] vertices;
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

        this.numVertices = vertices.length.as!uint;

        if(numVertices > MAX_VERTICES) {
            throw new Error("Model has more than %s vertices".format(MAX_VERTICES));
        }

        auto size = Vertex.sizeof * vertices.length;
        this.log("#vertices = %s size = %s", vertices.length, size);

        verts.write(vertices.ptr, numVertices);
        verts.upload(b);
    }
}