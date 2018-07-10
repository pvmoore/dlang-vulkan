#version 430 core
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_AMD_shader_trinary_minmax : enable
#extension GL_GOOGLE_include_directive : require

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

// inputs
layout(location = 0) in vec2 inPos[];
layout(location = 1) in vec2 inSize[];
layout(location = 2) in vec4 inColor1[];
layout(location = 3) in vec4 inColor2[];
layout(location = 4) in vec4 inColor3[];
layout(location = 5) in vec4 inColor4[];
layout(location = 6) in float inRadius[];

// outputs
layout(location = 0) out vec2 outPixelPos;
layout(location = 1) out flat vec2 outPos;
layout(location = 2) out flat vec2 outSize;
layout(location = 3) out vec4 outColor;
layout(location = 4) out flat float outRadius;

// bindings
layout(binding = 0, std140) uniform UBO {
    mat4 viewProj;
} ubo;

void main() {
    //  1--2
    //  | /|
    //  |/ |
    //  4--3
    //
    vec2 p1 = inPos[0];
    vec2 p2 = inPos[0] + vec2(inSize[0].x, 0);
    vec2 p3 = inPos[0] + inSize[0];
    vec2 p4 = inPos[0] + vec2(0, inSize[0].y);

    // 1
    gl_Position = ubo.viewProj * vec4(p1, 0, 1);
    outPixelPos = p1;
    outPos      = inPos[0];
    outSize     = inSize[0];
    outColor    = inColor1[0];
    outRadius   = inRadius[0];
    EmitVertex();

    // 2
    gl_Position = ubo.viewProj * vec4(p2, 0, 1);
    outPixelPos = p2;
    outPos      = inPos[0];
    outSize     = inSize[0];
    outColor    = inColor2[0];
    outRadius   = inRadius[0];
    EmitVertex();

    // 4
    gl_Position = ubo.viewProj * vec4(p4, 0, 1);
    outPixelPos = p4;
    outPos      = inPos[0];
    outSize     = inSize[0];
    outColor    = inColor4[0];
    outRadius   = inRadius[0];
    EmitVertex();

    // 3
    gl_Position = ubo.viewProj * vec4(p3, 0, 1);
    outPixelPos = p3;
    outPos      = inPos[0];
    outSize     = inSize[0];
    outColor    = inColor3[0];
    outRadius   = inRadius[0];
    EmitVertex();

    EndPrimitive();
}