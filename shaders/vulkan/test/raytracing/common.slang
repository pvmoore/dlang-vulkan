#language slang 2026

module common;

public static const float PI        = 3.14159265359f;
public static const float EPSILON   = 0.001f;

public struct Ray {
    public float3 origin;
    public float3 direction;
    public float3 invDirection;

	public __init(float3 origin, float3 direction) {
        this.origin = origin;
        this.direction = direction;
        this.invDirection = 1.0f / direction;
    }
}

public struct AABB {
    public float3 min;
    public float3 max;
}
public bool operator==(AABB a, AABB b) {
    return all(a.min == b.min) && all(a.max == b.max);
}
public bool operator!=(AABB a, AABB b) {
    return !(a == b);
}

public struct Cube {
    public float3 centre;
    public float3 radius;
    public float3 colour;
};

public struct Sphere {
    public float3 center;
    public float radius;
    public float3 colour;

    public float intersect(float3 ro, float3 rd) {
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

// (90.5).degrees()
public extension float {
    public float degrees() {
        return this * PI / 180.0;
    }
}

public float random01(inout uint seed) {
    uint pcg = pcg_hash(seed);
    seed = pcg;
    return pcg / float(0xffffffff);
}

public uint pcg_hash(uint input) {
    uint state = input * 747796405u + 2891336453u;
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
}

[ForceInline]
public float vmax(float3 v) {
    return max(v.x, max(v.y, v.z));
}
[ForceInline]
public float vmax(float2 v) {
	return max(v.x, v.y);
}

public float3 gamma(float3 c) {
    float p = 1.0/1.8;
    c = clamp(c, 0, 1);
    return float3(pow(c.x, p), pow(c.y, p), pow(c.z, p));
}

/// Apply phong specular reflectance to colour.
/// Assumes normal and toLight are normalised.
public float3 specularColour(float3 colour,
                             float3 normal,
                             float3 fromEye,
                             float3 toLight,
                             float power) 
{
    float cosAngle = max(0, dot(fromEye, reflect(toLight, normal)));
    return colour * pow(cosAngle, power);
}

//
// Calculate the minimum distance to the edge of the current volumn of size _volumeSize_
//
public float getMinDistToEdge(Ray ray, float3 pos, uint3 volumeSize) {
    float3 rem  = fmod(pos, volumeSize);
    float3 size = float3(ray.direction >= float3(0)) * volumeSize;
    float3 dist = size-rem;

    float3 m    = dist * ray.invDirection;
    float res = min(m.x, min(m.y, m.z));
    return max(res, 0);
}

public float2 intersectAABB(Ray ray, AABB aabb) {
    float3 tMin = (aabb.min - ray.origin) * ray.invDirection;
    float3 tMax = (aabb.max - ray.origin) * ray.invDirection;
    float3 t1 = min(tMin, tMax);
    float3 t2 = max(tMin, tMax);
    float tNear = max(max(t1.x, t1.y), t1.z);
    float tFar = min(min(t2.x, t2.y), t2.z);
    return float2(tNear, tFar);
}
