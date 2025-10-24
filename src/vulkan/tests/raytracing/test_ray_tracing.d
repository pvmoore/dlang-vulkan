module vulkan.tests.raytracing.test_ray_tracing;

public:

import core.sys.windows.windows;
import core.runtime;
import std.string             : toStringz;
import std.stdio              : writefln;
import std.format             : format;
import std.datetime.stopwatch : StopWatch;
import std.random             : Mt19937, uniform01, unpredictableSeed;

import vulkan.all;

import vulkan.tests.raytracing.scenes.scene;
import vulkan.tests.raytracing.scenes.animation_scene;
import vulkan.tests.raytracing.scenes.cubes_scene;
import vulkan.tests.raytracing.scenes.mixed_scene;
import vulkan.tests.raytracing.scenes.path_tracing;
import vulkan.tests.raytracing.scenes.reflection_scene;
import vulkan.tests.raytracing.scenes.sdf_scene;
import vulkan.tests.raytracing.scenes.spheres_scene;
import vulkan.tests.raytracing.scenes.shadow_scene;
import vulkan.tests.raytracing.scenes.triangle_scene;

enum {
    NEAR = 0.01f,
    FAR  = 10000f,
    FOV  = 60f,

    RT_VERTICES      = "rt_vertices".as!BufID,
    RT_INDEXES       = "rt_indices".as!BufID,
    RT_TRANSFORMS    = "rt_transforms".as!BufID,
    RT_INSTANCES     = "rt_instances".as!BufID,
    RT_AABBS         = "rt_aabbs".as!BufID,
    RT_STORAGE       = "rt_storage".as!BufID,
    RT_ACCUM_COLOURS = "rt_accum_colours".as!BufID
}
struct FrameResource {
    DeviceImage traceTarget;
    Quad quad;
}

