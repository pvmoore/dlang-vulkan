module vulkan.vulkan;

/**
 *  Todo:
 *      - Updating uniform buffers may really benefit from using shared memory.
 */
import vulkan.all;
import vulkan.glfw_events;

// Global Vulkan instance. We assume there will only be one
__gshared Vulkan g_vulkan;

final class Vulkan {
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

    InstanceHelper instanceHelper;
    Swapchain swapchain;
    QueueManager queueManager;

    GLFWwindow* getGLFWWindow() { return window; }
    ImGuiContext* getImguiContext() { return imguiContext; }

    ImFont* getImguiFont(uint index) {
        throwIf(index >= imguiFonts.length, "Font at index %s does not exist".format(index));
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

    VkCommandPool getGraphicsCP() { return graphicsCP; }
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
		destroy_VK_EXT_debug_utils(instance);
		if(instance) instance.destroyInstance();

		// glfw and derelict objects
        this.log("Terminating");
		if(window) glfwDestroyWindow(window);
		glfwTerminate();

        unloadSharedLibs();
	}
	void initialise() {
        assert(thread_isMainThread());

        loadSharedLibs();

        this.log("Initialising GLFW %s", glfwGetVersionString().fromStringz);
        if(!glfwInit()) {
            glfwTerminate();
            throw new Exception("glfwInit failed");
        }
        if(!glfwVulkanSupported()) {
            throw new Exception("Vulkan is not supported on this device.");
        }
        glfwSetErrorCallback(&errorCallbackHandler);

        // vulkan instance
        log("----------------------------------------------------------------------------------");
        instanceHelper = new InstanceHelper();
        instance = createInstance(vprops, instanceHelper);
        initialise_VK_EXT_debug_utils(instance, instanceHelper);

        vkLoadInstanceFunctions(instance);


        log("----------------------------------------------------------------------------------");

        string slangCompilerVersion = ShaderCompiler.getSlangCompilerVersion(vprops);
        string glslCompilerVersion = ShaderCompiler.getGlslCompilerVersion(vprops);
        this.log("Slang compiler version: %s", slangCompilerVersion);
        this.log("GLSL  compiler version: %s", glslCompilerVersion);

        log("----------------------------------------------------------------------------------");

        // physical device
        physicalDevice   = selectBestPhysicalDevice(instance, vprops.apiVersion, vprops.deviceExtensions);
        memoryProperties = physicalDevice.getMemoryProperties();
        properties       = physicalDevice.getProperties();
        limits           = properties.limits;

        log("----------------------------------------------------------------------------------");

        createQueueManager();

        log("----------------------------------------------------------------------------------");

        // window and surface
        if(!wprops.headless) {
            createWindow();
            createSurface();

            if (!physicalDevice.canPresent(surface, queueManager.getFamily(QueueManager.GRAPHICS).index)) {
                throw new Error("Can't present on this surface");
            }
        }

        log("----------------------------------------------------------------------------------");

        createLogicalDevice();

        log("----------------------------------------------------------------------------------");

        log("Loading device functions...");
        vkLoadDeviceFunctions(device);

        // these require a logical device

        this.shaderCompiler = new ShaderCompiler(device, vprops);

        if(!wprops.headless) {
            createSwapChain();
            this.log("windowSize = %s", windowSize);

            if(!wprops.fullscreen) {
                import std : fromStringz, format, strip;
                import core.cpuid: processor;
                string gpuName = cast(string)properties.deviceName.ptr.fromStringz;
                string title = "%s :: %s, %s".format(wprops.title, gpuName, processor()).strip();
                setWindowTitle(title);
            }
        }
        
        createCommandPools();
        createPerFrameResources();

        if(vprops.imgui.enabled) {
            initImgui();
        } else {
            this.log("Imgui is not enabled");
        }

        // Inform the app that we are now ready
        this.log("--------------------------------------------------------------- device ready");
        app.deviceReady(device, perFrameResources);

        if(wprops.showWindow) showWindow(true);
        isInitialised = true;
    }
    /**
     *  This will run until mainLoopExit() or glfwWindowShouldClose() is called.
     */
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
            frameTimeNanos      = time - lastFrameTotalNsecs;
            lastFrameTotalNsecs = time;

            frame.perSecond = frameTimeNanos/1_000_000_000.0;
            frame.number    = frame.number.next();
            frame.seconds  += frame.perSecond;

            frameNumber = frame.number;

            frameTiming.endFrame(frameTimeNanos);

