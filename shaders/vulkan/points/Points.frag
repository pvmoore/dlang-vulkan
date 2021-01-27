#version 450 core
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive     : require

#include "Points.inc"

layout(location = 0) in GS_OUT fs_in;
layout(location = 0) out vec4 color;

void main() {

    float dist = length(fs_in.pos);

    if(fs_in.enabled == 0 || dist > fs_in.size) discard;

    float f = 1 - (dist / fs_in.size);

    color = vec4(fs_in.colour.rgb, fs_in.colour.a * f);
}