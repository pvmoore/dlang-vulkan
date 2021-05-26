module vulkan.gui.IHAlignVAlign;

import vulkan.gui;

enum HAlign { CENTRE, LEFT, RIGHT }
enum VAlign { CENTRE, TOP, BOTTOM }

interface IHAlignVAlign {
    IHAlignVAlign setHAlign(HAlign a);
    IHAlignVAlign setVAlign(VAlign a);
}