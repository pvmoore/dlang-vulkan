module vulkan.api.shader;
/**
 * https://www.khronos.org/registry/vulkan/specs/1.0/man/html/VkShaderModuleCreateInfo.html
 */
import vulkan.all;

void destroy(VkDevice device, VkShaderModule shaderModule) {
    vkDestroyShaderModule(device, shaderModule, null);
}
