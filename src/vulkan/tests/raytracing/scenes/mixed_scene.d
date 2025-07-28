module vulkan.tests.raytracing.scenes.mixed_scene;

import vulkan.tests.raytracing.test_ray_tracing;

final class MixedScene : Scene {
public:
    this(VulkanContext context, VkCommandPool traceCP, FrameResource[] frameResources, int numObjects) {
        super(context, traceCP, frameResources);
        this.numObjects = numObjects;
        throwIf(numObjects & 1, "Must be a multiple of 2");
    }

    override string name() { return "Cubes and Spheres"; }
    override string description() { return "%s random cubes and spheres".format(numObjects); }

    override void destroy() {
        super.destroy();
        if(ubo) ubo.destroy();
        if(cubeData) cubeData.destroy();
        if(sphereData) sphereData.destroy();
        if(cubeBLAS) cubeBLAS.destroy();
        if(sphereBLAS) sphereBLAS.destroy();
    }
protected:
    override void subclassInitialise() {
        rng.seed(unpredictableSeed());

        moveCamera();
        createCubes();
        createSpheres();
        createCubeBLAS();
        createSphereBLAS();
        createTLAS();
        createUBO();
        createCubeDataBuffer();
        createSphereDataBuffer();
        createDescriptors();
        createPipeline();
        recordCommandBuffers();
    }
    override void subclassUpdate(Frame frame, float3 lightPos) {
        auto cmd = frame.resource.adhocCB;

        if(camera3d.wasModified()) {
            camera3d.resetModifiedState();
            updateCamera();
        }

        ubo.write((u) {
            u.lightPos = lightPos;
        });

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

    uint numObjects;
    Cube[] cubes;
    Sphere[] spheres;
    AABB[] aabbs;
    VkTransformMatrixKHR[] instanceTransforms;

    static struct UBO { 
        mat4 viewInverse;
        mat4 projInverse;
        float3 lightPos;
    }
    void moveCamera() {
        camera3d.movePositionAbsolute(float3(0,0,-150));
    }
    void updateCamera() {
        ubo.write((u) {
            u.viewInverse = camera3d.V().inversed();
            u.projInverse = camera3d.P().inversed();
        });
    }
    void createCubes() {
        foreach(i; 0..numObjects/2) {
            float3 origin = float3(uniform01(rng) * 2 - 1, uniform01(rng) * 2 - 1, uniform01(rng) * 2 - 1) * 60;
            float radius  = maxOf(3, uniform01(rng) * 20);
            float3 colour = float3(uniform01(rng), uniform01(rng), uniform01(rng)).max(float3(0.3));

            cubes ~= Cube(origin, radius, colour);

            float s = radius;

            VkTransformMatrixKHR transform = identityTransformMatrix();
            transform.translate(origin);
            transform.scale(float3(s, s, s));
            instanceTransforms ~= transform;       
        }
    }
    void createSpheres() {

        // A single BLAS AABB at the origin
        aabbs ~= AABB(float3(-1, -1, -1), float3(1, 1, 1));

        // Multiple TLAS instances with different transforms
        foreach(i; 0..numObjects/2) {
            Sphere sph = createRandomSphere(40, 10);
            spheres ~= sph;

            VkTransformMatrixKHR transform = identityTransformMatrix();
            transform.translate(sph.centre);
            transform.scale(float3(sph.radius));
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
        assert(instanceTransforms.length == numObjects);

        VkAccelerationStructureInstanceKHR[] instances;

        foreach(i, transform; instanceTransforms) {

            uint index = i.as!uint;
            uint sbtOffset = 0;
            ulong blasDeviceAddress = cubeBLAS.deviceAddress;

            if(i >= numObjects/2) {
                // Sphere
                index -= numObjects/2;
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

            // Set the instance id
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
        sphereData = new GPUData!Sphere(context, RT_STORAGE, true, spheres.length.as!uint)
            .withUploadStrategy(GPUDataUploadStrategy.ALL)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR
            ))
            .initialise();

        sphereData.write(spheres);
    }
    void createDescriptors() {
        // 0 -> acceleration structure
        // 1 -> target image
        // 2 -> uniform buffer (ubo)
        // 3 -> storage buffer (cubeData)
        // 4 -> storage buffer (sphereData)
        this.descriptors = new Descriptors(context)
            .createLayout()
                .accelerationStructure(VK_SHADER_STAGE_RAYGEN_BIT_KHR)
                .storageImage(VK_SHADER_STAGE_RAYGEN_BIT_KHR)
                .uniformBuffer(VK_SHADER_STAGE_RAYGEN_BIT_KHR | VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR | VK_SHADER_STAGE_INTERSECTION_BIT_KHR)
                .storageBuffer(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR)
                .storageBuffer(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR | VK_SHADER_STAGE_INTERSECTION_BIT_KHR)
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
                    .write();
        }
    }
    void createPipeline() {
        this.rtPipeline = new RayTracingPipeline(context)
            .withDSLayouts(descriptors.getAllLayouts())
            // A single raygen group
            .withRaygenGroup(0)   
            // A single miss group
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

        auto slangModule = context.shaders.getModule("vulkan/test/raytracing/mixed/rt_mixed.slang");

        rtPipeline.withShader(VK_SHADER_STAGE_RAYGEN_BIT_KHR, slangModule, null, "raygen")
                  .withShader(VK_SHADER_STAGE_MISS_BIT_KHR, slangModule, null, "miss")
                  .withShader(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR, slangModule, null, "closesthitCube")
                  .withShader(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR, slangModule, null, "closesthitSphere")
                  .withShader(VK_SHADER_STAGE_INTERSECTION_BIT_KHR, slangModule, null, "intersection");
       
        rtPipeline.build();
    }
}
