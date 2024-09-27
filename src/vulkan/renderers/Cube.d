module vulkan.renderers.Cube;

import vulkan.all;

/**
 * A box outline using a line list.
 *
 * new Cube(context, Kind.SOLID, 1.0f)
 *  .camera(...)
 *  .colour(...)
 *  .translate(...);
 */
final class Cube {
public:
    enum Kind { WIREFRAME, SOLID }

    this(VulkanContext context, Kind kind, float lineWidth = 1.0f) {
        this.context = context;
        this.kind = kind;
        this.lineWidth = lineWidth;
        initialise();
    }
    void destroy() {
        if(pipeline) pipeline.destroy();
        if(descriptors) descriptors.destroy();
        if(solidVertices) solidVertices.destroy();
        if(wireframeVertices) wireframeVertices.destroy();
        if(ubo) ubo.destroy();
        if(sampler) context.device.destroySampler(sampler);
    }
    auto camera(Camera3D cam) {
        ubo.write((u) { 
            u.viewProj = cam.VP();
            u.view     = cam.V();
            u.invView  = u.view.inversed(); 
        });
        return this;
    }
    auto colour(RGBA c) {
        ubo.write((u) { u.colour = c; });
        return this;
    }
    auto translate(float3 t) {
        modelTransform.translation = t;
        modelTransform.modified = true;
        return this;
    }
    auto rotate(Angle!float x, Angle!float y, Angle!float z) {
        modelTransform.rotation[0] = x;
        modelTransform.rotation[1] = y;
        modelTransform.rotation[2] = z;
        modelTransform.modified = true;
        return this;
    }
    auto scale(float3 t) {
        modelTransform.scale = t;
        modelTransform.modified = true;
        return this;
    }
    auto lightPosition(float3 pos) {
        ubo.write((u) {
            u.lightPositionWorldspace = pos;
        });
        return this;
    }
    //──────────────────────────────────────────────────────────────────────────────────────────────────
    void beforeRenderPass(Frame frame) {
        auto cmd = frame.resource.adhocCB;

        if(modelTransform.modified) {
            modelTransform.modified = false;

            auto sc  = mat4.scale(modelTransform.scale);
            auto rot = mat4.rotate(modelTransform.rotation[0], modelTransform.rotation[1], modelTransform.rotation[2]);
            auto tr  = mat4.translate(modelTransform.translation);

            ubo.write((u) {
                u.model = tr * rot * sc;
            });
        }

        ubo.upload(cmd);

        if(isWireframe()) {
            wireframeVertices.upload(cmd);
        } else {
            solidVertices.upload(cmd);
        }
    }
    void insideRenderPass(Frame frame) {
        auto res = frame.resource;
        auto cmd = res.adhocCB;

        cmd.bindPipeline(pipeline);
        cmd.bindDescriptorSets(
            VK_PIPELINE_BIND_POINT_GRAPHICS,
            pipeline.layout,
            0,                          // first set
            [descriptors.getSet(0,0)],
            null                        // dynamic offsets
        );

        uint numVertices;

        if(isWireframe()) {
            numVertices = WIREFRAME_VERTICES;
            cmd.bindVertexBuffers(
                0,                                              // first binding
                [wireframeVertices.getDeviceBuffer().handle],   // buffers
                [wireframeVertices.getDeviceBuffer().offset]);  // offsets
        } else {
            numVertices = SOLID_VERTICES;
            cmd.bindVertexBuffers(
                0,                                              // first binding
                [solidVertices.getDeviceBuffer().handle],       // buffers
                [solidVertices.getDeviceBuffer().offset]);      // offsets
        }

        cmd.draw(numVertices, 1, 0, 0);
    }
private:
    enum WIREFRAME_VERTICES = 24;
    enum SOLID_VERTICES     = 36;

    @Borrowed VulkanContext context;
    GraphicsPipeline pipeline;
    Descriptors descriptors;
    const float lineWidth;
    Kind kind;
    GPUData!UBO ubo;
    GPUData!VertexSOLID solidVertices;
    GPUData!VertexWF wireframeVertices;
    VkSampler sampler;

    struct Transformation { 
        float3 translation = float3(0,0,0);
        Angle!(float)[3] rotation = [0.radians, 0.radians, 0.radians ];
        float3 scale = float3(1,1,1);
        bool modified = true;
    } 
    Transformation modelTransform;

