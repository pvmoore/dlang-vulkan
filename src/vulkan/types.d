module vulkan.types;
/**
 *
 */
import vulkan.all;

struct FrameNumber {
	ulong value;
	FrameNumber next() { return FrameNumber(value+1); }
}

struct FrameBufferIndex { uint value; }

enum FRAME_BUFFER_INDEX_0 = FrameBufferIndex(0);

alias UV   = Vec2!float;
alias XY   = Vec2!float;
alias XYZ  = Vec3!float;
alias RGB  = Vec3!float;
alias RGBA = Vec4!float;

struct RGBb {
	ubyte r,g,b;
}
struct RGBAb {
	ubyte r,g,b,a;
}

enum BLACK     = RGBA(0,0,0,1);
enum WHITE     = RGBA(1,1,1,1);
enum RED 	   = RGBA(1,0,0,1);
enum GREEN     = RGBA(0,1,0,1);
enum BLUE      = RGBA(0,0,1,1);
enum YELLOW    = RGBA(1,1,0,1);
enum MAGENTA   = RGBA(1,0,1,1);
enum CYAN	   = RGBA(0,1,1,1);
enum PINK	   = RGBA(1,0.2,0.7,1);
enum RGBA_NONE = RGBA(0,0,0,0);


RGB randomRGB() {
	return RGB(uniform(0f,1f), uniform(0f,1f), uniform(0f,1f));
}
RGBA randomRGBA() {
	return RGBA(uniform(0f,1f), uniform(0f,1f), uniform(0f,1f), 1);
}
RGBA alpha(RGBA r, float a) {
	return RGBA(r.r, r.g, r.b, a);
}
RGBA merge(RGBA a, RGBA b) {
	return (a + b) * 0.5f;
}
RGBb toBytes(RGB o) {
	return RGBb(cast(ubyte)(o.r*255), cast(ubyte)(o.g*255), cast(ubyte)(o.b*255));
}
RGBAb toBytes(RGBA o) {
	return RGBAb(cast(ubyte)(o.r*255), cast(ubyte)(o.g*255), cast(ubyte)(o.b*255), cast(ubyte)(o.a*255));
}