            // Per second
            if(time/1_000_000_000L > seconds) {
                seconds = time/1_000_000_000L;
                double fps = 1_000_000_000.0 / frameTimeNanos;
                currentFPS = 1000.0 / frameTiming.average(2);

                if(wprops.titleBarFps && !wprops.fullscreen) {
                    string s = "%s :: %.2f fps".format(wprops.title, currentFPS);
                    glfwSetWindowTitle(window, s.toStringz);
                }

                this.log("Frame (number:%s, seconds:%.2f) perSecond=%.4f time:%.3f fps:%.2f",
                    frame.number,
                    frame.seconds,
                    frame.perSecond,
                    frameTimeNanos/1000000.0,
                    fps);
            }
        }
        this.log("╔═════════════════════════════════════════════════════════════════╗");
        this.log("║ Exiting main loop                                               ║");
        this.log("╚═════════════════════════════════════════════════════════════════╝");
	}
    /**
     *  Signal the main loop to exit.
     */
    void mainLoopExit() {
        glfwSetWindowShouldClose(window, true);
    }
    /**
     *  This function must only be called from the main thread
     */
    void showWindow(bool show=true) {
        assert(thread_isMainThread());
        if(show) glfwShowWindow(window);
        else glfwHideWindow(window);
	}
    ulong getFrameTimeNanos() {
        return frameTimeNanos;
    }
	float getFPSSnapshot() const {
	    return currentFPS;
	}
    /**
     * This function must only be called from the main thread
     */
	Tuple!(float,float) getMousePos() {
        assert(thread_isMainThread());
        double x,y;
        glfwGetCursorPos(window, &x, &y);
        return Tuple!(float,float)(cast(float)x, cast(float)y);
    }
    MouseState getMouseState() {
        auto state = mouseState;
        mouseState.wheel = 0;
        return state;
    }
    /**
     * Return true if the key is pressed with any of the the specified modifiers
     * (This can be called on any thread)
     *
     * https://www.glfw.org/docs/latest/group__keys.html
     */
    bool isKeyPressed(uint key, KeyMod mods = KeyMod.NONE) {
        KeyState state = keyStates[key];
        return state.action!=KeyAction.RELEASE && (mods == 0 || ((mods & state.mod) != 0));
    }
    /**
     * Return true if the mouse button is pressed with any of the the specified key modifiers
     * (This can be called on any thread)
     */
    bool isMouseButtonPressed(int button, KeyMod mods = KeyMod.NONE) {
        MouseButtonState state = mouseButtonStates[button];
        return state.pressed && (mods == 0 || ((mods & state.mod) != 0));
    }
    /**
     *  This function must only be called from the main thread
     */
    void setWindowTitle(string title) {
        assert(thread_isMainThread());
        wprops.title = title;
        glfwSetWindowTitle(window, title.toStringz);
    }
    /**
     *  This function must only be called from the main thread
     */
    void setWindowIcon(string pngfile) {
        assert(thread_isMainThread());
        auto png = PNG.read(pngfile);
        GLFWimage image = {
            width: png.width,
            height: png.height,
            pixels: png.data.ptr
        };
        glfwSetWindowIcon(window, 1, &image);
    }
    /**
     *  This function must only be called from the main thread
     */
    void setMouseCursorVisible(bool visible) {
        assert(thread_isMainThread());
        glfwSetInputMode(window, GLFW_CURSOR, visible? GLFW_CURSOR_NORMAL : GLFW_CURSOR_HIDDEN);
    }
    /**
     *  This will capture the mouse and make it hidden.
     *  The application will need to display its own cursor.
     *  This function must only be called from the main thread
     */
    void captureMouse() {
        assert(thread_isMainThread());
        glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
    }
    /**
     *  This sort of works but it doesn't display on Vulkan screen.
     *  Not sure whether this works better on OpenGL??
     *  This function must only be called from the main thread
     */
    void setCustomMouse(string pngfile, int xhotspot=0, int yhotspot=0) {
        assert(thread_isMainThread());
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
    VkCommandPool createCommandPool(uint queueFamily, VkCommandPoolCreateFlags flags) {
        throwIf((flags & ~(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT|VK_COMMAND_POOL_CREATE_TRANSIENT_BIT)) != 0);

        auto cp = device.createCommandPool(queueFamily, flags);
        commandPools ~= cp;
        return cp;
    }
    VkQueryPool createQueryPool(VkQueryType type, uint count, VkQueryPipelineStatisticFlags flags) {
        auto qp = device.createQueryPool(type, count, flags);
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
        auto drawData = igGetDrawData();
        ImGui_ImplVulkan_RenderDrawData(drawData, frame.resource.adhocCB, null);

        ImGuiIO* io = igGetIO();
        if(io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable) {
            // These are required to correctly display docking windows
            igUpdatePlatformWindows();
            igRenderPlatformWindowsDefault(null, null);
        }
    }
package:
    // Semi-private members. Used by vulkan_events.d
    WindowEventListener[] windowEventListeners;
    bool isIconified;
    MouseState mouseState;
private:
    bool isInitialised;
    float currentFPS = 0;   // latest FPS snapshot (recalculated every second)
    ulong frameTimeNanos;   // latest frame time in nanoseconds
    GLFWwindow* window;
    FrameNumber frameNumber;
    ulong resourceIndex;
    FrameBufferIndex frameBufferIndex;

    Timing frameTiming;
    PerFrameResource[] perFrameResources;

    VkCommandPool[] commandPools;
    VkQueryPool[] queryPools;
    VkCommandPool graphicsCP, transferCP;
    @Borrowed VkRenderPass renderPass;

    // optional if imgui is enabled
    VkDescriptorPool imguiDescriptorPool;
    ImGuiContext* imguiContext;
    ImFont*[] imguiFonts;

    void renderFrame(Frame frame) {

        /// Select the current frame resource.
        this.frameBufferIndex.value = (resourceIndex%perFrameResources.length).as!uint;
        resourceIndex++;

        frame.resource = perFrameResources[frameBufferIndex.value];

        /// Wait for the fence.
        device.waitFor(frame.resource.fence);
        device.reset(frame.resource.fence);

        /// Get the next available image view.
        frame.imageIndex = swapchain.acquireNext(frame.resource.imageAvailable, null);

        // Set the Frame image
        frame.image = swapchain.images[frame.imageIndex];
        frame.imageView = swapchain.views[frame.imageIndex];
        if(swapchain.frameBuffers.length != 0) {
            frame.frameBuffer = swapchain.frameBuffers[frame.imageIndex];
        }

        /// Let the app do its thing.
        app.render(frame);

        /// Present.
        swapchain.queuePresent(
            getQueue(QueueManager.GRAPHICS),
            frame.imageIndex,
            [frame.resource.renderFinished] // wait semaphores
        );
    }
    /**
     *  Select a single graphics and transfer queue family for our use.
     *  If 'headless' is requested then we don't need a graphics queue family.
     */
    void createQueueManager() {
        this.log("Creating QueueManager and selecting queue families...");
        auto queueFamilyProps = physicalDevice.getQueueFamilies();

        this.queueManager = new QueueManager(physicalDevice, surface, queueFamilyProps);

        /** Find a graphics queue family if we are not in headless mode */
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

        /** Create the logical device */
        device = .createLogicalDevice(app, physicalDevice, vprops, queueInfos);

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
                VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT | VK_COMMAND_POOL_CREATE_TRANSIENT_BIT);
            this.log("Vulkan: Created graphics command pool using queue family %s", queueManager.getFamily(QueueManager.GRAPHICS));
        }
        transferCP = createCommandPool(queueManager.getFamily(QueueManager.TRANSFER).index,
            VK_COMMAND_POOL_CREATE_TRANSIENT_BIT);
        this.log("Vulkan: Created transfer command pool using queue family %s", queueManager.getFamily(QueueManager.TRANSFER));
    }
    void createPerFrameResources() {
        if(wprops.headless) return;
        this.log("Creating per frame resources");
        throwIf(!vprops.useDynamicRendering && swapchain.frameBuffers[0] is null);
        foreach(i; 0..swapchain.numImages) {
            auto r = new PerFrameResource;
            r.index            = i;
            r.adhocCB          = device.allocFrom(graphicsCP);
            r.renderFinished   = device.createSemaphore();
            r.imageAvailable   = device.createSemaphore();
            r.fence            = device.createFence(true);

            setObjectDebugName!VK_OBJECT_TYPE_COMMAND_BUFFER(device, r.adhocCB, "PerFrameResource[%s].adhocCB".format(i));
            setObjectDebugName!VK_OBJECT_TYPE_SEMAPHORE(device, r.imageAvailable, "PerFrameResource[%s].imageAvailable".format(i));
            setObjectDebugName!VK_OBJECT_TYPE_SEMAPHORE(device, r.renderFinished, "PerFrameResource[%s].renderFinished".format(i));
            setObjectDebugName!VK_OBJECT_TYPE_FENCE(device, r.fence, "PerFrameResource[%s].fence".format(i));

            perFrameResources ~= r;
        }
        this.log("Created %s per frame resources", perFrameResources.length);
    }
    void createWindow() {
        this.log("Creating window");
        GLFWmonitor* monitor = glfwGetPrimaryMonitor();
        auto vidmode = glfwGetVideoMode(monitor);
        if(!wprops.fullscreen) {
            this.log("Windowed mode selected");
            monitor = null;
            if(wprops.width==0 || wprops.height==0) {
                wprops.width  = vidmode.width;
                wprops.height = vidmode.height;
            }
            glfwWindowHint(GLFW_VISIBLE, 0);
            glfwWindowHint(GLFW_RESIZABLE, wprops.resizable ? 1 : 0);
            glfwWindowHint(GLFW_DECORATED, wprops.decorated ? 1 : 0);
        } else {
            this.log("Full screen mode selected");
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

        // Key events
        glfwSetKeyCallback(window, &keyCallbackHandler);
        
        // Mouse events
        glfwSetMouseButtonCallback(window, &mouseButtonCallbackHandler);
        glfwSetCursorPosCallback(window, &cursorPosCallbackHandler);
        glfwSetScrollCallback(window, &scrollCallbackHandler);
        glfwSetCursorEnterCallback(window, &cursorEnterCallbackHandler);
        
        // Window events
        glfwSetWindowFocusCallback(window, &WindowFocusCallbackHandler);
        glfwSetWindowIconifyCallback(window, &windowIconifyCallbackHandler);

        //glfwSetWindowRefreshCallback(window, &windowRefreshCallbackHandler);
        //glfwSetWindowPosCallback(window, &windowPosCallbackHandler);
        //glfwSetWindowSizeCallback(window, &windowSizeCallbackHandler);
        //glfwSetWindowCloseCallback(window, &windowCloseCallbackHandler);
        //glfwSetWindowMaximizeCallback(window, &windowMaximizeCallbackHandler);
        //glfwSetDropCallback(window, &dropCallbackHandler);

        if(wprops.icon !is null) {
            setWindowIcon(wprops.icon);
        }
    }
    void createSurface() {
        this.log("Creating surface");
        check(glfwCreateWindowSurface(instance, window, null, &surface));
    }
    void createSwapChain() {
        this.swapchain = new Swapchain(this);
        this.swapchain.create(surface);
        
        if(!vprops.useDynamicRendering) {
            this.renderPass = app.getRenderPass(device);
            this.swapchain.createFrameBuffers(renderPass);
        }
    }
    void initImgui() {
        this.log("Initialising ImGui");

        VkDescriptorPoolSize[] poolSizes = [
            { VK_DESCRIPTOR_TYPE_SAMPLER, 1000 },
            { VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 1000 },
            { VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE, 1000 },
            { VK_DESCRIPTOR_TYPE_STORAGE_IMAGE, 1000 },
            { VK_DESCRIPTOR_TYPE_UNIFORM_TEXEL_BUFFER, 1000 },
            { VK_DESCRIPTOR_TYPE_STORAGE_TEXEL_BUFFER, 1000 },
            { VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, 1000 },
            { VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, 1000 },
            { VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC, 1000 },
            { VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC, 1000 },
            { VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT, 1000 }
        ];

        imguiDescriptorPool = createDescriptorPool(device, poolSizes, 1000, VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT);

        imguiContext = igCreateContext(null);
        throwIf(imguiContext is null);

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
        throwIf(!res, "ImGui_ImplGlfw_InitForVulkan failed");


        ImGui_ImplVulkan_InitInfo info = {
            Instance: instance,
            PhysicalDevice: physicalDevice,
            Device: device,
            Queue: getGraphicsQueue(),
            DescriptorPool: imguiDescriptorPool,
            MinImageCount: swapchain.numImages(),
            ImageCount: swapchain.numImages(),
            MSAASamples: VK_SAMPLE_COUNT_1_BIT,
            UseDynamicRendering: false,
            RenderPass: renderPass
        };

        res = ImGui_ImplVulkan_Init(&info);
        throwIf(!res, "ImGui_ImplVulkan_Init failed");

        // Upload font textures
        {
            throwIf(vprops.imgui.fontPaths.length != vprops.imgui.fontSizes.length,
                "fontPaths.length amd fontSizes.length must be the same");
            foreach(i, path; vprops.imgui.fontPaths) {
                auto size = vprops.imgui.fontSizes[i];

                auto font = ImFontAtlas_AddFontFromFileTTF(
                    io.Fonts,
                    toStringz(path),
                    size,
                    null,   // ImFontConfig* (in)
                    null);  // ImWchar* glyph_ranges (in)

                throwIf(font is null, "Failed to load font '%s'".format(path));

                imguiFonts ~= font;
            }
        }
    }
    void destroyImgui() {
        ImGui_ImplVulkan_Shutdown();
        ImGui_ImplGlfw_Shutdown();
        igDestroyContext(imguiContext);
        if(imguiDescriptorPool) device.destroyDescriptorPool(imguiDescriptorPool);
    }
}
