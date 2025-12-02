module vulkan.animation.easing.easeinout;
	
import vulkan.animation.Ease;

import std.math : pow, cos, PI;

/**
 * Start with ease in, end with ease out.
 */
final class EaseInOut : Easing {
public:	
	this(EasingSubType subtype, float distance, float maxT) {
		assert(maxT > 0);
		this.subtype = subtype;
		this.distance = distance;
		this.maxT = maxT;
		this.currentT = 0;
	}
	override void reset() {
		currentT = 0;
	}
	override bool isFinished() {
		return currentT >= maxT;
	}
	override float step(float amount = 1) {
		currentT += amount;
		
		final switch(subtype) with(EasingSubType){
			case SINE        : return sine(currentT, distance, maxT);
			case EXPONENTIAL : return exponential(currentT, distance, maxT);
		}
	}
private:
	const float distance;
	const float maxT;
	const EasingSubType subtype;
	float currentT;

	static float sine(float t, float distance, float maxT) {
		return t==0 ? 0 : -distance/2 * (cos(PI*t/maxT) - 1);
	}
	static float exponential(float t, float distance, float maxT) {
		if (t==0) return 0;
		if (t==maxT) return distance;
		if ((t/=maxT/2) < 1) return distance/2 * pow(2, 10 * (t - 1));
		return distance/2 * (-pow(2, -10 * --t) + 2);
	}	
}
	