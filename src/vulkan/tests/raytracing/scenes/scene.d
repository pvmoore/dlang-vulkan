module vulkan.tests.raytracing.scenes.scene;

import vulkan.tests.raytracing.test_ray_tracing;

abstract class Scene {
public:
    this(VulkanContext context, VkCommandPool traceCP, FrameResource[] frameResources) {
        this.context = context;
        this.device = context.device;
        this.vk = context.vk;
        this.traceCP = traceCP;
        this.frameResources = frameResources;
        this.windowSize = context.vk.windowSize();
    }

    final Descriptors getDescriptors() { return descriptors; }
    final RayTracingPipeline getPipeline() { return rtPipeline; }
    final Camera3D getCamera() { return camera3d; }
    final VkCommandBuffer getCommandBuffer(uint index) { return cmdBuffers[index]; }

    abstract string name();
    abstract string description();

    final void update(Frame frame, float3 lightPos) {
        subclassUpdate(frame, lightPos);
    }

    abstract void subclassUpdate(Frame frame, float3 lightPos);
    abstract void subclassInitialise();

    final void initialise() {
        subclassInitialise();
        recordCommandBuffers();
    }
    void destroy() {
        if(rtPipeline) rtPipeline.destroy();
        if(descriptors) descriptors.destroy();
        if(tlas) tlas.destroy();
        foreach(cmd; cmdBuffers) device.free(traceCP, cmd);
    }
protected:
    @Borrowed VulkanContext context;
    @Borrowed VkDevice device;
    @Borrowed Vulkan vk;
    @Borrowed VkCommandPool traceCP;
    @Borrowed FrameResource[] frameResources;

    static struct Sphere {
        float3 centre;
        float radius;
        float3 colour;
    }
    static struct Cube {
        float3 centre;
        float radius;
        float3 colour;
    }
    static struct AABB {
        float3 min;
        float3 max;
    }

    Mt19937 rng;
    Descriptors descriptors;
    RayTracingPipeline rtPipeline;
    TLAS tlas;
    Camera3D camera3d;
    VkCommandBuffer[] cmdBuffers;
    VkCommandPool buildCommandPool;

    uint2 windowSize;

    final void recordCommandBuffers() {

        foreach(i, fr; frameResources) {

            auto cmd = device.allocFrom(traceCP);
            cmdBuffers ~= cmd;

            cmd.begin();

            cmd.bindPipeline(rtPipeline);
            cmd.bindDescriptorSets(
                VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR,
                rtPipeline.layout,
                0,
                [descriptors.getSet(0, i.as!uint)],
                null
            );

            // Prepare the traceTarget image to be updated in the ray tracing shaders
            cmd.pipelineBarrier(
                VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                0,      // dependency flags
                null,   // memory barriers
                null,   // buffer barriers
                [
                    imageMemoryBarrier(
                        fr.traceTarget.handle,
                        VK_ACCESS_SHADER_READ_BIT,
                        VK_ACCESS_SHADER_WRITE_BIT,
                        VK_IMAGE_LAYOUT_UNDEFINED,
                        VK_IMAGE_LAYOUT_GENERAL
                    )
                ]
            );

            // Trace rays to traceTarget image
            cmd.traceRays(
                &rtPipeline.raygenStridedDeviceAddressRegion,
                &rtPipeline.missStridedDeviceAddressRegion,
                &rtPipeline.hitStridedDeviceAddressRegion,
                &rtPipeline.callableStridedDeviceAddressRegion,
                windowSize.x, windowSize.y, 1);

            // Prepare the traceTarget image to be used in the Quad fragment shader
            cmd.pipelineBarrier(
                VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                0,      // dependency flags
                null,   // memory barriers
                null,   // buffer barriers
                [
                    imageMemoryBarrier(
                        fr.traceTarget.handle,
                        VK_ACCESS_SHADER_WRITE_BIT,
                        VK_ACCESS_SHADER_READ_BIT,
                        VK_IMAGE_LAYOUT_GENERAL,
                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
                    )
                ]
            );

            cmd.end();
        }
    }
    Sphere createRandomSphere(float originScale, float radiusScale) {
        float3 origin = float3(uniform01(rng) * 2 - 1, uniform01(rng) * 2 - 1, uniform01(rng) * 2 - 1) * originScale;
        float radius = maxOf(1, uniform01(rng) * radiusScale);
        float3 colour = float3(uniform01(rng), uniform01(rng), uniform01(rng));

        colour = colour.max(float3(0.3));
        
        return Sphere(origin, radius, colour);
    }
    Cube createRandomCube(float centreScale, float radiusScale) {
        float3 centre = float3(uniform01(rng) * 2 - 1, uniform01(rng) * 2 - 1, uniform01(rng) * 2 - 1) * centreScale;
        float radius = maxOf(1, uniform01(rng) * radiusScale);
        float3 colour = float3(uniform01(rng), uniform01(rng), uniform01(rng));

        colour = colour.max(float3(0.3));
        
        return Cube(centre, radius, colour);
    }
    Tuple!(float3[], ushort[]) createCubeVerticesAndIndices() {
        /*
         Each cube consists of 6 sides, each side consists of 2 triangles
         
              +y  
               |  -z
               | /
               |/
        ------------ +x
              /|
             / |
            /  |  
          +z  -y

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

        enum r = 0.5;
        
        // 8 unique vertices
        float3[] vertices = [
            float3(-r,  r,  r), // 0
            float3( r,  r,  r), // 1
            float3( r, -r,  r), // 2
            float3(-r, -r,  r), // 3
            float3(-r,  r, -r), // 4
            float3( r,  r, -r), // 5
            float3( r, -r, -r), // 6
            float3(-r, -r, -r), // 7
        ];

        ushort[] indices;

        indices ~= [4,5,0, 5,1,0];  // up
        indices ~= [3,2,7, 2,6,7];  // bottom
        indices ~= [0,1,3, 1,2,3];  // front
        indices ~= [5,4,6, 4,7,6];  // back
        indices ~= [4,0,7, 0,3,7];  // left
        indices ~= [1,5,2, 5,6,2];  // right

        return tuple(vertices, indices);
    }
}
