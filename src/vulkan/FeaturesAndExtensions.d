module vulkan.FeaturesAndExtensions;

import vulkan.all;

/**
 * Utility class to query device features and enable device features and extensions
 *
 * https://github.com/KhronosGroup/Vulkan-Guide/blob/master/chapters/enabling_features.adoc
 */
final class FeaturesAndExtensions {
private:
    @Borrowed VkPhysicalDevice physicalDevice;
    ubyte[] structs;
    uint[string] structIndexes;
    VkPhysicalDeviceFeatures2 features2 = {
        sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2
    };
    import cc = common.containers;
    cc.Set!string extensions;
    cc.Set!string features;
public:
    void initialise(VkPhysicalDevice physicalDevice, VulkanProperties vprops) {
        this.physicalDevice = physicalDevice;
        this.extensions = new cc.Set!string;
        this.features = new cc.Set!string;

        // Enable some common V1 features.
        // Most of these are forced to be enabled by the AMD driver anyway 
        VkPhysicalDeviceFeatures v1 = {
            fragmentStoresAndAtomics: VK_TRUE,      // required in 1.4
            samplerAnisotropy: VK_TRUE,             // required in 1.4
            geometryShader: VK_TRUE,                // optional
            vertexPipelineStoresAndAtomics: VK_TRUE // optional
        };

        if(isFeatureSupported!(VkPhysicalDeviceFeatures, "wideLines")) {
            v1.wideLines = VK_TRUE;
        }
        addFeature(v1);

        // Assume swapchain is always required
        addExtension(VK_KHR_SWAPCHAIN_EXTENSION_NAME);

        if(vprops.enableShaderPrintf) {
            throwIf(!vprops.isV11orHigher(), "Shader printf requires Vulkan 1.1 or later");

            if(!vprops.isV13orHigher()) {
                // VK_KHR_shader_non_semantic_info is required in 1.3
                addExtension(VK_KHR_SHADER_NON_SEMANTIC_INFO_EXTENSION_NAME);
            }
        }

        if(vprops.useDynamicRendering) {
            if(vprops.isV13orHigher()) {
                // Dynamic rendering is required in 1.3 and the feature now needs to be enabled in the 1.3 struct
                VkPhysicalDeviceVulkan13Features v13 = {
                    sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_3_FEATURES,
                    dynamicRendering: VK_TRUE
                };
                addFeature(v13);
            } else {
                // Before 1.3 we need to enable the extension and set the feature in its dedicated struct
                VkPhysicalDeviceDynamicRenderingFeatures dr = {
                    sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DYNAMIC_RENDERING_FEATURES,
                    dynamicRendering: VK_TRUE
                };
                addFeature(dr);
                addExtension(VK_KHR_DYNAMIC_RENDERING_EXTENSION_NAME);
            }
        }
    }

    /** 
     *  Get the features supported by the device for the given struct type eg.
     *    getSupportedFeatures!VkPhysicalDeviceFeatures 
     *    getSupportedFeatures!VkPhysicalDeviceVulkan11Features
     */
    T getSupportedFeatures(T)() if(isVulkanStruct!T || is(T == VkPhysicalDeviceFeatures)) {
        throwIf(physicalDevice is null, "initialise() must already have been called");

        static if(is(T == VkPhysicalDeviceFeatures)) {
            VkPhysicalDeviceFeatures2 f2 = fetchSupportedFeatures(null);
            return f2.features;
        } else {
            T f = { sType: getStructureType!T };
            fetchSupportedFeatures(&f);
            return f;
        }
    }

    /** 
     *  Check if a specific feature is supported by the device eg.
     *    isFeatureSupported!(VkPhysicalDeviceFeatures, "robustBufferAccess")
     *    isFeatureSupported!(VkPhysicalDeviceVulkan11Features, "synchronization2");
     */
    bool isFeatureSupported(T,string P)() if(isVulkanStruct!T || is(T == VkPhysicalDeviceFeatures)) {
        return __traits(getMember, getSupportedFeatures!T(), P) == VK_TRUE;
    }

    string[] getEnabledExtensionNames() {
        return extensions.keys();
    }
    string[] getEnabledFeatureNames() {
        return features.keys();
    }
    uint getExtensionsCount() {
        return extensions.size().as!uint;
    }

