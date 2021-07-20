module vulkan.vulkan;
/**
 *  Todo:
 *        Try using this syntax for infos:
 *        VkDescriptorPoolSize s = {
 *            descriptorCount : 1
 *        };
 *
 *        If using dyanamic command buffers because of push constants:
 *          If the push constants don't change every frame it might
 *          be worthwhile baking the command buffer when the constants
 *          change and using them statically until the next change. This
 *          might work well for Text for example.
 *
 *        Updating uniform buffers may really benefit from using
 *        shared memory.
 */
import vulkan.all;

__gshared Vulkan g_vulkan;

final class Vulkan {
private:
    bool isInitialised;
    uint prevFrameIndex;
    float currentFPS = 0;
    GLFWwindow* window;
    MouseState mouseState;
    FrameNumber frameNumber;
    ulong resourceIndex;
    FrameBufferIndex frameBufferIndex;
    bool isIconified;

    Timing frameTiming;
    PerFrameResource[] perFrameResources;
    WindowEventListener[] windowEventListeners;

    VDebug debug_;
    VkCommandPool[] commandPools;
    VkQueryPool[] queryPools;
    VkCommandPool graphicsCP, transferCP;
    @Borrowed VkRenderPass renderPass;

    // optional if imgui is enabled
    VkDescriptorPool imguiDescriptorPool;
    ImGuiContext* imguiContext;
    ImFont*[] imguiFonts;
public:
    WindowProperties wprops;
    VulkanProperties vprops;
    IVulkanApplication app;
    ShaderCompiler shaderCompiler;

    VkInstance instance;
    VkPhysicalDevice physicalDevice;
    VkPhysicalDeviceProperties properties;
    VkPhysicalDeviceMemoryProperties memoryProperties;
    VkFormatProperties formatProperties;
    VkPhysicalDeviceLimits limits;
    VkDevice device;
    VkSurfaceKHR surface;

    Swapchain swapchain;
    QueueManager queueManager;

    GLFWwindow* getGLFWWindow() { return window; }
    ImGuiContext* getImguiContext() { return imguiContext; }

    ImFont* getImguiFont(uint index) {
        vkassert(imguiFonts.length > index);
        return imguiFonts[index];
    }

    QueueFamily getGraphicsQueueFamily() { return queueManager.getFamily(QueueManager.GRAPHICS); }
    QueueFamily getTransferQueueFamily() { return queueManager.getFamily(QueueManager.TRANSFER); }
    QueueFamily getComputeQueueFamily()  { return queueManager.getFamily(QueueManager.COMPUTE); }

    VkQueue getGraphicsQueue() { return getQueue(QueueManager.GRAPHICS); }
    VkQueue getTransferQueue() { return getQueue(QueueManager.TRANSFER); }
    VkQueue getComputeQueue()  { return getQueue(QueueManager.COMPUTE); }

    VkQueue getQueue(string label, uint queueIndex = 0) {
        return queueManager.getQueue(label, queueIndex);
    }

    VkCommandPool getTransferCP() { return transferCP; }
    uvec2 windowSize() const { return swapchain.extent.toUvec2; }

    FrameNumber getFrameNumber() { return frameNumber; }
    FrameBufferIndex getFrameBufferIndex() { return frameBufferIndex; }

    PerFrameResource getFrameResource(ulong i) { return perFrameResources[i]; }

