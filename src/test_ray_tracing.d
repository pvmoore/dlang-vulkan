module test_ray_tracing;


import core.sys.windows.windows;
import core.runtime;
import std.string : toStringz;
import std.stdio  : writefln;
import std.format : format;
import std.datetime.stopwatch : StopWatch;

import vulkan.all;

final class TestRayTracing : VulkanApplication {
public:
    this() {
        enum NAME = "Vulkan Ray Tracing";
        WindowProperties wprops = {
            width:          1400,   // 1920
            height:         800,    // 1080
            fullscreen:     false,
            vsync:          false,
            title:          NAME,
            icon:           "resources/images/logo.png",
            showWindow:     false,
            frameBuffers:   2,
            titleBarFps:    true
        };
        VulkanProperties vprops = {
            appName: NAME,
            apiVersion: vulkanVersion(1,1,0),
            features: DeviceFeatures.Features.RayTracingPipeline |
                      DeviceFeatures.Features.AccelerationStructure |
                      DeviceFeatures.Features.BufferDeviceAddress,
            shaderSpirvVersion: "1.4",
            imgui: {
                enabled: true,
                configFlags:
                    ImGuiConfigFlags_NoMouseCursorChange |
                    ImGuiConfigFlags_DockingEnable |
                    ImGuiConfigFlags_ViewportsEnable,
                fontPaths: [
                    "resources/fonts/Inconsolata-Bold.ttf"
                ],
                fontSizes: [
                    22
                ]
            }
        };

        debug {
            vprops.enableShaderPrintf = false;
            vprops.enableGpuValidation = true;
        }

        // Ray tracing device extensions
        vprops.addDeviceExtension("VK_KHR_acceleration_structure");
        vprops.addDeviceExtension("VK_KHR_ray_tracing_pipeline");

        // Required by VK_KHR_acceleration_structure
        vprops.addDeviceExtension("VK_KHR_deferred_host_operations");
        vprops.addDeviceExtension("VK_KHR_buffer_device_address");
        vprops.addDeviceExtension("VK_EXT_descriptor_indexing"),

        // SPIRV 1.4 stuff
        vprops.addDeviceExtension("VK_KHR_spirv_1_4");
        vprops.addDeviceExtension("VK_KHR_shader_float_controls");

		this.vk = new Vulkan(this, wprops, vprops);
        vk.initialise();
        vk.showWindow();
    }
    override void destroy() {
	    if(!vk) return;
	    if(device) {
	        vkDeviceWaitIdle(device);

            if(context) context.dumpMemory();

            foreach(r; frameResources) {
                r.quad.destroy();
                r.traceTarget.free();
            }

            if(rtPipeline) rtPipeline.destroy();
            if(descriptors) descriptors.destroy();
            if(ubo) ubo.destroy();

            if(tlas) tlas.destroy();
            if(blas) blas.destroy();

            if(quadSampler) device.destroySampler(quadSampler);

            if(renderPass) device.destroyRenderPass(renderPass);
            if(context) context.destroy();
	    }
		vk.destroy();
    }
    override void run() {
        vk.mainLoop();
    }
    override VkRenderPass getRenderPass(VkDevice device) {
        createRenderPass(device);
        return renderPass;
    }
    override void selectFeatures(DeviceFeatures deviceFeatures) {
        deviceFeatures.apply((ref VkPhysicalDeviceRayTracingPipelineFeaturesKHR f) {
            if(f.rayTracingPipeline == VK_FALSE) {
                throw new Exception("Hardware ray tracing is not supported on your device");
            }
        });
        deviceFeatures.apply((ref VkPhysicalDeviceAccelerationStructureFeaturesKHR f) {
            if(f.accelerationStructureHostCommands) {
                log("Building acceleration structures on the host supported");
            } else {
                log("Building acceleration structures on the host not supported");
            }
        });
        deviceFeatures.apply((ref VkPhysicalDeviceBufferDeviceAddressFeaturesEXT f) {
            throwIf(!f.bufferDeviceAddress, "Buffer Device Address feature is not supported on your device");
        });
    }
    override void deviceReady(VkDevice device, PerFrameResource[] frameResources) {
        this.device = device;
        initScene();
    }
    void update(Frame frame) {

        float zoomDelta = 100 * frame.perSecond;

        MouseState mouse = context.vk.getMouseState();
        float2 mousePos = mouse.pos;

        if(mouse.wheel < 0) {
            camera3d.moveForward(-zoomDelta);
            //if(camera3d.position.y > MAXY) {
            //    // We have gone too far.
            //    auto cameraPos = camera3d.position;
            //    cameraPos.y = MAXY;
            //    camera3d.movePositionAbsolute(cameraPos);
            //}
        } else if(mouse.wheel>0) {
            camera3d.moveForward(zoomDelta);
            //if(camera3d.position.y < MINY) {
            //    // We have gone too far.
            //    auto cameraPos = camera3d.position;
            //    cameraPos.y = MINY;
            //    camera3d.movePositionAbsolute(cameraPos);
            //}
        }

        // Start dragging the mouse
        if(mouse.isDragging && !dragging.isDragging && mouse.button == 0) {
            dragging.isDragging = true;
            dragging.startCameraPos = camera3d.position();
        }

        // Finish dragging the mouse
        if(!mouse.isDragging && dragging.isDragging) {
            dragging.isDragging = false;
        }

        // If the mouse has moved then update the camera position
        if(dragging.isDragging) {
            if(mousePos != dragging.currentMousePos) {
                dragging.currentMousePos = mousePos;

                float dist = camera3d.position().length();
                float3 w1 = camera3d.screenToWorld(mouse.dragStart.x, mouse.dragStart.y, 0);
                float3 w2 = camera3d.screenToWorld(mousePos.x, mousePos.y, 0);

                auto delta = ((w1 - w2) * 100 * dist) * float3(-1,1,1);
                camera3d.movePositionAbsolute(dragging.startCameraPos + delta);
            }
        }

        if(camera3d.wasModified()) {
            camera3d.resetModifiedState();
            updateUBO();
        }

        ubo.upload(frame.resource.adhocCB);
    }
    override void render(Frame frame) {
        auto res = frame.resource;
        auto resource = &frameResources[res.index];
        auto rayTraceCommand = resource.cmd;

	    auto b = frame.resource.adhocCB;
	    b.beginOneTimeSubmit();

        update(frame);

        // begin the render pass
        b.beginRenderPass(
            renderPass,
            frame.frameBuffer,
            toVkRect2D(0,0, vk.windowSize.toVkExtent2D),
            [ bgColour ],
            VK_SUBPASS_CONTENTS_INLINE
        );

        resource.quad.insideRenderPass(frame);
        imguiFrame(frame);

        b.endRenderPass();
        b.end();

        /// Submit our render buffer
        vk.getGraphicsQueue().submit(
            [rayTraceCommand, b],   // cmd buffers
            //[b],
            [res.imageAvailable],   // wait semaphores
            [VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT], // wait stages
            [res.renderFinished],  // signal semaphores
            res.fence              // fence
        );
    }
private:
    enum {
        NEAR = 0.01f,
        FAR  = 10000f,
        FOV  = 60f
    }

