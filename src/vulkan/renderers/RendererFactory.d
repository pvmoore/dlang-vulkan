module vulkan.renderers.RendererFactory;

import vulkan.all;

final class RendererFactory {
private:
    static struct Layer {
        int level;
    }
    static final class Renderers {
        Lines lines;
        Rectangles rectangles;
        RoundRectangles roundRectangles;
        Circles circles;
        Points points;
        Quads[string] quads;
        Text[string] texts;
    }
    @Borrowed VulkanContext context;
    VkSampler sampler;
    Renderers[Layer] renderers;
    int[] sortedLayers;
    Layer currentLayer;
    Camera2D currentCamera;

    uint[string] imageMaxChars;
    uint[string] fontMaxChars;

    uint maxLines, maxRectangles, maxRoundRectangles,
         maxCircles, maxQuads, maxPoints, maxCharacters;
public:
    this(VulkanContext context) {
        this.context = context;
        this.currentLayer = Layer(0);

        initialise();
    }
    void destroy() {
        if(sampler) context.device.destroySampler(sampler);
        foreach(r; renderers.values()) {
            if(r.lines) r.lines.destroy();
            if(r.rectangles) r.rectangles.destroy();
            if(r.roundRectangles) r.roundRectangles.destroy();
            if(r.circles) r.circles.destroy();
            if(r.points) r.points.destroy();
            foreach(q; r.quads.values()) q.destroy();
            foreach(t; r.texts.values()) t.destroy();
        }
    }
    auto withMaxLines(uint m) {
        vkassert(maxLines==0, "maxLines has already been set");
        this.maxLines = m;
        return this;
    }
    auto withMaxRectangles(uint m) {
        vkassert(maxRectangles==0, "maxRectangles has already been set");
        this.maxRectangles = m;
        return this;
    }
    auto withMaxRoundRectangles(uint m) {
        vkassert(maxRoundRectangles==0, "maxRoundRectangles has already been set");
        this.maxRoundRectangles = m;
        return this;
    }
    auto withMaxCircles(uint m) {
        vkassert(maxCircles==0, "maxCircles has already been set");
        this.maxCircles = m;
        return this;
    }
    auto withMaxQuads(uint m) {
        vkassert(maxQuads==0, "maxQuads has already been set");
        this.maxQuads = m;
        return this;
    }
    auto withMaxPoints(uint m) {
        vkassert(maxPoints==0, "maxPoints has already been set");
        this.maxPoints = m;
        return this;
    }
    auto withMaxCharacters(uint m) {
        vkassert(maxCharacters==0, "maxCharacters has already been set");
        this.maxCharacters = m;
        return this;
    }
    auto withImageMaxCharacters(string imageName, uint m) {
        vkassert(imageName !in imageMaxChars, "maxCharacters has already been set for image %s".format(imageName));
        imageMaxChars[imageName] = m;
        return this;
    }
    auto withFontMaxCharacters(string fontName, uint m) {
        vkassert(fontName !in fontMaxChars, "maxCharacters has already been set for font %s".format(fontName));
        fontMaxChars[fontName] = m;
        return this;
    }
    auto camera(Camera2D cam) {
        this.currentCamera = cam;
        setCamera();
        return this;
    }
    auto layer(int d) {
        this.currentLayer = Layer(d);
        initialiseLayer(currentLayer);
        return this;
    }
    auto clear() {
        todo();
        return this;
    }

