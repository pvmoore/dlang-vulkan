module vulkan.tests.test_graphs;

import core.cpuid: processor;
import core.sys.windows.windows;
import core.runtime;
import std.string : toStringz, fromStringz;
import std.stdio  : writefln;
import std.format : format;
import std.datetime.stopwatch : StopWatch;

import vulkan.all;

/**
 * Graph display
 */
final class TestGraphs : VulkanApplication {
public:
    this() {
        enum NAME = "Graphs";
        WindowProperties wprops = {
            width:          1600,
            height:         1000,
            fullscreen:     false,
            vsync:          false,
            title:          NAME,
            icon:           "resources/images/logo.png",
            showWindow:     false,
            frameBuffers:   3,
            titleBarFps:    true
        };
        VulkanProperties vprops = {
            appName: NAME,
            shaderSrcDirectories: ["shaders/"],
            shaderDestDirectory:  "resources/shaders/",
            apiVersion: VK_API_VERSION_1_4,
            shaderSpirvVersion:   "1.6",
            useDynamicRendering: true,
            imgui: {
                enabled: true,
                configFlags: 0
                    | ImGuiConfigFlags_NoMouseCursorChange
                    | ImGuiConfigFlags_DockingEnable
                    | ImGuiConfigFlags_ViewportsEnable,
                fontPaths: [
                    "resources/fonts/Roboto-Regular.ttf"
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

            if(vertices) vertices.destroy();
            if(ubo) ubo.destroy();
            if(pipeline) pipeline.destroy();
            if(descriptors) descriptors.destroy();
            if(context) context.destroy();
	    }
		vk.destroy();
    }
    override void run() {
        vk.mainLoop();
    }
    override VkRenderPass getRenderPass(VkDevice device) {
        throwIf(true, "Dynamic rendering is enabled, no render pass should be created");
        return null;
    }
    override void selectFeaturesAndExtensions(FeaturesAndExtensions fae) {
        VkPhysicalDeviceVulkan11Features v11 = {
            sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_FEATURES
        };
        VkPhysicalDeviceVulkan12Features v12 = {
            sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES,
            scalarBlockLayout: VK_TRUE
        };
        VkPhysicalDeviceVulkan13Features v13 = {
            sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_3_FEATURES
        };
        VkPhysicalDeviceVulkan14Features v14 = {
            sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_4_FEATURES
        };

        VkPhysicalDeviceFeatures v10 = {
            wideLines: VK_TRUE
        };
        fae.addFeatures(v11, v12, v13, v14, v10);
    }
    override void deviceReady(VkDevice device) {
        this.device = device;
        initScene();
    }
    void update(Frame frame) {
        auto b = frame.resource.adhocCB;
        ubo.upload(b);
        vertices.upload(b);
    }
    override void render(Frame frame) {
        auto res = frame.resource;
	    auto b = res.adhocCB;
	    b.beginOneTimeSubmit();

        update(frame);

        // Switch the frame image to VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
        b.pipelineBarrier(
            VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
            VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    frame.image,
                    0,
                    VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT,
                    VK_IMAGE_LAYOUT_UNDEFINED,
                    VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
                )
            ]
        );

        b.beginDynamicRendering(
            frame.imageView,
            toVkRect2D(0,0, vk.windowSize.toVkExtent2D),
            bgColour);

        // We are inside the render pass here

        drawGraphs(b);
        imguiFrame(frame);

        // Exit the render pass here
        b.endDynamicRendering();

        // Switch the frame image to VK_IMAGE_LAYOUT_PRESENT_SRC_KHR
        b.pipelineBarrier(
            VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
            VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    frame.image,
                    VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT,
                    0,
                    VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                    VK_IMAGE_LAYOUT_PRESENT_SRC_KHR
                )
            ]
        );

        b.end();

        /// Submit our render buffer
        vk.getGraphicsQueue().submit(
            [b],
            [res.imageAvailable],
            [VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT],
            [res.renderFinished],  // signal semaphores
            res.fence              // fence
        );
    }
