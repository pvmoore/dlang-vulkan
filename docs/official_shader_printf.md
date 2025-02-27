# Implementing printf inside Vulkan compute shaders

## Useful links

https://docs.vulkan.org/samples/latest/samples/extensions/shader_debugprintf/README.html

https://github.com/KhronosGroup/Vulkan-Samples/tree/main/samples/extensions/shader_debugprintf

https://www.khronos.org/registry/vulkan/specs/1.3-extensions/man/html/VK_EXT_debug_printf.html

VK_KHR_shader_non_semantic_info

```glsl
debugPrintfEXT("Transformed position = %v4f", outPosition);
```

## Setup

1. Add the layer VK_VALIDATION_FEATURE_ENABLE_DEBUG_PRINTF_EXT

```
VkValidationFeatureEnableEXT[]  validation_feature_enables =[VK_VALIDATION_FEATURE_ENABLE_DEBUG_PRINTF_EXT];

    VkValidationFeaturesEXT validation_features = { sType: VK_STRUCTURE_TYPE_VALIDATION_FEATURES_EXT };
    validation_features.enabledValidationFeatureCount = 1;
    validation_features.pEnabledValidationFeatures    = validation_feature_enables.ptr;

// chain this into the VkInstanceCreateInfo pNext ptr    

// Ensure the VK_LAYER_KHRONOS_validation layer is enabled
```
