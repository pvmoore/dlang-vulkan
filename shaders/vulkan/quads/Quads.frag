#version 450 core
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive     : require

#include "Quads.inc"

layout(location = 0) in GS_OUT fs_in;
layout(location = 0) out vec4 color;

layout(set = 0, binding = 1) uniform sampler2D sampler0;

void main() {

    if(fs_in.enabled == 0) discard;

    color =  texture(sampler0, fs_in.uv) * fs_in.colour;
}
