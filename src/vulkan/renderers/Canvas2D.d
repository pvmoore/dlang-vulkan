module vulkan.renderers.Canvas2D;

import vulkan.all;

final class Canvas2D {
private:
    static struct Depth {
        int level;
    }
    static final class Renderers {
        Lines lines;
        Rectangles rectangles;
        RoundRectangles roundRectangles;
        Circles circles;
        Quads quads;
        Points points;
    }
    @Borrowed VulkanContext context;
    VkSampler sampler;
    Renderers[Depth] renderers;
    int[] sortedDepths;
    Depth currentDepth;
    ImageMeta currentImage;
    Camera2D currentCamera;
    float4 currentColour;
    float currentLineThickness;

    uint maxLines, maxRectangles, maxRoundRectangles, maxCircles, maxQuads, maxPoints;
public:
    this(VulkanContext context, ImageMeta image = ImageMeta()) {
        this.context = context;
        this.currentImage = image;
        this.currentDepth = Depth(0);
        this.currentColour = float4(1,1,1,1);
        this.currentLineThickness = 1;

        initialise();
    }
    void destroy() {
        if(sampler) context.device.destroySampler(sampler);
        foreach(r; renderers.values) {
            if(r.lines) r.lines.destroy();
            if(r.rectangles) r.rectangles.destroy();
            if(r.roundRectangles) r.roundRectangles.destroy();
            if(r.circles) r.circles.destroy();
            if(r.quads) r.quads.destroy();
            if(r.points) r.points.destroy();
        }
    }
    auto withMaxLines(uint m) {
        _assert(maxLines==0, "maxLines has already been set");
        this.maxLines = m;
        return this;
    }
    auto withMaxRectangles(uint m) {
        _assert(maxRectangles==0, "maxRectangles has already been set");
        this.maxRectangles = m;
        return this;
    }
    auto withMaxRoundRectangles(uint m) {
        _assert(maxRoundRectangles==0, "maxRoundRectangles has already been set");
        this.maxRoundRectangles = m;
        return this;
    }
    auto withMaxCircles(uint m) {
        _assert(maxCircles==0, "maxCircles has already been set");
        this.maxCircles = m;
        return this;
    }
    auto withMaxQuads(uint m) {
        _assert(maxQuads==0, "maxQuads has already been set");
        this.maxQuads = m;
        return this;
    }
    auto withMaxPoints(uint m) {
        _assert(maxPoints==0, "maxPoints has already been set");
        this.maxPoints = m;
        return this;
    }
    auto camera(Camera2D cam) {
        this.currentCamera = cam;
        setCamera();
        return this;
    }
    auto depth(int d) {
        this.currentDepth = Depth(d);
        return this;
    }
    auto clear() {
        todo();
        return this;
    }
    auto colour(float4 c) {
        this.currentColour = c;
        return this;
    }

    auto lineThickness(float t) {
        this.currentLineThickness = t;
        return this;
    }
    auto line(float2 from, float2 to) {
        getLines().add(from, to, currentColour, currentColour, currentLineThickness, currentLineThickness);
        return this;
    }
    auto line(float2 from, float2 to, float thickness) {
        getLines().add(from, to, currentColour, currentColour, thickness, thickness);
        return this;
    }