    /** Get extensions for device creation */
    immutable(char)** getExtensionsPP() {
        immutable(char)*[] ptrs = extensions.keys().map!(e=>e.toStringz()).array;
        return ptrs.ptr;
    }
    /** Get features for device creation */
    void* getFeaturesPP() {
        void* chain = null;

        static struct VulkanStructHeader {
            VkStructureType sType;
            void* pNext;
        }
        static assert(VulkanStructHeader.pNext.offsetof == 8);

        foreach(uint u; structIndexes.values()) {
            auto structPtr = (structs.ptr + u).as!(VulkanStructHeader*);
            structPtr.pNext = chain;
            chain = structPtr;
        }

        features2.pNext = chain;

        return &features2;
    }
    /** Get Vulkan 1.0 features for device creation */
    VkPhysicalDeviceFeatures* getV1FeaturesPtr() {
        return &features2.features;
    }

    /** Add a device extension */
    void addExtension(string ext) {
        extensions.add(ext);
    }
    /** Add one or more device extensions */
    void addExtensions(string[] exts...) {
        foreach(e; exts) {
            addExtension(e);
        }
    }

    /**
     * Enable one or more device features from the provided feature struct.  
     * eg:
     * VkPhysicalDeviceVulkan11Features v11 = {
     *     sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_FEATURES,
     *     storageBuffer16BitAccess: VK_TRUE
     * };
     * features.addFeature(v11);
     *
     * @params:
     *   featureStruct: The feature struct with the features you want to enabled.
     *                  (sType must be set correctly)
     */
    void addFeature(T)(T featureStruct) if(isVulkanStruct!T || is(T == VkPhysicalDeviceFeatures)) {
        throwIf(physicalDevice is null, "initialise() must already have been called");

        static if(is(T == VkPhysicalDeviceFeatures)) {
            features2.features = mergeStructs(features2.features, featureStruct);
        } else {
            string name = T.stringof;
            throwIf(featureStruct.sType == 0, "%s.sType must not be 0", name);

            if(auto indexPtr = name in structIndexes) {
                // Merge the existing struct with the new one
                auto index = *indexPtr;
                ubyte[] slice = structs[index..index+T.sizeof];

                T old = decodeStruct!T(slice);
                T merged = mergeStructs(old, featureStruct);
                
                slice[] = encodeStruct(merged);

            } else {
                // Append the new struct
                uint index = structs.length.as!uint;
                structIndexes[name] = index;
                structs ~= encodeStruct(featureStruct);
            }
        }
        // Fetch the actually supported features and check that the requested features are supported.
        // This will also add them to the features set
        T supported = getSupportedFeatures!T();
        assertRequestedFeatures(featureStruct, supported);
    }
    /** Add multiple feature structs (see addFeature) */
    void addFeatures(T...)(T features) {
        foreach(f; features) {
            addFeature(f);
        }
    }
private:
    ubyte[] encodeStruct(T)(T s) {
        return (&s).as!(ubyte*)[0..T.sizeof];
    }
    T decodeStruct(T)(ubyte[] bytes) {
        return *(bytes.ptr.as!(T*));
    }
    /** Return a new struct with the features from (a OR b) enabled */
    T mergeStructs(T)(T a, T b) {
        T c = a;
        foreach(m; __traits(allMembers, T)) {
            static if(is(VkBool32 == typeof(__traits(getMember, a, m)))) {
                VkBool32 aValue = __traits(getMember, a, m);
                VkBool32 bValue = __traits(getMember, b, m);
                if(aValue || bValue) {
                    __traits(getMember, c, m) = VK_TRUE;
                }
            }
        }
        return c;
    }
    VkPhysicalDeviceFeatures2 fetchSupportedFeatures(void* featureStructPtr) {
        VkPhysicalDeviceFeatures2 f2 = {
            sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2,
            pNext: featureStructPtr
        };
        vkGetPhysicalDeviceFeatures2(physicalDevice, &f2);
        return f2;
    }
    /** 
     *  Assert that all enabled features in the requested struct are supported by the device. 
     */
    void assertRequestedFeatures(T)(T requested, T actual) {
        foreach(m; __traits(allMembers, T)) {
            static if(is(VkBool32 == typeof(__traits(getMember, requested, m)))) {
                VkBool32 requestedValue = __traits(getMember, requested, m);
                if(requestedValue == VK_TRUE) {
                    VkBool32 actualValue = __traits(getMember, actual, m);
                    throwIf(actualValue == VK_FALSE, "Requested feature %s is not supported", m);
                    string featureName = "%s.%s".format(T.stringof, m);
                    features.add(featureName);
                    this.verbose(" ... Feature %s is supported", featureName);
                }
            }
        }
    }
}
