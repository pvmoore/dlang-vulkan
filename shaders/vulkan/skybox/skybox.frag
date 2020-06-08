#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(location = 0) in vec3 inUvs;

layout(location = 0) out vec4 outColor;

layout(set = 0, binding = 1) uniform samplerCube sampler0;

void main() {
    outColor = texture(sampler0, inUvs * 0.01);
    //outColor = vec4(1,1,1,1);
}