module vulkan.tests.raytracing.scenes.spheres_scene;

import vulkan.tests.raytracing.test_ray_tracing;

final class SpheresScene : Scene {
public:
    //
    // Option 1 : Create multiple sphere AABBs in a single BLAS with a single TLAS instance.
    // Option 2 : Create a single sphere AABB in a single BLAS and multiple TLAS instances pointing to the same BLAS.
    //
    this(VulkanContext context, VkCommandPool traceCP, FrameResource[] frameResources, int option, int numSpheres) {
        super(context, traceCP, frameResources);
        throwIf(option != 1 && option != 2);
        this.option = option;
        this.numSpheres = numSpheres;
    }

    override string name() { return "Spheres %s".format(option); }
    override string description() { 
        if(option == 1) return "BLAS containing %s spheres, single TLAS instance".format(numSpheres);
        if(option == 2) return "BLAS containing a single sphere, %s TLAS instances".format(numSpheres);
        assert(false);
    }

    override void destroy() {
        super.destroy();
        if(ubo) ubo.destroy();
        if(sphereData) sphereData.destroy();
        if(blas) blas.destroy();
    }
protected:
    override void subclassInitialise() {
        createCamera();
        createSpheres();
        createBLAS();
        createTLAS();
        createUBO();
        createSphereDataBuffer();
        createDescriptors();
        createPipeline();
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
        sphereData.upload(cmd);
    }
private:
    BLAS blas;
    GPUData!UBO ubo;
    GPUData!Sphere sphereData;

    Sphere[] spheres;
    AABB[] aabbs;
    VkTransformMatrixKHR[] instanceTransforms;

    uint option;
    uint numSpheres;

