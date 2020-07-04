#version 450 core
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive     : require

// inputs
layout(location = 0) in vec4 colour;

// outputs
layout(location = 0) out vec4 color;


void main() {
    color = colour;
}