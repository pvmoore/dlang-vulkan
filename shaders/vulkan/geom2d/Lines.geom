#version 450 core
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive     : require

#include "Lines.inc"

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

// input
layout(location = 0) in VS_OUT gs_in[];

// output
layout(location = 0) out vec4 colour;

// bindings
layout(set = 0, binding = 0, std140) uniform UBO {
    mat4 viewProj; // [  0]
} ubo;

void main() {
    vec2 pos0    = gs_in[0].from;
    vec2 pos1    = gs_in[0].to;
    vec2 forward = normalize(pos1 - pos0);

    // stretch the line to account for thickness
    pos0 -= forward * gs_in[0].thickness * 0.5;
    pos1 += forward * gs_in[0].thickness * 0.5;

    vec2 right   = vec2(-forward.y, forward.x);
    vec2 offset  = (vec2(gs_in[0].thickness) / 2) * right;

    gl_Position = ubo.viewProj * vec4(pos0 + offset, 0, 1);
    colour      = gs_in[0].fromColour;
    EmitVertex();
    gl_Position = ubo.viewProj * vec4(pos0 - offset, 0, 1);
    colour      = gs_in[0].fromColour;
    EmitVertex();
    gl_Position = ubo.viewProj * vec4(pos1 + offset, 0, 1);
    colour      = gs_in[0].toColour;
    EmitVertex();
    gl_Position = ubo.viewProj * vec4(pos1 - offset, 0, 1);
    colour      = gs_in[0].toColour;
    EmitVertex();

    EndPrimitive();
}