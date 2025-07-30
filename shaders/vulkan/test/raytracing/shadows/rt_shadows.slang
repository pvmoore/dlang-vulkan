
[require(GL_EXT_debug_printf)]

struct UBO {
    float4x4 viewInverse;
    float4x4 projInverse;
    float3 lightPos;
};
struct Cube {
    float3 centre;
    float3 radius;
    float3 colour;
};
struct Sphere {
    float3 center;
    float radius;
    float3 colour;

    float intersect(float3 ro, float3 rd) {
        float3 oc = ro - center;
        float b = dot(oc, rd);
        float c = dot(oc, oc) - radius * radius;
        float h = b * b - c;
        if (h < 0.0) {
            return -1.0;
        }
        h = sqrt(h);
        return -b - h;
    }
};
struct [raypayload] RayPayload {
    float3 colour      : read(caller) : write(caller, closesthit, miss);
    bool hit           : read(caller) : write(caller, closesthit, miss);
    float3 hitWorldPos : read(caller) : write(caller, closesthit);
};

[[vk::binding(0, 0)]] RaytracingAccelerationStructure tlas;
[[vk::binding(1, 0)]] [format("rgba8")] RWTexture2D<float4> image;
[[vk::binding(2, 0)]] ConstantBuffer<UBO, ScalarDataLayout> ubo; 
[[vk::binding(3, 0)]] StructuredBuffer<Cube, ScalarDataLayout> cubes; 
[[vk::binding(4, 0)]] StructuredBuffer<Sphere, ScalarDataLayout> spheres; 

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

    RayPayload payload;

    TraceRay(tlas, RAY_FLAG_FORCE_OPAQUE, 0xff, 0, 0, 0, ray, payload);

    float3 colour = payload.colour;
    
    // Note: In other examples, the shadow ray is cast from the closest hit shader but I have found that
    //       when using procedural geometry this is incredibly slow.
    //       For some reason it seems to be a lot faster to do the shadow ray here. 
    //       I am not sure whether this is something I am doing wrong or an AMD thing or something else
    //       but doing it here works fine and is fast.
    if(payload.hit && isShadowed(payload)) {
        colour *= 0.2;
    }

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

static const float3 normals[6] = {
    float3(0, 1, 0),  // top
    float3(0,-1, 0),  // bottom
    float3(0, 0, 1),  // front
    float3(0, 0,-1),  // back
    float3(-1, 0, 0), // left
    float3(1, 0, 0)   // right
};

[shader("closesthit")]
void closesthitCube(inout RayPayload p, in BuiltInTriangleIntersectionAttributes attribs) {
    // If we get here we hit a Cube (hit group 0)
    // Get the instance id from the instance.instanceCustomIndex
    Cube cube = cubes[InstanceID()];

    // Calculate the cube side
    uint normalIndex = (PrimitiveIndex() / 2) % 6;

    float3 worldPos = WorldRayOrigin() + WorldRayDirection() * RayTCurrent();
    float3 worldNormal = normals[normalIndex];

    // Basic lighting
    float3 lightVector = normalize(ubo.lightPos);
    float dotProduct = dot(lightVector, worldNormal);

    if(dotProduct < 0.0) {
        p.colour = float3(0, 0, 0);
        p.hit = false;
    } else {
        p.colour = cube.colour * dotProduct;
        p.hitWorldPos = worldPos;
        p.hit = true;
    }
}

[shader("closesthit")]
void closesthitSphere(inout RayPayload p) {
    // If we get here we hit a Sphere (hit group 1)
    // Get the instance id from the instance.instanceCustomIndex
    Sphere sphere = spheres[InstanceID()];

    float3 worldPos = WorldRayOrigin() + WorldRayDirection() * RayTCurrent();
    float3 worldNormal = normalize(worldPos - sphere.center);

    // Basic lighting
    float3 lightVector = normalize(ubo.lightPos);
    float dotProduct = dot(lightVector, worldNormal);

    if(dotProduct < 0.0) {
        p.colour = float3(0, 0, 0);
        p.hit = false;
    } else {
        p.colour = sphere.colour * dotProduct;
        // Move the hit pos a little way towards the light to avoid colliding with the same sphere
        p.hitWorldPos = worldPos + lightVector * 0.025;
        p.hit = true;
    }
}

[shader("intersection")]
void intersection() {
    // If we get here this instance must be an AABB of a Sphere
    // Get the instance id from the instance.instanceCustomIndex
    Sphere sphere = spheres[InstanceID()];

    float t = sphere.intersect(WorldRayOrigin(), WorldRayDirection());

    if(t > 0) {
        ReportHit(t, 0, 0);
    }
}

[shader("miss")]
void miss(inout RayPayload p) {
    p.colour = float3(0.1, 0.1, 0.0);
    p.hit = false;
}

[shader("miss")]
void shadowMiss(inout RayPayload p) {
    p.hit = false;
}