    Vulkan vk;
	VkDevice device;
    VulkanContext context;
    VkRenderPass renderPass;

    Camera2D camera2d;
    Camera3D camera3d;
    VkClearValue bgColour;
    uvec2 windowSize;

    enum {
        RT_VERTICES     = "rt_vertices".as!BufID,
        RT_INDEXES      = "rt_indices".as!BufID,
        RT_TRANSFORMS   = "rt_transforms".as!BufID,
        RT_INSTANCES    = "rt_instances".as!BufID
    }
    static struct UBO { static assert(UBO.sizeof == 64+64);
        mat4 viewInverse;
        mat4 projInverse;
    }
    static struct FrameResource {
        VkCommandBuffer cmd;
        DeviceImage traceTarget;
        Quad quad;
    }

    VkCommandPool traceCP;

    FrameResource[] frameResources;
    GPUData!UBO ubo;
    Descriptors descriptors;
    VkSampler quadSampler;

    float fov = FOV;

    RayTracingPipeline rtPipeline;
    TLAS tlas;
    BLAS blas;

    MouseDragging dragging;

    static struct MouseDragging {
        bool isDragging = false;
        float3 startCameraPos;
        float2 currentMousePos;
    }

    void initScene() {
        this.log("────────────────────────────────────────────────────────────────────");
        this.log(" Initialising scene");
        this.log("────────────────────────────────────────────────────────────────────");
        this.windowSize = cast(uvec2)vk.swapchain.extent;
        createCamera();

        auto mem = new MemoryAllocator(vk);

        auto maxLocal =
            mem.builder(0)
                .withAll(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                .withoutAll(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT)
                .maxHeapSize();

        this.log("Max device memory = %s MBs (%.3f GBs)", maxLocal / 1.MB, maxLocal.as!double/1.GB);

        // Allocate memory (Device local memory needs the VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT flag)

        this.context = new VulkanContext(vk)
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("TRT_Local", 256.MB, VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("TRT_Staging", 32.MB + 2.MB + 16.MB));
            //.withMemory(MemID.SHARED, mem.allocStdShared("TRT_Shared", 128.MB));

        // General buffers
        context.withBuffer(MemID.LOCAL, BufID.VERTEX, VK_BUFFER_USAGE_VERTEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 32.MB)
               .withBuffer(MemID.LOCAL, BufID.INDEX, VK_BUFFER_USAGE_INDEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 32.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM, VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 1.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, 32.MB + 4.MB);

        // Buffers for ray tracing
        context.withBuffer(MemID.LOCAL, BufID.RT_ACCELERATION,
            VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT,
            32.MB);
        context.withBuffer(MemID.LOCAL, BufID.RT_SCRATCH,
            VK_BUFFER_USAGE_STORAGE_BUFFER_BIT |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT,
            32.MB);
        context.withBuffer(MemID.STAGING, BufID.RT_SBT,
            VK_BUFFER_USAGE_SHADER_BINDING_TABLE_BIT_KHR |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT |
            VK_BUFFER_USAGE_TRANSFER_DST_BIT,
            2.MB);

        context.withBuffer(MemID.LOCAL, RT_VERTICES,
            VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT |
            VK_BUFFER_USAGE_TRANSFER_DST_BIT,
            2.MB);
        context.withBuffer(MemID.LOCAL, RT_INDEXES,
            VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT |
            VK_BUFFER_USAGE_TRANSFER_DST_BIT,
            2.MB);
        context.withBuffer(MemID.LOCAL, RT_TRANSFORMS,
            VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT |
            VK_BUFFER_USAGE_TRANSFER_DST_BIT,
            2.MB);
        context.withBuffer(MemID.LOCAL, RT_INSTANCES,
            VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT |
            VK_BUFFER_USAGE_TRANSFER_DST_BIT,
            2.MB);

        context.withFonts("resources/fonts/")
               .withImages("resources/images/")
               .withRenderPass(renderPass);

        this.log("shared mem available = %s", context.hasMemory(MemID.SHARED));

        this.log("%s", context);

        this.bgColour = clearColour(0.0f, 0, 0, 1);

        createSamplers();

        this.traceCP = vk.createCommandPool(vk.getGraphicsQueueFamily().index, 0);

        createFrameResources();

        buildBLAS();
        buildTLAS();
        createUBO();
        createDescriptors();
        createPipeline();
        createRayTracingCommandBuffers();

        this.log("────────────────────────────────────────────────────────────────────");
        this.log(" Scene initialised");
        this.log("────────────────────────────────────────────────────────────────────");
    }
    void createCamera() {

        this.camera2d = Camera2D.forVulkan(vk.windowSize());
        this.camera3d = Camera3D.forVulkan(vk.windowSize(), vec3(0,0,-2.5), vec3(0,0,0));
        this.camera3d.fovNearFar(FOV.degrees, NEAR, FAR);

        this.log("Camera2D = %s", camera2d);
        this.log("Camera3D = %s", camera3d);
    }
    void updateUBO() {
        ubo.write((u) {
            u.viewInverse = camera3d.V().inversed();
            u.projInverse = camera3d.P().inversed();
        });
    }
    void imguiFrame(Frame frame) {
        vk.imguiRenderStart(frame);

        auto vp = igGetMainViewport();
        igSetNextWindowPos(vp.WorkPos + ImVec2(5,5), ImGuiCond_Always, ImVec2(0.0, 0.0));
        igSetNextWindowSize(ImVec2(250, 200), ImGuiCond_Always);

        if(igBegin("Camera", null, ImGuiWindowFlags_None)) {

            igText("Pos  %.1f, %.1f, %.1f", camera3d.position().x, camera3d.position().y, camera3d.position().z);
            igText("Look %.1f, %.1f, %.1f", camera3d.forward().x, camera3d.forward().y, camera3d.forward().z);
            igText("Up   %.1f, %.1f, %.1f", camera3d.up().x, camera3d.up().y, camera3d.up().z);
            if(igDragFloat("FOV", &fov, 1, 30, 120, "%.0f", ImGuiSliderFlags_None)) {
                camera3d.fovNearFar(fov.degrees, NEAR, FAR);
                updateUBO();
            }

            igEnd();
        }

        float2 pos = vp.WorkPos.as!float2 + float2(0, vp.WorkSize.y) + float2(5,-44);
        float2 size = float2(vp.WorkSize.x - 10, 40);

        igSetNextWindowPos(pos.as!ImVec2, ImGuiCond_Always, ImVec2(0.0, 0.0));
        igSetNextWindowSize(size.as!ImVec2, ImGuiCond_Always);

        if(igBegin("Info", null, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize)) {
            igText("Drag the screen with the LMB, scroll wheel to zoom in/out");
            igEnd();
        }

        vk.imguiRenderEnd(frame);
    }
    void createRenderPass(VkDevice device) {
        this.log("Creating render pass");
        auto colorAttachment    = attachmentDescription(vk.swapchain.colorFormat);
        auto colorAttachmentRef = attachmentReference(0);

        auto subpass = subpassDescription((info) {
            info.colorAttachmentCount = 1;
            info.pColorAttachments    = &colorAttachmentRef;
        });

        auto dependency = subpassDependency();

        renderPass = .createRenderPass(
            device,
            [colorAttachment],
            [subpass],
            subpassDependency2()//[dependency]
        );
    }
    void createUBO() {
        this.log("Creating UBO...");
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true)
            .withUploadStrategy(GPUDataUploadStrategy.ALL)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .initialise();

        updateUBO();
    }
    void createSamplers() {
        this.quadSampler = device.createSampler(samplerCreateInfo((info){
            info.addressModeU = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE;
            info.addressModeV = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE;
        }));
    }
    void createFrameResources() {
        foreach(i; 0..vk.swapchain.numImages()) {
            frameResources ~= FrameResource();
            auto fr = &frameResources[$-1];

            fr.cmd = device.allocFrom(traceCP);
            fr.traceTarget = context.memory(MemID.LOCAL).allocImage(
                    "TargetImage%s".format(frameResources.length+1),
                    [windowSize.width(), windowSize.height()],
                    VK_IMAGE_USAGE_STORAGE_BIT | VK_IMAGE_USAGE_SAMPLED_BIT,
                    VK_FORMAT_R8G8B8A8_UNORM
                );
            fr.traceTarget.createView(VK_FORMAT_R8G8B8A8_UNORM, VK_IMAGE_VIEW_TYPE_2D, VK_IMAGE_ASPECT_COLOR_BIT);
            fr.quad = new Quad(context, ImageMeta(fr.traceTarget, VK_FORMAT_R8G8B8A8_UNORM), quadSampler);

            auto scale = mat4.scale(vec3(windowSize.to!float, 0));
            auto trans = mat4.translate(vec3(0, 0, 0));
            fr.quad.setVP(trans*scale, camera2d.V(), camera2d.P());
        }
    }
    void createDescriptors() {
        this.log("Creating descriptors...");

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
        this.log("Creating pipeline...");

        this.rtPipeline = new RayTracingPipeline(context)
            .withDSLayouts(descriptors.getAllLayouts())
            .withRaygenGroup(0)   
            .withMissGroup(1)    
            .withHitGroup(VK_RAY_TRACING_SHADER_GROUP_TYPE_TRIANGLES_HIT_GROUP_KHR,
                2,                      // closest
                VK_SHADER_UNUSED_KHR,   // any
                VK_SHADER_UNUSED_KHR    // intersection
            )
            .withShader(VK_SHADER_STAGE_RAYGEN_BIT_KHR,
                context.shaders.getModule("vulkan/test/raytracing/generate_rays.rgen"))
            .withShader(VK_SHADER_STAGE_MISS_BIT_KHR,
                context.shaders.getModule("vulkan/test/raytracing/miss.rmiss"))
            .withShader(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR,
                context.shaders.getModule("vulkan/test/raytracing/hit_closest.rchit"))
            .build();
    }
    /**
     *  Bottom Level Acceleration Structure
     */
    void buildBLAS() {

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

        // Upload vertices, indices and transforms to the GPU
        auto vertexBuffer = context.buffer(RT_VERTICES);
        auto indexBuffer = context.buffer(RT_INDEXES);
        auto transformBuffer = context.buffer(RT_TRANSFORMS);

        auto vertexDeviceAddress = getDeviceAddress(context.device, vertexBuffer);
        auto indexDeviceAddress = getDeviceAddress(context.device, indexBuffer);
        auto transformDeviceAddress = getDeviceAddress(context.device, transformBuffer);

        context.transfer().from(vertices.ptr, 0).to(vertexBuffer).size(vertices.length*Vertex.sizeof);
        context.transfer().from(indices.ptr, 0).to(indexBuffer).size(indices.length*ushort.sizeof);
        context.transfer().from(&transform, 0).to(transformBuffer).size(VkTransformMatrixKHR.sizeof);

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

        blas = new BLAS(context, "blas");
        blas.addTriangles(VK_GEOMETRY_OPAQUE_BIT_KHR, triangles, 1);
        
        auto cmd = device.allocFrom(vk.getGraphicsCP());
        cmd.beginOneTimeSubmit();
        blas.buildAll(cmd, VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR);
        cmd.end();
        submitAndWait(device, vk.getGraphicsQueue(), cmd);
        device.free(vk.getGraphicsCP(), cmd);
    }
    /**
     *  Top Level Acceleration Structure
     */
    void buildTLAS() {
        // We now have a BLAS
        auto instancesBuffer = context.buffer(RT_INSTANCES);
        auto instancesDeviceAddress = getDeviceAddress(context.device, instancesBuffer);

        this.log("instances device address = %s", instancesDeviceAddress);

        VkTransformMatrixKHR transform = identityTransformMatrix();
        this.log("transform = %s", transform);

        {
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

            // Copy instances to instancesBuffer on device
            context.transfer().from(&instance, 0).to(instancesBuffer).size(VkAccelerationStructureInstanceKHR.sizeof);
        }

        tlas = new TLAS(context, "tlas");
        tlas.addInstances(VK_GEOMETRY_OPAQUE_BIT_KHR, instancesDeviceAddress, 1);

        auto cmd = device.allocFrom(vk.getGraphicsCP());
        cmd.beginOneTimeSubmit();
        tlas.buildAll(cmd, VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR);
        cmd.end();
        submitAndWait(device, vk.getGraphicsQueue(), cmd);
        device.free(vk.getGraphicsCP(), cmd);

        // instances buffer can be freed here
    }
    void createRayTracingCommandBuffers() {
        this.log("Creating ray tracing command buffers...");

        foreach(i, fr; frameResources) {

            fr.cmd.begin();

            fr.cmd.bindPipeline(rtPipeline);
            fr.cmd.bindDescriptorSets(
                VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR,
                rtPipeline.layout,
                0,
                [descriptors.getSet(0, i.as!uint)],
                null
            );

            // Prepare the traceTarget image to be updated in the ray tracing shaders
            fr.cmd.pipelineBarrier(
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
            fr.cmd.traceRays(
                 &rtPipeline.raygenStridedDeviceAddressRegion,
                 &rtPipeline.missStridedDeviceAddressRegion,
                 &rtPipeline.hitStridedDeviceAddressRegion,
                 &rtPipeline.callableStridedDeviceAddressRegion,
                 windowSize.x, windowSize.y, 1);

            // Prepare the traceTarget image to be used in the Quad fragment shader
            fr.cmd.pipelineBarrier(
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

            fr.cmd.end();
        }
        this.log("Created %s ray tracing command buffers", frameResources.length);
    }
}
