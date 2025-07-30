module vulkan.tests.raytracing.scenes.path_tracing;

import vulkan.tests.raytracing.test_ray_tracing;

final class PathTracingScene : Scene {
public:
    this(VulkanContext context, VkCommandPool traceCP, FrameResource[] frameResources) {
        super(context, traceCP, frameResources);
    }

    override bool showCoordinates() { return false; }

    override string name() { return "Path tracing"; }
    override string description() { return "Cubes and spheres with path tracing"; }

    override void destroy() {
        super.destroy();
        if(ubo) ubo.destroy();
        if(cubeData) cubeData.destroy();
        if(sphereData) sphereData.destroy();
        if(cubeBLAS) cubeBLAS.destroy();
        if(sphereBLAS) sphereBLAS.destroy();
    }
    override VkCommandBuffer getCommandBuffer(uint index) { 

        auto fr = frameResources[index];
        auto cmd = cmdBuffers[index];

        cmd.beginOneTimeSubmit();

        cmd.resetQueryPool(queryPool, index*4, 4);        

        cmd.writeTimestamp(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, queryPool, index*4); 

        cmd.bindPipeline(rtPipeline);
        cmd.bindDescriptorSets(
            VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR,
            rtPipeline.layout,
            0,
            [descriptors.getSet(0, index.as!uint)],
            null
        );

        cmd.pushConstants(
            rtPipeline.layout,
            VK_SHADER_STAGE_RAYGEN_BIT_KHR,
            0,
            PushConstants.sizeof,
            &pushConstants
        );

        // Prepare the traceTarget image to be used in the ray tracing shaders
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

        cmd.writeTimestamp(VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR, queryPool, index*4+1); 

        // Trace rays to traceTarget image
        cmd.traceRays(
            &rtPipeline.raygenStridedDeviceAddressRegion,
            &rtPipeline.missStridedDeviceAddressRegion,
            &rtPipeline.hitStridedDeviceAddressRegion,
            &rtPipeline.callableStridedDeviceAddressRegion,
            windowSize.x, windowSize.y, 1);

        cmd.writeTimestamp(VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR, queryPool, index*4+2);     

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

        cmd.writeTimestamp(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT, queryPool, index*4+3); 

        cmd.end();

        return cmd; 
    }
protected:
    override void subclassInitialise() {
        rng.seed(unpredictableSeed());

        moveCamera();
        createObjects();
        createCubeBLAS();
        createSphereBLAS();
        createTLAS();
        createUBO();
        createCubeDataBuffer();
        createSphereDataBuffer();
        createAccumulatedColoursBuffer();
        createDescriptors();
        createPipeline();
        recordCommandBuffers();
    }
    override void subclassUpdate(Frame frame, float3 lightPos) {
        auto cmd = frame.resource.adhocCB;

        if(camera3d.wasModified()) {
            camera3d.resetModifiedState();
            updateCamera();
            pushConstants.imageIteration = 0;
        } 
         
        pushConstants.imageIteration++;
        
        ubo.upload(cmd);
        cubeData.upload(cmd);
        sphereData.upload(cmd);
    }
private:
    AccelerationStructure cubeBLAS;
    AccelerationStructure sphereBLAS;
    GPUData!UBO ubo;
    GPUData!Cube cubeData;
    GPUData!Sphere sphereData;
    SubBuffer accumulatedColours;

    Cube[] cubes;
    Sphere[] spheres;
    AABB[] aabbs;
    VkTransformMatrixKHR[] instanceTransforms;
    PushConstants pushConstants = PushConstants(0, 1);

