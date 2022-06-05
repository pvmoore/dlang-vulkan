module vulkan.misc.load_unload;

import vulkan.all;

void loadSharedLibs() {
    internalLoadGlfw();
    internalLoadVulkan();
    internalLoadImgui();
}
void unloadSharedLibs() {
    internalUnloadGlfw();
    internalUnloadVulkan();
    internalUnloadImgui();
}

private:

void internalLoadGlfw() {
    GLFWSupport ret = loadGLFW();
    if(ret != glfwSupport) {
        if(ret == GLFWSupport.noLibrary) {
            // The GLFW shared library failed to load
            vkassert(false, "GLFW shared library not found");
        } else if(GLFWSupport.badLibrary) {
            /*
            One or more symbols failed to load.
            The likely cause is that the shared library is for a lower version than
            bindbc-glfw was configured to load (via GLFW_31, GLFW_32 etc.)
            */
            vkassert(false, "The required GLFW version was not found");
        }
        vkassert(false, "GLFW could not be loaded");
    }
    loadGLFW_Windows();
    loadGLFW_Vulkan();
}
void internalUnloadGlfw() {
    unloadGLFW();
}

void internalLoadVulkan() {
    VulkanLoader.load();
    vkLoadGlobalCommandFunctions();
}
void internalUnloadVulkan() {
    VulkanLoader.unload();
}

void internalLoadImgui() {
    loadImGui();
}
void internalUnloadImgui() {
    unloadImGui();
}