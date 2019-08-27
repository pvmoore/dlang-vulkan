/**
 *	Add the following to your shader:
 *	// ==============================================  printf start
 * layout(set=1, binding=0, std430) writeonly buffer PRINTF_BUFFER {
 *	float buf[];
 * } printf;
 * layout(set=1, binding=1, std430) buffer PRINTF_STATS {
 *   uint buf[];
 * } printf_stats;
 * #include "_printf.inc"
 * // ============================================== printf end
 *
 *	Encoding:
 *  byte 0 	    = Type
 *  byte 1 	    = components eg 1 = scalar, 4 = vec4
 *  (if type==6): byte 2 is columns of matrix
 *  (if type==6): byte 3 is rows of matrix
 *  byte 2..len = value(s)
 *
 * | Type | Value       | Size(in floats per component) |
 * |------|-------------|---|
 * | 0    | char   		| 1 |
 * | 1    | uint   		| 1 |
 * | 2    | int    		| 1 |
 * | 3    | float  		| 1 |
 * | 4    | ulong  		| 2 |
 * | 5    | long   		| 2 |
 * | 6    | float (mat) | 1 | *special - num components followed by mat cols and rows
 * | 7    | set suffix  | na | *special - sets suffix for subsequent calls (default is LF 10)
 *
 * eg.
 * - `1,1, 17` is a uint -> 17
 * - `1,2, 3,7,)` is uvec2(3,7)
 * - `3,16, ...` is a mat4
 * - `3,4, ...` is a vec4
 * - `6,8,2,4, ...` is a mat2x4 followed by 8 floats
 *
 * Example shader usage:
 * if(printBarrier()) { print(3.14); }
 *
 * See vulkan.test_compute for example usage.
 */
bool printBarrier() {
	return atomicOr(printf_stats.buf[0], 1)==0;
}
void printSetSuffix(int s) {
	uint i = atomicAdd(printf_stats.buf[1], 3);
	if(i>4000000) return;

	printf.buf[i]   = 7; // type
	printf.buf[i+1] = 0; // components
	printf.buf[i+2] = s; // suffix
}
void _doprint(float v, float type) {
    uint i = atomicAdd(printf_stats.buf[1], 3);
	if(i>4000000) return;

    printf.buf[i]   = type; // type
	printf.buf[i+1] = 1; // 1 component
    printf.buf[i+2] = v; // the value
}
void _doprint(vec2 v, float type) {
    uint i = atomicAdd(printf_stats.buf[1], 4);
	if(i>4000000) return;

    printf.buf[i]   = type; // type
	printf.buf[i+1] = 2; // 2 components
    printf.buf[i+2] = v.x;
	printf.buf[i+3] = v.y;
}
void _doprint(vec3 v, float type) {
    uint i = atomicAdd(printf_stats.buf[1], 5);
	if(i>4000000) return;

    printf.buf[i]   = type; // type
	printf.buf[i+1] = 3; // 3 components
    printf.buf[i+2] = v.x;
	printf.buf[i+3] = v.y;
	printf.buf[i+4] = v.z;
}
void _doprint(vec4 v, float type) {
    uint i = atomicAdd(printf_stats.buf[1], 6);
	if(i>4000000) return;

    printf.buf[i]   = type; // type
	printf.buf[i+1] = 4; // 4 components
    printf.buf[i+2] = v.x;
	printf.buf[i+3] = v.y;
	printf.buf[i+4] = v.z;
	printf.buf[i+5] = v.w;
}
void print(mat4 v) {
    uint i = atomicAdd(printf_stats.buf[1], 20);
	if(i>4000000) return;

    printf.buf[i]   = 6; // type
	printf.buf[i+1] = 16; // components
	printf.buf[i+2] = 4; // cols
    printf.buf[i+3] = 4; // rows
	for(int j=0; j<16; j++) {
		printf.buf[i+j+4] = v[j/4][j%4];
	}
}
void print(mat4x2 v) { // 4 cols, 2 rows (column-major)
    uint i = atomicAdd(printf_stats.buf[1], 12);
	if(i>4000000) return;

    printf.buf[i]   = 6; // type
	printf.buf[i+1] = 8; // components
	printf.buf[i+2] = 4; // cols
    printf.buf[i+3] = 2; // rows
	for(int j=0; j<8; j++) {
		printf.buf[i+j+4] = v[j/2][j%2];
	}
}
void print(mat2x4 v) { // 2 cols, 4 rows (column-major)
    uint i = atomicAdd(printf_stats.buf[1], 12);
	if(i>4000000) return;

    printf.buf[i]   = 6; // type
	printf.buf[i+1] = 8; // components
	printf.buf[i+2] = 2; // cols
    printf.buf[i+3] = 4; // rows
	for(int j=0; j<8; j++) {
		printf.buf[i+j+4] = v[j/4][j%4];
	}
}
void print(mat4x3 v) { // 4 cols, 3 rows (column-major)
    uint i = atomicAdd(printf_stats.buf[1], 16);
	if(i>4000000) return;

    printf.buf[i]   = 6; // type
	printf.buf[i+1] = 12; // components
	printf.buf[i+2] = 4; // cols
    printf.buf[i+3] = 3; // rows
	for(int j=0; j<12; j++) {
		printf.buf[i+j+4] = v[j/3][j%3];
	}
}
void print(mat3x4 v) { // 3 cols, 4 rows (column-major)
    uint i = atomicAdd(printf_stats.buf[1], 16);
	if(i>4000000) return;

    printf.buf[i]   = 6; // type
	printf.buf[i+1] = 12; // components
	printf.buf[i+2] = 3; // cols
    printf.buf[i+3] = 4; // rows
	for(int j=0; j<12; j++) {
		printf.buf[i+j+4] = v[j/4][j%4];
	}
}
void print(mat2x2 v) { // 2 cols, 2 rows (column-major)
    uint i = atomicAdd(printf_stats.buf[1], 8);
	if(i>4000000) return;

    printf.buf[i]   = 6; // type
	printf.buf[i+1] = 4; // components
	printf.buf[i+2] = 2; // cols
    printf.buf[i+3] = 2; // rows
	for(int j=0; j<4; j++) {
		printf.buf[i+j+4] = v[j/2][j%2];
	}
}
void print(mat3x3 v) { // 3 cols, 3 rows (column-major)
    uint i = atomicAdd(printf_stats.buf[1], 13);
	if(i>4000000) return;

    printf.buf[i]   = 6; // type
	printf.buf[i+1] = 9; // components
	printf.buf[i+2] = 3; // cols
    printf.buf[i+3] = 3; // rows
	for(int j=0; j<9; j++) {
		printf.buf[i+j+4] = v[j/3][j%3];
	}
}
void printc(uint v) {
    _doprint(v, 0);
}
void printu(int v) {
    _doprint(v, 1);
}
void printi(int v) {
    _doprint(v, 2);
}
void print(float v) {
    _doprint(v, 3);
}
void print(uvec2 v) {
    _doprint(vec2(v), 1);
}
void print(uvec3 v) {
    _doprint(vec3(v), 1);
}
void print(uvec4 v) {
    _doprint(vec4(v), 1);
}
void print(ivec2 v) {
    _doprint(vec2(v), 2);
}
void print(ivec3 v) {
    _doprint(vec3(v), 2);
}
void print(ivec4 v) {
    _doprint(vec4(v), 2);
}
void print(vec2 v) {
    _doprint(v, 3);
}
void print(vec3 v) {
    _doprint(v, 3);
}
void print(vec4 v) {
    _doprint(v, 3);
}
