#version 450
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive     : require

layout(location = 0) in vec3 vertexPosition_modelspace;
layout(location = 1) in vec3 vertexNormal_modelspace;
layout(location = 2) in vec2 vertexUV;
layout(location = 3) in vec4 vertexColour;

layout(location = 0) out vec3 normal_worldspace;
layout(location = 1) out vec3 toLight_worldspace;
layout(location = 2) out vec3 toCamera_worldspace;
layout(location = 3) out vec2 outVertexUV;
layout(location = 4) out vec4 outColour;

layout(set = 0, binding = 0, std140) uniform UBO {
	mat4 VP;
	mat4 V;
	mat4 invV;
	mat4 M;
	vec3 LightPosition_worldspace;
	float _pad1;
} ubo;

void main() {
	gl_Position =  ubo.VP * ubo.M * vec4(vertexPosition_modelspace, 1);

	vec4 position_worldspace = ubo.M * vec4(vertexPosition_modelspace, 1);

	normal_worldspace   = (ubo.M*vec4(vertexNormal_modelspace, 0)).xyz;
	toLight_worldspace  = ubo.LightPosition_worldspace - position_worldspace.xyz;
	toCamera_worldspace = ((ubo.invV * vec4(0, 0, 0, 1) - position_worldspace)).xyz;
	outVertexUV			= vertexUV;
	outColour			= vertexColour;
}

