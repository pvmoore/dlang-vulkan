module vulkan.tests.raytracing.test_ray_tracing;

import core.sys.windows.windows;
import core.runtime;
import std.string             : toStringz;
import std.stdio              : writefln;
import std.format             : format;
import std.datetime.stopwatch : StopWatch;
import std.random             : Mt19937, uniform01, unpredictableSeed;

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
            apiVersion: VK_API_VERSION_1_3,
            features: DeviceFeatures.Features.RayTracingPipeline |
                      DeviceFeatures.Features.AccelerationStructure |
                      DeviceFeatures.Features.BufferDeviceAddress,
            shaderSpirvVersion: "1.6",
            imgui: {
                enabled: true,
                configFlags:
                    ImGuiConfigFlags_NoMouseCursorChange |
                    ImGuiConfigFlags_DockingEnable |
                    ImGuiConfigFlags_ViewportsEnable,
                fontPaths: [
                    "resources/fonts/RobotoMono-Medium.ttf"
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

            foreach(s; scenes) s.destroy();

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
            throwIf(f.rayTracingPipeline == VK_FALSE, "Hardware ray tracing is not supported on your device");
        });
        deviceFeatures.apply((ref VkPhysicalDeviceAccelerationStructureFeaturesKHR f) {
            if(f.accelerationStructureHostCommands) {
                log("Building acceleration structures on the host supported");
            } else {
                log("Building acceleration structures on the host not supported");
            }
        });
        deviceFeatures.apply((ref VkPhysicalDeviceBufferDeviceAddressFeaturesEXT f) {
            throwIf(f.bufferDeviceAddress == VK_FALSE, "Buffer Device Address feature is not supported on your device");
        });
    }
    override void deviceReady(VkDevice device) {
        this.device = device;
        initScene();
    }
    void update(Frame frame) {
        if(!scene) return;

        float zoomDelta = 100 * frame.perSecond;

        auto camera3d = scene.getCamera();
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

        scene.update(frame);
    }
    override void render(Frame frame) {
        auto res = frame.resource;
        auto resource = &frameResources[frame.imageIndex];
        auto rayTraceCommand = scene.getCommandBuffer(frame.imageIndex);

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
    enum {
        RT_VERTICES     = "rt_vertices".as!BufID,
        RT_INDEXES      = "rt_indices".as!BufID,
        RT_TRANSFORMS   = "rt_transforms".as!BufID,
        RT_INSTANCES    = "rt_instances".as!BufID,
        RT_AABBS        = "rt_aabbs".as!BufID,
        RT_STORAGE      = "rt_storage".as!BufID
    }

    Vulkan vk;
	VkDevice device;
    VulkanContext context;
    VkRenderPass renderPass;

    Camera2D camera2d;
    VkClearValue bgColour;
    uvec2 windowSize;

    static struct FrameResource {
        DeviceImage traceTarget;
        Quad quad;
    }

    FrameResource[] frameResources;
    VkSampler quadSampler;

    VkCommandPool traceCP;

    MouseDragging dragging;

    static struct MouseDragging {
        bool isDragging = false;
        float3 startCameraPos;
        float2 currentMousePos;
    }

    Scene[] scenes;
    Scene scene = null;

    void initScene() {
        this.log("────────────────────────────────────────────────────────────────────");
        this.log(" Initialising scene");
        this.log("────────────────────────────────────────────────────────────────────");
        this.windowSize = cast(uvec2)vk.swapchain.extent;
        create2DCamera();

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

        // General ray tracing buffers
        context.withBuffer(MemID.LOCAL, BufID.RT_ACCELERATION,
            VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT,
            32.MB);
        context.withBuffer(MemID.LOCAL, BufID.RT_SCRATCH,
            VK_BUFFER_USAGE_STORAGE_BUFFER_BIT |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT,
            32.MB);
        context.withBuffer(MemID.LOCAL, BufID.RT_SBT,
            VK_BUFFER_USAGE_SHADER_BINDING_TABLE_BIT_KHR |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT |
            VK_BUFFER_USAGE_TRANSFER_DST_BIT,
            2.MB);

        // Application specific ray tracing buffers
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
        context.withBuffer(MemID.LOCAL, RT_STORAGE,
            VK_BUFFER_USAGE_STORAGE_BUFFER_BIT |
            VK_BUFFER_USAGE_TRANSFER_DST_BIT,
            16.MB);    
        context.withBuffer(MemID.LOCAL, RT_AABBS,
            VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT |
            VK_BUFFER_USAGE_TRANSFER_DST_BIT,
            16.MB);     

        context.withFonts("resources/fonts/")
               .withImages("resources/images/")
               .withRenderPass(renderPass);

        this.log("shared mem available = %s", context.hasMemory(MemID.SHARED));

        this.log("%s", context);

        this.bgColour = clearColour(0.0f, 0, 0, 1);

        createSamplers();

        this.traceCP = vk.createCommandPool(vk.getGraphicsQueueFamily().index, 0);

        createFrameResources();

        // Create all scenes
        scenes ~= new TriangleScene();
        scenes ~= new SpheresScene(1, 1000);
        scenes ~= new SpheresScene(2, 1000);

        foreach(s; scenes) {
            s.initialise();
        }

        // Select scene 0
        this.scene = scenes[2];

        this.log("────────────────────────────────────────────────────────────────────");
        this.log(" Scene initialised");
        this.log("────────────────────────────────────────────────────────────────────");
    }
    void switchScene(uint newSceneIndex) {
        if(newSceneIndex >= scenes.length) return;

        log("Changing to scene index %s", newSceneIndex);
        this.scene = scenes[newSceneIndex];
    }
    void create2DCamera() {
        this.camera2d = Camera2D.forVulkan(vk.windowSize());
    }
    void imguiFrame(Frame frame) {
        vk.imguiRenderStart(frame);

        auto vp = igGetMainViewport();
        igSetNextWindowPos(vp.WorkPos + ImVec2(5,5), ImGuiCond_Always, ImVec2(0.0, 0.0));
        igSetNextWindowSize(ImVec2(250, 200), ImGuiCond_Always);

        if(igBegin("Camera", null, ImGuiWindowFlags_None)) {

            auto camera3d = scene.getCamera();
            igText("Pos %.1f, %.1f, %.1f", camera3d.position().x, camera3d.position().y, camera3d.position().z);
            igText("Dir %.1f, %.1f, %.1f", camera3d.forward().x, camera3d.forward().y, camera3d.forward().z);
            igText("Up  %.1f, %.1f, %.1f", camera3d.up().x, camera3d.up().y, camera3d.up().z);
        }
        igEnd();

        // Select scene using combo box
        igSetNextWindowPos(vp.WorkPos + ImVec2(5,200), ImGuiCond_Always, ImVec2(0.0, 0.0));
        igSetNextWindowSize(ImVec2(250, 0), ImGuiCond_Always);

        if(igBegin("Scene", null, ImGuiWindowFlags_None)) {
            if(igBeginCombo("##scene_combo", scene.name().toStringz(), ImGuiComboFlags_HeightLargest)) {
                foreach(i, s; scenes) {
                    bool isSelected = scene is s;
                    if(igSelectable_Bool(s.name().toStringz(), isSelected, ImGuiSelectableFlags_None, ImVec2(0,0))) {
                        switchScene(i.as!int);
                    }
              
                    if(isSelected) {
                        igSetItemDefaultFocus();
                    }
                }
                igEndCombo();
            }
        }
        igPushTextWrapPos(245);
        igText(scene.description().toStringz());
        igPopTextWrapPos();
        igEnd();

        float2 pos = vp.WorkPos.as!float2 + float2(0, vp.WorkSize.y) + float2(5,-44);
        float2 size = float2(vp.WorkSize.x - 10, 40);

        igSetNextWindowPos(pos.as!ImVec2, ImGuiCond_Always, ImVec2(0.0, 0.0));
        igSetNextWindowSize(size.as!ImVec2, ImGuiCond_Always);

        if(igBegin("Info", null, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize)) {
            igText("Drag the screen with the LMB, scroll wheel to zoom in/out");
        }
        igEnd();

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

        renderPass = .createRenderPass(
            device,
            [colorAttachment],
            [subpass],
            subpassDependency2()
        );
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

    //──────────────────────────────────────────────────────────────────────────────────────────────────

    abstract class Scene {
        final Descriptors getDescriptors() { return descriptors; }
        final RayTracingPipeline getPipeline() { return rtPipeline; }
        final Camera3D getCamera() { return camera3d; }
        final VkCommandBuffer getCommandBuffer(uint index) { return cmdBuffers[index]; }

        abstract string name();
        abstract string description();
        abstract void initialise();
        abstract void update(Frame frame);

        void destroy() {
            if(rtPipeline) rtPipeline.destroy();
            if(descriptors) descriptors.destroy();
            if(tlas) tlas.destroy();
            foreach(cmd; cmdBuffers) device.free(traceCP, cmd);
        }
    protected:
        Descriptors descriptors;
        RayTracingPipeline rtPipeline;
        TLAS tlas;
        Camera3D camera3d;
        VkCommandBuffer[] cmdBuffers;

        void recordCommandBuffers() {

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
    }

    //──────────────────────────────────────────────────────────────────────────────────────────────────

    final class TriangleScene : Scene {
        override string name() { return "Triangle"; }
        override string description() { return "A single triangle"; }

        override void initialise() {
            createCamera();
            createBLAS();
            createTLAS();
            createUBO();
            createDescriptors();
            createPipeline();
            recordCommandBuffers();
        }
        override void destroy() {
            super.destroy();
            if(ubo) ubo.destroy();
            if(blas) blas.destroy();
        }
        override void update(Frame frame) {
            auto cmd = frame.resource.adhocCB;

            if(camera3d.wasModified()) {
                camera3d.resetModifiedState();
                updateUBO();
            }
            ubo.upload(cmd);
        }
    private:
        GPUData!UBO ubo;
        BLAS blas;

        static struct UBO { 
            mat4 viewInverse;
            mat4 projInverse;
        }
        void createCamera() {
            this.camera3d = Camera3D.forVulkan(vk.windowSize(), vec3(0,0,-2.5), vec3(0,0,0));
            this.camera3d.fovNearFar(FOV.degrees, NEAR, FAR);
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

            this.blas = new BLAS(context, "blas");
            blas.addTriangles(VK_GEOMETRY_OPAQUE_BIT_KHR, triangles, 1);
            
            auto cmd = device.allocFrom(vk.getGraphicsCP());
            cmd.beginOneTimeSubmit();
            blas.buildAll(cmd, VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR);
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
            
            this.tlas = new TLAS(context, "tlas");
            tlas.addInstances(VK_GEOMETRY_OPAQUE_BIT_KHR, instancesDeviceAddress, 1);

            auto cmd = device.allocFrom(vk.getGraphicsCP());
            cmd.beginOneTimeSubmit();
            tlas.buildAll(cmd, VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR);
            cmd.end();
            submitAndWait(device, vk.getGraphicsQueue(), cmd);
            device.free(vk.getGraphicsCP(), cmd);

            // instances buffer can be freed here
        }
    }

    //──────────────────────────────────────────────────────────────────────────────────────────────────

    final class SpheresScene : Scene {
        //
        // Option 1 : Create multiple sphere AABBs in a single BLAS with a single TLAS instance.
        // Option 2 : Create a single sphere AABB in a single BLAS and multiple TLAS instances pointing to the same BLAS.
        //
        this(int option, int numSpheres) {
            throwIf(option != 1 && option != 2);
            this.option = option;
            this.numSpheres = numSpheres;
        }

        override string name() { return "Spheres %s".format(option); }
        override string description() { 
            if(option == 1) return "BLAS containing multiple spheres, single TLAS instance";
            if(option == 2) return "BLAS containing a single sphere, multiple TLAS instances";
            assert(false);
        }

        override void initialise() {
            createCamera();
            createSpheres();
            createBLAS();
            createTLAS();
            createUBO();
            createSphereDataBuffer();
            createDescriptors();
            createPipeline();
            recordCommandBuffers();
        }
        override void destroy() {
            super.destroy();
            if(ubo) ubo.destroy();
            if(sphereData) sphereData.destroy();
            if(blas) blas.destroy();
        }
        override void update(Frame frame) {
            auto cmd = frame.resource.adhocCB;

            if(camera3d.wasModified()) {
                camera3d.resetModifiedState();
                updateUBO();
            }

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
            float4 lightPos;
            uint option;
        }
        static struct Sphere {
            float3 center;
            float radius;
            float4 colour;
        }
        static struct AABB {
            float3 min;
            float3 max;
        }
        void createCamera() {
            this.camera3d = Camera3D.forVulkan(vk.windowSize(), vec3(0,0,120), vec3(0,0,0));
            this.camera3d.fovNearFar(FOV.degrees, NEAR, FAR);
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
                    float4 colour = float4(uniform01(rng) + 0.2, uniform01(rng) + 0.2, uniform01(rng) + 0.2, 1);
                    
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
                    float4 colour = float4(uniform01(rng) + 0.2, uniform01(rng) + 0.2, uniform01(rng) + 0.2, 1);
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

                float timer = .85;

                import std.math : sin, cos;

                float toRadians(float degrees) {
                    return degrees * 0.01745329251994329576923690768489;
                }

                u.lightPos = float4(
                    cos(toRadians(timer * 360.0f)) * 60.0f, 
                    //0.0f, 
                    25.0f + sin(toRadians(timer * 360.0f)) * 60.0f, 
                    25f,
                    0.0f);
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

            this.blas = new BLAS(context, "blas");
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
                    instance.setFlags(VK_GEOMETRY_INSTANCE_TRIANGLE_FACING_CULL_DISABLE_BIT_KHR);
                    instances ~= instance;
                }
            } 

            auto instancesSize = VkAccelerationStructureInstanceKHR.sizeof * instances.length;
            SubBuffer instancesBuffer = context.buffer(RT_INSTANCES).alloc(instancesSize);
            auto instancesDeviceAddress = getDeviceAddress(device, instancesBuffer);
            context.transfer().from(instances.ptr, 0)
                              .to(instancesBuffer)
                              .size(instancesSize);

            this.tlas = new TLAS(context, "tlas");
            tlas.addInstances(VK_GEOMETRY_OPAQUE_BIT_KHR, instancesDeviceAddress, instances.length.as!uint);

            auto cmd = device.allocFrom(vk.getGraphicsCP());
            cmd.beginOneTimeSubmit();
            tlas.buildAll(cmd, VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR);
            cmd.end();
            submitAndWait(device, vk.getGraphicsQueue(), cmd);
            device.free(vk.getGraphicsCP(), cmd);
        }
    }
}
