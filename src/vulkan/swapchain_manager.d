module vulkan.swapchain_manager;

import vulkan.all;

final class VulkanSwapchain {
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
        init();
    }
    void destroy() {
        log("Swapchain: Destroying swapchain");
        foreach(ref v; views) {
            vkDestroyImageView(device, v, null);
        }
        destroySwapchainKHR(device, handle, null);
    }
    void create(VkSurfaceKHR surface) {
        this.surface = surface;

        selectSurfaceFormat();
        createSwapChain();
        getSwapChainImages();
        createImageViews();
    }
    /**
     * This needs to be done after create beecause it needs the renderPass
     * from the application which itself might need the swapchain :|
     */
    void createFrameBuffers(VkRenderPass renderPass) {
        expect(renderPass !is null);
        frameBuffers.length = numImages;
        foreach(i, view; views) {
            frameBuffers[i] = device.createFrameBuffer(
                renderPass,
                [view],
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
                log("Swapchain is out of date");
                break;
            case VK_SUBOPTIMAL_KHR:
                log("Swapchain is suboptimal");
                break;
            case VK_NOT_READY:
                log("Swapchain not ready");
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
                log("Swapchain is out of date");
                break;
            case VK_SUBOPTIMAL_KHR:
                log("Swapchain is suboptimal");
                break;
            case VK_NOT_READY:
                log("Swapchain not ready");
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

    void init() {
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

        log("Swapchain: Creating swap chain (size %s)", surfaceCaps.currentExtent);

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
    }
    VkSurfaceTransformFlagBitsKHR selectPreTransform(VkSurfaceCapabilitiesKHR caps) {
        auto trans = caps.currentTransform;
        with(VkSurfaceTransformFlagBitsKHR) {
            if(caps.supportedTransforms & VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR) {
                trans = VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR;
            }
        }
        log("Swapchain: Setting preTransform to %s", trans);
        return trans;
    }
    uint selectNumImages(VkSurfaceCapabilitiesKHR caps) {
        expect(vk.wprops.frameBuffers>0);
        uint num = max!int(caps.minImageCount, vk.wprops.frameBuffers);
        if(caps.maxImageCount>0 && num>caps.maxImageCount) {
            num = caps.maxImageCount;
        }
        log("Swapchain: Requesting %s images", num);
        return num;
    }
    void selectSurfaceFormat() {
        VkSurfaceFormatKHR[] formats = physicalDevice.getFormats(surface);
        assert(formats.length >= 1);

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
        log("Swapchain: Colour space  = %s", colorSpace);
        log("Swapchain: Colour format = %s", colorFormat);
    }
    VkPresentModeKHR selectPresentMode() {
        log("Swapchain: Selecting present mode (user requested vsync=%s) ...", vk.wprops.vsync);
        auto presentModes = physicalDevice.getPresentModes(surface);
        presentModes.dump();

        with(VkPresentModeKHR) {
            auto mode = VK_PRESENT_MODE_FIFO_KHR;
            foreach(m; presentModes) {
                if(vk.wprops.vsync) {
                    /// prefer mailbox over FIFO
                    if(m==VK_PRESENT_MODE_MAILBOX_KHR) {
                        mode = m;
                    }
                } else {
                    /// Use immediate if available otherwise mailbox
                    if(m==VK_PRESENT_MODE_IMMEDIATE_KHR) {
                        mode = m;
                    } else if(m==VK_PRESENT_MODE_MAILBOX_KHR) {
                        mode = m;
                    }
                }
            }
            log("Swapchain: Setting present mode to %s", mode);
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
        log("Swapchain: Setting extent to %s", extent);
        return extent;
    }
    void getSwapChainImages() {
        uint count;
        check(getSwapchainImagesKHR(device, handle, &count, null));

        images.length = count;

        check(getSwapchainImagesKHR(device, handle, &count, images.ptr));

        log("Swapchain: Got %s images", images.length);
    }
    void createImageViews() {
        log("Swapchain: Creating image views");
        views.length = images.length;
        for(auto i=0; i<images.length; i++) {

            views[i] = device.createImageView(
                imageViewCreateInfo(images[i], colorFormat, VImageViewType._2D)
            );
        }
    }
}

