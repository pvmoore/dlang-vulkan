module vulkan.api.instance;

import vulkan.all;

VkInstance createInstance(VulkanProperties vprops, InstanceHelper helper) {
    verbose(__FILE__, "Creating instance...");

    // Log the latest version that the driver supports.
    // This is a Vulkan 1.1 feature

    if(vkEnumerateInstanceVersion) {
        uint instanceApiVersion = 0;
        vkEnumerateInstanceVersion(&instanceApiVersion);
        verbose(__FILE__, ".. This Vulkan instance supports API version %s", versionToString(instanceApiVersion));
    
        // Exit if we know the instance does not support the requested version
        if(vprops.apiVersion > instanceApiVersion && instanceApiVersion != 0) {
            throwIf(true, "Requested Vulkan API version %s > instance version %s", versionToString(vprops.apiVersion), versionToString(instanceApiVersion));
        }
    }

    VkApplicationInfo applicationInfo = {
        sType: VkStructureType.VK_STRUCTURE_TYPE_APPLICATION_INFO,
        pApplicationName: vprops.appName.toStringz,
        applicationVersion: 1,
        pEngineName: null,
        engineVersion: 1,
        apiVersion: vprops.apiVersion
    };
    
    VkInstanceCreateInfo instanceCreateInfo = {
        sType: VkStructureType.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        pApplicationInfo: &applicationInfo
    };

    verbose(__FILE__, ".. Requested Vulkan API Version %s", applicationInfo.apiVersion.versionToString);
    verbose(__FILE__, ".. App name '%s'", applicationInfo.pApplicationName.fromStringz);

    helper.dumpLayers();
    helper.dumpExtensions();

    immutable(char)*[] requestedLayers = vprops.layers.dup;

    // Add validation layer if we are in debug mode
    debug {
        if(helper.hasLayer("VK_LAYER_KHRONOS_validation")) {
            requestedLayers ~= "VK_LAYER_KHRONOS_validation".ptr;
        } 
    }
    instanceCreateInfo.enabledLayerCount   = cast(uint)requestedLayers.length;
    instanceCreateInfo.ppEnabledLayerNames = requestedLayers.ptr;

    if(instanceCreateInfo.enabledLayerCount>0) {
        verbose(__FILE__, "Enabled instance layers:");
        foreach(l; requestedLayers) verbose(__FILE__, "\t\t%s", l.fromStringz);
    }

    auto extensions = [
        "VK_KHR_surface".ptr,
        "VK_KHR_win32_surface".ptr
    ];

    if(helper.hasExtension("VK_EXT_debug_utils")) {
        extensions ~= "VK_EXT_debug_utils".ptr;
    } 

    instanceCreateInfo.enabledExtensionCount	 = cast(uint)extensions.length;
    instanceCreateInfo.ppEnabledExtensionNames = extensions.ptr;

    verbose(__FILE__, "Enabled instance extensions:");
    foreach(e; extensions) verbose(__FILE__, "\t\t%s", e.fromStringz);

    // Add validation features
    VkValidationFeatureEnableEXT[] enabledValidations;
    VkValidationFeatureDisableEXT[] disabledValidations;
    
    if(vprops.enableGpuValidation) {
        verbose(__FILE__, "Enabling GPU validation");

        enabledValidations ~= [
            VK_VALIDATION_FEATURE_ENABLE_GPU_ASSISTED_EXT,
            VK_VALIDATION_FEATURE_ENABLE_BEST_PRACTICES_EXT,
            VK_VALIDATION_FEATURE_ENABLE_SYNCHRONIZATION_VALIDATION_EXT
        ];
        
    } else {
        verbose(__FILE__, "Disabling GPU validation");
        disabledValidations ~= VK_VALIDATION_FEATURE_DISABLE_ALL_EXT;
    }
    // Note that the doc says that shader printf cannot be enabled at the same time as 
    // GPU assisted validation but this seems to work fine for me.
    if(vprops.enableShaderPrintf) {
        enabledValidations ~= VK_VALIDATION_FEATURE_ENABLE_DEBUG_PRINTF_EXT;
    }

    VkValidationFeaturesEXT validationFeatures = {
        sType: VK_STRUCTURE_TYPE_VALIDATION_FEATURES_EXT,
        enabledValidationFeatureCount: enabledValidations.length.as!uint,
        disabledValidationFeatureCount: disabledValidations.length.as!uint,
        pEnabledValidationFeatures: enabledValidations.ptr,
        pDisabledValidationFeatures: disabledValidations.ptr
    };

    verbose(__FILE__, "VkValidationFeatureEnableEXT: (%s)", enabledValidations.length);
    foreach(v; enabledValidations) verbose(__FILE__, "\t\t%s", v.to!string);
    verbose(__FILE__, "VkValidationFeatureDisableEXT: (%s)", disabledValidations.length);
    foreach(v; disabledValidations) verbose(__FILE__, "\t\t%s", v.to!string);
    
    instanceCreateInfo.pNext = &validationFeatures;

    VkInstance instance;
    check(vkCreateInstance(&instanceCreateInfo, null, &instance));

    verbose(__FILE__, "Instance created successfully");
    return instance;
}
// we can't use destroy here :(
void destroyInstance(VkInstance instance) {
    vkDestroyInstance(instance, null);
}
T getProcAddr(T)(VkInstance instance, string procName) {
    auto a = cast(T)vkGetInstanceProcAddr(instance, procName.ptr);
    throwIf(a is null);
    return a;
}
