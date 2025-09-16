module vulkan.DeviceFeatures;

import vulkan.all;

final class DeviceFeatures {
private:
    @Borrowed VkPhysicalDevice physicalDevice;
    VulkanProperties vprops;
    Features bitmap;

    VkPhysicalDeviceFeatures2 query;
    VkPhysicalDeviceFeatures v10Features;
    VkPhysicalDeviceVulkan11Features v11Features;
    VkPhysicalDeviceVulkan12Features v12Features;
    VkPhysicalDeviceVulkan13Features v13Features;
    VkPhysicalDeviceVulkan14Features v14Features;
    VkPhysicalDeviceRayTracingMaintenance1FeaturesKHR rtm1Features;
    VkPhysicalDeviceAccelerationStructureFeaturesKHR asFeatures;
    VkPhysicalDeviceRayTracingPipelineFeaturesKHR rtpFeatures;
    VkPhysicalDeviceRobustness2FeaturesKHR r2Features;
    VkPhysicalDeviceBufferDeviceAddressFeaturesEXT bdaFeatures;
    VkPhysicalDeviceDynamicRenderingFeatures drFeatures;
    VkPhysicalDeviceExtendedDynamicStateFeaturesEXT dsFeatures;
    VkPhysicalDeviceExtendedDynamicState2FeaturesEXT ds2Features;
    VkPhysicalDeviceExtendedDynamicState3FeaturesEXT ds3Features;
    VkPhysicalDeviceUnifiedImageLayoutsFeaturesKHR uilFeatures;
    VkPhysicalDeviceSynchronization2Features sync2Features;
    VkPhysicalDeviceComputeShaderDerivativesFeaturesKHR csdFeatures;
    VkPhysicalDeviceShaderQuadControlFeaturesKHR shaderQuadControlFeatures; 
public:
    enum Features : uint {
        None                     = 0,
        Vulkan11                 = 1<<0,
        Vulkan12                 = 1<<1,
        Vulkan13                 = 1<<2,
        Vulkan14                 = 1<<3,
        RayTracingMaintenance1   = 1<<4,
        AccelerationStructure    = 1<<5,
        RayTracingPipeline       = 1<<6,
        Robustness2              = 1<<7,
        BufferDeviceAddress      = 1<<8,
        DynamicRendering         = 1<<9,
        ExtendedDynamicState     = 1<<10,
        ExtendedDynamicState2    = 1<<11,
        ExtendedDynamicState3    = 1<<12,
        UnifiedImageLayouts      = 1<<13,    // VK_KHR_unified_image_layouts
        Synchronization2         = 1<<14,    // VK_KHR_synchronization2
        ComputeShaderDerivatives = 1<<15,    // VK_KHR_compute_shader_derivatives
        ShaderQuadControl        = 1<<16,    // VK_KHR_shader_quad_control
        
