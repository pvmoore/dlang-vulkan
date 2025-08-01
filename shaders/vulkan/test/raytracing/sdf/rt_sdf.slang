#language slang 2026

[require(GL_EXT_debug_printf)]

import common;
import sdf;

struct UBO {
    float4x4 viewInverse;
    float4x4 projInverse;
    float3 lightPos;
};

struct [raypayload] RayPayload {
    float3 colour : read(caller) : write(caller, closesthit, miss);
    bool hit           : read(caller) : write(caller, closesthit, miss);
    float3 normal      : read(caller) : write(caller, closesthit);
    float3 hitWorldPos : read(caller) : write(caller, closesthit);
};

[[vk::binding(0, 0)]] RaytracingAccelerationStructure tlas;
[[vk::binding(1, 0)]] [format("rgba8")] RWTexture2D<float4> image;
[[vk::binding(2, 0)]] ConstantBuffer<UBO, ScalarDataLayout> ubo;
[[vk::binding(3, 0)]] StructuredBuffer<Shape, ScalarDataLayout> shapes;
[[vk::binding(4, 0)]] Sampler2D sampler0; 

[shader("raygeneration")]
void raygen() {
    uint2 launchID   = DispatchRaysIndex().xy;
    uint3 launchSize = DispatchRaysDimensions();

    float2 pixelCenter = float2(launchID) + float2(0.5);
	float2 inUV        = pixelCenter/float2(launchSize.xy);
	float2 d           = inUV * 2.0 - 1.0;
    
    float4 origin    = mul(ubo.viewInverse, float4(0,0,0,1));
	float4 target    = mul(ubo.projInverse, float4(d.x, d.y, 1, 1));
	float4 direction = mul(ubo.viewInverse, float4(normalize(target.xyz), 0));

    RayDesc ray;
    ray.Origin    = origin.xyz;
    ray.Direction = direction.xyz;
    ray.TMin      = 0.001f;
    ray.TMax      = 10000.0f;

    // RayPayload payload;

    // TraceRay(tlas, RAY_FLAG_FORCE_OPAQUE, 0xff, 0, 0, 0, ray, payload);

    // float3 colour = payload.colour;

    // if(payload.hit && isShadowed(payload)) {
    //     colour *= 0.3;
    // }

    let maxBounces = 4;
    float f = 1.0f;
    RayPayload payload;
    float3 colour = float3(0, 0, 0);

    for(int i = 0; i <= maxBounces; i++) {

        TraceRay(tlas, RAY_FLAG_FORCE_OPAQUE, 0xff, 0, 0, 0, ray, payload);

        // If we didn't hit anything, we can exit
        if(!payload.hit) break;

        float3 c = payload.colour;
    
        // Cast a shadow ray
        if(isShadowed(payload)) {
            c *= 0.2;
        }

        // Accumulate the colours
        colour += f * c;
        f      *= 0.333f;

        ray.Origin    = payload.hitWorldPos;
        ray.Direction = reflect(ray.Direction, payload.normal);
    }

    colour = saturate(colour);

    image[launchID] = float4(colour, 1);
}

// Cast a shadow ray from hitWorldPos to lightPos. Return true if geometry is hit
bool isShadowed(in RayPayload p) {
    RayDesc ray;
    ray.Origin = p.hitWorldPos;
    ray.Direction = normalize(ubo.lightPos);
    ray.TMin = 0.001f;
    ray.TMax = length(ubo.lightPos);
    p.hit = true;

    let shadowRayFlags =
        RAY_FLAG_ACCEPT_FIRST_HIT_AND_END_SEARCH |
        RAY_FLAG_FORCE_OPAQUE |
        RAY_FLAG_SKIP_CLOSEST_HIT_SHADER;

    TraceRay(tlas, shadowRayFlags, 0xff, 0, 0, 1, ray, p);

    return p.hit;
}

