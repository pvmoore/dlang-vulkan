#language slang 2026
/**
 *  Signed distance field functions.
 *  See https://iquilezles.org/www/articles/distfunctions/distfunctions.htm
 */
module sdf;

import common;

public struct HitAttributes {
    public float3 normal;
	public float2 uv;
};

public struct Shape { 
    public float3 pos;
    public float3 scale;
    public float3 colour;
    public uint type;
};

public interface Scene {
	public float maxSteps() { return 500; }
	public float stepMutiplier() { return 0.75; }

    public float map(float3 p);

	public float3 calcNormal(float3 p) {
        float2 e = float2(0.01, 0);
        float3 n = float3(
            this.map(p + e.xyy) - this.map(p - e.xyy),
            this.map(p + e.yxy) - this.map(p - e.yxy),
            this.map(p + e.yyx) - this.map(p - e.yyx)
        );
        return normalize(n);
    }
	public float2 getUV(float3 hit, float3 normal) { return float2(0); }
}

//==============================================================================================
// Transformations
//==============================================================================================
public float3 sdfMove(inout float3 p, float3 v) {
    return p - v;
}
public float3 rotateX(inout float3 p, float a) {
	return float3(p.x, cos(a)*p.yz + sin(a)*float2(p.z, -p.y));
}
public float3 rotateY(inout float3 p, float a) {
	float2 xz = cos(a)*p.xz + sin(a)*float2(p.z, -p.x);
	return float3(xz.x, p.y, xz.y);
}

//==============================================================================================
// Shapes
//==============================================================================================
public float sdfSphere(float3 p, float r) {
	return length(p) - r;
}
public float sdfBox(float3 p, float3 b) {
	float3 d = abs(p) - b;
	return length(max(d, float3(0))) + vmax(min(d, float3(0)));
}
public float sdfRoundedBox(float3 p, float3 size, float r) {
    return length(max(abs(p)-size+float3(r),0))-r;
}
public float sdfCylinder(float3 p, float height, float r) {
	float d = length(p.xz) - r;
	return max(d, abs(p.y) - height);
}
/**
 *  r1: large radius
 *  r2: smallradius
 *  c:  height/2
 */
public float sdfCone(float3 p, float r1, float r2, float c) {
	float d = length(p.xz)-lerp(r1, r2, (c+p.y)/(c+c));
	d = max(d, -p.y-c);
	return max(d,p.y-c);
}
/**
 *  Torus in the XZ plane
 */
public float sdfRing(float3 p, float smallRadius, float largeRadius) {
	return length(float2(length(p.xz) - largeRadius, p.y)) - smallRadius;
}
/**
 *  b: 		 box size
 *  sampler: texture to displace with
 */
public float sdfDisplacedBox(float3 p, float3 b, Sampler2D sampler) {
    float3 normal = normaliseToAxis(p);
    float2 uv     = boxUV(p, normal);
    float f = sampler.Sample(uv).r;

    return vmax(abs(p) - b) - f*0.5;
}

public float sdCutHollowSphere(float3 p, float r, float h, float t) {
  // sampling independent computations (only depend on shape)
  float w = sqrt(r*r-h*h);
  
  // sampling dependant computations
  float2 q = float2( length(p.xz), p.y );
  return ((h*q.x<w*q.y) ? length(q-float2(w,h)) : 
                          abs(length(q)-r) ) - t;
}

//-------------------------------------------------------------------
// Combination operators
//-------------------------------------------------------------------
public float opUnion(float a, float b) {
    return min(a, b);
}
public float opSubtraction(float a, float b) {
    return max(a, -b);
}
public float opIntersection(float a, float b) {
    return max(a, b);
}
public float opUnionSmooth(float a, float b, float r) {
    float h = clamp( 0.5 + 0.5*(b-a)/r, 0.0, 1.0 );
    return lerp(b, a, h) - r*h*(1.0-h);
}
public float opSubtractionSmooth(float a, float b, float r) {
	float h = clamp( 0.5 - 0.5*(a+b)/r, 0.0, 1.0 );
    return lerp( a, -b, h ) + r*h*(1.0-h);
}
public float opIntersectionSmooth(float a, float b, float r) {
    float h = clamp( 0.5 - 0.5*(b-a)/r, 0.0, 1.0 );
    return lerp(b, a, h) + r*h*(1.0-h);
}

//==============================================================================================
// Other
//==============================================================================================
public float2 sphereUVCheap(float3 normal) {
    return normal.xy / 2 + 0.5;
}
public float2 sphereUV(float3 normal) {
    return asin(normal.xy) / PI + 0.5;
}
public float2 boxUV(float3 hit, float3 normal) {
	return (normal.x*hit.yz +
			normal.y*hit.xz +
			normal.z*hit.xy) / 2 + 0.5;
	
}
/// Truncate vector to an axis aligned normal.
public float3 normaliseToAxis(float3 v) {
    float3 a = abs(v);
    float3 b = a.x>a.y && a.x>a.z ? float3(1, 0, 0) :
        				  a.y>a.z ? float3(0, 1, 0) : 
						  			float3(0, 0, 1);
    return b * sign(v);
}
