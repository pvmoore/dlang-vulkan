#version 460
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive     : require

// Inputs

// Outputs
layout(location = 0) out vec4 out_colour;

// Bindings
layout(set = 0, binding = 0, std140) uniform UBO {
	mat4 VP;
	mat4 V;
	mat4 invV;
	mat4 M;
    vec3 lightPosition_worldspace;
    float _pad;
    vec4 colour;
} ubo;

void main() {
    out_colour = ubo.colour;
}
