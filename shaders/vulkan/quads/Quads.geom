#version 450 core
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive     : require

#include "Quads.inc"

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

// bindings
layout(set = 0, binding = 0, std140) uniform UBO {
    mat4 viewProj;
} ubo;

layout(location = 0) in VS_OUT gs_in[];
layout(location = 0) out GS_OUT gs_out;

mat4 getTranslationMatrix() {
    mat4 m = mat4(1);
    m[3][0] = gs_in[0].pos.x + gs_in[0].size.x*0.5;
    m[3][1] = gs_in[0].pos.y + gs_in[0].size.y*0.5;
    return m;
}
mat4 getRotationZMatrix() {
    mat4 m = mat4(1);
    float angle = gs_in[0].rotation;
    float C = cos(angle);
    float S = sin(angle);
    m[0][0] = C;
    m[0][1] = S;
    m[1][0] = -S;
    m[1][1] = C;
    return m;
}
// vec2 pos;
// vec2 size;
// vec4 uv;
// vec4 colour;
// float rotation;
// float enabled;

// vec2 uv;
// vec4 colour;
// float enabled;

void main() {
    if(gs_in[0].enabled == 1) {

        mat4 trans = ubo.viewProj * getTranslationMatrix() * getRotationZMatrix();
        vec2 pp = gs_in[0].pos;

        // 0-----3
        // |   / |
        // |  ·  |
        // | /   |
        // 1-----2

        vec2 r		 = gs_in[0].size * 0.5;

        vec4 pos0    = vec4(-r, 0, 1);
        vec4 pos2    = vec4(r, 0, 1);
        vec4 pos1    = vec4(-r.x, r.y, 0, 1);
        vec4 pos3    = vec4(r.x, -r.y, 0, 1);

        // xy
        // zw

        gl_Position	   = trans * pos0;
        gs_out.uv      = gs_in[0].uv.xy;
        gs_out.colour  = gs_in[0].colour;
        EmitVertex();

        gl_Position	   = trans * pos1;
        gs_out.uv      = gs_in[0].uv.xw;
        gs_out.colour  = gs_in[0].colour;
        EmitVertex();

        gl_Position	   = trans * pos3;
        gs_out.uv      = gs_in[0].uv.zy;
        gs_out.colour  = gs_in[0].colour;
        EmitVertex();

        gl_Position	   = trans * pos2;
        gs_out.uv      = gs_in[0].uv.zw;
        gs_out.colour  = gs_in[0].colour;
        EmitVertex();

        EndPrimitive();
    }
}