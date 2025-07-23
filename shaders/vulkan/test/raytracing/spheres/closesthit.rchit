/* 
 * This is a modified version of Sascha Willems' ray tracing tutorial.
 * For original see https://github.com/SaschaWillems/Vulkan
 *
 * 	// Work dimensions
 *  in    uvec3  gl_LaunchIDEXT;
 *  in    uvec3  gl_LaunchSizeEXT;
 *
 *  // Geometry instance ids
 *  in     int   gl_PrimitiveID;
 *  in     int   gl_InstanceID;
 *  in     int   gl_InstanceCustomIndexEXT;
 *  in     int   gl_GeometryIndexEXT;
 *
 *  // World space parameters
 *  in    vec3   gl_WorldRayOriginEXT;
 *  in    vec3   gl_WorldRayDirectionEXT;
 *  in    vec3   gl_ObjectRayOriginEXT;
 *  in    vec3   gl_ObjectRayDirectionEXT;
 *
 *  // Ray parameters
 *  in    float  gl_RayTminEXT;
 *  in    float  gl_RayTmaxEXT;
 *  in    uint   gl_IncomingRayFlagsEXT;
 *
 *  // Ray hit info
 *  in    float  gl_HitTEXT;
 *  in    uint   gl_HitKindEXT;  (gl_HitKindFrontFacingTriangleEXT (0xFE) or gl_HitKindBackFacingTriangleEXT (0xFF)
 *							      if using the built-in - triangle - interesection shader)	
 *
 *  // Transform matrices
 *  in    mat4x3 gl_ObjectToWorldEXT;
 *  in    mat3x4 gl_ObjectToWorld3x4EXT;
 *  in    mat4x3 gl_WorldToObjectEXT;
 *  in    mat3x4 gl_WorldToObject3x4EXT;
 *
 * The anyhit shader has access to the same variables.
 */
#version 460
#extension GL_EXT_ray_tracing : require
#extension GL_EXT_nonuniform_qualifier : enable
#extension GL_EXT_debug_printf : enable

layout(location = 0) rayPayloadInEXT vec3 hitValue;
//layout(location = 2) rayPayloadEXT bool shadowed;
//hitAttributeEXT vec2 attribs;

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
}