    Lines getLines() {
        auto r = getRenderers();
        auto lines = r.lines;
        if(!lines) {
            vkassert(maxLines > 0, "maxLines has not been set");
            lines = r.lines = new Lines(context, maxLines);
            lines.camera(currentCamera);
        }
        return lines;
    }
    Rectangles getRectangles() {
        auto r = getRenderers();
        auto rectangles = r.rectangles;
        if(!rectangles) {
            vkassert(maxRectangles > 0, "maxRectangles has not been set");
            rectangles = r.rectangles = new Rectangles(context, maxRectangles);
            rectangles.camera(currentCamera);
        }
        return rectangles;
    }
    RoundRectangles getRoundRectangles() {
        auto r = getRenderers();
        auto rectangles = r.roundRectangles;
        if(!rectangles) {
            vkassert(maxRoundRectangles > 0, "maxRoundRectangles has not been set");
            rectangles = r.roundRectangles = new RoundRectangles(context, maxRoundRectangles);
            rectangles.camera(currentCamera);
        }
        return rectangles;
    }
    Circles getCircles() {
        auto r = getRenderers();
        auto circles = r.circles;
        if(!circles) {
            vkassert(maxCircles > 0, "maxCircles has not been set");
            circles = r.circles = new Circles(context, maxCircles);
            circles.camera(currentCamera);
        }
        return circles;
    }
    Points getPoints() {
        auto r = getRenderers();
        auto points = r.points;
        if(!points) {
            vkassert(maxPoints > 0, "maxPoints has not been set");
            points = r.points = new Points(context, maxPoints);
            points.camera(currentCamera);
        }
        return points;
    }
    Quads getQuads(string imageName) {
        auto r = getRenderers();
        auto p = imageName in r.quads;
        if(!p) {
            uint m = imageMaxChars.get(imageName, maxQuads);
            vkassert(m > 0, "maxQuads has not been set for image %s".format(imageName));
            auto meta = context.images().get(imageName);
            auto q = new Quads(context, meta, sampler, m);
            q.camera(currentCamera);
            r.quads[imageName] = q;
            return q;
        }
        return *p;
    }
    Text getText(string fontName) {
        auto r = getRenderers();
        auto p = fontName in r.texts;
        if(!p) {
            uint m = fontMaxChars.get(fontName, maxCharacters);
            vkassert(m > 0, "maxCharacters has not been set for font %s".format(fontName));
            auto t = new Text(context, context.fonts().get(fontName), true, m);
            t.camera(currentCamera);
            r.texts[fontName] = t;
            return t;
        }
        return *p;
    }

    void beforeRenderPass(Frame frame) {
        foreach(r; renderers.values) {
            if(r.lines) r.lines.beforeRenderPass(frame);
            if(r.rectangles) r.rectangles.beforeRenderPass(frame);
            if(r.roundRectangles) r.roundRectangles.beforeRenderPass(frame);
            if(r.circles) r.circles.beforeRenderPass(frame);
            if(r.points) r.points.beforeRenderPass(frame);
            foreach(q; r.quads.values()) q.beforeRenderPass(frame);
            foreach(t; r.texts.values()) t.beforeRenderPass(frame);
        }
    }
    void insideRenderPass(Frame frame) {
        foreach(d; sortedLayers) {
            auto r = renderers[Layer(d)];
            if(r.lines) r.lines.insideRenderPass(frame);
            if(r.rectangles) r.rectangles.insideRenderPass(frame);
            if(r.roundRectangles) r.roundRectangles.insideRenderPass(frame);
            if(r.circles) r.circles.insideRenderPass(frame);
            if(r.points) r.points.insideRenderPass(frame);
            foreach(q; r.quads.values()) q.insideRenderPass(frame);
            foreach(t; r.texts.values()) t.insideRenderPass(frame);
        }
    }
private:
    void initialise() {
        createSampler();
        initialiseLayer(currentLayer);
    }
    void createSampler() {
        this.sampler = context.device.createSampler(samplerCreateInfo());
    }
    void initialiseLayer(Layer layer) {
        if(layer in renderers) return;
        this.renderers[layer] = new Renderers();
        this.sortedLayers ~= layer.level;
        this.sortedLayers.sort();
        this.log("sortedLayers = %s", sortedLayers);
    }
    auto getRenderers() {
        return renderers[currentLayer];
    }
    void setCamera() {
        foreach(r; renderers.values) {
            if(r.lines) r.lines.camera(currentCamera);
            if(r.rectangles) r.rectangles.camera(currentCamera);
            if(r.roundRectangles) r.roundRectangles.camera(currentCamera);
            if(r.circles) r.circles.camera(currentCamera);
            if(r.points) r.points.camera(currentCamera);
            foreach(q; r.quads.values()) q.camera(currentCamera);
            foreach(t; r.texts.values()) t.camera(currentCamera);
        }
    }
}
