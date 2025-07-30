module common;

public static const float PI = 3.14159265359f;

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

public float maxElement(float3 v) {
    return max(v.x, max(v.y, v.z));
}

public float3 gamma(float3 c) {
    float p = 1.0/1.8;
    c = clamp(c, 0, 1);
    return float3(pow(c.x, p), pow(c.y, p), pow(c.z, p));
}

