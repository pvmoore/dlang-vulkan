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
layout(location = 1) out vec2 pos;
layout(location = 2) out flat vec2 from;
layout(location = 3) out flat vec2 to;
layout(location = 4) out flat float halfFromThickness;
layout(location = 5) out flat float halfToThickness;

// bindings
layout(set = 0, binding = 0, std140) uniform UBO {
    mat4 viewProj; // [  0]
} ubo;

void main() {
    vec2 pos0    = gs_in[0].from;
    vec2 pos1    = gs_in[0].to;
    vec2 forward = normalize(pos1 - pos0);

    // stretch the line to account for thickness
    pos0 -= forward * gs_in[0].fromThickness * 0.5;
    pos1 += forward * gs_in[0].toThickness * 0.5;

    vec2 right   = vec2(-forward.y, forward.x);
    vec2 offset0 = (vec2(gs_in[0].fromThickness) / 2) * right;
    vec2 offset1 = (vec2(gs_in[0].toThickness) / 2) * right;

    gl_Position       = ubo.viewProj * vec4(pos0 + offset0, 0, 1);
    colour            = gs_in[0].fromColour;
    pos               = pos0 + offset0;
    from              = gs_in[0].from;
    to                = gs_in[0].to;
    halfFromThickness = gs_in[0].fromThickness * 0.5f;
    halfToThickness   = gs_in[0].toThickness * 0.5f;
    EmitVertex();

    gl_Position       = ubo.viewProj * vec4(pos0 - offset0, 0, 1);
    colour            = gs_in[0].fromColour;
    pos               = pos0 - offset0;
    from              = gs_in[0].from;
    to                = gs_in[0].to;
    halfFromThickness = gs_in[0].fromThickness * 0.5f;
    halfToThickness   = gs_in[0].toThickness * 0.5f;
    EmitVertex();

    gl_Position       = ubo.viewProj * vec4(pos1 + offset1, 0, 1);
    colour            = gs_in[0].toColour;
    pos               = pos1 + offset1;
    from              = gs_in[0].from;
    to                = gs_in[0].to;
    halfFromThickness = gs_in[0].fromThickness * 0.5f;
    halfToThickness   = gs_in[0].toThickness * 0.5f;
    EmitVertex();

    gl_Position       = ubo.viewProj * vec4(pos1 - offset1, 0, 1);
    colour            = gs_in[0].toColour;
    pos               = pos1 - offset1;
    from              = gs_in[0].from;
    to                = gs_in[0].to;
    halfFromThickness = gs_in[0].fromThickness * 0.5f;
    halfToThickness   = gs_in[0].toThickness * 0.5f;
    EmitVertex();

    EndPrimitive();
}