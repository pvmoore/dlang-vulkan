#version 450 core
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive     : require

#include "Lines.inc"

// input
layout(location = 0) in vec4 fromTo;
layout(location = 1) in vec4 fromColour;
layout(location = 2) in vec4 toColour;
layout(location = 3) in float fromThickness;
layout(location = 4) in float toThickness;

// output
layout(location = 0) out VS_OUT vs_out;

void main() {
    vs_out.from          = fromTo.xy;
    vs_out.to            = fromTo.zw;
    vs_out.fromColour    = fromColour;
    vs_out.toColour      = toColour;
    vs_out.fromThickness = fromThickness;
    vs_out.toThickness   = toThickness;
}
