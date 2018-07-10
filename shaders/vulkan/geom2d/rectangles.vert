#version 430 core
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_AMD_shader_trinary_minmax : enable
#extension GL_GOOGLE_include_directive : require

// input
layout(location = 0) in vec2 inPosition;
layout(location = 1) in vec4 inColor;

// output
layout(location = 0) out vec4 outColor;

// bindings
layout(binding = 0, std140) uniform UBO {
    mat4 viewProj;
} ubo;

void main() {
    gl_Position = ubo.viewProj * vec4(inPosition, 0, 1);
    outColor    = inColor;
}