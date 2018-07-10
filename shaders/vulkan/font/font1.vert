#version 430 core
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

// inputs
layout(location = 0) in vec4 in_pos;	// x,y,w,h
layout(location = 1) in vec4 in_uvs;    // uv, uv2
layout(location = 2) in vec4 in_colour;
layout(location = 3) in float in_size;

// outputs
layout(location = 0) out vec4 out_posdim;
layout(location = 1) out vec4 out_uvs;
layout(location = 2) out vec4 out_colour;
layout(location = 3) out float out_size;

// bindings (None)

void main() {
    out_posdim   = in_pos;
    out_uvs	     = in_uvs;
    out_colour   = in_colour;
    out_size     = in_size;
}