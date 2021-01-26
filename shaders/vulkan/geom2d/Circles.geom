#version 450 core
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive     : require

#include "Circles.inc"

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

// bindings
layout(set = 0, binding = 0, std140) uniform UBO {
    mat4 viewProj; 
} ubo;

layout(location = 0) in VS_OUT gs_in[];
layout(location = 0) out GS_OUT gs_out;

void main() {
    vec2 pp = gs_in[0].pos;

    float r		 = gs_in[0].radius + (gs_in[0].edgeThickness*0.5);
    vec4 pos0    = vec4(pp-r, 0, 1);
    vec4 pos2    = vec4(pp+r, 0, 1);
    vec4 pos1    = vec4(pp.x-r, pp.y+r, 0, 1);
    vec4 pos3    = vec4(pp.x+r, pp.y-r, 0, 1);

    gl_Position		     = ubo.viewProj * pos0;
    gs_out.pos		     = pos0.xy-pp;
    gs_out.fillColour    = gs_in[0].fillColour;
    gs_out.edgeColour    = gs_in[0].edgeColour;
    gs_out.radius	     = gs_in[0].radius;
    gs_out.edgeThickness = gs_in[0].edgeThickness;
    EmitVertex();

    gl_Position			 = ubo.viewProj * pos1;
    gs_out.pos			 = pos1.xy-pp;
    gs_out.fillColour    = gs_in[0].fillColour;
    gs_out.edgeColour    = gs_in[0].edgeColour;
    gs_out.radius	     = gs_in[0].radius;
    gs_out.edgeThickness = gs_in[0].edgeThickness;
    EmitVertex();

    gl_Position			 = ubo.viewProj * pos3;
    gs_out.pos			 = pos3.xy-pp;
    gs_out.fillColour    = gs_in[0].fillColour;
    gs_out.edgeColour    = gs_in[0].edgeColour;
    gs_out.radius	     = gs_in[0].radius;
    gs_out.edgeThickness = gs_in[0].edgeThickness;
    EmitVertex();

    gl_Position			 = ubo.viewProj * pos2;
    gs_out.pos			 = pos2.xy-pp;
    gs_out.fillColour    = gs_in[0].fillColour;
    gs_out.edgeColour    = gs_in[0].edgeColour;
    gs_out.radius	     = gs_in[0].radius;
    gs_out.edgeThickness = gs_in[0].edgeThickness;
    EmitVertex();

    EndPrimitive();
}