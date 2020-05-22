module vulkan.api.instance;
/**
 *
 */
import vulkan.all;

VkInstance createInstance(VulkanProperties vprops) {
    log("Creating instance...");

    uint apiVersion = vprops.minApiVersion;

    // Request the latest version that the driver supports
    if(vkEnumerateInstanceVersion) {
        vkEnumerateInstanceVersion(&apiVersion);
        log(".. Driver supports Vulkan API version %s", versionToString(apiVersion));

        if(vprops.minApiVersion > apiVersion) {
            throw new Error("Requested Vulkan API version %s > driver version %s".format(versionToString(vprops.minApiVersion), versionToString(apiVersion)));
        }
    }

    VkInstance instance;
    VkApplicationInfo applicationInfo;
    VkInstanceCreateInfo instanceInfo;

    applicationInfo.sType			 = VkStructureType.VK_STRUCTURE_TYPE_APPLICATION_INFO;
    applicationInfo.pNext			 = null;
    applicationInfo.pApplicationName = vprops.appName.toStringz;
    applicationInfo.pEngineName		 = null;
    applicationInfo.engineVersion	 = 1;
    applicationInfo.apiVersion		 = apiVersion;

    instanceInfo.sType				 = VkStructureType.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    instanceInfo.pNext				 = null;
    instanceInfo.flags				 = 0;
    instanceInfo.pApplicationInfo	 = &applicationInfo;

    log(".. App name '%s'", applicationInfo.pApplicationName.fromStringz);
    log(".. Requested minimum API Version %s", applicationInfo.apiVersion.versionToString);

    // https://vulkan.lunarg.com/doc/view/1.0.46.0/windows/layers.html
    immutable(char)*[] layers = vprops.layers.dup;
    version(assert) {
        layers ~= [
            "VK_LAYER_LUNARG_standard_validation".ptr,
            //"VK_LAYER_LUNARG_api_dump".ptr
            "VK_LAYER_KHRONOS_validation".ptr,
            "VK_LAYER_LUNARG_monitor".ptr       // show FPS on title bar
        ];
    }
    instanceInfo.enabledLayerCount   = cast(uint)layers.length;
    instanceInfo.ppEnabledLayerNames = layers.ptr;

    if(instanceInfo.enabledLayerCount>0) {
        log(".. Enabled instance layers:");
        foreach(l; layers) log("\t\t%s", l.fromStringz);
    }

    auto extensions = [
        cast(char*)VK_KHR_SURFACE_EXTENSION_NAME,
        cast(char*)VK_KHR_WIN32_SURFACE_EXTENSION_NAME,
        cast(char*)VK_EXT_DEBUG_REPORT_EXTENSION_NAME
    ];
    instanceInfo.enabledExtensionCount	 = cast(uint)extensions.length;
    instanceInfo.ppEnabledExtensionNames = extensions.ptr;

    log(".. Enabled instance extensions:");
    foreach(e; extensions) log("\t\t%s", e.fromStringz);

    check(vkCreateInstance(&instanceInfo, null, &instance));

    dumpInstanceExtensions();
    dumpInstanceLayers();

    return instance;
}
// we can't use destroy here :(
void destroyInstance(VkInstance instance) {
    vkDestroyInstance(instance, null);
}
T getProcAddr(T)(VkInstance instance, string procName) {
    auto a = cast(T)vkGetInstanceProcAddr(instance, procName.ptr);
    assert(a);
    return a;
}
