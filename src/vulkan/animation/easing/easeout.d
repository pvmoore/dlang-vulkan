module vulkan.animation.easing.easeout;

import vulkan.animation.Ease;

import std.math : pow, sin, PI;

/**
 * Start off at max speed then decrease to stop.
 */
final class EaseOut : Easing {
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
		
		final switch(subtype) with(EasingSubType) {
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
		return t==0 ? 0 : distance * sin(t/maxT * (PI/2));
	}
	static float exponential(float t, float distance, float maxT) {
		return (t==maxT) ? distance : distance * (-pow(2, -10 * t/maxT) + 1);
	}
}
	