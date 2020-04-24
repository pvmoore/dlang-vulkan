module vulkan.types;
/**
 *
 */
import vulkan.all;

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

immutable RGBA BLACK   = RGBA(0,0,0,1);
immutable RGBA WHITE   = RGBA(1,1,1,1);
immutable RGBA RED 	   = RGBA(1,0,0,1);
immutable RGBA GREEN   = RGBA(0,1,0,1);
immutable RGBA BLUE    = RGBA(0,0,1,1);
immutable RGBA YELLOW  = RGBA(1,1,0,1);
immutable RGBA MAGENTA = RGBA(1,0,1,1);
immutable RGBA CYAN	   = RGBA(0,1,1,1);
immutable RGBA PINK	   = RGBA(1,0.2,0.7,1);
immutable RGBA_NONE	   = RGBA(0,0,0,0);


RGB randomRGB() {
	return RGB(uniform(0f,1f), uniform(0f,1f), uniform(0f,1f));
}
RGBA randomRGBA() {
	return RGBA(uniform(0f,1f), uniform(0f,1f), uniform(0f,1f), 1);
}
RGBA alpha(RGBA r, float a) {
	return RGBA(r.r, r.g, r.b, a);
}
RGBb toBytes(RGB o) {
	return RGBb(cast(ubyte)(o.r*255), cast(ubyte)(o.g*255), cast(ubyte)(o.b*255));
}
RGBAb toBytes(RGBA o) {
	return RGBAb(cast(ubyte)(o.r*255), cast(ubyte)(o.g*255), cast(ubyte)(o.b*255), cast(ubyte)(o.a*255));
}


