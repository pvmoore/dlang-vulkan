#version 460
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive     : require

// Inputs
layout(location = 0) in vec3 normal_worldspace;
layout(location = 1) in vec3 toLight_worldspace;
layout(location = 2) in vec3 toCamera_worldspace;
layout(location = 3) in vec2 in_UV;

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

layout(set = 0, binding = 1) uniform sampler2D sampler0;

void main() {
    vec3 specularColour = vec3(1,1,1);
    float reflectivity = 1.0f;
    float shineDamping = 10.0f;

	vec3 unitNormal   = normalize(normal_worldspace);
	vec3 unitToLight  = normalize(toLight_worldspace);
	vec3 unitToCamera = normalize(toCamera_worldspace);

    vec3 lightDirection			 = -unitToLight;
	vec3 reflectedLightDirection = reflect(lightDirection, unitNormal);

	vec3 ambient = vec3(0.05, 0.05, 0.05);

    float specularFactor = max(dot(reflectedLightDirection, unitToCamera), 0);
	float dampingFactor  = pow(specularFactor, shineDamping);
	vec3 specular 	     = dampingFactor * reflectivity * specularColour;

    float NdotL 	 = dot(unitNormal, unitToLight);
	float brightness = max(NdotL, 0);
	vec3 diffuse 	 = brightness * ubo.colour.rgb;

	vec4 t = texture(sampler0, in_UV);
    //out_colour = t*2 * vec4(ambient + diffuse + specular, ubo.colour.a);

    out_colour = t * vec4(ambient + diffuse + specular, ubo.colour.a);
}