private:
    Vulkan vk;
	VkDevice device;
    VulkanContext context;
    VkRenderPass renderPass;

    Camera2D camera;
    VkClearValue bgColour;

    struct Vertex {
        float2 pos;
    }
    struct UBO { //static assert(UBO.sizeof%16==0);
        mat4 model;
        mat4 viewProj;
        uint selector;
    }

    GPUData!UBO ubo;
    GPUData!Vertex vertices;
    Descriptors descriptors;
    GraphicsPipeline pipeline;
    uint selected;

    void initScene() {
        this.camera = Camera2D.forVulkan(vk.windowSize);

        auto mem = new MemoryAllocator(vk);

        auto maxLocal =
            mem.builder(0)
                .withAll(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                .withoutAll(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT)
                .maxHeapSize();

        this.log("Max local memory = %s MBs", maxLocal / 1.MB);

        this.context = new VulkanContext(vk)
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("Local", 256.MB))
          //.withMemory(MemID.SHARED, mem.allocStdShared("Shared", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("Staging", 32.MB));

        context.withBuffer(MemID.LOCAL, BufID.VERTEX, VK_BUFFER_USAGE_VERTEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 32.MB)
               .withBuffer(MemID.LOCAL, BufID.INDEX, VK_BUFFER_USAGE_INDEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 32.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM, VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 1.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, 32.MB);

        context.withFonts("resources/fonts/")
               .withImages("resources/images/")
               .withRenderPass(renderPass);

        this.log("shared mem available = %s", context.hasMemory(MemID.SHARED));

        this.log("%s", context);

        bgColour = clearColour(0,0,0,1);

        createUBO();
        createVertices();
        createDescriptors();
        createPipeline();
    }
    void createUBO() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true)
            .initialise();

        auto w = vk.windowSize.to!float;
        auto aspect = w.y/w.x;

        float2 size = float2(800 * aspect, 800 * aspect);
        float2 pos  = float2(w.x/2-size.x/2, 20);

        auto scale = mat4.scale(float3(size, 0));
        auto trans = mat4.translate(float3(pos, 0));

        ubo.write((u) {
            u.model     = trans * scale;
            u.viewProj  = camera.VP();
            u.selector  = 0;
        });
    }
    void createVertices() {
        //
        // 0----1
        // |\   |
        // | \  |
        // |  \ |
        // |   \|
        // 3----2
        Vertex[] verticesArray = [
            Vertex(float2(0,0)),    // 0,1,2
            Vertex(float2(1,0)),
            Vertex(float2(1,1)),

            Vertex(float2(0,0)),    // 0,2,3
            Vertex(float2(1,1)),
            Vertex(float2(0,1)),
        ];

        this.vertices = new GPUData!Vertex(context, BufID.VERTEX, true, verticesArray.length.as!uint)
            .initialise();

        this.vertices.write(verticesArray);
    }
    void createDescriptors() {
        /**
         *  0 -> UBO
         */
        this.descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
                   .add(ubo)
                   .write();
    }
    void createPipeline() {
        auto shader = context.shaders().getModule("vulkan/graphs/graphs.slang");

        this.pipeline = new GraphicsPipeline(context)
            .withVertexInputState!Vertex(VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST)
            .withDSLayouts(descriptors.getAllLayouts())
            .withVertexShader(shader, null, "vsmain")
            .withFragmentShader(shader, null, "fsmain")
            //.withStdColorBlendState()
            .build();
    }
    void drawGraphs(VkCommandBuffer b) {
        b.bindPipeline(pipeline);
        b.bindDescriptorSets(
            VK_PIPELINE_BIND_POINT_GRAPHICS,
            pipeline.layout,
            0,                              // first set
            [descriptors.getSet(0,0)],
            null                            // dynamic offsets
        );
        b.bindVertexBuffers(
            0,                                      // first binding
            [vertices.getDeviceBuffer().handle],    // buffers
            [vertices.getDeviceBuffer().offset]);   // offsets

        b.draw(6, 1, 0, 0);
    }
    void imguiFrame(Frame frame) {
        vk.imguiRenderStart(frame);

        // This will turn the main window into a dockspace
        // which means it won't have a menu bar.
        // If you don't want this behaviour then comment the line below
        igDockSpaceOverViewport(0, null, ImGuiDockNodeFlags_PassthruCentralNode, null);

        bool my_tool_active;
        if(igBegin("Selector", &my_tool_active, ImGuiWindowFlags_MenuBar)) {

            igPushItemWidth(235);

            string[] options = [
                "x",
                "x*x",
                "x*x*x",
                "x*x*x*x",
                "1-x",
                "1-x*x",
                "1-x*x*x",
                "(1-x)*(1-x)",
                "1 - (1-x)*(1-x)",
                "1 - (1-x)*(1-x)*(1-x)",
            ];
            igoCombo("##selector_combo", options[selected], options, selected, (i, name) {
                selected = i.as!int;
                ubo.write((u) {
                    u.selector = selected;
                });
            });

            igPopItemWidth();
        }
        igEnd();


        vk.imguiRenderEnd(frame);
    }
}