final class TestRayTracing : VulkanApplication {
public:
    this() {
        enum NAME = "Vulkan Ray Tracing";
        WindowProperties wprops = {
            width:          1920,   
            height:         1080,    
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
            shaderSrcDirectories:   ["shaders/", "shaders/vulkan/test/raytracing/"],          
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
            vprops.enableShaderPrintf  = true;
            vprops.enableGpuValidation = true;
        }

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

            if(cartesianCoordinates) cartesianCoordinates.destroy();

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
    override void selectFeaturesAndExtensions(FeaturesAndExtensions fae) {

        VkPhysicalDeviceRayTracingPipelineFeaturesKHR rtp = {
            sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PIPELINE_FEATURES_KHR,
            rayTracingPipeline: VK_TRUE
        };
        VkPhysicalDeviceAccelerationStructureFeaturesKHR as = {
            sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_FEATURES_KHR,
            accelerationStructure: VK_TRUE
        };
        VkPhysicalDeviceVulkan12Features v12 = {
            sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES,
            bufferDeviceAddress: VK_TRUE,
            descriptorIndexing: VK_TRUE,
            scalarBlockLayout: VK_TRUE
        };
        VkPhysicalDeviceVulkan13Features v13 = {
            sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_3_FEATURES,
            maintenance4: VK_TRUE
        };
        fae.addFeatures(v12, v13, rtp, as);

        auto actualAs = fae.getSupportedFeatures!VkPhysicalDeviceAccelerationStructureFeaturesKHR;
        
        if(actualAs.accelerationStructureHostCommands == VK_TRUE) {
            log(__FILE__, "Building acceleration structures on the host supported");
        } else {
            log(__FILE__, "Building acceleration structures on the host not supported");
        }

        fae.addExtensions(
            "VK_KHR_ray_tracing_pipeline", 
            "VK_KHR_acceleration_structure", 
            "VK_KHR_deferred_host_operations",
            "VK_EXT_scalar_block_layout",
            "VK_KHR_buffer_device_address",
            "VK_KHR_shader_float_controls",
            "VK_EXT_descriptor_indexing"
        );
    }
    override void deviceReady(VkDevice device) {
        this.device = device;
        initScene();
    }
    void update(Frame frame) {

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

        timer += frame.perSecond * 20;

        float3 point = float3(0, 0, 50).rotatedAroundY((timer*2).degrees);
        lightPos = point + float3(0, 100, -80);

        if(camera3d.wasModified()) {
            cartesianCoordinates.camera(camera3d);
        }
        scene.update(frame, lightPos);

        cartesianCoordinates.beforeRenderPass(frame);

        histogram1.tick(scene.getFrameTimeMs());
        histogram2.tick(scene.getTraceTimeMs());
    }
    override void render(Frame frame) {

        switchScene();

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

        if(scene.showCoordinates()) {
            cartesianCoordinates.insideRenderPass(frame);
        }

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
    Vulkan vk;
	VkDevice device;
    VulkanContext context;
    VkRenderPass renderPass;

    Camera2D camera2d;
    VkClearValue bgColour;
    uvec2 windowSize;

    FrameResource[] frameResources;
    VkSampler quadSampler;

    VkCommandPool traceCP;
    CartesianCoordinates cartesianCoordinates;
    Histogram histogram1;
    Histogram histogram2;

    float3 lightPos;
    float timer = 200;

    MouseDragging dragging;

    static struct MouseDragging {
        bool isDragging = false;
        float3 startCameraPos;
        float2 currentMousePos;
    }

    Scene[] scenes;
    Scene scene = null;
    int selectedScene = -1; // If this is not -1 then we are switching scenes

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
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("TRT_Local", 512.MB, VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT))
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
            64.MB);
        context.withBuffer(MemID.LOCAL, BufID.RT_SCRATCH,
            VK_BUFFER_USAGE_STORAGE_BUFFER_BIT |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT,
            64.MB);
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
            4.MB);
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
            32.MB);    
        context.withBuffer(MemID.LOCAL, RT_AABBS,
            VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT |
            VK_BUFFER_USAGE_TRANSFER_DST_BIT,
            16.MB); 
        context.withBuffer(MemID.LOCAL, RT_ACCUM_COLOURS,
            VK_BUFFER_USAGE_STORAGE_BUFFER_BIT,
            128.MB);         

        context.withFonts("resources/fonts/")
               .withImages("resources/images/")
               .withRenderPass(renderPass);

        this.log("shared mem available = %s", context.hasMemory(MemID.SHARED));

        this.log("%s", context);

        this.bgColour = clearColour(0.0f, 0, 0, 1);

        createSamplers();

        this.traceCP = vk.createCommandPool(vk.getGraphicsQueueFamily(), 
            VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT
        );

        this.histogram1 = new Histogram(2048, "%.3f", ImVec2(300, 40));
        this.histogram2 = new Histogram(2048, "%.3f", ImVec2(300, 40));

        createFrameResources();

        // Create all scenes
        scenes ~= new TriangleScene(context, traceCP, frameResources);
        scenes ~= new SpheresScene(context, traceCP, frameResources, 1, 1000);
        scenes ~= new SpheresScene(context, traceCP, frameResources, 2, 1000);
        scenes ~= new CubesScene(context, traceCP, frameResources, 1000);
        scenes ~= new MixedScene(context, traceCP, frameResources, 1000);
        scenes ~= new AnimationScene(context, traceCP, frameResources, AnimationScene.Option.SPHERES_TLASn_BLAS1, true);
        scenes ~= new AnimationScene(context, traceCP, frameResources, AnimationScene.Option.SPHERES_TLASn_BLAS1, false);
        scenes ~= new AnimationScene(context, traceCP, frameResources, AnimationScene.Option.CUBES_TLASn_BLAS1, true);
        scenes ~= new AnimationScene(context, traceCP, frameResources, AnimationScene.Option.CUBES_TLASn_BLAS1, false);
        scenes ~= new AnimationScene(context, traceCP, frameResources, AnimationScene.Option.CUBES_TLAS1_BLASn, true);
        scenes ~= new AnimationScene(context, traceCP, frameResources, AnimationScene.Option.CUBES_TLAS1_BLASn, false);
        scenes ~= new ShadowScene(context, traceCP, frameResources);
        scenes ~= new ReflectionScene(context, traceCP, frameResources);
        scenes ~= new PathTracingScene(context, traceCP, frameResources);
        scenes ~= new SDFScene(context, traceCP, frameResources);

        foreach(s; scenes) {
            s.initialise();
        }

        // Select scene 
        this.scene = scenes[14];

        cartesianCoordinates = new CartesianCoordinates(context, 2, 50)
            .camera(scene.getCamera());

        this.log("────────────────────────────────────────────────────────────────────");
        this.log(" Scene initialised");
        this.log("────────────────────────────────────────────────────────────────────");
    }
    void switchScene() {
        if(selectedScene == -1 || selectedScene >= scenes.length) return;

        log(__FILE__, "Changing to scene index %s", selectedScene);
        this.scene = scenes[selectedScene];

        cartesianCoordinates.camera(scene.getCamera());

        selectedScene = -1;
    }
    void create2DCamera() {
        this.camera2d = Camera2D.forVulkan(vk.windowSize());
    }
    void imguiFrame(Frame frame) {
        vk.imguiRenderStart(frame);

        auto vp = igGetMainViewport();
        igSetNextWindowPos(vp.WorkPos + ImVec2(5,5), ImGuiCond_Always, ImVec2(0.0, 0.0));
        igSetNextWindowSize(ImVec2(250, 135), ImGuiCond_Always);

        if(igBegin("Camera", null, ImGuiWindowFlags_None)) {

            auto camera3d = scene.getCamera();
            igText("Pos %.1f, %.1f, %.1f", camera3d.position().x, camera3d.position().y, camera3d.position().z);
            igText("Dir %.1f, %.1f, %.1f", camera3d.forward().x, camera3d.forward().y, camera3d.forward().z);
            igText("Up  %.1f, %.1f, %.1f", camera3d.up().x, camera3d.up().y, camera3d.up().z);
        }
        igEnd();

        // Select scene using combo box
        igSetNextWindowPos(vp.WorkPos + ImVec2(5,145), ImGuiCond_Always, ImVec2(0.0, 0.0));
        igSetNextWindowSize(ImVec2(250, 0), ImGuiCond_Always);

        if(igBegin("Scene", null, ImGuiWindowFlags_None)) {

            igPushItemWidth(235);

            string[] sceneNames = scenes.map!(it=>it.name()).array;
            igoCombo("##scene_combo", scene.name(), sceneNames, scenes.indexOf(scene).as!uint, (i, name) {
                selectedScene = i.as!int;
            });

            igPopItemWidth();

            igPushTextWrapPos(245);
            igText(scene.description().toStringz());
            igPopTextWrapPos();


            if(igCollapsingHeader("Frame time", ImGuiTreeNodeFlags_DefaultOpen)) {
                igText("%.4f ms", scene.getFrameTimeMs());
                histogram1.render();
            }
            if(igCollapsingHeader("Trace time", ImGuiTreeNodeFlags_DefaultOpen)) {
                igText("%.4f ms", scene.getTraceTimeMs());
                histogram2.render();
            }
        }
        igEnd();

        float2 pos = vp.WorkPos.as!float2 + float2(0, vp.WorkSize.y) + float2(5,-44);
        float2 size = float2(vp.WorkSize.x - 10, 40);

        igSetNextWindowPos(pos.as!ImVec2, ImGuiCond_Always, ImVec2(0.0, 0.0));
        igSetNextWindowSize(size.as!ImVec2, ImGuiCond_Always);

        if(igBegin("Info", null, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize)) {
            igText("Drag the screen with the LMB, scroll wheel to zoom in/out");
        }
        igEnd();

        scene.imguiFrame(frame);

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
}
