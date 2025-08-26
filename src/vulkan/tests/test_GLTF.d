module vulkan.tests.test_GLTF;

import vulkan.all;

import core.cpuid: processor;
import core.sys.windows.windows;
import core.runtime;
import std.string : toStringz, fromStringz;
import std.stdio  : writefln;
import std.format : format;
import std.datetime.stopwatch : StopWatch;

/**
 * Example GLTF usage.
 */
final class TestGLTF : VulkanApplication {
public:
    this() {
        enum NAME = "Vulkan GLTF Test";
        WindowProperties wprops = {
            width:          2000,
            height:         1200,
            fullscreen:     false,
            vsync:          false,
            title:          NAME,
            icon:           "resources/images/logo.png",
            showWindow:     false,
            frameBuffers:   3,
            titleBarFps:    true
        };
        ImguiOptions imgui = {
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
        };
        VulkanProperties vprops = {
            appName: NAME,
            shaderSrcDirectories: ["shaders/"],
            shaderDestDirectory:  "resources/shaders/",
            apiVersion: VK_API_VERSION_1_3,
            shaderSpirvVersion:   "1.6",
            features: DeviceFeatures.Features.RayTracingPipeline |
                      DeviceFeatures.Features.AccelerationStructure |
                      DeviceFeatures.Features.Vulkan11 |
                      DeviceFeatures.Features.Vulkan12 |
                      DeviceFeatures.Features.Vulkan13,
            imgui: imgui    
        };

        debug {
            vprops.enableShaderPrintf  = true;
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

        // Use scalar UBO and storage buffer layouts for convenience 
        vprops.addDeviceExtension("VK_EXT_scalar_block_layout");

		this.vk = new Vulkan(this, wprops, vprops);
        vk.initialise();
        vk.showWindow();
    }
    override void destroy() {
	    if(!vk) return;
	    if(device) {
	        vkDeviceWaitIdle(device);

            if(context) context.dumpMemory();

            if(tlas) tlas.destroy();
            if(gltfModel) gltfModel.destroy();

            if(cartesianCoordinates) cartesianCoordinates.destroy();
            if(quadSampler) device.destroySampler(quadSampler);
            foreach(r; frameResources) {
                r.quad.destroy();
                r.traceTarget.free();
            }
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
    override void deviceReady(VkDevice device) {
        this.device = device;
        initScene();
    }
    void update(Frame frame) {

        float zoomDelta = 300 * frame.perSecond;

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
        this.lightPos = point + float3(0, 100, -80);
        gltfModel.lightPosition(lightPos);

        if(camera3d.wasModified()) {
            camera3d.resetModifiedState();
            gltfModel.camera(camera3d);
            cartesianCoordinates.camera(camera3d);
        }
        cartesianCoordinates.beforeRenderPass(frame);
    }
    override void render(Frame frame) {
        auto res = frame.resource;
        auto resource = &frameResources[frame.imageIndex];
        auto rayTraceCommand = gltfModel.getCommandBuffer(frame);
	    auto b = res.adhocCB;

	    b.beginOneTimeSubmit();

        update(frame);

        // begin the render pass
        b.beginRenderPass(
            renderPass,
            frame.frameBuffer,
            toVkRect2D(0,0, vk.windowSize.toVkExtent2D),
            [ bgColour ],
            VK_SUBPASS_CONTENTS_INLINE
            //VK_SUBPASS_CONTENTS_SECONDARY_COMMAND_BUFFERS
        );

        resource.quad.insideRenderPass(frame);
        cartesianCoordinates.insideRenderPass(frame);
        imguiFrame(frame);

        b.endRenderPass();
        b.end();

        /// Submit our render buffer
        vk.getGraphicsQueue().submit(
            [rayTraceCommand, b],
            [res.imageAvailable],
            [VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT],
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
    static struct FrameResource {
        DeviceImage traceTarget;
        Quad quad;
    }
    static struct MouseDragging {
        bool isDragging = false;
        float3 startCameraPos;
        float2 currentMousePos;
    }
    MouseDragging dragging;

    Vulkan vk;
	VkDevice device;
    VulkanContext context;
    VkRenderPass renderPass;

    Camera2D camera2d;
    Camera3D camera3d;
    VkClearValue bgColour;

    GLTFModelRT gltfModel;
    TLAS tlas;
    FrameResource[] frameResources;
    VkSampler quadSampler;
    CartesianCoordinates cartesianCoordinates;
    float timer = 200;
    float3 lightPos = float3(100,100,-100);

    void initScene() {
        createCameras();

        auto mem = new MemoryAllocator(vk);

        auto maxLocal =
            mem.builder(0)
                .withAll(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                .withoutAll(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT)
                .maxHeapSize();

        this.log("Max local memory = %s MBs", maxLocal / 1.MB);

        this.context = new VulkanContext(vk)
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("G2D_Local", 1024.MB, VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT))
          //.withMemory(MemID.SHARED, mem.allocStdShared("G2D_Shared", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("G2D_Staging", 64.MB));

        context.withBuffer(MemID.LOCAL, BufID.VERTEX, VK_BUFFER_USAGE_VERTEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 8.MB)
               .withBuffer(MemID.LOCAL, BufID.INDEX, VK_BUFFER_USAGE_INDEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 8.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM, VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 1.MB);

        // Staging upload buffer
        context.withBuffer(MemID.STAGING, BufID.STAGING, 
            VK_BUFFER_USAGE_TRANSFER_SRC_BIT, 
            64.MB);

        // Storage buffer for triangle data
        context.withBuffer(MemID.LOCAL, BufID.STORAGE, 
            VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | 
            VK_BUFFER_USAGE_TRANSFER_DST_BIT, 
            128.MB);

        // General ray tracing buffers
        context.withBuffer(MemID.LOCAL, BufID.RT_ACCELERATION,
            VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT,
            128.MB);
        context.withBuffer(MemID.LOCAL, BufID.RT_SCRATCH,
            VK_BUFFER_USAGE_STORAGE_BUFFER_BIT |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT,
            64.MB);
        context.withBuffer(MemID.LOCAL, BufID.RT_SBT,
            VK_BUFFER_USAGE_SHADER_BINDING_TABLE_BIT_KHR |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT |
            VK_BUFFER_USAGE_TRANSFER_DST_BIT,
            4.MB);

        // Application specific ray tracing buffers
        context.withBuffer(MemID.LOCAL, BufID.RT_VERTICES,
            VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT |
            VK_BUFFER_USAGE_VERTEX_BUFFER_BIT |
            VK_BUFFER_USAGE_TRANSFER_DST_BIT,
            64.MB);
        context.withBuffer(MemID.LOCAL, BufID.RT_INDEXES,
            VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT |
            VK_BUFFER_USAGE_INDEX_BUFFER_BIT |
            VK_BUFFER_USAGE_TRANSFER_DST_BIT,
            32.MB);
        context.withBuffer(MemID.LOCAL, BufID.RT_TRANSFORMS,
            VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT |
            VK_BUFFER_USAGE_TRANSFER_DST_BIT,
            4.MB);
        context.withBuffer(MemID.LOCAL, BufID.RT_INSTANCES,
            VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR |
            VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT |
            VK_BUFFER_USAGE_TRANSFER_DST_BIT,
            4.MB);    

        context.withFonts("resources/fonts/")
               .withImages("resources/images/")
               .withRenderPass(renderPass);

        this.log("shared mem available = %s", context.hasMemory(MemID.SHARED));

        this.log("%s", context);

        this.bgColour = clearColour(0.0f,0,0,1);

        this.cartesianCoordinates = new CartesianCoordinates(context, 2, 50)
            .camera(camera3d);

        createSamplers();
        createFrameResources();
        createTlas();

        string boxGltf = "external/glTF-Sample-Assets/models/Box/glTF/Box.gltf";
        string boxTexturedGltf = "external/glTF-Sample-Assets/models/BoxTextured/glTF/BoxTextured.gltf";

        this.gltfModel = new GLTFModelRT(context, tlas, frameResources.map!(r => r.traceTarget.handle).array(), 
                                                        frameResources.map!(r => r.traceTarget.view).array())
            .scale(float3(10,10,10))
            .translate(float3(0,0,0))
            .camera(camera3d)
            .lightPosition(lightPos)
            .modelDataFromFile(boxTexturedGltf);
    }
    void createCameras() {
        this.camera2d = Camera2D.forVulkan(vk.windowSize);

        this.camera3d = Camera3D.forVulkan(vk.windowSize(), vec3(0,0,-100), vec3(0,0,0));
        this.camera3d.fovNearFar(FOV.degrees, NEAR, FAR);
        this.camera3d.rotateZRelative(180.degrees());
    }
    void createSamplers() {
        this.quadSampler = device.createSampler(samplerCreateInfo((info){
            info.addressModeU = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE;
            info.addressModeV = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE;
        }));
    }
    void createFrameResources() {

        auto windowSize = vk.windowSize();

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
    void createTlas() {
        // Create the TLAS but don't add any instances or call create()
        this.tlas = new TLAS(context, "tlas_gltf", VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR);
    }
    void imguiFrame(Frame frame) {
        vk.imguiRenderStart(frame);

        auto vp = igGetMainViewport();
        igSetNextWindowPos(vp.WorkPos + ImVec2(5,5), ImGuiCond_Always, ImVec2(0.0, 0.0));
        igSetNextWindowSize(ImVec2(280, 145), ImGuiCond_Always);

        if(igBegin("Camera", null, ImGuiWindowFlags_None)) {

            igText("Pos %.1f, %.1f, %.1f", camera3d.position().x, camera3d.position().y, camera3d.position().z);
            igText("Dir %.1f, %.1f, %.1f", camera3d.forward().x, camera3d.forward().y, camera3d.forward().z);
            igText("Up  %.1f, %.1f, %.1f", camera3d.up().x, camera3d.up().y, camera3d.up().z);
            igText("Light %.1f, %.1f, %.1f", lightPos.x, lightPos.y, lightPos.z);
        }
        igEnd();

        gltfModel.imguiFrame(frame);

/*
        // Select scene using combo box
        igSetNextWindowPos(vp.WorkPos + ImVec2(5,145), ImGuiCond_Always, ImVec2(0.0, 0.0));
        igSetNextWindowSize(ImVec2(250, 0), ImGuiCond_Always);

        if(igBegin("Model", null, ImGuiWindowFlags_None)) {

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
*/

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
}
