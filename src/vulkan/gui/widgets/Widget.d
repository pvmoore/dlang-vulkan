module vulkan.gui.widgets.Widget;

import vulkan.all;
import vulkan.gui;

abstract class Widget {
protected:
    int2 relPos;
    uint2 size;
    int borderSize;
    int layer;      // lower is further back
    Widget parent;
    Widget[] children;
    bool mouseEnterred; // true if mouse has enterred this widget
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
        bool changed = p!=relPos;
        relPos = p;
        if(changed) onMoved();
        return this;
    }
    final uint2 getSize() {
        return size;
    }
    final Widget setSize(uint2 s) {
        bool changed = s!=size;
        size = s;
        if(changed) onResized();
        return this;
    }
    Widget setLayer(int layer) {
        this.layer = layer;
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

        // Call events
        child.onAdded();
        onChildAdded(child);
        if(auto stage = getStage()) child.fireOnAddedToStage(stage);
        return this;
    }
    final void remove(Widget child) {
        auto stage = getStage();
        child.parent = null;
        if(children.remove(child)) {
            // Call events of child was actually removed
            child.onRemoved();
            onChildRemoved(child);
            if(stage) child.fireOnRemovedFromStage(stage);
        }
    }
    final bool isAttached() {
        return parent !is null;
    }
    final void detach() {
        if(!isAttached()) return;
        parent.remove(this);
    }
    void update(Frame frame) {
        // override me
    }
    void render(Frame frame) {
        // override me
    }
    abstract void destroy();
    //====================================================================
    // Child events
    //====================================================================
    void onAdded() {
        // override this if you need to do things after you are added
    }
    void onRemoved() {
        // override if you need to do things after you are removed
    }
    void onAddedToStage(Stage stage) {
        // override if you need to do things after you are
        // added to the stage (directly or indirectly)
    }
    void onRemovedFromStage(Stage stage) {
        // override if you need to do things after you are
        // removed from the stage (directly or indirectly)
    }
    void onMoved() {
        // override if you are interested in move events
    }
    void onResized() {
        // override if you are interested in size events
    }
    //====================================================================
    // Parent events
    //====================================================================
    void onChildAdded(Widget child) {
        // override if you are interested
    }
    void onChildRemoved(Widget child) {
        // override if you are interested
    }
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
        auto childrenCopy = children.dup;
        update(frame);

        // Update children in reverse order
        foreach_reverse(c; childrenCopy) {
            c.fireUpdate(frame);
        }
    }
    final void fireRender(Frame frame) {
        auto childrenCopy = children.dup;
        render(frame);
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
    void fireOnAddedToStage(Stage stage) {
        auto childrenCopy = children.dup;
        onAddedToStage(stage);
        foreach(c; childrenCopy) {
            c.fireOnAddedToStage(stage);
        }
    }
    void fireOnRemovedFromStage(Stage stage) {
        auto childrenCopy = children.dup;
        onRemovedFromStage(stage);
        foreach(c; childrenCopy) {
            c.fireOnRemovedFromStage(stage);
        }
    }
}