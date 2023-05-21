module vulkan.renderers.RendererFactory;

import vulkan.all;

final class RendererFactory {
public:
    static struct Properties {
        uint maxLines;
        uint maxRectangles;
        uint maxRoundRectangles;
        uint maxCircles;
        uint maxPoints;
        uint maxQuads;
        uint maxCharacters;
        uint[string] imageMaxQuads;
        uint[string] fontMaxCharacters;
    }
    this(VulkanContext context, Properties props) {
        this.context = context;
        this.props = props;
        this.currentLayer = Layer(0);

        initialise();
    }
    void destroy() {
        log("Destroying RendererFactory");
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
            throwIf(props.maxLines == 0, "maxLines has not been set");
            lines = r.lines = new Lines(context, props.maxLines);
            lines.camera(currentCamera);
        }
        return lines;
    }
    Rectangles getRectangles() {
        auto r = getRenderers();
        auto rectangles = r.rectangles;
        if(!rectangles) {
            throwIf(props.maxRectangles == 0, "maxRectangles has not been set");
            rectangles = r.rectangles = new Rectangles(context, props.maxRectangles);
            rectangles.camera(currentCamera);
        }
        return rectangles;
    }
    RoundRectangles getRoundRectangles() {
        auto r = getRenderers();
        auto rectangles = r.roundRectangles;
        if(!rectangles) {
            throwIf(props.maxRoundRectangles == 0, "maxRoundRectangles has not been set");
            rectangles = r.roundRectangles = new RoundRectangles(context, props.maxRoundRectangles);
            rectangles.camera(currentCamera);
        }
        return rectangles;
    }
    Circles getCircles() {
        auto r = getRenderers();
        auto circles = r.circles;
        if(!circles) {
            throwIf(props.maxCircles == 0, "maxCircles has not been set");
            circles = r.circles = new Circles(context, props.maxCircles);
            circles.camera(currentCamera);
        }
        return circles;
    }
    Points getPoints() {
        auto r = getRenderers();
        auto points = r.points;
        if(!points) {
            throwIf(props.maxPoints == 0, "maxPoints has not been set");
            points = r.points = new Points(context, props.maxPoints);
            points.camera(currentCamera);
        }
        return points;
    }
    Quads getQuads(string imageName) {
        auto r = getRenderers();
        auto p = imageName in r.quads;
        if(!p) {
            uint m = props.imageMaxQuads.get(imageName, props.maxQuads);
            throwIf(m == 0, "maxQuads has not been set for image %s".format(imageName));
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
            uint m = props.fontMaxCharacters.get(fontName, props.maxCharacters);
            throwIf(m == 0, "maxCharacters has not been set for font %s".format(fontName));
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
    static struct Layer {
        int level;
    }
    static final class Renderers {
        Lines lines;
        Rectangles rectangles;
        RoundRectangles roundRectangles;
        Circles circles;
        Points points;
        Quads[string] quads;    // key = image name
        Text[string] texts;     // key = font name
    }
    Properties props;
    @Borrowed VulkanContext context;
    VkSampler sampler;
    Renderers[Layer] renderers;
    int[] sortedLayers;
    Layer currentLayer;
    Camera2D currentCamera;

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
