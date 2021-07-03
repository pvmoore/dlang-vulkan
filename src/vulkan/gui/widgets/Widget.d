module vulkan.gui.widgets.Widget;

import vulkan.all;
import vulkan.gui;

abstract class Widget {
protected:
    @Borrowed VulkanContext context;
    int2 relPos;
    uint2 size;
    int layer;      // lower is further back
    Widget parent;
    Widget[] children;
    bool mouseEnterred; // true if mouse has enterred this widget
    bool _isModified = true;
    bool _isInitialised = false;
public:
    bool isEnabled = true;
    GUIProps props;
    GUIFrameEvent[] frameEvents;

    /** Returns the sum of all relative positions. */
    final int2 getAbsPos() {
        if(parent is null) return relPos;
        return relPos + parent.getAbsPos();
    }
    final int2 getRelPos() {
        return relPos;
    }
    final Widget setRelPos(int2 p) {
        relPos = p;
        this._isModified = true;
        return this;
    }
    final uint2 getSize() {
        return size;
    }
    final Widget setSize(uint2 s) {
        size = s;
        this._isModified = true;
        return this;
    }
    Widget setLayer(int layer) {
        this.layer = layer;
        this._isModified = true;
        return this;
    }
    final int indexOf(Widget child) {
        return children.indexOf(child);
    }
    /**
     * Increase depth.
     * Move child to the front of the list.
     */
    final void moveToBack(Widget child) {
        auto i = children.indexOf(child);
        if(i > 0) {
            children.removeAt(i);
            children.insertAt(0, child);
        }
        this._isModified = true;
    }
    /**
     * Decrease depth.
     * Move child to the end of the list.
     */
    final void moveToFront(Widget child) {
        auto i = children.indexOf(child);
        if(i!=-1 && i!=children.length-1) {
            children.removeAt(i);
            children ~= child;
        }
        this._isModified = true;
    }
    final bool enclosesPoint(float2 p) {
        return contains(getAbsPos(), getSize(), p);
    }
    final Stage getStage() {
        if(this.isA!Stage) return this.as!Stage;
        if(parent is null) return null;
        return parent.getStage();
    }
    final bool isOnStage() {
        return getStage !is null;
    }
    //====================================================================
    final Widget add(Widget child) {
        if(child.parent !is null) {
            if(child.parent is this) {
                // Child is already a child of this parent
                return this;
            }
            // Detach first
            child.detach();
        }
        child.parent = this;
        children ~= child;

        child.setLayer(this.layer-1);

        return this;
    }
    final void remove(Widget child) {
        child.parent = null;
        children.remove(child);
    }
    final bool isInitialised() {
        return _isInitialised;
    }
    final bool isAttached() {
        return parent !is null;
    }
    final void detach() {
        if(!isAttached()) return;
        parent.remove(this);
    }
    //====================================================================
    /** Return true if any properties have been changed requiring a UI update */
    bool isModified() {
        return _isModified || props.isModified;
    }
    enum UpdateState { NORMAL, INIT, UPDATE }
    /** Called before the render phase */
    void onUpdate(Frame frame, UpdateState state) {
        // override me
    }
    void onRender(Frame frame) {
        // override me if the Widget has bespoke rendering
    }
    abstract void destroy();

    //====================================================================
    override string toString() {
        auto s =  format("%s[%s : %s %s children] parent:%s",
                             className(this),
                             relPos, size, children.length,
                             className(parent));
        foreach(c; children) {
            s ~= "\n\t" ~ c.toString();
        }
        return s;
    }
protected:
    final void fireDestroy() {
        auto childrenCopy = children.dup;
        destroy();
        foreach(c; childrenCopy) {
            c.fireDestroy();
        }
    }
    final void fireUpdate(Frame frame) {
        if(!isEnabled) return;

        auto childrenCopy = children.dup;

        auto state = UpdateState.NORMAL;

        if(isModified()) {
            if(isInitialised()) {
                state = UpdateState.UPDATE;
            } else {
                state = UpdateState.INIT;
            }
        }
        onUpdate(frame, state);
        _isInitialised = true;

        // Update children in reverse order
        foreach_reverse(c; childrenCopy) {
            c.fireUpdate(frame);
        }
    }
    final void fireRender(Frame frame) {
        if(!isEnabled) return;
        if(!isInitialised()) return;

        auto childrenCopy = children.dup;
        onRender(frame);

        // Reset modification flags
        _isModified = false;
        if(props) props.isModified = false; else this.log("%s has not created props", this.className());

        foreach(c; childrenCopy) {
            c.fireRender(frame);
        }
    }
    final void recurse(bool delegate(Widget w) functor) {
        if(functor(this)) {
            foreach(ch; children) {
                ch.recurse(functor);
            }
        }
    }
private:
}