    static struct UBO { 
        mat4 viewInverse;
        mat4 projInverse;
        float3 lightPos;
        uint option;
    }
    static struct Sphere {
        float3 center;
        float radius;
        float3 colour;
    }
    static struct AABB {
        float3 min;
        float3 max;
    }
    void createCamera() {
        this.camera3d = Camera3D.forVulkan(vk.windowSize(), vec3(0,0,-120), vec3(0,0,0));
        this.camera3d.fovNearFar(FOV.degrees, NEAR, FAR);
        this.camera3d.rotateZRelative(180.degrees());
    }
    void createSpheres() {
        Mt19937 rng;

        // Use the same seed
        //rng.seed(unpredictableSeed());
        rng.seed(1);

        if(option == 1) {
            // A single TLAS instance
            instanceTransforms ~= identityTransformMatrix();

            // A single BLAS containing multiple spheres
            foreach(i; 0..numSpheres) {
                float3 origin = float3(uniform01(rng) * 2 - 1, uniform01(rng) * 2 - 1, uniform01(rng) * 2 - 1) * 40;
                float radius = maxOf(1, uniform01(rng) * 10);
                float3 colour = float3(uniform01(rng) + 0.2, uniform01(rng) + 0.2, uniform01(rng) + 0.2);
                
                spheres ~= Sphere(origin, radius, colour);
                aabbs ~= AABB(origin - radius, origin + radius);
            }

        } else if(option == 2) {
            // A single BLAS AABB at the origin
            aabbs ~= AABB(float3(-10, -10, -10), float3(10, 10, 10));

            // Multiple TLAS instances with different transforms
            foreach(i; 0..numSpheres) {
                float3 origin = float3(uniform01(rng) * 2 - 1, uniform01(rng) * 2 - 1, uniform01(rng) * 2 - 1) * 40;
                float radius = maxOf(1, uniform01(rng) * 10);
                float3 colour = float3(uniform01(rng) + 0.2, uniform01(rng) + 0.2, uniform01(rng) + 0.2);
                spheres ~= Sphere(origin, radius, colour);

                float s = radius / 10;

                VkTransformMatrixKHR transform = identityTransformMatrix();
                transform.translate(origin);
                transform.scale(float3(s, s, s));
                instanceTransforms ~= transform;
            }
        
        } 
    }
    void updateUBO() {
        ubo.write((u) {
            u.viewInverse = camera3d.V().inversed();
            u.projInverse = camera3d.P().inversed();

            u.option = option;
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
    void createSphereDataBuffer() {
        sphereData = new GPUData!Sphere(context, RT_STORAGE, true, numSpheres)
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
        // 3 -> storage buffer (sphereData)
        this.descriptors = new Descriptors(context)
            .createLayout()
                .accelerationStructure(VK_SHADER_STAGE_RAYGEN_BIT_KHR)
                .storageImage(VK_SHADER_STAGE_RAYGEN_BIT_KHR)
                .uniformBuffer(VK_SHADER_STAGE_RAYGEN_BIT_KHR | VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR | VK_SHADER_STAGE_INTERSECTION_BIT_KHR)
                .storageBuffer(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR | VK_SHADER_STAGE_INTERSECTION_BIT_KHR)
                .sets(vk.swapchain.numImages());
        descriptors.build();

        foreach(res; frameResources) {
            auto view = res.traceTarget.view;

            descriptors.createSetFromLayout(0)
                    .add(tlas.handle)
                    .add(view, VK_IMAGE_LAYOUT_GENERAL)
                    .add(ubo)
                    .add(sphereData)
                    .write();
        }
    }
    void createPipeline() {
        this.rtPipeline = new RayTracingPipeline(context)
            .withDSLayouts(descriptors.getAllLayouts())
            .withRaygenGroup(0)   
            .withMissGroup(1)    
            .withHitGroup(VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_KHR,
                2,                      // closest
                VK_SHADER_UNUSED_KHR,   // any
                3                       // intersection
            );


        enum USE_SLANG = true;

        static if(USE_SLANG) {
            auto slangModule = context.shaders.getModule("vulkan/test/raytracing/spheres/rt_spheres.slang");

            rtPipeline.withShader(VK_SHADER_STAGE_RAYGEN_BIT_KHR, slangModule, null, "raygen")
                        .withShader(VK_SHADER_STAGE_MISS_BIT_KHR, slangModule, null, "miss")
                        .withShader(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR, slangModule, null, "closesthit")
                        .withShader(VK_SHADER_STAGE_INTERSECTION_BIT_KHR, slangModule, null, "intersection"); 
        } else { 
            rtPipeline.withShader(VK_SHADER_STAGE_RAYGEN_BIT_KHR,
                            context.shaders.getModule("vulkan/test/raytracing/spheres/raygen.rgen"))
                        .withShader(VK_SHADER_STAGE_MISS_BIT_KHR,
                            context.shaders.getModule("vulkan/test/raytracing/spheres/miss.rmiss"))
                        .withShader(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR,
                            context.shaders.getModule("vulkan/test/raytracing/spheres/closesthit.rchit"))
                        .withShader(VK_SHADER_STAGE_INTERSECTION_BIT_KHR,
                            context.shaders.getModule("vulkan/test/raytracing/spheres/intersection.rint"));
        }
        rtPipeline.build();
    }

    void createBLAS() {
        auto aabbsSize = aabbs.length*AABB.sizeof;
        SubBuffer aabbsBuffer = context.buffer(RT_AABBS).alloc(aabbsSize);
        auto aabbsDeviceAddress = getDeviceAddress(context.device, aabbsBuffer);
        context.transfer().from(aabbs.ptr, 0).to(aabbsBuffer).size(aabbsSize);

        this.blas = new BLAS(context, "blas_sphere_aabbs");
        blas.addAABBs(VK_GEOMETRY_OPAQUE_BIT_KHR, aabbsDeviceAddress, AABB.sizeof, aabbs.length.as!int);
        
        auto cmd = device.allocFrom(vk.getGraphicsCP());
        cmd.beginOneTimeSubmit();
        blas.buildAll(cmd, VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR);
        cmd.end();
        submitAndWait(device, vk.getGraphicsQueue(), cmd);
        device.free(vk.getGraphicsCP(), cmd);
    }
    void createTLAS() {
        // This struct uses bitfields which is not natively supported in D.
        VkAccelerationStructureInstanceKHR[] instances;
        if(option == 1) {
            // A single instance
            VkAccelerationStructureInstanceKHR instance = {
                transform: instanceTransforms[0],
                accelerationStructureReference: blas.deviceAddress
            };
            instance.setInstanceCustomIndex(0);
            instance.setMask(0xFF);
            instance.setInstanceShaderBindingTableRecordOffset(0);
            instance.setFlags(VK_GEOMETRY_INSTANCE_TRIANGLE_FACING_CULL_DISABLE_BIT_KHR);
            instances ~= instance;

        } else if(option == 2) {
            foreach(i; 0..numSpheres) {
                // Multiple instances pointing to the same BLAS but with a different transform
                VkAccelerationStructureInstanceKHR instance = {
                    transform: instanceTransforms[i],
                    accelerationStructureReference: blas.deviceAddress
                };
                instance.setInstanceCustomIndex(0);
                instance.setMask(0xFF);
                instance.setInstanceShaderBindingTableRecordOffset(0);
                instance.setFlags(
                    VK_GEOMETRY_INSTANCE_FORCE_OPAQUE_BIT_KHR | 
                    VK_GEOMETRY_INSTANCE_TRIANGLE_FACING_CULL_DISABLE_BIT_KHR);
                instances ~= instance;
            }
        } 

        auto instancesSize = VkAccelerationStructureInstanceKHR.sizeof * instances.length;
        SubBuffer instancesBuffer = context.buffer(RT_INSTANCES).alloc(instancesSize);
        auto instancesDeviceAddress = getDeviceAddress(device, instancesBuffer);
        context.transfer().from(instances.ptr, 0)
                            .to(instancesBuffer)
                            .size(instancesSize);

        this.tlas = new TLAS(context, "tlas_spheres");
        tlas.addInstances(VK_GEOMETRY_OPAQUE_BIT_KHR, instancesDeviceAddress, instances.length.as!uint);

        auto cmd = device.allocFrom(vk.getGraphicsCP());
        cmd.beginOneTimeSubmit();
        tlas.buildAll(cmd, VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR);
        cmd.end();
        submitAndWait(device, vk.getGraphicsQueue(), cmd);
        device.free(vk.getGraphicsCP(), cmd);
    }
}
