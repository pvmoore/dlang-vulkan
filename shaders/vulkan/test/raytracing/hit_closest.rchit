#version 460 core
#extension GL_EXT_ray_tracing : require
#extension GL_GOOGLE_include_directive : require

layout(location = 0) rayPayloadInEXT vec3 ResultColor;

hitAttributeEXT vec3 HitAttribs;

/**
 * gl_PrimitiveID
 * gl_InstanceID
 * gl_GeometryIndexEXT
 * gl_InstanceCustomIndexEXT
 */
void main() {
    //vec3 objectPos = gl_ObjectRayOriginEXT + gl_ObjectRayDirectionEXT * gl_HitTEXT;
    //vec3 worldPos = gl_WorldRayOriginEXT + gl_WorldRayDirectionEXT * gl_HitTEXT;

    const vec3 barycentrics = vec3(1.0f - HitAttribs.x - HitAttribs.y, HitAttribs.x, HitAttribs.y);

    ResultColor = barycentrics;

    //ResultColor = vec3(1,1,1);
}
