module vulkan.tests.raytracing.scenes.sdf_scene;

import vulkan.tests.raytracing.test_ray_tracing;

final class SDFScene : Scene {
public:
    this(VulkanContext context, VkCommandPool traceCP, FrameResource[] frameResources) {
        super(context, traceCP, frameResources);

        rng.seed(unpredictableSeed());
    }

    override string name() { return "SDF Shapes"; }
    override string description() { return "SDF shapes"; }

    override void destroy() {
        super.destroy();
        if(ubo) ubo.destroy();
        if(shapesData) shapesData.destroy(); 
        if(blas) blas.destroy();
        if(sampler) device.destroySampler(sampler);
    }
protected:
    override void subclassInitialise() {
        moveCamera();
        createShapes();
        loadTextures();
        createSampler();
        createBLAS();
        createTLAS();
        createUBO();
        createShapesDataBuffer();
        createDescriptors();
        createPipeline();
        recordCommandBuffers();
    }
    override void subclassUpdate(Frame frame, float3 lightPos) {
        auto cmd = frame.resource.adhocCB;

        if(camera3d.wasModified()) {
            camera3d.resetModifiedState();
            updateUBO();
        }

        ubo.write((u) {
            u.lightPos = lightPos;
        });

        ubo.upload(cmd);
        shapesData.upload(cmd);
    }
private:
    AccelerationStructure blas;
    GPUData!UBO ubo;
    GPUData!Shape shapesData;
    ImageMeta texture1;
    VkSampler sampler;

    Shape[] shapes;

    AABB[] aabbs;
    VkTransformMatrixKHR[] instanceTransforms;

