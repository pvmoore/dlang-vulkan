#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(location = 0) in vec4 fragColor;
layout(location = 1) in vec2 fragUV;

layout(location = 0) out vec4 outColor;

layout(binding = 1) uniform sampler2D sampler0;

void main() {
    outColor = texture(sampler0, fragUV) * fragColor;
}