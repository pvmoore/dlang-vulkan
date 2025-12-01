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

    final double getFrameTimeMs() { return frameTimeMs; }
    final double getTraceTimeMs() { return traceTimeMs; }
    bool showCoordinates() { return true; }

    final Descriptors getDescriptors() { return descriptors; }
    final RayTracingPipeline getPipeline() { return rtPipeline; }
    final Camera3D getCamera() { return camera3d; }
    VkCommandBuffer getCommandBuffer(uint index) { return cmdBuffers[index]; }

    abstract string name();
    abstract string description();

    final void update(Frame frame, float3 lightPos) {

        if(frame.number.value > vk.swapchain.numImages) {
            ulong[4] queryData;
            if(VK_SUCCESS==device.getQueryPoolResults(queryPool, frame.imageIndex*4, 4, 32, queryData.ptr, 8, VK_QUERY_RESULT_64_BIT)) {
                ulong frameTime = cast(ulong)((queryData[3]-queryData[0])*vk.limits.timestampPeriod);
                ulong traceTime = cast(ulong)((queryData[2]-queryData[1])*vk.limits.timestampPeriod);
                frameTimeMs = frameTime.as!double / 1000000.0;
                traceTimeMs = traceTime.as!double / 1000000.0;
            }
        }

        subclassUpdate(frame, lightPos);
    }

    void imguiFrame(Frame frame) {}

    abstract void subclassUpdate(Frame frame, float3 lightPos);
    abstract void subclassInitialise();

    final void initialise() {
        createCamera();
        createQueryPool();

        subclassInitialise();
    }
    void destroy() {
        if(queryPool) device.destroyQueryPool(queryPool);
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
        float3 radius;
        float3 colour;
    }
    static struct AABB {
        float3 min;
        float3 max;
    }

    Descriptors descriptors;
    RayTracingPipeline rtPipeline;
    AccelerationStructure tlas;
    VkCommandBuffer[] cmdBuffers;
    VkQueryPool queryPool;

    Mt19937 rng;
    Camera3D camera3d;
    uint2 windowSize;
    double frameTimeMs = 0;
    double traceTimeMs = 0;

    final void createQueryPool() {
        this.queryPool = device.createQueryPool(
            VK_QUERY_TYPE_TIMESTAMP,    // queryType
            vk.swapchain.numImages*4    // num queries
        );
    }
    final void createCamera() {
        this.camera3d = Camera3D.forVulkan(vk.windowSize(), float3(0,0,-100), float3(0,0,0));
        this.camera3d.fovNearFar(FOV.degrees, NEAR, FAR);
        this.camera3d.rotateZRelative(180.degrees());
    }
    final void recordCommandBuffers() {

        foreach(index, fr; frameResources) {

            auto cmd = device.allocFrom(traceCP);
            cmdBuffers ~= cmd;

            cmd.begin();

            cmd.resetQueryPool(queryPool, index.as!uint*4, 4);                

            cmd.writeTimestamp(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, queryPool, index.as!uint*4); 

            cmd.bindPipeline(rtPipeline);
            cmd.bindDescriptorSets(
                VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR,
                rtPipeline.layout,
                0,
                [descriptors.getSet(0, index.as!uint)],
                null
            );

            // Prepare the traceTarget image to be updated in the ray tracing shaders
            cmd.pipelineBarrier(
                VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT,
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

            cmd.writeTimestamp(VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR, queryPool, index.as!uint*4+1);

            // Trace rays to traceTarget image
            cmd.traceRays(
                &rtPipeline.raygenStridedDeviceAddressRegion,
                &rtPipeline.missStridedDeviceAddressRegion,
                &rtPipeline.hitStridedDeviceAddressRegion,
                &rtPipeline.callableStridedDeviceAddressRegion,
                windowSize.x, windowSize.y, 1);

            cmd.writeTimestamp(VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR, queryPool, index.as!uint*4+2);    

            // Prepare the traceTarget image to be used in the Quad fragment shader
            cmd.pipelineBarrier(
                VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT,
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

            cmd.writeTimestamp(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT, queryPool, index.as!uint*4+3); 

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
        float3 radius = float3(maxOf(1, uniform01(rng) * radiusScale));
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

        enum r = 1;
        
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
