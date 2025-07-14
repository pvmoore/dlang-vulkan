#version 460 core
#extension GL_EXT_ray_tracing : require
#extension GL_GOOGLE_include_directive : require

layout(location = 0) rayPayloadInEXT vec3 ResultColor;

hitAttributeEXT vec3 HitAttribs;

/**
 * int gl_PrimitiveID               -  
 * int gl_InstanceID                - 
 * int gl_GeometryIndexEXT          - 
 * int gl_InstanceCustomIndexEXT    - 
 * vec3 gl_WorldRayOriginEXT 	    -	
 * vec3 gl_WorldRayDirectionEXT 	-	
 * vec3 gl_ObjectRayOriginEXT 		-    
 * vec3 gl_ObjectRayDirectionEXT 	-	
 * float gl_RayTminEXT 		        -
 * float gl_RayTmaxEXT 		        -
 * uint gl_IncomingRayFlagsEXT 	    -	
 * float gl_HitTEXT 		        -
 * uint gl_HitKindEXT 	            -	
 * mat4x3 gl_ObjectToWorldEXT 		-    
 * mat4x3 gl_WorldToObjectEXT       -
 */
void main() {
    //vec3 objectPos = gl_ObjectRayOriginEXT + gl_ObjectRayDirectionEXT * gl_HitTEXT;
    //vec3 worldPos = gl_WorldRayOriginEXT + gl_WorldRayDirectionEXT * gl_HitTEXT;

    const vec3 barycentrics = vec3(1.0f - HitAttribs.x - HitAttribs.y, HitAttribs.x, HitAttribs.y);

    ResultColor = barycentrics;
}
