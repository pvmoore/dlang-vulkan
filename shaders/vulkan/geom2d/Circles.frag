#version 450 core
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive     : require

#include "Circles.inc"

layout(location = 0) in GS_OUT fs_in;
layout(location = 0) out vec4 color;

void main() {
    float dist = length(fs_in.pos);

    float f = clamp(fs_in.radius - dist, 0, 1);

    float a = abs(dist - fs_in.radius) / (fs_in.edgeThickness*0.5);
    float p = pow(a, max(5, fs_in.edgeThickness*1));
    float e = clamp(1 - p, 0, 1);

    vec4 fill = fs_in.fillColour;
    vec4 edge = fs_in.edgeColour;

    color = mix(vec4(0), fill, f) + mix(vec4(0), edge, e);
}
