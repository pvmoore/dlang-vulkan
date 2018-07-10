#version 430 core
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_AMD_shader_trinary_minmax : enable
#extension GL_GOOGLE_include_directive : require

// input
layout(location = 0) in vec2 inPos;
layout(location = 1) in vec2 inSize;
layout(location = 2) in vec4 inColor1;
layout(location = 3) in vec4 inColor2;
layout(location = 4) in vec4 inColor3;
layout(location = 5) in vec4 inColor4;
layout(location = 6) in float inRadius;

// output
layout(location = 0) out vec2 outPos;
layout(location = 1) out vec2 outSize;
layout(location = 2) out vec4 outColor1;
layout(location = 3) out vec4 outColor2;
layout(location = 4) out vec4 outColor3;
layout(location = 5) out vec4 outColor4;
layout(location = 6) out float outRadius;

// bindings

void main() {
    outPos     = inPos;
    outSize    = inSize;
    outColor1  = inColor1;
    outColor2  = inColor2;
    outColor3  = inColor3;
    outColor4  = inColor4;
    outRadius  = inRadius;
}