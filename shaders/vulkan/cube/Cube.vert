#version 460 core
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive     : require

// Inputs
layout(location = 0) in vec3 in_pos;
layout(location = 1) in vec3 in_normal;
layout(location = 2) in vec2 in_UV;

// Outputs
layout(location = 0) out vec3 normal_worldspace;
layout(location = 1) out vec3 toLight_worldspace;
layout(location = 2) out vec3 toCamera_worldspace;
layout(location = 3) out vec2 out_UV;

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

    vec4 position_worldspace = ubo.M * vec4(in_pos, 1);

    normal_worldspace   = (ubo.M*vec4(in_normal, 0)).xyz;
	toLight_worldspace  = ubo.lightPosition_worldspace - position_worldspace.xyz;
	toCamera_worldspace = ((ubo.invV * vec4(0, 0, 0, 1) - position_worldspace)).xyz;
    out_UV			    = in_UV;
}
