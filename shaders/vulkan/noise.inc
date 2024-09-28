// From https://www.shadertoy.com/view/4dS3Wd
// By Morgan McGuire @morgan3d, http://graphicscodex.com
// Reuse permitted under the BSD license.

// All noise functions are designed for values on integer scale.
// They are tuned to avoid visible periodicity for both positive and
// negative coordinates within a few orders of magnitude.

/*
	Example usage:
	
	Single octave noise:
	noise(f); noise(xy); noise(xyz);
	
	Octave noise:
	fbm(f); fbm(xy); fbm(xyz);
*/

float noisehash(float n) { return fract(sin(n) * 1e4); }
float noisehash(vec2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }

// range [0..1]
float noise(float x) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f);
    return mix(noisehash(i), noisehash(i + 1.0), u);
}
// range [0..1]
float noise(vec2 x) {
    vec2 i = floor(x);
    vec2 f = fract(x);

	// Four corners in 2D of a tile
	float a = noisehash(i);
    float b = noisehash(i + vec2(1.0, 0.0));
    float c = noisehash(i + vec2(0.0, 1.0));
    float d = noisehash(i + vec2(1.0, 1.0));

    // Simple 2D lerp using smoothstep envelope between the values.
	// return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),
	//			mix(c, d, smoothstep(0.0, 1.0, f.x)),
	//			smoothstep(0.0, 1.0, f.y)));

	// Same code, with the clamps in smoothstep and common subexpressions
	// optimized away.
    vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}
// range [0..1]
float noise(vec3 x) {
    const vec3 step = vec3(110, 241, 171);

    vec3 i = floor(x);
    vec3 f = fract(x);
 
    // For performance, compute the base input to a 1D noisehash from the integer part of the argument and the 
    // incremental change to the 1D based on the 3D -> 1D wrapping
    float n = dot(i, step);

    vec3 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(mix( noisehash(n + dot(step, vec3(0, 0, 0))), noisehash(n + dot(step, vec3(1, 0, 0))), u.x),
                   mix( noisehash(n + dot(step, vec3(0, 1, 0))), noisehash(n + dot(step, vec3(1, 1, 0))), u.x), u.y),
               mix(mix( noisehash(n + dot(step, vec3(0, 0, 1))), noisehash(n + dot(step, vec3(1, 0, 1))), u.x),
                   mix( noisehash(n + dot(step, vec3(0, 1, 1))), noisehash(n + dot(step, vec3(1, 1, 1))), u.x), u.y), u.z);
}
// range [0..1]
float fbm(float x, int octaves) {
	float v = 0.0;
	float a = 0.5;
	float shift = float(100);
	for(int i = 0; i < octaves; ++i) {
		v += a * noise(x);
		x = x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}
// range [0..1]
float fbm(vec2 x, int octaves) {
	float v = 0.0;
	float a = 0.5;
	vec2 shift = vec2(100);
	// Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
	for(int i = 0; i < octaves; ++i) {
		v += a * noise(x);
		x = rot * x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}
// range [0..1]
float fbm(vec3 x, int octaves) {
	float v = 0.0;
	float a = 0.5;
	vec3 shift = vec3(100);
	for(int i = 0; i < octaves; ++i) {
		v += a * noise(x);
		x = x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}