    static struct UBO { 
        mat4 viewInverse;
        mat4 projInverse;
        float3 lightPos;
    }
    static struct Shape {
        float3 pos;
        float3 scale;
        float3 colour;
        uint type;
    }
    void moveCamera() {
        camera3d.movePositionAbsolute(float3(0,0,-200));
    }
    void createShapes() {

        // Create the shapes in object space
        //   0 - sphere
        //   1 - box
        //   2 - cone
        //   3 - cylinder
        //   4 - rounded box
        //   5 - torus
        //   6 - displaced box
        //   7 - bowl

        // floor
        shapes ~= Shape(
            float3(0, -50, 0), 
            float3(100, 5, 80), 
            float3(1,1,1), 
            1
        );

        shapes ~= Shape(
            float3(-80, 30,0), 
            float3(20, 20, 20), 
            float3(0,1,0), 
            4);

        shapes ~= Shape(
            float3(-30, 30, 0), 
            float3(20, 20, 20), 
            float3(1,0,1), 
            1);      

        shapes ~= Shape(
            float3(30, 30, 0), 
            float3(20, 20, 20), 
            float3(1,1,0), 
            0);

        shapes ~= Shape(
            float3(80, 30, 0), 
            float3(20, 20, 20), 
            float3(1,1,1), 
            6);    


        shapes ~= Shape(
            float3(-80, -30,0), 
            float3(20, 20, 20), 
            float3(0,0,1), 
            5);     

        shapes ~= Shape(
            float3(-30,-30,0), 
            float3(20, 20, 20), 
            float3(0,1,1), 
            2);  

        shapes ~= Shape(
            float3(30,-30,0), 
            float3(20, 20, 20), 
            float3(1,0,0), 
            3);  

        shapes ~= Shape(
            float3(80,-30,0), 
            float3(20, 20, 20), 
            float3(1,0.5,0.5), 
            7);          

        // We only need a single AABB of unit size
        aabbs ~= AABB(float3(-1), float3(1));

        // Create the AABBs and instances
        foreach(i, s; shapes) {
            // Instance - this will transform to world space
            VkTransformMatrixKHR transform = identityTransformMatrix();
            transform.translate(s.pos);
            transform.scale(s.scale);

            instanceTransforms ~= transform;
        }
    }
    void loadTextures() {
        texture1 = context.images().get("wood.png");
    }
    void createSampler() {
        sampler = context.device.createSampler(samplerCreateInfo((info) {
            info.addressModeU = VK_SAMPLER_ADDRESS_MODE_REPEAT;
            info.addressModeV = VK_SAMPLER_ADDRESS_MODE_REPEAT;
            info.maxAnisotropy = 16;
            info.anisotropyEnable = VK_TRUE;
        }));
    }
    void updateUBO() {
        ubo.write((u) {
            u.viewInverse = camera3d.V().inversed();
            u.projInverse = camera3d.P().inversed();
        });
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

        updateUBO();
    }
    void createShapesDataBuffer() {
        shapesData = new GPUData!Shape(context, RT_STORAGE, true, shapes.length.as!uint)
            .withUploadStrategy(GPUDataUploadStrategy.ALL)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR
            ))
            .initialise();

        shapesData.write(shapes);
    }
    void createDescriptors() {
        // 0 -> acceleration structure
        // 1 -> target image
        // 2 -> uniform buffer (ubo)
        // 3 -> storage buffer (shapesData)
        // 4 -> combined image sampler
        this.descriptors = new Descriptors(context)
            .createLayout()
                .accelerationStructure(VK_SHADER_STAGE_RAYGEN_BIT_KHR)
                .storageImage(VK_SHADER_STAGE_RAYGEN_BIT_KHR)
                .uniformBuffer(VK_SHADER_STAGE_RAYGEN_BIT_KHR | VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR | VK_SHADER_STAGE_INTERSECTION_BIT_KHR)
                .storageBuffer(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR | VK_SHADER_STAGE_INTERSECTION_BIT_KHR)
                .combinedImageSampler(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR)
                .sets(vk.swapchain.numImages());
        descriptors.build();

        foreach(res; frameResources) {
            auto view = res.traceTarget.view;

            descriptors.createSetFromLayout(0)
                    .add(tlas.handle)
                    .add(view, VK_IMAGE_LAYOUT_GENERAL)
                    .add(ubo)
                    .add(shapesData)
                    .add(sampler,
                        texture1.image.view(texture1.format, VK_IMAGE_VIEW_TYPE_2D),
                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)
                    .write();
        }
    }
    void createPipeline() {
        this.rtPipeline = new RayTracingPipeline(context)
            .withDSLayouts(descriptors.getAllLayouts())
            .withRaygenGroup(0)   
            .withMissGroup(1)  
            .withMissGroup(2)

            // shape group 0
            .withHitGroup(VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_KHR,
                3,                      // closest
                VK_SHADER_UNUSED_KHR,   // any
                4                       // intersection
            )
            // shape group 1
            .withHitGroup(VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_KHR,
                3,                      // closest
                VK_SHADER_UNUSED_KHR,   // any
                5                       // intersection
            )
            // shape group 2
            .withHitGroup(VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_KHR,
                3,                      // closest
                VK_SHADER_UNUSED_KHR,   // any
                6                       // intersection
            )
            // shape group 3
            .withHitGroup(VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_KHR,
                3,                      // closest
                VK_SHADER_UNUSED_KHR,   // any
                7                       // intersection
            )
            // shape group 4
            .withHitGroup(VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_KHR,
                3,                      // closest
                VK_SHADER_UNUSED_KHR,   // any
                8                       // intersection
            )
            // shape group 5
            .withHitGroup(VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_KHR,
                3,                      // closest
                VK_SHADER_UNUSED_KHR,   // any
                9                       // intersection
            )
            // shape group 6
            .withHitGroup(VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_KHR,
                3,                      // closest
                VK_SHADER_UNUSED_KHR,   // any
                10                      // intersection
            )
            // shape group 7
            .withHitGroup(VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_KHR,
                3,                      // closest
                VK_SHADER_UNUSED_KHR,   // any
                11                      // intersection
            )
            ;

        auto slangModule = context.shaders.getModule("vulkan/test/raytracing/sdf/rt_sdf.slang");
        auto intersection = context.shaders.getModule("vulkan/test/raytracing/sdf/sdf_intersection.slang");

        rtPipeline.withShader(VK_SHADER_STAGE_RAYGEN_BIT_KHR, slangModule, null, "raygen") // 0
                    .withShader(VK_SHADER_STAGE_MISS_BIT_KHR, slangModule, null, "miss")    // 1
                    .withShader(VK_SHADER_STAGE_MISS_BIT_KHR, slangModule, null, "shadowMiss") // 2
                    .withShader(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR, slangModule, null, "closesthit") // 3
                    .withShader(VK_SHADER_STAGE_INTERSECTION_BIT_KHR, intersection, null, "intersection0")  // 4
                    .withShader(VK_SHADER_STAGE_INTERSECTION_BIT_KHR, intersection, null, "intersection1")  // 5
                    .withShader(VK_SHADER_STAGE_INTERSECTION_BIT_KHR, intersection, null, "intersection2")  // 6
                    .withShader(VK_SHADER_STAGE_INTERSECTION_BIT_KHR, intersection, null, "intersection3")  // 7
                    .withShader(VK_SHADER_STAGE_INTERSECTION_BIT_KHR, intersection, null, "intersection4")  // 8
                    .withShader(VK_SHADER_STAGE_INTERSECTION_BIT_KHR, intersection, null, "intersection5")  // 9
                    .withShader(VK_SHADER_STAGE_INTERSECTION_BIT_KHR, intersection, null, "intersection6")  // 10
                    .withShader(VK_SHADER_STAGE_INTERSECTION_BIT_KHR, intersection, null, "intersection7")  // 11
                    .withMaxRecursionDepth(4)
                    .build();   
    }

    void createBLAS() {
        auto aabbsSize = aabbs.length*AABB.sizeof;
        SubBuffer aabbsBuffer = context.buffer(RT_AABBS).alloc(aabbsSize);
        auto aabbsDeviceAddress = getDeviceAddress(context.device, aabbsBuffer);
        context.transfer().from(aabbs.ptr, 0).to(aabbsBuffer).size(aabbsSize);

        this.blas = new BLAS(context, "blas_shapes_aabbs", VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR)
            .addAABBs(VK_GEOMETRY_OPAQUE_BIT_KHR, aabbsDeviceAddress, AABB.sizeof, aabbs.length.as!int)
            .create();

        auto cmd = device.allocFrom(vk.getGraphicsCP());
        cmd.beginOneTimeSubmit();
        blas.update(cmd);
        cmd.end();
        submitAndWait(device, vk.getGraphicsQueue(), cmd);
        device.free(vk.getGraphicsCP(), cmd);
    }
    void createTLAS() {
        VkAccelerationStructureInstanceKHR[] instances;

        foreach(i, transform; instanceTransforms) {

            VkAccelerationStructureInstanceKHR instance = {
                transform: transform,
                accelerationStructureReference: blas.deviceAddress
            };
            instance.setMask(0xFF);

            // The shape type will choose the intersection shader
            instance.setInstanceShaderBindingTableRecordOffset(shapes[i].type);

            instance.setInstanceCustomIndex(0);

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

        this.tlas = new TLAS(context, "tlas_shapes", VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR)
            .addInstances(VK_GEOMETRY_OPAQUE_BIT_KHR, instancesDeviceAddress, instances.length.as!uint)
            .create();

        auto cmd = device.allocFrom(vk.getGraphicsCP());
        cmd.beginOneTimeSubmit();
        tlas.update(cmd);
        cmd.end();
        submitAndWait(device, vk.getGraphicsQueue(), cmd);
        device.free(vk.getGraphicsCP(), cmd);
    }
}
