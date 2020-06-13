#version 450
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive     : require

layout(location = 0) in vec3 normal_worldspace;
layout(location = 1) in vec3 toLight_worldspace;
layout(location = 2) in vec3 toCamera_worldspace;
layout(location = 3) in vec2 vertexUV;
layout(location = 4) in vec4 inColour;

layout(location = 0) out vec4 color;

layout(set = 0, binding = 1, std140) uniform UBO {
	float shineDamping;
	float reflectivity;
	float _pad1;
	float _pad2;
} ubo;

layout(set = 0, binding = 2) uniform sampler2D sampler0;

void main() {
	vec3 specularColour = vec3(1,1,1);

	vec3 unitNormal   = normalize(normal_worldspace);
	vec3 unitToLight  = normalize(toLight_worldspace);
	vec3 unitToCamera = normalize(toCamera_worldspace);

	vec3 lightDirection			 = -unitToLight;
	vec3 reflectedLightDirection = reflect(lightDirection, unitNormal);

	vec3 ambient = vec3(0.05, 0.05, 0.05);

	float specularFactor = max(dot(reflectedLightDirection, unitToCamera), 0);
	float dampingFactor  = pow(specularFactor, ubo.shineDamping);
	vec3 specular 	     = dampingFactor * ubo.reflectivity * specularColour;

	float NdotL 	 = dot(unitNormal, unitToLight);
	float brightness = max(NdotL, 0);
	vec3 diffuse 	 = brightness * inColour.rgb;

	vec4 t = texture(sampler0, vertexUV);

	color = t*2 * vec4(ambient + diffuse + specular, inColour.a);
}