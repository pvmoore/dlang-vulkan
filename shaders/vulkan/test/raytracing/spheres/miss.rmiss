/** 
 *  // Work dimensions
 *  in    uvec3  gl_LaunchIDEXT;
 *  in    uvec3  gl_LaunchSizeEXT;

 *  // World space parameters
 *  in    vec3   gl_WorldRayOriginEXT;
 *  in    vec3   gl_WorldRayDirectionEXT;

 *  // Ray parameters
 *  in    float  gl_RayTminEXT;
 *  in    float  gl_RayTmaxEXT;
 *  in    uint   gl_IncomingRayFlagsEXT;
 */
#version 460
#extension GL_EXT_ray_tracing : require

layout(location = 0) rayPayloadInEXT vec3 hitValue;

void main() {
    hitValue = vec3(0.1, 0.1, 0.0);
}