	this(IVulkanApplication app,
	     ref WindowProperties wprops,
	     ref VulkanProperties vprops)
    {
        g_vulkan          = this;
	    this.app          = app;
		this.wprops       = wprops;
		this.vprops       = vprops;
		this.frameTiming  = new Timing(10,3);
	}
	void destroy() {
		this.log("Destroy called...");

        // device objects
		if(device) {
            vkDeviceWaitIdle(device);

            if(shaderCompiler) shaderCompiler.destroy();

            foreach(qp; queryPools) {
                device.destroyQueryPool(qp);
            }
            this.log("Destroyed %s query pools", queryPools.length);
            queryPools = null;

            foreach(cp; commandPools) {
                device.destroyCommandPool(cp);
            }
            this.log("Destroyed %s command pools", commandPools.length);
            commandPools = null;

            foreach(r; perFrameResources) {
                if(r is null) continue;
                if(r.imageAvailable) device.destroySemaphore(r.imageAvailable);
                if(r.renderFinished) device.destroySemaphore(r.renderFinished);
                if(r.fence) device.destroyFence(r.fence);
                if(r.frameBuffer) device.destroyFrameBuffer(r.frameBuffer);
            }
            this.log("Destroyed %s per frame resources", perFrameResources.length);
            perFrameResources = null;

            if(swapchain) swapchain.destroy();

            if(vprops.imgui.enabled) {
                destroyImgui();
            }

            device.destroyDevice();
        }

        // instance objects
        if(surface) instance.destroySurfaceKHR(surface);
		if(debug_) debug_.destroy();
		if(instance) instance.destroyInstance();

		// glfw and derelict objects
        this.log("Terminating");
		if(window) glfwDestroyWindow(window);
		glfwTerminate();

        unloadSharedLibs();
	}
	void initialise() {
        loadSharedLibs();

        this.log("Initialising GLFW %s", glfwGetVersionString().fromStringz);
        if(!glfwInit()) {
            glfwTerminate();
            throw new Exception("glfwInit failed");
        }
        if(!glfwVulkanSupported()) {
            throw new Exception("Vulkan is not supported on this device.");
        }
        glfwSetErrorCallback(&errorCallback);

        // vulkan instance
        instance = createInstance(vprops);
        debug debug_ = new VDebug(instance);

        loadVulkanInstanceFunctions(instance);

        // physical device
        physicalDevice   = selectBestPhysicalDevice(instance, vprops.minApiVersion, vprops.deviceExtensions);
        memoryProperties = physicalDevice.getMemoryProperties();
        properties       = physicalDevice.getProperties();
        limits           = properties.limits;

        // window
        if(!wprops.headless) {
            createWindow();
            createSurface();
        }

        createQueueManager();

        if(!wprops.headless) {
            if (!physicalDevice.canPresent(surface, queueManager.getFamily(QueueManager.GRAPHICS).index)) {
                throw new Error("Can't present on this surface");
            }
        }

        createLogicalDevice();

        // these require a logical device

        this.shaderCompiler = new ShaderCompiler(device, "shaders/", vprops.shaderDirectory);
        createSwapChain();
        createCommandPools();
        createPerFrameResources();

        if(vprops.imgui.enabled) {
            initImgui();
        }

        // Inform the app that we are now ready
        this.log("--------------------- device ready");
        app.deviceReady(device, perFrameResources);

        if(wprops.showWindow) showWindow(true);
        isInitialised = true;
    }
	void mainLoop() {
	    this.log("╔═════════════════════════════════════════════════════════════════╗");
        this.log("║ Entering main loop                                              ║");
        this.log("╚═════════════════════════════════════════════════════════════════╝");
	    import core.sys.windows.windows;

	    if(!isInitialised) throw new Error("vulkan.init() has not been called");
        ulong lastFrameTotalNsecs;
        ulong seconds;
        Frame frame = {
            number: FrameNumber(0),
            seconds: 0,
            perSecond: 1,
            resource: null
        };
        StopWatch watch;
        watch.start();

        while(!glfwWindowShouldClose(window)) {
            glfwPollEvents();

            if(isIconified) {
                // Don't render the frame if the app is iconified.
                // We could still call the app to let it do processing but
                // this needs some thought.
                if(watch.running) {
                    watch.stop();
                }
                continue;
            }
            // Make sure watch is running after possible iconification
            if(!watch.running) {
                watch.start();
            }

            renderFrame(frame);

            ulong time          = watch.peek().total!"nsecs";
            ulong frameNsecs    = time - lastFrameTotalNsecs;
            lastFrameTotalNsecs = time;

            frame.perSecond = frameNsecs/1_000_000_000.0;
            frame.number    = frame.number.next();
            frame.seconds  += frame.perSecond;

            frameNumber = frame.number;

            frameTiming.endFrame(frameNsecs);

            if(time/1_000_000_000L > seconds) {
                seconds = time/1_000_000_000L;
                double fps = 1_000_000_000.0 / frameNsecs;
                currentFPS = 1000.0 / frameTiming.average(2);

                this.log("Frame (number:%s, seconds:%.2f) perSecond=%.4f time:%.3f fps:%.2f",
                    frame.number,
                    frame.seconds,
                    frame.perSecond,
                    frameNsecs/1000000.0,
                    fps);
            }
        }
        this.log("╔═════════════════════════════════════════════════════════════════╗");
        this.log("║ Exiting main loop                                               ║");
        this.log("╚═════════════════════════════════════════════════════════════════╝");
	}
    void showWindow(bool show=true) {
        if(show) glfwShowWindow(window);
        else glfwHideWindow(window);
	}
	float getFPS() const {
	    return currentFPS;
	}
	Tuple!(float,float) getMousePos() {
        double x,y;
        glfwGetCursorPos(window, &x, &y);
        return Tuple!(float,float)(cast(float)x, cast(float)y);
    }
    MouseState getMouseState() {
        auto state = mouseState;
        mouseState.wheel = 0;
        return state;
    }
    /// http://www.glfw.org/docs/3.0/group__keys.html
    bool isKeyPressed(uint key) {
        return glfwGetKey(window, key) == GLFW_PRESS;
    }
    bool isMouseButtonPressed(int button) {
        return glfwGetMouseButton(window, button) == GLFW_PRESS;
    }
    void setWindowTitle(string title) {
        wprops.title = title;
        glfwSetWindowTitle(window, title.toStringz);
    }
    void setWindowIcon(string pngfile) {
        auto png = PNG.read(pngfile);
        GLFWimage image = {
            width: png.width,
            height: png.height,
            pixels: png.data.ptr
        };
        glfwSetWindowIcon(window, 1, &image);
    }
    void setMouseCursorVisible(bool visible) {
        glfwSetInputMode(window, GLFW_CURSOR, visible? GLFW_CURSOR_NORMAL : GLFW_CURSOR_HIDDEN);
    }
    /**
     *  This will capture the mouse and make it hidden.
     *  The application will need to display its own cursor.
     */
    void captureMouse() {
        glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
    }
    /**
     *  This sort of works but it doesn't display on Vulkan screen.
     *  Not sure whether this works better on OpenGL??
     */
    void setCustomMouse(string pngfile, int xhotspot=0, int yhotspot=0) {
        auto png = PNG.read(pngfile);
        GLFWimage image = {
            width: png.width,
            height: png.height,
            pixels: png.data.ptr
        };
        auto cursor = glfwCreateCursor(&image, xhotspot, yhotspot);
        if(cursor) {
            glfwSetCursor(window, cursor);
        }
        // cursor will be destroyed by glfwTerminate
    }
    /**
     *  VCommandPoolCreate.RESET_COMMAND_BUFFER
     *  VCommandPoolCreate.TRANSIENT
     */
    VkCommandPool createCommandPool(uint queueFamily, VCommandPoolCreate flags) {
        with(VCommandPoolCreate) vkassert((flags & ~(RESET_COMMAND_BUFFER|TRANSIENT))==0);

        auto cp = device.createCommandPool(queueFamily, flags);
        commandPools ~= cp;
        return cp;
    }
    VkQueryPool createQueryPool(VQueryType type, uint count) {
        auto qp = device.createQueryPool(type, count);
        queryPools ~= qp;
        return qp;
    }
    void addWindowEventListener(WindowEventListener listener) {
        this.windowEventListeners ~= listener;
    }
    /** Call this before doing any imgui rendering in your frame */
    void imguiRenderStart(Frame frame) {
        ImGui_ImplVulkan_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        igNewFrame();
    }
    /** Call this after doing your imgui rendering in your frame */
    void imguiRenderEnd(Frame frame) {
        igRender();
        ImGui_ImplVulkan_RenderDrawData(igGetDrawData(), frame.resource.adhocCB, null);
    }
private:
    void renderFrame(Frame frame) {


        /// Select the current frame resource.
        this.frameBufferIndex.value = (resourceIndex%perFrameResources.length).as!uint;
        resourceIndex++;

        frame.resource = perFrameResources[frameBufferIndex.value];

        //logTime("Wait fence");
        /// Wait for the fence.
        device.waitFor(frame.resource.fence);
        device.reset(frame.resource.fence);
        //logTime("Fence signalled");

        /// Get the next available image view.
        uint index = swapchain.acquireNext(frame.resource.imageAvailable, null);

        /// Let the app do its thing.
        app.render(frame);

        /// Present.
        swapchain.queuePresent(
            getQueue(QueueManager.GRAPHICS),
            index,
            [frame.resource.renderFinished] // wait semaphores
        );

        prevFrameIndex = index;
    }
    /**
     *  Select a single graphics and transfer queue family for our use.
     *  If 'headless' is requested then we don't need a graphics queue family.
     */
    void createQueueManager() {
        this.log("Creating QueueManager and selecting queue families...");
        auto queueFamilyProps = physicalDevice.getQueueFamilies();

        this.queueManager = new QueueManager(physicalDevice, surface, queueFamilyProps);

        /** Find a grphics queue family if we are not in headless mode */
        QueueFamily graphics = QueueFamily.NONE;

        if(!wprops.headless) {
            graphics = queueManager.findFirstWith(VkQueueFlagBits.VK_QUEUE_GRAPHICS_BIT);
            if(graphics==QueueFamily.NONE) {
                throw new Error("No graphics queue family found");
            }
            queueManager.request(QueueManager.GRAPHICS, graphics, 1);
        } else {
            this.log("Headless mode requested: Not selecting a graphics queue family");
        }

        /** Try to find a dedicated transfer queue family */
        auto transfer = queueManager.findFirstWith(VkQueueFlagBits.VK_QUEUE_TRANSFER_BIT, [graphics]);
        if(transfer==QueueFamily.NONE) {
            transfer = queueManager.findFirstWith(VkQueueFlagBits.VK_QUEUE_TRANSFER_BIT);
        }
        if(transfer==QueueFamily.NONE) {
            throw new Error("No transfer queue family found");
        }
        queueManager.request(QueueManager.TRANSFER, transfer, 1);

        /** Try to find a dedicated compute queue family */
        auto allCompute = queueManager.findQueueFamilies(VkQueueFlagBits.VK_QUEUE_COMPUTE_BIT, VkQueueFlagBits.VK_QUEUE_GRAPHICS_BIT);
        if(allCompute.length==0) {
            /** No non-graphics compute queue families. Get a non-dedicated one */
            allCompute = queueManager.findQueueFamilies(VkQueueFlagBits.VK_QUEUE_COMPUTE_BIT, 0.as!VkQueueFlagBits);
        }
        if(allCompute.length==0) {
            throw new Error("No compute queue family found");
        }
        /** Use the first one */
        queueManager.request(QueueManager.COMPUTE, allCompute[0], 1);

        /// Let the app make adjustments and validate
        app.selectQueueFamilies(queueManager);
    }
    void createLogicalDevice() {
        this.log("Creating logical device...");

        this.log("   Creating queue infos:");
        VkDeviceQueueCreateInfo[] queueInfos;
        foreach(t; queueManager.getAllRequestedQueues()) {
            uint index = t[0];
            uint count = t[1];

            this.log("   Family index %s : %s queues", index, count);

            float[] priorities = new float[count];
            priorities[] = 1.0f;
            queueInfos ~= deviceQueueCreateInfo(index, priorities);
        }

        /** Create the logicla device */
        device = physicalDevice.createLogicalDevice(
            vprops.deviceExtensions,
            vprops.features,
            queueInfos
        );

        queueManager.onDeviceCreated(device);

        // optimise some device calls to remove trampoline
//        vkCreateBuffer     = device.getProcAddr!PFN_vkCreateBuffer("vkCreateBuffer");
//        vkBindBufferMemory = device.getProcAddr!PFN_vkBindBufferMemory("vkBindBufferMemory");
//        vkMapMemory        = device.getProcAddr!PFN_vkMapMemory("vkMapMemory");
//        vkUnmapMemory      = device.getProcAddr!PFN_vkUnmapMemory("vkUnmapMemory");
//        vkGetBufferMemoryRequirements = device.getProcAddr!PFN_vkGetBufferMemoryRequirements("vkGetBufferMemoryRequirements");
//
//        vkAllocateCommandBuffers = device.getProcAddr!PFN_vkAllocateCommandBuffers("vkAllocateCommandBuffers");
//
//        vkCreateFence = device.getProcAddr!PFN_vkCreateFence("vkCreateFence");
//        vkDestroyFence = device.getProcAddr!PFN_vkDestroyFence("vkDestroyFence");
//
//        vkQueueSubmit = device.getProcAddr!PFN_vkQueueSubmit("vkQueueSubmit");
    }
    void createCommandPools() {
        this.log("Creating command pools");
        if(!wprops.headless) {
            graphicsCP = createCommandPool(queueManager.getFamily(QueueManager.GRAPHICS).index,
                VCommandPoolCreate.RESET_COMMAND_BUFFER | VCommandPoolCreate.TRANSIENT);
            this.log("Vulkan: Created graphics command pool using queue family %s", queueManager.getFamily(QueueManager.GRAPHICS));
        }
        transferCP = createCommandPool(queueManager.getFamily(QueueManager.TRANSFER).index,
            VCommandPoolCreate.TRANSIENT);
        this.log("Vulkan: Created transfer command pool using queue family %s", queueManager.getFamily(QueueManager.TRANSFER));
    }
    void createPerFrameResources() {
        if(wprops.headless) return;
        this.log("Creating per frame resources");
        vkassert(swapchain.frameBuffers[0] !is null);
        foreach(i; 0..swapchain.numImages) {
            auto r = new PerFrameResource;
            r.index            = i;
            r.adhocCB          = device.allocFrom(graphicsCP);
            r.renderFinished   = device.createSemaphore();
            r.imageAvailable   = device.createSemaphore();
            r.fence            = device.createFence(true);
            r.image            = swapchain.images[i];
            r.imageView        = swapchain.views[i];
            r.frameBuffer      = swapchain.frameBuffers[i];
            perFrameResources ~= r;
        }
        this.log("Created %s per frame resources", perFrameResources.length);
    }
    void createWindow() {
        this.log("Creating window");
        GLFWmonitor* monitor = glfwGetPrimaryMonitor();
        auto vidmode = glfwGetVideoMode(monitor);
        if(!wprops.fullscreen) {
            monitor = null;
            if(wprops.width==0 || wprops.height==0) {
                wprops.width  = vidmode.width;
                wprops.height = vidmode.height;
            }
            glfwWindowHint(GLFW_VISIBLE, 0);
            glfwWindowHint(GLFW_RESIZABLE, wprops.resizable ? 1 : 0);
            glfwWindowHint(GLFW_DECORATED, wprops.decorated ? 1 : 0);
        } else {
            //glfwWindowHint(GLFW_REFRESH_RATE, 60);
            wprops.width  = vidmode.width;
            wprops.height = vidmode.height;
        }

        // other window hints
        //glfwWindowHint(GLFW_DOUBLEBUFFER, 1);
//        if(hints.samples > 0) {
//            glfwWindowHint(GLFW_SAMPLES, hints.samples);
//        }
        glfwWindowHint(GLFW_AUTO_ICONIFY, wprops.autoIconify ? 1 : 0);

        glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
        GLFWwindow* share = null;
        window = glfwCreateWindow(wprops.width, wprops.height, wprops.title.toStringz, monitor, share);

        if(!wprops.fullscreen) {
            glfwSetWindowPos(
                window,
                ((cast(int)vidmode.width - wprops.width) / 2),
                ((cast(int)vidmode.height - wprops.height) / 2)
            );
        }

        glfwSetKeyCallback(window, &onKeyEvent);
        glfwSetWindowFocusCallback(window, &onWindowFocusEvent);
        glfwSetMouseButtonCallback(window, &onMouseClickEvent);
        glfwSetScrollCallback(window, &onScrollEvent);
        glfwSetCursorPosCallback(window, &onMouseMoveEvent);
        glfwSetCursorEnterCallback(window, &onMouseEnterEvent);
        glfwSetWindowIconifyCallback(window, &onIconifyEvent);

        //glfwSetWindowRefreshCallback(window, &refreshWindow);
        //glfwSetWindowSizeCallback(window, &resizeWindow);
        //glfwSetWindowCloseCallback(window, &onWindowCloseEvent);
        //glfwSetDropCallback(window, &onDropEvent);

        //glfwSetInputMode(window, GLFW_STICKY_KEYS, 1);

        if(wprops.icon !is null) {
            setWindowIcon(wprops.icon);
        }
    }
    void createSurface() {
        this.log("Creating surface");
        check(glfwCreateWindowSurface(instance, window, null, &surface));
    }
    void createSwapChain() {
        if(wprops.headless) return;
        this.swapchain = new Swapchain(this);
        swapchain.create(surface);
        this.renderPass = app.getRenderPass(device);
        swapchain.createFrameBuffers(renderPass);
    }
    void initImgui() {
        this.log("Initialising ImGui");

        VkDescriptorPoolSize[] poolSizes = [
            { VDescriptorType.SAMPLER, 1000 },
            { VDescriptorType.COMBINED_IMAGE_SAMPLER, 1000 },
            { VDescriptorType.SAMPLED_IMAGE, 1000 },
            { VDescriptorType.STORAGE_IMAGE, 1000 },
            { VDescriptorType.UNIFORM_TEXEL_BUFFER, 1000 },
            { VDescriptorType.STORAGE_TEXEL_BUFFER, 1000 },
            { VDescriptorType.UNIFORM_BUFFER, 1000 },
            { VDescriptorType.STORAGE_BUFFER, 1000 },
            { VDescriptorType.UNIFORM_BUFFER_DYNAMIC, 1000 },
            { VDescriptorType.STORAGE_BUFFER_DYNAMIC, 1000 },
            { VDescriptorType.INPUT_ATTACHMENT, 1000 }
        ];

        imguiDescriptorPool = createDescriptorPool(device, poolSizes, 1000, VDescriptorPoolCreate.FREE_DESCRIPTOR_SET);

        imguiContext = igCreateContext(null);
        vkassert(imguiContext);

        ImGuiIO* io = igGetIO();

        //io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;     // Enable Keyboard Controls
        //io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;      // Enable Gamepad Controls

        //io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;

        // Don't capture the keyboard
        //io.ConfigFlags |= ImGuiConfigFlags_NavNoCaptureKeyboard;

        // Don't change the mouse pointer
        //io.ConfigFlags |= ImGuiConfigFlags_NoMouseCursorChange;

        // Enable docking
        // io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;
        // io.ConfigFlags |= ImGuiConfigFlags_ViewportsEnable;

        io.ConfigFlags |= vprops.imgui.configFlags;

        igStyleColorsDark(null);

        auto v = igGetVersion();
        this.log("ImGui version is %s", fromStringz(v));

        bool res = ImGui_ImplGlfw_InitForVulkan(window, true);
        vkassert(res, "ImGui_ImplGlfw_InitForVulkan failed");


        ImGui_ImplVulkan_InitInfo info = {
            Instance: instance,
            PhysicalDevice: physicalDevice,
            Device: device,
            Queue: getGraphicsQueue(),
            DescriptorPool: imguiDescriptorPool,
            MinImageCount: swapchain.numImages(),
            ImageCount: swapchain.numImages(),
            MSAASamples: VSampleCount._1
        };

        res = ImGui_ImplVulkan_Init(&info, renderPass);
        vkassert(res, "ImGui_ImplVulkan_Init failed");

        // Upload font textures
        {
            vkassert(vprops.imgui.fontPaths.length == vprops.imgui.fontSizes.length);
            foreach(i, path; vprops.imgui.fontPaths) {
                auto size = vprops.imgui.fontSizes[i];

                auto font = ImFontAtlas_AddFontFromFileTTF(
                    io.Fonts,
                    toStringz(path),
                    size,
                    null,   // ImFontConfig* (in)
                    null);  // ImWchar* glyph_ranges (in)

                imguiFonts ~= font;
            }

            auto cmdPool = device.createCommandPool(
                getGraphicsQueueFamily().index,
                VCommandPoolCreate.TRANSIENT);
            scope(exit) device.destroyCommandPool(cmdPool);

            auto cmd = device.allocFrom(cmdPool);
            scope(exit) device.free(cmdPool, cmd);

            cmd.beginOneTimeSubmit();
            ImGui_ImplVulkan_CreateFontsTexture(cmd);
            cmd.end();
            auto fence = device.createFence();
            scope(exit) device.destroyFence(fence);

            getGraphicsQueue().submit([cmd], fence);

            device.waitFor(fence);

            ImGui_ImplVulkan_DestroyFontUploadObjects();
        }
    }
    void destroyImgui() {
        ImGui_ImplVulkan_Shutdown();
        ImGui_ImplGlfw_Shutdown();
        igDestroyContext(imguiContext);
        if(imguiDescriptorPool) device.destroyDescriptorPool(imguiDescriptorPool);
    }
}