    auto rectangle(float2 p1, float2 p2, float2 p3, float2 p4) {
        getRectangles().add(p1, p2, p3, p4,
                 currentColour, currentColour, currentColour, currentColour);
        return this;
    }
    auto circle(float2 centre, float radius) {
        getCircles().add(centre, radius, currentLineThickness, float4(0,0,0,0), currentColour);
        return this;
    }
    auto filledCircle(float2 centre, float radius, float4 innerColour) {
        getCircles().add(centre, radius, currentLineThickness, innerColour, currentColour);
        return this;
    }
    auto roundRectangle(float2 pos, float2 size, float cornerRadius) {
        getRoundRectangles()
            .add(pos, size, currentColour, currentColour, currentColour, currentColour, cornerRadius);
        return this;
    }
    auto point(float2 pos, float size) {
        getPoints().add(pos, size, currentColour);
        return this;
    }
    auto quad(float2 pos, float2 size, float4 uv, float rotation) {
        getQuads().add(pos, size, uv, currentColour, rotation);
        return this;
    }
    void beforeRenderPass(Frame frame) {
        foreach(r; renderers.values) {
            if(r.lines) r.lines.beforeRenderPass(frame);
            if(r.rectangles) r.rectangles.beforeRenderPass(frame);
            if(r.roundRectangles) r.roundRectangles.beforeRenderPass(frame);
            if(r.circles) r.circles.beforeRenderPass(frame);
            if(r.quads) r.quads.beforeRenderPass(frame);
            if(r.points) r.points.beforeRenderPass(frame);
        }
    }
    void insideRenderPass(Frame frame) {
        foreach(d; sortedDepths) {
            auto r = renderers[Depth(d)];
            if(r.lines) r.lines.insideRenderPass(frame);
            if(r.rectangles) r.rectangles.insideRenderPass(frame);
            if(r.roundRectangles) r.roundRectangles.insideRenderPass(frame);
            if(r.circles) r.circles.insideRenderPass(frame);
            if(r.quads) r.quads.insideRenderPass(frame);
            if(r.points) r.points.insideRenderPass(frame);
        }
    }
private:
    void initialise() {
        createSampler();
        initialiseDepth(currentDepth);
    }
    void createSampler() {
        this.sampler = context.device.createSampler(samplerCreateInfo());
    }
    void initialiseDepth(Depth depth) {
        if(depth in renderers) return;
        this.renderers[depth] = new Renderers();
        this.sortedDepths ~= depth.level;
        this.sortedDepths.sort();
        this.log("sortedDepths = %s", sortedDepths);
    }
    auto getRenderers() {
        return renderers[currentDepth];
    }
    void setCamera() {
        foreach(r; renderers.values) {
            if(r.lines) r.lines.camera(currentCamera);
            if(r.rectangles) r.rectangles.camera(currentCamera);
            if(r.roundRectangles) r.roundRectangles.camera(currentCamera);
            if(r.circles) r.circles.camera(currentCamera);
            if(r.quads) r.quads.camera(currentCamera);
            if(r.points) r.points.camera(currentCamera);
        }
    }
    auto getLines() {
        auto r = getRenderers();
        auto lines = r.lines;
        if(!lines) {
            _assert(maxLines > 0, "maxLines has not been set");
            lines = r.lines = new Lines(context, maxLines);
            lines.camera(currentCamera);
        }
        return lines;
    }
    auto getRectangles() {
        auto r = getRenderers();
        auto rectangles = r.rectangles;
        if(!rectangles) {
            _assert(maxRectangles > 0, "maxRectangles has not been set");
            rectangles = r.rectangles = new Rectangles(context, maxRectangles);
            rectangles.camera(currentCamera);
        }
        return rectangles;
    }
    auto getRoundRectangles() {
        auto r = getRenderers();
        auto rectangles = r.roundRectangles;
        if(!rectangles) {
            _assert(maxRoundRectangles > 0, "maxRoundRectangles has not been set");
            rectangles = r.roundRectangles = new RoundRectangles(context, maxRoundRectangles);
            rectangles.camera(currentCamera);
        }
        return rectangles;
    }
    auto getCircles() {
        auto r = getRenderers();
        auto circles = r.circles;
        if(!circles) {
            _assert(maxCircles > 0, "maxCircles has not been set");
            circles = r.circles = new Circles(context, maxCircles);
            circles.camera(currentCamera);
        }
        return circles;
    }
    auto getPoints() {
        auto r = getRenderers();
        auto points = r.points;
        if(!points) {
            _assert(maxPoints > 0, "maxPoints has not been set");
            points = r.points = new Points(context, maxPoints);
            points.camera(currentCamera);
        }
        return points;
    }
    auto getQuads() {
        auto r = getRenderers();
        auto quads = r.quads;
        if(!quads) {
            _assert(maxQuads > 0, "maxQuads has not been set");
            quads = r.quads = new Quads(context, currentImage, sampler, maxQuads);
            quads.camera(currentCamera);
        }
        return quads;
    }
}
