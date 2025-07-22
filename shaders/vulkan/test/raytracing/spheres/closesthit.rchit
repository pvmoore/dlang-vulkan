/* 
 * This is a modified version of Sascha Willems' ray tracing tutorial.
 * For original see https://github.com/SaschaWillems/Vulkan
 */
#version 460
#extension GL_EXT_ray_tracing : require
#extension GL_EXT_nonuniform_qualifier : enable
#extension GL_EXT_debug_printf : enable

layout(location = 0) rayPayloadInEXT vec3 hitValue;
layout(location = 2) rayPayloadEXT bool shadowed;
hitAttributeEXT vec2 attribs;

layout(binding = 2, set = 0) uniform UBO {
	mat4 viewInverse;
	mat4 projInverse;
	vec4 lightPos;
	uint option;
} ubo;

struct Sphere {
	vec3 center;
	float radius;
	vec4 color;
};
layout(binding = 3, set = 0) buffer Spheres { 
	Sphere s[]; 
} spheres;

// * Option 1 : Multiple primitives, single instance
// * Option 2 : Single primitive, multiple instances

void main() {
	const uint id = ubo.option == 1 ? gl_PrimitiveID : gl_InstanceID;
    Sphere sphere = spheres.s[id];

	vec3 worldPos = gl_WorldRayOriginEXT + gl_WorldRayDirectionEXT * gl_HitTEXT;
	vec3 worldNormal = normalize(worldPos - sphere.center);

	// Basic lighting
	vec3 lightVector = normalize(ubo.lightPos.xyz);
	float dot_product = max(dot(lightVector, worldNormal), 0.2);
	hitValue = sphere.color.rgb * dot_product;

	//debugPrintfEXT("Closest hit %d, %f,%f,%f", id, hitValue.x, hitValue.y, hitValue.z);
}