        // Add more features below here
    }
    this(VkPhysicalDevice physicalDevice, VulkanProperties vprops) {
        this.physicalDevice = physicalDevice;
        this.vprops = vprops;
        this.bitmap = vprops.features;

        if(vprops.useDynamicRendering) {
            bitmap |= Features.DynamicRendering;
        }

        if(vprops.isV10()) {
            queryFeaturesV10();
        } else {
            queryFeaturesV11();
        }
    }
    VkPhysicalDeviceFeatures* getV10FeaturesPtr() { return &v10Features; }
    VkPhysicalDeviceFeatures2* getFeatures2Ptr() { return &query; }
    //──────────────────────────────────────────────────────────────────────────────────────────────
    void apply(void delegate(ref VkPhysicalDeviceFeatures f) d) {
        if(vprops.isV10()) {
            d(v10Features);
        } else {
            d(query.features);
        }
    }
    void apply(void delegate(ref VkPhysicalDeviceVulkan11Features f) d) {
        throwIf(!isEnabled(Features.Vulkan11));
        d(v11Features);
    }
    void apply(void delegate(ref VkPhysicalDeviceVulkan12Features f) d) {
        throwIf(!isEnabled(Features.Vulkan12));
        d(v12Features);
    }
    void apply(void delegate(ref VkPhysicalDeviceVulkan13Features f) d) {
        throwIf(!isEnabled(Features.Vulkan13));
        d(v13Features);
    }
    void apply(void delegate(ref VkPhysicalDeviceVulkan14Features f) d) {
        throwIf(!isEnabled(Features.Vulkan14));
        d(v14Features);
    }
    void apply(void delegate(ref VkPhysicalDeviceRayTracingMaintenance1FeaturesKHR f) d) {
        throwIf(!isEnabled(Features.RayTracingMaintenance1));
        d(rtm1Features);
    }
    void apply(void delegate(ref VkPhysicalDeviceAccelerationStructureFeaturesKHR f) d) {
        throwIf(!isEnabled(Features.AccelerationStructure));
        d(asFeatures);
    }
    void apply(void delegate(ref VkPhysicalDeviceRayTracingPipelineFeaturesKHR f) d) {
        throwIf(!isEnabled(Features.RayTracingPipeline));
        d(rtpFeatures);
    }
    void apply(void delegate(ref VkPhysicalDeviceRobustness2FeaturesKHR f) d) {
        throwIf(!isEnabled(Features.Robustness2));
        d(r2Features);
    }
    void apply(void delegate(ref VkPhysicalDeviceBufferDeviceAddressFeaturesEXT f) d) {
        throwIf(!isEnabled(Features.BufferDeviceAddress));
        d(bdaFeatures);
    }
    void apply(void delegate(ref VkPhysicalDeviceDynamicRenderingFeatures f) d) {
        throwIf(!isEnabled(Features.DynamicRendering));
        d(drFeatures);
    }
    void apply(void delegate(ref VkPhysicalDeviceExtendedDynamicStateFeaturesEXT f) d) {
        throwIf(!isEnabled(Features.ExtendedDynamicState));
        d(dsFeatures);
    }
    void apply(void delegate(ref VkPhysicalDeviceExtendedDynamicState2FeaturesEXT f) d) {
        throwIf(!isEnabled(Features.ExtendedDynamicState2));
        d(ds2Features);
    }
    void apply(void delegate(ref VkPhysicalDeviceExtendedDynamicState3FeaturesEXT f) d) {
        throwIf(!isEnabled(Features.ExtendedDynamicState3));
        d(ds3Features);
    }
    void apply(void delegate(ref VkPhysicalDeviceUnifiedImageLayoutsFeaturesKHR f) d) {
        throwIf(!isEnabled(Features.UnifiedImageLayouts));
        d(uilFeatures);
    }
    void apply(void delegate(ref VkPhysicalDeviceSynchronization2Features f) d) {
        throwIf(!isEnabled(Features.Synchronization2));
        d(sync2Features);
    }
    void apply(void delegate(ref VkPhysicalDeviceComputeShaderDerivativesFeaturesKHR f) d) {
        throwIf(!isEnabled(Features.ComputeShaderDerivatives));
        d(csdFeatures);
    }
    void apply(void delegate(ref VkPhysicalDeviceShaderQuadControlFeaturesKHR f) d) {
        throwIf(!isEnabled(Features.ShaderQuadControl));
        d(shaderQuadControlFeatures);
    }
private:
    bool isEnabled(Features f) {
        return (bitmap&f) != 0;
    }
    void queryFeaturesV10() {
        this.verbose("Querying for V1.0 device features");

        v10Features = getFeatures(physicalDevice);
    }
    void queryFeaturesV11() {
        this.verbose("Querying for V1.1 device features: %s", toArray!Features(bitmap));

        // Setup the query chain

        query.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2;
        void* chainNext = null;

        if(isEnabled(Features.Vulkan11)) {
            v11Features.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_FEATURES;
            v11Features.pNext = chainNext;
            chainNext = &v11Features;
        }
        if(isEnabled(Features.Vulkan12)) {
            v12Features.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES;
            v12Features.pNext = chainNext;
            chainNext = &v12Features;
        }
        if(isEnabled(Features.Vulkan13)) {
            v13Features.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_3_FEATURES;
            v13Features.pNext = chainNext;
            chainNext = &v13Features;
        }
        if(isEnabled(Features.Vulkan14)) {
            v14Features.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_4_FEATURES;
            v14Features.pNext = chainNext;
            chainNext = &v14Features;
        }
        if(isEnabled(Features.RayTracingMaintenance1)) {
            rtm1Features.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_MAINTENANCE_1_FEATURES_KHR;
            rtm1Features.pNext = chainNext;
            chainNext = &rtm1Features;
        }
        if(isEnabled(Features.AccelerationStructure)) {
            asFeatures.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_FEATURES_KHR;
            asFeatures.pNext = chainNext;
            chainNext = &asFeatures;
        }
        if(isEnabled(Features.RayTracingPipeline)) {
            rtpFeatures.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PIPELINE_FEATURES_KHR;
            rtpFeatures.pNext = chainNext;
            chainNext = &rtpFeatures;
        }
        if(isEnabled(Features.Robustness2)) {
            r2Features.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ROBUSTNESS_2_FEATURES_EXT;
            r2Features.pNext = chainNext;
            chainNext = &r2Features;
        }
        if(isEnabled(Features.BufferDeviceAddress)) {
            bdaFeatures.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_BUFFER_DEVICE_ADDRESS_FEATURES;
            bdaFeatures.pNext = chainNext;
            chainNext = &bdaFeatures;
        }
        if(isEnabled(Features.DynamicRendering)) {
            drFeatures.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DYNAMIC_RENDERING_FEATURES;
            drFeatures.pNext = chainNext;
            chainNext = &drFeatures;
        }
        if(isEnabled(Features.ExtendedDynamicState)) {
            dsFeatures.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_FEATURES_EXT;
            dsFeatures.pNext = chainNext;
            chainNext = &dsFeatures;
        }
        if(isEnabled(Features.ExtendedDynamicState2)) {
            ds2Features.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_2_FEATURES_EXT;
            ds2Features.pNext = chainNext;
            chainNext = &ds2Features;
        }
        if(isEnabled(Features.ExtendedDynamicState3)) {
            ds3Features.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_3_FEATURES_EXT;
            ds3Features.pNext = chainNext;
            chainNext = &ds3Features;
        }
        if(isEnabled(Features.UnifiedImageLayouts)) {
            uilFeatures.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_UNIFIED_IMAGE_LAYOUTS_FEATURES_KHR;
            uilFeatures.pNext = chainNext;
            chainNext = &uilFeatures;
        }
        if(isEnabled(Features.Synchronization2)) {
            sync2Features.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SYNCHRONIZATION_2_FEATURES;
            sync2Features.pNext = chainNext;
            chainNext = &sync2Features;
        }
        if(isEnabled(Features.ComputeShaderDerivatives)) {
            csdFeatures.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COMPUTE_SHADER_DERIVATIVES_FEATURES_KHR;
            csdFeatures.pNext = chainNext;
            chainNext = &csdFeatures;
        }
        if(isEnabled(Features.ShaderQuadControl)) {
            shaderQuadControlFeatures.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_QUAD_CONTROL_FEATURES_KHR;
            shaderQuadControlFeatures.pNext = chainNext;
            chainNext = &shaderQuadControlFeatures;
        }

        // Query for all of the features we are interested in

        query.pNext = chainNext;
        vkGetPhysicalDeviceFeatures2(physicalDevice, &query);

        // Log the supported features

        dumpStructure(query.features);

        if(isEnabled(Features.Vulkan11)) {
            dumpStructure(v11Features);
        }
        if(isEnabled(Features.Vulkan12)) {
            dumpStructure(v12Features);
        }
        if(isEnabled(Features.Vulkan13)) {
            dumpStructure(v13Features);
        }
        if(isEnabled(Features.Vulkan14)) {
            dumpStructure(v14Features);
        }
        if(isEnabled(Features.RayTracingMaintenance1)) {
            dumpStructure(rtm1Features);
        }
        if(isEnabled(Features.AccelerationStructure)) {
            dumpStructure(asFeatures);
        }
        if(isEnabled(Features.RayTracingPipeline)) {
            dumpStructure(rtpFeatures);
        }
        if(isEnabled(Features.Robustness2)) {
            dumpStructure(r2Features);
        }
        if(isEnabled(Features.BufferDeviceAddress)) {
            dumpStructure(bdaFeatures);
        }
        if(isEnabled(Features.DynamicRendering)) {
            dumpStructure(drFeatures);
        }
        if(isEnabled(Features.ExtendedDynamicState)) {
            dumpStructure(dsFeatures);
        }
        if(isEnabled(Features.ExtendedDynamicState2)) {
            dumpStructure(ds2Features);
        }
        if(isEnabled(Features.ExtendedDynamicState3)) {
            dumpStructure(ds3Features);
        }
        if(isEnabled(Features.UnifiedImageLayouts)) {
            dumpStructure(uilFeatures);
        }
        if(isEnabled(Features.Synchronization2)) {
            dumpStructure(sync2Features);
        }
        if(isEnabled(Features.ComputeShaderDerivatives)) {
            dumpStructure(csdFeatures);
        }
        if(isEnabled(Features.ShaderQuadControl)) {
            dumpStructure(shaderQuadControlFeatures);
        }
    }
}
