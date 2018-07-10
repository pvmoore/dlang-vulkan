#version 430 core
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_AMD_shader_trinary_minmax : enable
#extension GL_GOOGLE_include_directive : require

layout(location = 0) in vec4 inColor;

layout(location = 0) out vec4 outColor;

void main() {
    outColor = inColor;
}