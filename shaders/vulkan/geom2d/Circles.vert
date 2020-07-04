#version 450 core
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive     : require

#include "Circles.inc"

layout(location = 0) in vec4 posRadiusBorderRadius;	// xy, radius, borderRadius
layout(location = 1) in vec4 fillColour;
layout(location = 2) in vec4 edgeColour;

layout(location = 0) out VS_OUT vs_out;

void main() {
    vs_out.pos			 = posRadiusBorderRadius.xy;
    vs_out.fillColour	 = fillColour;
    vs_out.edgeColour	 = edgeColour;
    vs_out.radius		 = posRadiusBorderRadius.z;
    vs_out.edgeThickness = posRadiusBorderRadius.w;
}
