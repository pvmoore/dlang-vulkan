module vulkan.Swapchain;

import vulkan.all;

final class Swapchain {
private:
    DeviceMemory depthStencilMem;
    DeviceImage depthStencilImage;
public:
    Vulkan vk;
    VkPhysicalDevice physicalDevice;
    VkDevice device;
    VkSurfaceKHR surface;

    VkSwapchainKHR handle;
    VkFormat colorFormat;
    VkColorSpaceKHR colorSpace;
    VkExtent2D extent;

    VkImage[] images;
    VkImageView[] views;
    VkFramebuffer[] frameBuffers;

    uint numImages() const { return cast(uint)images.length; }

    this(Vulkan vk) {
        this.vk             = vk;
        this.physicalDevice = vk.physicalDevice;
        this.device         = vk.device;

        initialise();
    }
    void destroy() {
        this.log("Destroying");
        foreach(ref v; views) {
            vkDestroyImageView(device, v, null);
        }
        if(depthStencilMem) {
            depthStencilMem.destroy();
        }
        destroySwapchainKHR(device, handle, null);
    }
    void create(VkSurfaceKHR surface) {
        this.surface = surface;

        selectSurfaceFormat();
        createSwapChain();
        getSwapChainImages();
        createImageViews();
        createDepthBuffer();
    }
    /**
     * This needs to be done after create beecause it needs the renderPass
     * from the application which itself might need the swapchain :|
     */
    void createFrameBuffers(VkRenderPass renderPass) {
        this.log("Creating frame buffers");
        expect(renderPass !is null);
        frameBuffers.length = numImages;
        foreach(i, imageView; views) {

            auto frameBufferViews = [imageView];

            /** Add depth/stencil view */
            if(depthStencilImage) {
                frameBufferViews ~= depthStencilImage.view();
            }

            frameBuffers[i] = device.createFrameBuffer(
                renderPass,
                frameBufferViews,
                extent.width,
                extent.height,
                1
            );
        }
    }
    uint acquireNext(VkSemaphore imageAvailableSemaphore, VkFence fence) {
        uint imageIndex;
        //logTime("Acquire");
        auto result = acquireNextImageKHR(
            device,
            handle,
            ulong.max,
            imageAvailableSemaphore,
            fence,
            &imageIndex
        );
        //logTime("Acquired %s".format(imageIndex));
        switch(result) with(VkResult) {
            case VK_SUCCESS:
                break;
            case VK_ERROR_OUT_OF_DATE_KHR:
                this.log("Swapchain is out of date");
                break;
            case VK_SUBOPTIMAL_KHR:
                this.log("Swapchain is suboptimal");
                break;
            case VK_NOT_READY:
                this.log("Swapchain not ready");
                break;
            default:
                throw new Error("Swapchain acquire error: %s".format(result));
        }
        return imageIndex;
    }
    void queuePresent(VkQueue queue,
                      uint imageIndex,
                      VkSemaphore[] waitSemaphores)
    {
        VkResult[] results;

        VkPresentInfoKHR info;
        info.sType = VkStructureType.VK_STRUCTURE_TYPE_PRESENT_INFO_KHR;

        info.waitSemaphoreCount = cast(uint)waitSemaphores.length;
        info.pWaitSemaphores    = waitSemaphores.ptr;

        info.swapchainCount     = 1;
        info.pSwapchains        = &handle;
        info.pImageIndices      = &imageIndex;
        info.pResults           = results.ptr;

        //logTime("Present %s".format(imageIndex));
        auto result = queuePresentKHR(queue, &info);
        //logTime("Presented %s".format(imageIndex));

        switch(result) with(VkResult) {
            case VK_SUCCESS:
                break;
            case VK_ERROR_OUT_OF_DATE_KHR:
                this.log("Swapchain is out of date");
                break;
            case VK_SUBOPTIMAL_KHR:
                this.log("Swapchain is suboptimal");
                break;
            case VK_NOT_READY:
                this.log("Swapchain not ready");
                break;
            default:
                throw new Error("Swapchain present error: %s".format(result));
        }
    }
private:
    PFN_vkCreateSwapchainKHR createSwapchainKHR;
    PFN_vkDestroySwapchainKHR destroySwapchainKHR;
    PFN_vkGetSwapchainImagesKHR getSwapchainImagesKHR;
    PFN_vkAcquireNextImageKHR acquireNextImageKHR;
    PFN_vkQueuePresentKHR queuePresentKHR;

