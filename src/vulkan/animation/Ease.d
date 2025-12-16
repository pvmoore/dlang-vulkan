module vulkan.animation.Ease;

import vulkan.animation.easing.easein;
import vulkan.animation.easing.easeout;
import vulkan.animation.easing.easeinout;

enum EasingType {
	EASEIN,
	EASEOUT,
	EASEINOUT
}

enum EasingSubType {
	SINE,
	EXPONENTIAL
}

interface Easing {
	bool isFinished();
	float step(float amount = 1);
    void reset();
}

/**
 * Ease between two sets of values over a fixed number of seconds
 */
final class Ease {
public:
    void* getUserData() { return userData; }

    this(float numSeconds, EasingType easingType, EasingSubType easingSubtype, float[] from, float[] to) {
        assert(numSeconds > 0, "'numSeconds' must be greater than 0");
        assert(from.length > 0, "'from' must have at least one value");
        assert(from.length == to.length, "'from' and 'to' arrays must be the same length");

        this.numSeconds = numSeconds;
        this.easingType = easingType;
        this.easingSubtype = easingSubtype;
        this.from = from;
        this.to = to;
        this.currentSecond = 0;
        this.current = from.dup;

        foreach(i; 0..from.length) {
            float distance = to[i] - from[i];

            final switch(easingType) with(EasingType) {
                case EASEIN :
                    easings ~= new EaseIn(easingSubtype, distance, numSeconds);
                    break;
                case EASEOUT :
                    easings ~= new EaseOut(easingSubtype, distance, numSeconds);
                    break;
                case EASEINOUT :
                    easings ~= new EaseInOut(easingSubtype, distance, numSeconds);
                    break;
            }
        }
    }
    void reset() {
        currentSecond = 0;
        current = from.dup;
        onFinishCalled = false;
        foreach(e; easings) {
            e.reset();
        }
    }
    auto withUserData(void* data) {
        this.userData = data;
        return this;
    }
    auto onFinish(void delegate(Ease) callback) {
        this.onFinishCallback = callback;
        return this;
    }
    bool isFinished() {
        return currentSecond >= numSeconds;
    }
    float[] step(float incrementSeconds) {
        if(currentSecond >= numSeconds) {
            current = to;
            return get();
        }
        currentSecond += incrementSeconds;

        foreach(i; 0..from.length) {
            current[i] = from[i] + easings[i].step(incrementSeconds);
        }

        if(onFinishCallback && !onFinishCalled && currentSecond >= numSeconds) {
            onFinishCalled = true;
            onFinishCallback(this);
        }

        return get();
    }
    float[] get() {
        return current;
    }
private:
    const float numSeconds;
    const EasingType easingType;
    const EasingSubType easingSubtype;
    float[] from;
    float[] to;
    Easing[] easings;
    void delegate(Ease) onFinishCallback;
    bool onFinishCalled;
    void* userData;

    // Current state
    float currentSecond;
    float[] current;
}
