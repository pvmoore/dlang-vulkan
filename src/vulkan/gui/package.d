module vulkan.gui;

public:

import vulkan.all;
import vulkan.gui.GUI;
import vulkan.gui.Props;
import vulkan.gui.Stage;

import vulkan.gui.IHAlignVAlign;

import vulkan.gui.widgets.Button;
import vulkan.gui.widgets.Label;
import vulkan.gui.widgets.Menu;
import vulkan.gui.widgets.MenuBar;
import vulkan.gui.widgets.MenuItem;
import vulkan.gui.widgets.VScrollBar;
import vulkan.gui.widgets.Widget;

bool contains(IntRect a, float2 point) {
    return  point.x >= a.x &&
            point.y >= a.y &&
            point.x < a.x+a.width &&
            point.y < a.y+a.height;
}
