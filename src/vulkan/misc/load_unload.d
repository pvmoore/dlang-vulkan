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
    GLFWLoader.load();
}
void internalUnloadGlfw() {
    GLFWLoader.unload();
}

void internalLoadVulkan() {
    VulkanLoader.load();
    vkLoadGlobalCommandFunctions();
}
void internalUnloadVulkan() {
    VulkanLoader.unload();
}

void internalLoadImgui() {
    CImguiLoader.load();
}
void internalUnloadImgui() {
    CImguiLoader.unload();
}