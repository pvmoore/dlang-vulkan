
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
    float3 colour  : read(caller) : write(caller, closesthit, miss);
    float distance : read(caller) : write(caller, closesthit, miss);
    float3 normal  : read(caller) : write(caller, closesthit);
    bool shadowed  : read(caller) : write(caller, closesthit, miss);
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

    float3 colour = float3(0, 0, 0);

    int maxBounces = 4;
    float f = 1.0f;
    RayPayload payload;

    for(int i = 0; i <= maxBounces; i++) {
        TraceRay(tlas, RAY_FLAG_FORCE_OPAQUE, 0xff, 0, 0, 0, ray, payload);

        if(payload.distance < 0) break;

        colour += f*payload.colour;
        f      *= 0.333f;

        float3 hitPos = ray.Origin + ray.Direction * payload.distance;
        ray.Origin    = hitPos + payload.normal * 0.001f;
        ray.Direction = reflect(ray.Direction, payload.normal);
    }

    colour = saturate(colour);

    image[launchID] = float4(colour, 1);
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
    float intensity    = dot(lightVector, worldNormal);

    p.normal = worldNormal;
    p.distance = RayTCurrent();

    if(intensity < 0.0) {
        p.colour = float3(0, 0, 0);
        return;
    }

    p.colour = cube.colour * intensity;
    
    RayDesc ray;
    ray.Origin = worldPos;
    ray.Direction = lightVector;
    ray.TMin = 0.001f;
    ray.TMax = 1000.0f;
    p.shadowed = true;

    let shadowRayFlags =
        RAY_FLAG_ACCEPT_FIRST_HIT_AND_END_SEARCH |
        RAY_FLAG_FORCE_OPAQUE |
        RAY_FLAG_SKIP_CLOSEST_HIT_SHADER;

    TraceRay(tlas, shadowRayFlags, 0xff, 0, 0, 1, ray, p);

    if(p.shadowed) {
        p.colour *= 0.2;
    } else {
        p.colour += specular(intensity, WorldRayDirection(), lightVector, worldNormal);
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
    float intensity = dot(lightVector, worldNormal);

    p.normal = worldNormal;
    p.distance = RayTCurrent();

    if (intensity < 0.0) {
        p.colour = float3(0, 0, 0);
        return;
    }

    p.colour = sphere.colour * intensity;

    RayDesc ray;
    ray.Origin = worldPos;
    ray.Direction = lightVector;
    ray.TMin = 0.1f;
    ray.TMax = 1000.0f;
    p.shadowed = true;

    let shadowRayFlags = 
        RAY_FLAG_ACCEPT_FIRST_HIT_AND_END_SEARCH | 
        RAY_FLAG_FORCE_OPAQUE | 
        RAY_FLAG_SKIP_CLOSEST_HIT_SHADER;

    TraceRay(tlas, shadowRayFlags, 0xff, 0, 0, 1, ray, p);

    if(p.shadowed) {
        p.colour *= 0.2;
    } else {
        p.colour += specular(intensity, WorldRayDirection(), lightVector, worldNormal);
    }
}

[shader("intersection")]
void intersection() {
    // If we get here this instance must be an AABB of a Sphere
    // Get the instance id from the instance.instanceCustomIndex
    Sphere sphere = spheres[InstanceID()];

    float t = sphere.intersect(WorldRayOrigin(), WorldRayDirection());

    if (t > 0) {
        ReportHit(t, 0, 0);
    }
}

[shader("miss")]
void miss(inout RayPayload p) {
    p.colour   = float3(0.1, 0.1, 0.0);
    p.distance = -1.0;
}

[shader("miss")]
void shadowMiss(inout RayPayload p) {
    p.shadowed = false;
}

float3 specular(float lightIntensity, float3 viewDir, float3 lightDir, float3 normal) {
    let specularPower = 50;
    let R = normalize(2.0f * lightIntensity * normal - lightDir);
    let V = normalize(-viewDir);
    let specValue = pow(saturate(dot(R, V)), specularPower);
    return float3(specValue);
}
