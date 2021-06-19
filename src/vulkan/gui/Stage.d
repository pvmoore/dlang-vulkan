module vulkan.gui.Stage;

import vulkan.all;
import vulkan.gui;

final class Stage : Widget {
private:
    @Borrowed Vulkan vk;
    @Borrowed VkDevice device;
    @Borrowed VulkanContext context;
    @Borrowed Camera2D _camera;
    //Animations animations = new Animations();
    Hook[] afterUpdateHooks;
    VkSampler sampler;
    RendererFactory canvas;
public:
    alias Hook = void delegate();
    Camera2D getCamera() { return _camera; }
    //Animations getAnimations() { return animations; }

    VulkanContext getContext() {
        return context;
    }
    auto getSampler() {
        if(!sampler) {
            sampler = device.createSampler(samplerCreateInfo());
        }
        return sampler;
    }
    auto getTextRenderer(string fontName, int layer) {
        return canvas.layer(layer).getText(fontName);
    }
    auto getImageRenderer(string imageName, int layer) {
        return canvas.layer(layer).getQuads(imageName);
    }
    auto getRoundRectangles(int layer) {
        return canvas.layer(layer).getRoundRectangles();
    }
    auto getRectangles(int layer) {
        return canvas.layer(layer).getRectangles();
    }
    int getMaxDepth() {
        todo();
        return 0;
    }
    int getMinDepth() {
        todo();
        return 0;
    }

    void addAfterUpdateHook(Hook h) { afterUpdateHooks ~= h; }

    this(VulkanContext context, GUIProps props) {
        this.context = context;
        this.vk = context.vk;
        this.device = context.device;
        this.props = props;
        this.canvas = new RendererFactory(context )
            .withMaxLines(200)
            .withMaxCircles(200)
            .withMaxRectangles(200)
            .withMaxRoundRectangles(200)
            .withMaxPoints(200)
            .withMaxQuads(200)
            .withMaxCharacters(2000)
            .camera(_camera);

        vk.addWindowEventListener(new class WindowEventListener {
            override void keyPress(uint keyCode, uint scanCode, KeyAction action, uint mods) {
                handle(GUIFrameEvent.keyPress(null, keyCode, scanCode, action, mods));
            }
            override void mouseMoved(float x, float y) {
                handle(GUIFrameEvent.mouseMove(null, x.as!int, y.as!int), x.as!int, y.as!int);

                // do per Widget mouse enter/leave
                foreach(ch; children) {
                    ch.recurse((w) {
                        auto isInside = w.enclosesPoint(float2(x,y));
                        if(isInside && !w.mouseEnterred) {
                            // create enter event
                            w.frameEvents ~= GUIFrameEvent.mouseEnter(w, x.as!int, y.as!int, true);
                        } else if(!isInside && w.mouseEnterred) {
                            // create leave event
                            w.frameEvents ~= GUIFrameEvent.mouseEnter(w, x.as!int, y.as!int, false);
                        }
                        w.mouseEnterred = isInside;
                        return true;
                    });
                }
            }
            override void mouseButton(uint button, float x, float y, bool down, uint mods) {
                handle(GUIFrameEvent.mouseButton(null, x.as!int, y.as!int, button, down, mods), x.as!int, y.as!int);
            }
            override void mouseWheel(float xdelta, float ydelta, float x, float y) {
                handle(GUIFrameEvent.mouseWheel(null, x.as!int, y.as!int, xdelta, ydelta), x.as!int, y.as!int);
            }
            override void mouseEnter(float x, float y, bool enterred) {

            }
            override void iconify(bool flag) {
                handle(GUIFrameEvent.iconify(null, flag));
            }
            override void focus(bool flag) {
                handle(GUIFrameEvent.focus(null, flag));
            }
            void handle(GUIFrameEvent event) {
                foreach(ch; children) {
                    ch.recurse((w) {
                        event.widget = w;
                        w.frameEvents ~= event;
                        return true;
                    });
                }
            }
            void handle(GUIFrameEvent event, int x, int y) {
                 foreach(ch; children) {
                    ch.recurse((w) {
                        if(w.enclosesPoint(float2(x,y))) {
                            event.widget = w;
                            w.frameEvents ~= event;
                            return true;
                        }
                        return false;
                    });
                }
            }
        });
    }
    override void destroy() {
        foreach(c; children) {
            c.fireDestroy();
        }
        if(canvas) canvas.destroy();
        if(sampler) device.destroySampler(sampler);
    }
    void camera(Camera2D camera) {
        this._camera = camera;
        this.canvas.camera(camera);
    }
    override void update(Frame frame) {
        assert(_camera);

        //animations.update(frame.delta);

        canvas.beforeRenderPass(frame);

        // Update children in reverse order
        foreach_reverse(c; children) {
            c.fireUpdate(frame);
        }

        if(afterUpdateHooks.length > 0) {
            foreach(hook; afterUpdateHooks) {
                hook();
            }
            afterUpdateHooks.length = 0;
        }
    }
    override void render(Frame frame) {
        resetEvents();

        canvas.insideRenderPass(frame);

        foreach(c; children) {
            c.fireRender(frame);
        }
    }
private:
    void resetEvents() {
        recurse((w) {
            w.frameEvents.length = 0;
            return true;
        });
    }
}