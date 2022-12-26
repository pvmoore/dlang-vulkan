module vulkan.api.instance;

import vulkan.all;

VkInstance createInstance(VulkanProperties vprops) {
    log("Creating instance...");

    uint driverApiVersion = 0;

    //Log latest version that the driver supports
    if(vkEnumerateInstanceVersion) {
        vkEnumerateInstanceVersion(&driverApiVersion);
        log(".. Driver supports Vulkan API version %s", versionToString(driverApiVersion));
    }

    // Exit if we know the driver does not support the requested version
    if(vprops.apiVersion > driverApiVersion && driverApiVersion != 0) {
        throw new Error("Requested Vulkan API version %s > driver version %s".format(versionToString(vprops.apiVersion), versionToString(driverApiVersion)));
    }


    VkInstance instance;
    VkApplicationInfo applicationInfo;
    VkInstanceCreateInfo instanceInfo;

    applicationInfo.sType			   = VkStructureType.VK_STRUCTURE_TYPE_APPLICATION_INFO;
    applicationInfo.pNext			   = null;
    applicationInfo.pApplicationName   = vprops.appName.toStringz;
    applicationInfo.applicationVersion = 1;
    applicationInfo.pEngineName		   = null;
    applicationInfo.engineVersion	   = 1;
    applicationInfo.apiVersion		   = vprops.apiVersion;

    instanceInfo.sType				 = VkStructureType.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    instanceInfo.pNext				 = null;
    instanceInfo.flags				 = 0;
    instanceInfo.pApplicationInfo	 = &applicationInfo;

    log(".. Requested Vulkan API Version %s", applicationInfo.apiVersion.versionToString);
    log(".. App name '%s'", applicationInfo.pApplicationName.fromStringz);

    auto info = new InstanceInfo();

    info.dumpLayers();
    info.dumpExtensions();

    immutable(char)*[] layers = vprops.layers.dup;

    version(assert) {

        if(info.hasLayer("VK_LAYER_KHRONOS_validation")) {
            layers ~= "VK_LAYER_KHRONOS_validation".ptr;

        } else if(info.hasLayer("VK_LAYER_LUNARG_standard_validation")) {
            layers ~= "VK_LAYER_LUNARG_standard_validation".ptr;
        }

        if(info.hasLayer("VK_LAYER_LUNARG_api_dump")) {
            layers ~= "VK_LAYER_LUNARG_api_dump".ptr;
        }

        // "VK_LAYER_LUNARG_api_dump".ptr       // prints API calls, parameters, and values
        // "VK_LAYER_LUNARG_monitor".ptr        // show FPS on title bar
    }
    instanceInfo.enabledLayerCount   = cast(uint)layers.length;
    instanceInfo.ppEnabledLayerNames = layers.ptr;

    if(instanceInfo.enabledLayerCount>0) {
        log(".. Enabled instance layers:");
        foreach(l; layers) log("\t\t%s", l.fromStringz);
    }

    auto extensions = [
        "VK_KHR_surface".ptr,
        "VK_KHR_win32_surface".ptr,
        "VK_EXT_debug_report".ptr
    ];
    instanceInfo.enabledExtensionCount	 = cast(uint)extensions.length;
    instanceInfo.ppEnabledExtensionNames = extensions.ptr;

    log(".. Enabled instance extensions:");
    foreach(e; extensions) log("\t\t%s", e.fromStringz);

    check(vkCreateInstance(&instanceInfo, null, &instance));

    log("Instance created successfully");
    return instance;
}
// we can't use destroy here :(
void destroyInstance(VkInstance instance) {
    vkDestroyInstance(instance, null);
}
T getProcAddr(T)(VkInstance instance, string procName) {
    auto a = cast(T)vkGetInstanceProcAddr(instance, procName.ptr);
    vkassert(a);
    return a;
}