    static struct VertexSOLID {
        float3 pos;
        float3 normal;
        float2 uv;
    }
    static struct VertexWF {
        float3 pos;
    }

    static struct UBO { static assert(UBO.sizeof == 64 + 64 + 64 + 64 + 16 + 16);
        mat4 viewProj;
        mat4 view;
        mat4 invView;
        mat4 model;
        float3 lightPositionWorldspace;
        float _pad;
        RGBA colour;
    }

    bool isWireframe() { return kind == Kind.WIREFRAME; }

    void initialise() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true).initialise();
        
        colour(RGBA(1,1,1,1));
        lightPosition(float3(200f,1000f,800f));

        createSampler();
        createVertices();
        createDescriptors();
        createPipeline();
    }
    void createSampler() {
        this.sampler = context.device.createSampler(samplerCreateInfo());
    }
    void createVertices() {
        if(isWireframe()) {
            createWireframeVertices();
        } else {
            createSolidVertices();
        }
    }
    void createWireframeVertices() {
        this.wireframeVertices = new GPUData!VertexWF(context, BufID.VERTEX, true, WIREFRAME_VERTICES).initialise();

        /*
         top (+y)
         0---->1 ┌──> x
         ^     | |
         |       ↓
         |     | z
         |     |
         |     v
         3<----2

         bottom (-y)
         4---->5 ┌──> x
         ^     | |
         |     | ↓
         |     | z
         |     |
         |     v
         7<----6

         left (-x)
         0     3 ┌──> z
         ^     | |
         |     | ↓
         |     | -y
         |     |
         |     v
         4     7

         right (+x)
         2     1 ┌──> -z
         ^     | |
         |     | ↓
         |     | -y
         |     |
         |     v
         6     5
        */

        // 8 unique vertices
        VertexWF[] v = [
            VertexWF(float3(-.5,  .5, -.5)), // 0
            VertexWF(float3( .5,  .5, -.5)), // 1
            VertexWF(float3( .5,  .5,  .5)), // 2
            VertexWF(float3(-.5,  .5,  .5)), // 3

            VertexWF(float3(-.5, -.5, -.5)), // 4
            VertexWF(float3( .5, -.5, -.5)), // 5
            VertexWF(float3( .5, -.5,  .5)), // 6
            VertexWF(float3(-.5, -.5,  .5)), // 7
        ];

        // 24 vertices total 
        VertexWF[] verts = [
            v[0], v[1], // top     
            v[1], v[2],
            v[2], v[3],
            v[3], v[0],

            v[4], v[5], // bottom
            v[5], v[6],
            v[6], v[7], 
            v[7], v[4],

            v[4], v[0], // left
            v[7], v[3],

            v[6], v[2], // right
            v[5], v[1],
        ];

        wireframeVertices.write(verts, 0);
    }
    void createSolidVertices() {
        this.solidVertices = new GPUData!VertexSOLID(context, BufID.VERTEX, true, SOLID_VERTICES).initialise();
        /*
              +y  
               |  -z
               | /
               |/
        ------------ +x
              /|
             / |
            /  |  
          +z  -y
        out of screen

            4--------5   
           /┊       /|
          / ┊      / |
         /  ┊     /  |
        0--------1   |
        |   ┊    |   |
        |   7┄┄┄┄|┄┄┄6
        |  /     |  /
        | /      | /
        |/       |/
        3--------2

        top 
        4-----5
        |    /|
        |   / |
        |  /  |
        | /   |
        |/    |
        0-----1

        bottom
        3-----2
        |    /|
        |   / |
        |  /  |
        | /   |
        |/    |
        7-----6

        front
        0-----1
        |    /|
        |   / |
        |  /  |
        | /   |
        |/    |
        3-----2

        back
        5-----4
        |    /|
        |   / |
        |  /  |
        | /   |
        |/    |
        6-----7

        left
        4-----0
        |    /|
        |   / |
        |  /  |
        | /   |
        |/    |
        7-----3

        right
        1-----5
        |    /|
        |   / |
        |  /  |
        | /   |
        |/    |
        2-----6

        */
        
        // 8 unique vertices
        VertexSOLID[] v = [
            VertexSOLID(float3(-.5,  .5,  .5)), // 0
            VertexSOLID(float3( .5,  .5,  .5)), // 1
            VertexSOLID(float3( .5, -.5,  .5)), // 2
            VertexSOLID(float3(-.5, -.5,  .5)), // 3
            VertexSOLID(float3(-.5,  .5, -.5)), // 4
            VertexSOLID(float3( .5,  .5, -.5)), // 5
            VertexSOLID(float3( .5, -.5, -.5)), // 6
            VertexSOLID(float3(-.5, -.5, -.5)), // 7
        ];

        /*
            UV coordinates:
            0-----1 Triangle A = 0,1,2
            |    /| Triangle B = 1,2,3
            |   / |
            |  /  |
            | /   |
            |/    |
            3-----2
        */

        float4[string] UVS = [
            "top" : float4(0.75, 0.00, 1.00, 0.25), 
            "bottom" : float4(0.25, 0.00, 0.50, 0.25), 
            "front" : float4(0.00, 0.25, 0.25, 0.50),
            "back" : float4(0.50, 0.00, 0.75, 0.25), 
            "left" : float4(0.25, 0.25, 0.50, 0.50), 
            "right" : float4(0.00, 0.00, 0.25, 0.25)
        ];

        VertexSOLID[] side(string side, int i0, int i1, int i2, int i3, float3 normal) {
            VertexSOLID v0 = v[i0];
            VertexSOLID v1 = v[i1];
            VertexSOLID v2 = v[i2];
            VertexSOLID v3 = v[i3];

            v0.normal = normal;
            v1.normal = normal;
            v2.normal = normal;
            v3.normal = normal;

            float4 uvs = UVS[side];

            v0.uv = uvs.xy;
            v1.uv = float2(uvs.z, uvs.y);
            v2.uv = uvs.zw;
            v3.uv = float2(uvs.x, uvs.w);

            return [v0, v1, v3,   v1, v2, v3];
        }

        float3 up    = float3(0,1,0);
        float3 down  = float3(0,-1,0);
        float3 left  = float3(-1,0,0);
        float3 right = float3(1,0,0);
        float3 in_   = float3(0,0,-1);
        float3 out_  = float3(0,0,1);

        // 36 vertices total 
        VertexSOLID[] verts = side("top", 4,5,1,0, up) ~
                              side("bottom", 3,2,6,7, down) ~
                              side("front", 0,1,2,3, out_) ~
                              side("back", 5,4,7,6, in_) ~
                              side("left", 4,0,3,7, left) ~
                              side("right", 1,5,6,2, right);

        solidVertices.write(verts, 0);
    }
    /**
     * Bindings:
     *    0 : uniform buffer
     *    1 : sampler
     */
    void createDescriptors() {

        auto img = context.images().get("123456.bmp");

        this.descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT)
                .combinedImageSampler(VK_SHADER_STAGE_FRAGMENT_BIT)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
            .add(ubo)
            .add(sampler, img.image.view(img.format, VK_IMAGE_VIEW_TYPE_2D), VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)
            .write();
    }
    void createPipeline() {
        // Note that we flip the viewport Y here so that +Y is up and -Y is down
        this.pipeline = new GraphicsPipeline(context, true)
            .withDSLayouts(descriptors.getAllLayouts())
            .withStdColorBlendState();

        if(isWireframe()) {
            pipeline.withVertexInputState!VertexWF(VK_PRIMITIVE_TOPOLOGY_LINE_LIST)
                    .withVertexShader(context.vk.shaderCompiler.getModule("cube/Cube_wf_vert.spv"))
                    .withFragmentShader(context.vk.shaderCompiler.getModule("cube/Cube_wf_frag.spv"))
                    .withRasterisationState((VkPipelineRasterizationStateCreateInfo* rs) {
                        rs.lineWidth = lineWidth;
                    });
        } else {
            pipeline.withVertexInputState!VertexSOLID(VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST)
                    .withVertexShader(context.vk.shaderCompiler.getModule("cube/Cube_vert.spv"))
                    .withFragmentShader(context.vk.shaderCompiler.getModule("cube/Cube_frag.spv"))
                    .withRasterisationState((VkPipelineRasterizationStateCreateInfo* rs) {
                        rs.cullMode = VkCullModeFlagBits.VK_CULL_MODE_BACK_BIT;
                        rs.frontFace = VkFrontFace.VK_FRONT_FACE_CLOCKWISE;
                    });
        }   

        pipeline.build();
    }
}