//===================================================================================

private:

extern(C) {
void errorCallback(int error, const(char)* description) nothrow {
    log("glfw error: %s %s", error, description);
}
void onKeyEvent(GLFWwindow* window, int key, int scancode, int action, int mods) nothrow {
	if(key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
		glfwSetWindowShouldClose(window, true);
		return;
	}
	//bool shiftClick = (mods & GLFW_MOD_SHIFT) != 0;
	//bool ctrlClick	= (mods & GLFW_MOD_CONTROL) != 0;
	//bool altClick	= (mods & GLFW_MOD_ALT ) != 0;

    try{
        foreach(l; g_vulkan.windowEventListeners) {
            l.keyPress(key, scancode, cast(KeyAction)action, mods);
        }
	}catch(Throwable t) {
        log("WARN: Exception ignored: %s", t);
    }
}
void onWindowFocusEvent(GLFWwindow* window, int focussed) nothrow {
	//this.log("window focus changed to %s FOCUS", focussed?"GAINED":"LOST");
    try{
        foreach(l; g_vulkan.windowEventListeners) {
            l.focus(focussed!=0);
        }
    }catch(Throwable t) {
        log("WARN: Exception ignored: %s", t);
    }
}
void onIconifyEvent(GLFWwindow* window, int iconified) nothrow {
	//this.log("window %s", iconified ? "iconified":"non iconified");
    try{
        g_vulkan.isIconified = iconified!=0;
        foreach(l; g_vulkan.windowEventListeners) {
            l.iconify(iconified!=0);
        }
    }catch(Throwable t) {
        log("WARN: Exception ignored: %s", t);
    }
}
void onMouseClickEvent(GLFWwindow* window, int button, int action, int mods) nothrow {
	bool pressed = (action == 1);
	double x,y;
	glfwGetCursorPos(window, &x, &y);

	try{
        foreach(l; g_vulkan.windowEventListeners) {
            l.mouseButton(button, cast(float)x, cast(float)y, pressed, mods);
        }
    }catch(Throwable t) {
        log("WARN: Exception ignored: %s", t);
    }

    auto mouseState = &g_vulkan.mouseState;

	if(pressed) {
		mouseState.button = button;
	} else {
		mouseState.button = -1;
		if(mouseState.isDragging) {
			mouseState.isDragging = false;
			mouseState.dragEnd = float2(x,y);
		}
	}
}
void onMouseMoveEvent(GLFWwindow* window, double x, double y) nothrow {
	//this.log("mouse move %s %s", x, y);
	try{
        foreach(l; g_vulkan.windowEventListeners) {
            l.mouseMoved(cast(float)x, cast(float)y);
        }
	}catch(Throwable t) {
        log("WARN: Exception ignored: %s", t);
    }

    auto mouseState = &g_vulkan.mouseState;

	mouseState.pos = Vector2(x,y);
	if(!mouseState.isDragging && mouseState.button >= 0) {
		mouseState.isDragging = true;
		mouseState.dragStart = Vector2(x,y);
	}
}
void onScrollEvent(GLFWwindow* window, double xoffset, double yoffset) nothrow {
	//this.log("scroll event: %s %s", xoffset, yoffset);
	try{
        double x,y;
        glfwGetCursorPos(window, &x, &y);

        g_vulkan.mouseState.wheel += yoffset;

        foreach(l; g_vulkan.windowEventListeners) {
            l.mouseWheel(cast(float)xoffset, cast(float)yoffset, cast(float)x, cast(float)y);
        }
	}catch(Throwable t) {
        log("WARN: Exception ignored: %s", t);
    }
}
void onMouseEnterEvent(GLFWwindow* window, int enterred) nothrow {
	//this.log("mouse %s", enterred ? "enterred" : "exited");
    try{
        foreach(l; g_vulkan.windowEventListeners) {
            double x,y;
            glfwGetCursorPos(window, &x, &y);
            l.mouseEnter(x,y, enterred!=0);
        }
    }catch(Throwable t) {
        log("WARN: Exception ignored: %s", t);
    }
}

} // extern(C)
