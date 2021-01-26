module vulkan.renderers.Canvas2D;

import vulkan.all;

/**
 *
 *
 *
 */
final class Canvas2D {
private:
    static struct Depth {
        int level;
    }
    static struct Renderers {
        Lines lines;
        Rectangles rectangles;
        RoundRectangles roundRectangles;
        Circles circles;
        Quad quads;
    }
    @Borrowed VulkanContext context;
    Renderers[Depth] renderers;
    Depth currentDepth;
public:
    this(VulkanContext context) {
        this.context = context;
        this.currentDepth = Depth(0);
        initialise();
    }
    void destroy() {
        foreach(ref r; renderers.values) {
            r.lines.destroy();
            r.rectangles.destroy();
            r.roundRectangles.destroy();
            r.circles.destroy();
            r.quads.destroy();
        }
    }
    auto camera(Camera2D cam) {
        foreach(ref r; renderers.values) {

        }
        return this;
    }
    auto depth(int d) {
        this.currentDepth = Depth(d);
        return this;
    }
private:
    void initialise() {

    }
}
