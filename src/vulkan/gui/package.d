module vulkan.gui;

public:

import vulkan.all;
import vulkan.gui.GUI;
import vulkan.gui.GUIEvent;
import vulkan.gui.Props;
import vulkan.gui.Stage;

import vulkan.gui.IHAlignVAlign;

import vulkan.gui.widgets.Label;
import vulkan.gui.widgets.Menu;
import vulkan.gui.widgets.MenuBar;
import vulkan.gui.widgets.MenuItem;
import vulkan.gui.widgets.VScrollBar;
import vulkan.gui.widgets.Widget;

import vulkan.gui.widgets.buttons.Button;
import vulkan.gui.widgets.buttons.CycleButton;
import vulkan.gui.widgets.buttons.ToggleButton;
import vulkan.gui.widgets.buttons.ToggleGroup;

import vulkan.gui.widgets.text.TextBox;


bool contains(int2 pos, uint2 size, float2 point) {
    return  point.x >= pos.x &&
            point.y >= pos.y &&
            point.x < pos.x+size.width &&
            point.y < pos.y+size.height;
}

/**
 * TODO
 *  - Checkbox
 *  - RadioButton
 *  - Slider
 *  - MenuBar/Menu/MenuItem
 *  - SelectBox
 *  - ListBox
 *  - ContextMenu
 *  - TreeView
 *  - TextBox (editable)
 *  - TextArea (editable/rich)
 *  - StatusBar
 *  - Tab
 */