    static struct UBO { 
        mat4 viewInverse;
        mat4 projInverse;
        float3 lightPos;
    }
    static struct PushConstants {
        uint frameNumber;
        uint imageIteration;
    }
    void moveCamera() {
        camera3d.movePositionAbsolute(float3(0, 80, -200));
        camera3d.rotateXRelative(20.degrees());
    }
    void updateCamera() {
        ubo.write((u) {
            u.viewInverse = camera3d.V().inversed();
            u.projInverse = camera3d.P().inversed();
        });
    }
    void createObjects() {
         
        // Floor wall
        cubes ~= Cube(float3(0, -1, 0), float3(100, 1, 100), float3(1, 0.7, 0.2));

        // Back wall
        cubes ~= Cube(float3(0, 50, 100), float3(100, 50, 1), float3(0.2, 0.2, 0.2));

        // Left wall
        cubes ~= Cube(float3(-100, 50, 0), float3(1, 50, 100), float3(1, 0.0, 0.0));

        // Right wall
        cubes ~= Cube(float3(100, 50, 0), float3(1, 50, 100), float3(0.0, 1, 0.0));

        // Ceiling
        cubes ~= Cube(float3(0, 100, 0), float3(100, 1, 100), float3(0.2, 0.2, 0.2));

        // White box 
        cubes ~= Cube(float3(0, 40, 30), float3(20, 40, 20), float3(1, 1, 1));

        // Blue box 
        cubes ~= Cube(float3(-10, 12, -20), float3(12), float3(0.2, 0.6, 1.0));

        // light
        cubes ~= Cube(float3(0, 99.5, 0), float3(10, 1, 10), float3(1, 1, 1));

        foreach(c; cubes) {
            VkTransformMatrixKHR transform = identityTransformMatrix();
            transform.translate(c.centre);
            transform.scale(c.radius);
            instanceTransforms ~= transform;       
        }

        // A single BLAS AABB at the origin
        aabbs ~= AABB(float3(-1, -1, -1), float3(1, 1, 1));

        // specular
        spheres ~= Sphere(float3(30,15,-10), 15, float3(1,1,1));

        // glass 
        spheres ~= Sphere(float3(-10, 30, -20), 7, float3(1,1,1));
        
        // diffuse yellow
        spheres ~= Sphere(float3(-40,20,10), 20, float3(1,1,0.5));

        foreach(s; spheres) {
            VkTransformMatrixKHR transform = identityTransformMatrix();
            transform.translate(s.centre);
            transform.scale(float3(s.radius));
            instanceTransforms ~= transform;
        }
    }
    void createCubeBLAS() {

        auto t = createCubeVerticesAndIndices();
        float3[] vertices = t[0];
        ushort[] indices = t[1];    
        VkTransformMatrixKHR transform = identityTransformMatrix();

        auto verticesSize = vertices.length * float3.sizeof;
        auto indicesSize = indices.length * ushort.sizeof;
        auto transformsSize = VkTransformMatrixKHR.sizeof;

        SubBuffer vertexBuffer = context.buffer(RT_VERTICES).alloc(verticesSize, 0);
        SubBuffer indexBuffer = context.buffer(RT_INDEXES).alloc(indicesSize, 0);
        SubBuffer transformBuffer = context.buffer(RT_TRANSFORMS).alloc(transformsSize, 0);
   
        auto vertexDeviceAddress = getDeviceAddress(context.device, vertexBuffer);
        auto indexDeviceAddress = getDeviceAddress(context.device, indexBuffer);
        auto transformDeviceAddress = getDeviceAddress(context.device, transformBuffer);

        context.transfer().from(vertices.ptr, 0).to(vertexBuffer).size(verticesSize);
        context.transfer().from(indices.ptr, 0).to(indexBuffer).size(indicesSize);
        context.transfer().from(&transform, 0).to(transformBuffer).size(transformsSize);

        VkAccelerationStructureGeometryTrianglesDataKHR triangles = {
            sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR,
            pNext: null,
            vertexFormat: VK_FORMAT_R32G32B32_SFLOAT,
            vertexStride: float3.sizeof,
            maxVertex: vertices.length.as!uint,
            indexType: VK_INDEX_TYPE_UINT16,
            vertexData: { deviceAddress: vertexDeviceAddress },
            indexData: { deviceAddress: indexDeviceAddress },
            transformData: { deviceAddress: transformDeviceAddress }
        };

        this.cubeBLAS = new BLAS(context, "blas_mixed_cube", VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR)
            .addTriangles(VK_GEOMETRY_OPAQUE_BIT_KHR, triangles, indices.length.as!uint / 3)
            .create();

        auto cmd = device.allocFrom(vk.getGraphicsCP());
        cmd.beginOneTimeSubmit();
        cubeBLAS.update(cmd);
        cmd.end();
        submitAndWait(device, vk.getGraphicsQueue(), cmd);
        device.free(vk.getGraphicsCP(), cmd);
    }
    void createSphereBLAS() {
        // We only actually have 1 AABB
        assert(aabbs.length == 1);

        auto aabbsSize = aabbs.length*AABB.sizeof;
        SubBuffer aabbsBuffer = context.buffer(RT_AABBS).alloc(aabbsSize);
        auto aabbsDeviceAddress = getDeviceAddress(context.device, aabbsBuffer);

        context.transfer().from(aabbs.ptr, 0)
                          .to(aabbsBuffer)
                          .size(aabbsSize);

        this.sphereBLAS = new BLAS(context, "blas_mixed_sphere_aabbs", VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR)
            .addAABBs(VK_GEOMETRY_OPAQUE_BIT_KHR, aabbsDeviceAddress, AABB.sizeof, aabbs.length.as!int)
            .create();

        auto cmd = device.allocFrom(vk.getGraphicsCP());
        cmd.beginOneTimeSubmit();
        sphereBLAS.update(cmd);
        cmd.end();
        submitAndWait(device, vk.getGraphicsQueue(), cmd);
        device.free(vk.getGraphicsCP(), cmd);
    }
    void createTLAS() {

        uint cubeIndex;
        uint sphereIndex;

        VkAccelerationStructureInstanceKHR[] instances;

        foreach(i, transform; instanceTransforms) {

            uint index;
            uint sbtOffset;
            ulong blasDeviceAddress;

            if(i < cubes.length) {
                // Cube
                index = cubeIndex++;
                sbtOffset = 0;
                blasDeviceAddress = cubeBLAS.deviceAddress;
            } else {
                // Sphere
                index = sphereIndex++;
                sbtOffset = 1;
                blasDeviceAddress = sphereBLAS.deviceAddress;
            }
            
            VkAccelerationStructureInstanceKHR instance = {
                transform: transform,
                accelerationStructureReference: blasDeviceAddress
            };
            instance.setMask(0xFF);

            // Note: This is how we select the hit group to use for cube (hit group 0) vs sphere (hit group 1)
            //       We refer to this elsewhere as Ioffset 
            instance.setInstanceShaderBindingTableRecordOffset(sbtOffset);

            // Set the index into either cubeData or sphereData
            instance.setInstanceCustomIndex(index);

            instance.setFlags(
                VK_GEOMETRY_INSTANCE_FORCE_OPAQUE_BIT_KHR | 
                //VK_GEOMETRY_INSTANCE_TRIANGLE_FLIP_FACING_BIT_KHR | 
                //VK_GEOMETRY_INSTANCE_TRIANGLE_FRONT_COUNTERCLOCKWISE_BIT_KHR |
                VK_GEOMETRY_INSTANCE_TRIANGLE_FACING_CULL_DISABLE_BIT_KHR);
            instances ~= instance;
        }

        auto instancesSize = VkAccelerationStructureInstanceKHR.sizeof * instances.length;
        SubBuffer instancesBuffer = context.buffer(RT_INSTANCES).alloc(instancesSize);
        auto instancesDeviceAddress = getDeviceAddress(device, instancesBuffer);

        context.transfer().from(instances.ptr, 0)
                          .to(instancesBuffer)
                          .size(instancesSize);

        this.tlas = new TLAS(context, "tlas_mixed_cubes", VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR)
            .addInstances(VK_GEOMETRY_OPAQUE_BIT_KHR, instancesDeviceAddress, instances.length.as!uint)
            .create();

        auto cmd = device.allocFrom(vk.getGraphicsCP());
        cmd.beginOneTimeSubmit();
        tlas.update(cmd);
        cmd.end();
        submitAndWait(device, vk.getGraphicsQueue(), cmd);
        device.free(vk.getGraphicsCP(), cmd);
    }
    void createUBO() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true)
            .withUploadStrategy(GPUDataUploadStrategy.ALL)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                VkAccessFlagBits.VK_ACCESS_UNIFORM_READ_BIT,
                VkAccessFlagBits.VK_ACCESS_UNIFORM_READ_BIT,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR
            ))
            .initialise();  

        updateCamera();

        ubo.write((u) {
            u.lightPos = float3(0, 100, -80);
        });
    }
    void createCubeDataBuffer() {
        cubeData = new GPUData!Cube(context, RT_STORAGE, true, cubes.length.as!uint)
            .withUploadStrategy(GPUDataUploadStrategy.ALL)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR
            ))
            .initialise();

        cubeData.write(cubes);
    }
    void createSphereDataBuffer() {
        sphereData = new GPUData!Sphere(context, RT_STORAGE, true, maxOf(1, spheres.length.as!uint))
            .withUploadStrategy(GPUDataUploadStrategy.ALL)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR
            ))
            .initialise();

        if(spheres.length > 0) sphereData.write(spheres);
    }
    void createAccumulatedColoursBuffer() {
        accumulatedColours = context.buffer(RT_ACCUM_COLOURS)
                                    .alloc(windowSize.x * windowSize.y * float3.sizeof, 64);
    }
    void createDescriptors() {
        // 0 -> acceleration structure
        // 1 -> target image
        // 2 -> uniform buffer (ubo)
        // 3 -> storage buffer (cubeData)
        // 4 -> storage buffer (sphereData)
        // 5 -> storage buffer (accumulatedColours)
        this.descriptors = new Descriptors(context)
            .createLayout()
                .accelerationStructure(VK_SHADER_STAGE_RAYGEN_BIT_KHR | VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR)
                .storageImage(VK_SHADER_STAGE_RAYGEN_BIT_KHR)
                .uniformBuffer(VK_SHADER_STAGE_RAYGEN_BIT_KHR | VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR | VK_SHADER_STAGE_INTERSECTION_BIT_KHR)
                .storageBuffer(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR)
                .storageBuffer(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR | VK_SHADER_STAGE_INTERSECTION_BIT_KHR)
                .storageBuffer(VK_SHADER_STAGE_RAYGEN_BIT_KHR)
                .sets(vk.swapchain.numImages());
        descriptors.build();

        foreach(res; frameResources) {
            auto view = res.traceTarget.view;

            descriptors.createSetFromLayout(0)
                    .add(tlas.handle)
                    .add(view, VK_IMAGE_LAYOUT_GENERAL)
                    .add(ubo)
                    .add(cubeData)
                    .add(sphereData)
                    .add(accumulatedColours)
                    .write();
        }
    }
    void createPipeline() {
        this.rtPipeline = new RayTracingPipeline(context)
            .withDSLayouts(descriptors.getAllLayouts())
            // A single raygen group
            .withRaygenGroup(0)   
            // 2 miss groups
            .withMissGroup(1)   
            // Cube hit group
            .withHitGroup(VK_RAY_TRACING_SHADER_GROUP_TYPE_TRIANGLES_HIT_GROUP_KHR,
                2,                      // closest
                VK_SHADER_UNUSED_KHR,   // any
                VK_SHADER_UNUSED_KHR    // intersection
            )
            // Sphere hit group
            .withHitGroup(VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_KHR,
                3,                      // closest
                VK_SHADER_UNUSED_KHR,   // any
                4                       // intersection
            );

        auto slangModule = context.shaders.getModule("vulkan/test/raytracing/pathtracing/rt_pathtracing.slang");

        rtPipeline.withShader(VK_SHADER_STAGE_RAYGEN_BIT_KHR, slangModule, null, "raygen")
                  .withShader(VK_SHADER_STAGE_MISS_BIT_KHR, slangModule, null, "miss")
                  .withShader(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR, slangModule, null, "closesthitCube")
                  .withShader(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR, slangModule, null, "closesthitSphere")
                  .withShader(VK_SHADER_STAGE_INTERSECTION_BIT_KHR, slangModule, null, "intersection")
                  .withMaxRecursionDepth(10)
                  .withPushConstantRange!PushConstants(VK_SHADER_STAGE_RAYGEN_BIT_KHR);
       
        rtPipeline.build();
    }
}
