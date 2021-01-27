#version 450 core
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive     : require

#include "Quads.inc"

// input
layout(location = 0) in vec2 pos;
layout(location = 1) in vec2 size;
layout(location = 2) in vec4 uv;        // top-left, bottom-right
layout(location = 3) in vec4 colour;
layout(location = 4) in float rotation;
layout(location = 5) in float enabled;

// output
layout(location = 0) out VS_OUT vs_out;

void main() {
    vs_out.pos      = pos;
    vs_out.size     = size;
    vs_out.uv       = uv;
    vs_out.colour   = colour;
    vs_out.rotation = rotation;
    vs_out.enabled  = enabled;
}