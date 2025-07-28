module vulkan.tests.raytracing.scenes.triangle_scene;

import vulkan.tests.raytracing.test_ray_tracing;

final class TriangleScene : Scene {
public:
    this(VulkanContext context, VkCommandPool traceCP, FrameResource[] frameResources) {
        super(context, traceCP, frameResources);
    }

    override string name() { return "Triangle"; }
    override string description() { return "A single triangle"; }

    override void destroy() {
        super.destroy();
        if(ubo) ubo.destroy();
        if(blas) blas.destroy();
    }
protected:
    override void subclassInitialise() {
        moveCamera();
        createBLAS();
        createTLAS();
        createUBO();
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
        ubo.upload(cmd);
    }
private:
    GPUData!UBO ubo;
    AccelerationStructure blas;

    static struct UBO { 
        mat4 viewInverse;
        mat4 projInverse;
    }
    void moveCamera() {
        camera3d.movePositionAbsolute(float3(0,0,-2.5));
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
    void createDescriptors() {
        // 0 -> acceleration structure
        // 1 -> target image
        // 2 -> uniform buffer
        this.descriptors = new Descriptors(context)
            .createLayout()
                .accelerationStructure(VK_SHADER_STAGE_RAYGEN_BIT_KHR)
                .storageImage(VK_SHADER_STAGE_RAYGEN_BIT_KHR)
                .uniformBuffer(VK_SHADER_STAGE_RAYGEN_BIT_KHR)
                .sets(vk.swapchain.numImages());
        descriptors.build();

        foreach(res; frameResources) {
            auto view = res.traceTarget.view;

            descriptors.createSetFromLayout(0)
                    .add(tlas.handle)
                    .add(view, VK_IMAGE_LAYOUT_GENERAL)
                    .add(ubo)
                    .write();
        }
    }
    void createPipeline() {
        this.rtPipeline = new RayTracingPipeline(context)
            .withDSLayouts(descriptors.getAllLayouts())
            .withRaygenGroup(0)   
            .withMissGroup(1)    
            .withHitGroup(VK_RAY_TRACING_SHADER_GROUP_TYPE_TRIANGLES_HIT_GROUP_KHR,
                2,                      // closest
                VK_SHADER_UNUSED_KHR,   // any
                VK_SHADER_UNUSED_KHR    // intersection
            );

        enum USE_SLANG = true;

        static if(USE_SLANG) {
            auto slangModule = context.shaders.getModule("vulkan/test/raytracing/triangle/rt_triangle.slang");

            rtPipeline.withShader(VK_SHADER_STAGE_RAYGEN_BIT_KHR, slangModule, null, "raygen")
                        .withShader(VK_SHADER_STAGE_MISS_BIT_KHR, slangModule, null, "miss")
                        .withShader(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR, slangModule, null, "closesthit");
        } else {
            rtPipeline
            .withShader(VK_SHADER_STAGE_RAYGEN_BIT_KHR,
                context.shaders.getModule("vulkan/test/raytracing/triangle/raygen.rgen"))
            .withShader(VK_SHADER_STAGE_MISS_BIT_KHR,
                context.shaders.getModule("vulkan/test/raytracing/triangle/miss.rmiss"))
            .withShader(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR,
                context.shaders.getModule("vulkan/test/raytracing/triangle/closesthit.rchit"));
        }
        rtPipeline.build();
    }
    void createBLAS() {
        static struct Vertex { static assert(Vertex.sizeof==12);
            float x,y,z;

            this(float x, float y, float z) {
                this.x = x*1;
                this.y = y*1;
                this.z = z*1;
            }
        }
        Vertex[] vertices = [
            Vertex(1.0f, 1.0f, 0.0f),
            Vertex(-1.0f, 1.0f, 0.0f),
            Vertex(0.0f, -1.0f, 0.0f)
        ];

        ushort[] indices = [ 0, 1, 2 ];

        VkTransformMatrixKHR transform = identityTransformMatrix();

        auto verticesSize = vertices.length * Vertex.sizeof;
        auto indicesSize = indices.length * ushort.sizeof;
        auto transformSize = VkTransformMatrixKHR.sizeof;

        // Upload vertices, indices and transforms to the GPU
        SubBuffer vertexBuffer = context.buffer(RT_VERTICES).alloc(verticesSize, 0);
        SubBuffer indexBuffer = context.buffer(RT_INDEXES).alloc(indicesSize, 0);
        SubBuffer transformBuffer = context.buffer(RT_TRANSFORMS).alloc(transformSize, 0);

        auto vertexDeviceAddress = getDeviceAddress(context.device, vertexBuffer);
        auto indexDeviceAddress = getDeviceAddress(context.device, indexBuffer);
        auto transformDeviceAddress = getDeviceAddress(context.device, transformBuffer);

        context.transfer().from(vertices.ptr, 0).to(vertexBuffer).size(verticesSize);
        context.transfer().from(indices.ptr, 0).to(indexBuffer).size(indicesSize);
        context.transfer().from(&transform, 0).to(transformBuffer).size(transformSize);

        VkAccelerationStructureGeometryTrianglesDataKHR triangles = {
            sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR,
            pNext: null,
            vertexFormat: VK_FORMAT_R32G32B32_SFLOAT,
            vertexStride: Vertex.sizeof,
            maxVertex: vertices.length.as!uint,
            indexType: VK_INDEX_TYPE_UINT16,
            vertexData: { deviceAddress: vertexDeviceAddress },
            indexData: { deviceAddress: indexDeviceAddress },
            transformData: { deviceAddress: transformDeviceAddress }
        };

        this.blas = new BLAS(context, "blas_triangle", VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR)
            .addTriangles(VK_GEOMETRY_OPAQUE_BIT_KHR, triangles, 1)
            .create();
        
        auto cmd = device.allocFrom(vk.getGraphicsCP());
        cmd.beginOneTimeSubmit();
        blas.update(cmd);
        cmd.end();
        submitAndWait(device, vk.getGraphicsQueue(), cmd);
        device.free(vk.getGraphicsCP(), cmd);
    }
    void createTLAS() {
        VkTransformMatrixKHR transform = identityTransformMatrix();

        // This struct has bitfields which are not natively supported in D.
        VkAccelerationStructureInstanceKHR instance = {
            transform: transform,
            accelerationStructureReference: blas.deviceAddress
        };
        throwIf(instance.sizeof != 64);

        // Set the bitfields
        instance.setInstanceCustomIndex(0);
        instance.setMask(0xff);
        instance.setFlags(VK_GEOMETRY_INSTANCE_TRIANGLE_FACING_CULL_DISABLE_BIT_KHR);
        instance.setInstanceShaderBindingTableRecordOffset(0);
        
        auto instancesSize = VkAccelerationStructureInstanceKHR.sizeof;
        SubBuffer instancesBuffer = context.buffer(RT_INSTANCES).alloc(instancesSize);
        auto instancesDeviceAddress = getDeviceAddress(context.device, instancesBuffer);

        // Copy instances to instancesBuffer on device
        context.transfer().from(&instance, 0)
                            .to(instancesBuffer)
                            .size(instancesSize);
        
        this.tlas = new TLAS(context, "tlas_triangle", VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR)
            .addInstances(VK_GEOMETRY_OPAQUE_BIT_KHR, instancesDeviceAddress, 1)
            .create();

        auto cmd = device.allocFrom(vk.getGraphicsCP());
        cmd.beginOneTimeSubmit();
        tlas.update(cmd);
        cmd.end();
        submitAndWait(device, vk.getGraphicsQueue(), cmd);
        device.free(vk.getGraphicsCP(), cmd);

        // instances buffer can be freed here
    }
}
