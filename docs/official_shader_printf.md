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

1.
Optionally set the environment variables:
- 'VK_LAYER_PRINTF_BUFFER_SIZE' (default is 1024 MB).
- VK_LAYER_PRINTF_VERBOSE to 1 or 0 (default is 0)

2. Add the instance feature VK_VALIDATION_FEATURE_ENABLE_DEBUG_PRINTF_EXT
   Ensure the VK_LAYER_KHRONOS_validation layer is also enabled

3. Enable the device extension VK_KHR_shader_non_semantic_info

4. Enable in the shader code eg. "#extension GL_EXT_debug_printf : enable"

5. Use the following int the GLSL shader code:

GLSL

    debugPrintfEXT("hello");

HLSL or SLang

    printf("hello");

