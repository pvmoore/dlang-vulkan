module vulkan.api.shader;
/**
 * https://www.khronos.org/registry/vulkan/specs/1.0/man/html/VkShaderModuleCreateInfo.html
 */
import vulkan.all;

VkShaderModule createShaderModule(VkDevice device, string filename) {
    import std.stdio : File;
    auto f = File(filename, "rb");
    scope(exit) f.close();

    auto bytes = f.rawRead(new ubyte[f.size]);
    return createShaderModule(device, bytes);
}
VkShaderModule createShaderModule(VkDevice device, ubyte[] code) {
    VkShaderModule handle;
    VkShaderModuleCreateInfo info;
    info.sType      = VkStructureType.VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO;
    info.flags      = 0;
    info.codeSize   = code.length;    // in bytes
    info.pCode      = cast(uint*)code.ptr;

    check(vkCreateShaderModule(
        device,
        &info,
        null,
        &handle
    ));
    return handle;
}
void destroy(VkDevice device, VkShaderModule shaderModule) {
    vkDestroyShaderModule(device, shaderModule, null);
}