    void initialise() {
        // get logical device proc addresses because they will be faster
        this.createSwapchainKHR =
            device.getProcAddr!PFN_vkCreateSwapchainKHR("vkCreateSwapchainKHR");
        this.destroySwapchainKHR =
            device.getProcAddr!PFN_vkDestroySwapchainKHR("vkDestroySwapchainKHR");
        this.getSwapchainImagesKHR =
            device.getProcAddr!PFN_vkGetSwapchainImagesKHR("vkGetSwapchainImagesKHR");
        this.acquireNextImageKHR =
            device.getProcAddr!PFN_vkAcquireNextImageKHR("vkAcquireNextImageKHR");
        this.queuePresentKHR =
            device.getProcAddr!PFN_vkQueuePresentKHR("vkQueuePresentKHR");
    }
    void createSwapChain() {
        auto surfaceCaps = physicalDevice.getCapabilities(surface);

        this.log("Creating swap chain (size %s)", surfaceCaps.currentExtent);

        VkSwapchainCreateInfoKHR i;
        i.sType = VkStructureType.VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR;

        // VK_SWAPCHAIN_CREATE_BIND_SFR_BIT_KHX
        i.flags = 0;

        i.surface               = surface;
        i.minImageCount         = selectNumImages(surfaceCaps);
        i.imageFormat           = colorFormat;
        i.imageColorSpace       = colorSpace;
        i.imageExtent           = selectExtent(surfaceCaps);

        // For non-stereoscopic-3D applications, this value is 1.
        i.imageArrayLayers = 1;

        i.imageUsage = VImageUsage.COLOR_ATTACHMENT |
                       vk.vprops.swapchainUsage;

        if(false) {
            // todo - handle multiple queues
            uint[] queueIndexes = [0,1];
            i.imageSharingMode = VSharingMode.CONCURRENT;
            // Queue families that will access this swapchain.
            i.queueFamilyIndexCount = cast(uint)queueIndexes.length;
            i.pQueueFamilyIndices   = queueIndexes.ptr;
        } else {
            i.imageSharingMode      = VSharingMode.EXCLUSIVE;
            i.queueFamilyIndexCount = 0;
            i.pQueueFamilyIndices   = null;
        }

        // use identity transform if available
        i.preTransform = selectPreTransform(surfaceCaps);

        i.compositeAlpha        = VkCompositeAlphaFlagBitsKHR.VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR;
        i.presentMode           = selectPresentMode();
        i.clipped               = VK_TRUE;
        i.oldSwapchain          = null;

        check(createSwapchainKHR(device, &i, null, &handle));
        this.log("Swapchain created");
    }
    VkSurfaceTransformFlagBitsKHR selectPreTransform(VkSurfaceCapabilitiesKHR caps) {
        auto trans = caps.currentTransform;
        with(VkSurfaceTransformFlagBitsKHR) {
            if(caps.supportedTransforms & VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR) {
                trans = VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR;
            }
        }
        this.log("Setting preTransform to %s", trans);
        return trans;
    }
    uint selectNumImages(VkSurfaceCapabilitiesKHR caps) {
        expect(vk.wprops.frameBuffers>0);
        uint num = max!int(caps.minImageCount, vk.wprops.frameBuffers);
        if(caps.maxImageCount>0 && num>caps.maxImageCount) {
            num = caps.maxImageCount;
        }
        this.log("Requesting %s images", num);
        return num;
    }
    void selectSurfaceFormat() {
        this.log("Selecting surface format");
        VkSurfaceFormatKHR[] formats = physicalDevice.getFormats(surface);
        assert(formats.length >= 1);

        this.log("  Possible formats: %s", formats);

        // note that it is VK_COLOR_SPACE_SRGB_NONLINEAR_KHR in later spec versions
        auto desiredFormat     = VkFormat.VK_FORMAT_B8G8R8A8_UNORM;
        auto desiredColorSpace = VkColorSpaceKHR.VK_COLORSPACE_SRGB_NONLINEAR_KHR;

        // If the format list includes just one entry of VK_FORMAT_UNDEFINED,
        // the surface has no preferred format. Otherwise, at least one
        // supported format will be returned
        if(formats.length == 1 && formats[0].format == VkFormat.VK_FORMAT_UNDEFINED) {
            colorFormat = VkFormat.VK_FORMAT_B8G8R8A8_UNORM;
            colorSpace  = formats[0].colorSpace;
        } else {
            colorFormat = formats[0].format;
            colorSpace  = formats[0].colorSpace;

            foreach(f; formats) {
                if(f.format==desiredFormat && f.colorSpace==desiredColorSpace) {
                    colorFormat = f.format;
                    colorSpace  = f.colorSpace;
                }
            }

        }
        this.log("Colour space  = %s", colorSpace);
        this.log("Colour format = %s", colorFormat);
    }
    VkPresentModeKHR selectPresentMode() {
        this.log("Selecting present mode (user requested vsync=%s) ...", vk.wprops.vsync);
        auto presentModes = physicalDevice.getPresentModes(surface);
        presentModes.dump();

        with(VkPresentModeKHR) {
            auto mode = VK_PRESENT_MODE_FIFO_KHR;
            foreach(m; presentModes) {
                if(vk.wprops.vsync) {
                    // VK_PRESENT_MODE_FIFO_KHR

                } else {
                    /// Use mailbox if available otherwise immediate
                    if(m==VK_PRESENT_MODE_MAILBOX_KHR) {
                        mode = m;
                    } else if(m==VK_PRESENT_MODE_IMMEDIATE_KHR) {
                        if(mode==VK_PRESENT_MODE_FIFO_KHR) {
                            mode = m;
                        }
                    }
                }
            }
            this.log(" Setting present mode to %s", mode);
            return mode;
        }
    }
    VkExtent2D selectExtent(VkSurfaceCapabilitiesKHR caps) {
        extent = caps.currentExtent;
        if(extent.width==uint.max) {
            // we can set it to what we want
            // todo - get values from somewhere
            extent = VkExtent2D(600,600);
        }
        this.log("Setting extent to %s", extent);
        return extent;
    }
    void getSwapChainImages() {
        uint count;
        check(getSwapchainImagesKHR(device, handle, &count, null));

        images.length = count;

        check(getSwapchainImagesKHR(device, handle, &count, images.ptr));

        this.log("Got %s images", images.length);
    }
    void createImageViews() {
        this.log("Creating image views");
        views.length = images.length;
        for(auto i=0; i<images.length; i++) {

            views[i] = device.createImageView(
                imageViewCreateInfo(images[i], colorFormat, VImageViewType._2D)
            );
        }
        this.log("Image views created");
    }
    /**
     *  Only one depth/stencil buffer is required regardless of the number of images in the swapchain.
     *  This is because only one image can be drawn at a time.
     */
    void createDepthBuffer() {
        auto format = vk.vprops.depthStencilFormat;
        if(format == VFormat.UNDEFINED) return;

        this.log("Creating depth/stencil buffer");

        auto mem = new MemoryAllocator(vk);

        // Note that this is an estimate. It would be better to determine the required size
        // of the image before allocating the memory.
        auto size = extent.width * extent.height * 4 * 4;

        this.depthStencilMem = mem.allocStdDeviceLocal("Swapchain_depthstencil", size);

        this.depthStencilImage = depthStencilMem.allocImage(
            "Swapchain_depthsetencil_image",
            [extent.width, extent.height],
            VImageUsage.DEPTH_STENCIL_ATTACHMENT | vk.vprops.depthStencilUsage,
            format
            );

        depthStencilImage.createView(format, VImageViewType._2D, VImageAspect.DEPTH);
    }
}

