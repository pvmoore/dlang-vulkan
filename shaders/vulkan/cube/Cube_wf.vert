#version 460 core
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive     : require

// Inputs
layout(location = 0) in vec3 in_pos;

// Outputs

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
    gl_Position = ubo.VP * ubo.M * vec4(in_pos, 1);
}