[shader("closesthit")]
void closesthit(inout RayPayload p, HitAttributes attribs) {
    Shape shape = shapes[InstanceIndex()];

    float3 worldPos    = WorldRayOrigin() + WorldRayDirection() * RayTCurrent();
    float3 worldNormal = attribs.normal;

    // N.L lighting
    float3 lightVector = normalize(ubo.lightPos);
    float dotProduct   = dot(lightVector, worldNormal);

    p.colour  = shape.colour * dotProduct;
    p.colour += specularColour(float3(1), worldNormal, WorldRayDirection(), lightVector, 50);

    p.normal = worldNormal;

    if(attribs.uv.y != 0) {
        p.colour *= sampler0.Sample(attribs.uv).rgb;
    }

    if(dotProduct < 0) {
        p.hit = false;
        p.colour *= 0.6;
    } else {
        p.hit = true;

        // move towards the light a little way to avoid self-shadowing
        p.hitWorldPos = worldPos + lightVector * 0.025;
    }
}

[shader("miss")]
void miss(inout RayPayload p) {
    p.hit = false;
    p.colour = float3(0.1, 0.1, 0.0);
}
[shader("miss")]
void shadowMiss(inout RayPayload p) {
    p.hit = false;
}

// void intersectionAABB() {
//     Shape shape = shapes[InstanceIndex()];

//     // Shapes are in world space
//     AABB worldAabb = AABB(shape.min, shape.max);

//     Ray r = { WorldRayOrigin(), WorldRayDirection(), 1.0f / WorldRayDirection() };
//     float2 nearFar = intersectAABB(r, worldAabb);

//     if(nearFar.x < RayTMin() || nearFar.y > RayTCurrent()) {
//         return;
//     }

//     ReportHit(nearFar.x, 0, 0);
// }

// void intersectionAABB_world_to_objectSpace() {
//     Shape shape = shapes[InstanceIndex()];

//     // Shapes are in object space
//     AABB objectAabb = AABB(shape.min, shape.max);

//     // Convert to world space
//     AABB worldAabb = {
//         mul(ObjectToWorld(), float4(objectAabb.min, 1)).xyz,
//         mul(ObjectToWorld(), float4(objectAabb.max, 1)).xyz
//     };

//     //printf("world aabb: %1.3v3f .. %1.3v3f\n", worldAabb.min, worldAabb.max);

//     Ray r = { WorldRayOrigin(), WorldRayDirection(), 1.0f / WorldRayDirection() };
//     float2 nearFar = intersectAABB(r, worldAabb);
//     float near = nearFar.x;

//     if(near > RayTMin() && near < RayTCurrent()) {
//         ReportHit(near, 0, 0);
//     }
// }

// void intersectionAABB_objectSpace() {
//     Shape shape = shapes[InstanceIndex()];

//     // Shapes are in object space
//     AABB objectAabb = AABB(shape.min, shape.max);

//     //printf("world aabb: %1.3v3f .. %1.3v3f\n", worldAabb.min, worldAabb.max);

//     Ray r = { ObjectRayOrigin(), ObjectRayDirection(), 1.0f / ObjectRayDirection() };
//     float2 nearFar = intersectAABB(r, objectAabb);
//     float near = nearFar.x;

//     if(near > RayTMin() && near < RayTCurrent()) {
//         ReportHit(near, 0, 0);
//     }
// }

// void intersectionSDF_worldSpace() {
//     Shape shape = shapes[InstanceIndex()];

//     // Shapes are in world space
//     AABB worldAabb = AABB(shape.min, shape.max);

//     Ray ray = { WorldRayOrigin(), WorldRayDirection(), 1.0f / WorldRayDirection() };
//     float2 nearFar = intersectAABB(ray, worldAabb);
//     float near = nearFar.x;
//     float far  = nearFar.y;

//     // RayTCurrent is the maximum distance
//     if(near < RayTMin() || near > RayTCurrent()) {
//         return;
//     }

//     // These are the flags used when tracing the ray. May be useful /shrug
//     //uint rayFlags = RayFlags();

//     // March the ray in world space
//     float t = near;
//     if(march(ray, far, t)) {
//         ReportHit(t, 0, 0);
//     }
//}

