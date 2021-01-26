#version 450 core
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive     : require

#include "Points.inc"

// input
layout(location = 0) in vec2 pos;
layout(location = 1) in float size;
layout(location = 2) in float enabled;
layout(location = 3) in vec4 colour;

// output
layout(location = 0) out VS_OUT vs_out;

void main() {
    vs_out.pos     = pos;
    vs_out.size    = size;
    vs_out.enabled = enabled;
    vs_out.colour  = colour;
}
