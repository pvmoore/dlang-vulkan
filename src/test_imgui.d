module test_imgui;

import core.sys.windows.windows;
import core.runtime;
import std.string : toStringz;
import std.stdio  : writefln;
import std.format : format;
import std.datetime.stopwatch : StopWatch;

import vulkan.all;

final class TestImgui : VulkanApplication {
    Vulkan vk;
	VkDevice device;
    VulkanContext context;
    VkRenderPass renderPass;

    FPS fps;
    Camera2D camera;

    VkClearValue bgColour;

    ubyte[] ram;

    this() {
        enum NAME = "Vulkan Imgui Test";
        WindowProperties wprops = {
            width:          1400,
            height:         800,
            fullscreen:     false,
            vsync:          false,
            title:          NAME,
            icon:           "resources/images/logo.png",
            showWindow:     false,
            frameBuffers:   3,
            titleBarFps:    true
        };
        VulkanProperties vprops = {
            appName: NAME,
            imgui: {
                enabled: true,
                configFlags: 0 
                    | ImGuiConfigFlags_NoMouseCursorChange 
                    | ImGuiConfigFlags_DockingEnable 
                    | ImGuiConfigFlags_ViewportsEnable,
                fontPaths: [
                    "resources/fonts/Roboto-Regular.ttf",
                    "resources/fonts/RobotoCondensed-Regular.ttf"
                ],
                fontSizes: [
                    22,
                    20
                ]
            }
        };

        this.ram = new ubyte[65536];
        foreach(i; 0..ram.length) {
            ram[i] = (uniform01()*255).as!ubyte;
        }

		this.vk = new Vulkan(this, wprops, vprops);
        vk.initialise();
        vk.showWindow();
    }
    override void destroy() {
	    if(!vk) return;
	    if(device) {
	        vkDeviceWaitIdle(device);

            if(context) context.dumpMemory();

            if(fps) fps.destroy();
            if(renderPass) device.destroyRenderPass(renderPass);
            if(context) context.destroy();
	    }
		vk.destroy();
    }
    override void run() {
        vk.mainLoop();
    }
    override VkRenderPass getRenderPass(VkDevice device) {
        createRenderPass(device);
        return renderPass;
    }
    override void deviceReady(VkDevice device, PerFrameResource[] frameResources) {
        this.device = device;
        initScene();
    }
    void update(Frame frame) {
        fps.beforeRenderPass(frame, vk.getFPSSnapshot());
    }
    override void render(Frame frame) {
        auto res = frame.resource;
	    auto b = res.adhocCB;
	    b.beginOneTimeSubmit();

        update(frame);

        // begin the render pass
        b.beginRenderPass(
            renderPass,
            frame.frameBuffer,
            toVkRect2D(0,0, vk.windowSize.toVkExtent2D),
            [ bgColour ],
            VK_SUBPASS_CONTENTS_INLINE
        );

        imguiFrame(frame);
        fps.insideRenderPass(frame);

        b.endRenderPass();
        b.end();

        /// Submit our render buffer
        vk.getGraphicsQueue().submit(
            [b],
            [res.imageAvailable],
            [VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT],
            [res.renderFinished],  // signal semaphores
            res.fence              // fence
        );
    }
private:
    void initScene() {
        this.camera = Camera2D.forVulkan(vk.windowSize);

        auto mem = new MemoryAllocator(vk);

        auto maxLocal =
            mem.builder(0)
                .withAll(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                .withoutAll(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT)
                .maxHeapSize();

        this.log("Max local memory = %s MBs", maxLocal / 1.MB);

        this.context = new VulkanContext(vk)
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("G2D_Local", 256.MB))
          //.withMemory(MemID.SHARED, mem.allocStdShared("G2D_Shared", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("G2D_Staging", 32.MB));

        context.withBuffer(MemID.LOCAL, BufID.VERTEX,    VK_BUFFER_USAGE_VERTEX_BUFFER_BIT  | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 32.MB)
               .withBuffer(MemID.LOCAL, BufID.INDEX,     VK_BUFFER_USAGE_INDEX_BUFFER_BIT   | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 32.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM,   VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 1.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, 32.MB);

        context.withFonts("resources/fonts/")
               .withImages("resources/images")
               .withRenderPass(renderPass);

        this.log("shared mem available = %s", context.hasMemory(MemID.SHARED));

        this.log("%s", context);

        this.fps = new FPS(context);

        this.memoryEditor = new MemoryEditor()
            .withFont(vk.getImguiFont(1));

        this.memoryEditor.OptShowDataPreview = true;

        this.bgColour = clearColour(0.15f, 0.15f, 0, 1);
    }
    void createRenderPass(VkDevice device) {
        this.log("Creating render pass");
        auto colorAttachment    = attachmentDescription(vk.swapchain.colorFormat);
        auto colorAttachmentRef = attachmentReference(0);

        auto subpass = subpassDescription((info) {
            info.colorAttachmentCount = 1;
            info.pColorAttachments    = &colorAttachmentRef;
        });

        auto dependency = subpassDependency();

        renderPass = .createRenderPass(
            device,
            [colorAttachment],
            [subpass],
            subpassDependency2()//[dependency]
        );
    }

    bool show_demo_window = true;
    bool show_another_window = false;
    void imguiFrame(Frame frame) {
        vk.imguiRenderStart(frame);

        // This will turn the main window into a dockspace
        // which means it won't have a menu bar.
        // If you don't want this behaviour then comment the line below
        igDockSpaceOverViewport(0, null, ImGuiDockNodeFlags_PassthruCentralNode, null);
        

        // if (show_demo_window)
        //      igShowDemoWindow(&show_demo_window);

        // string text = "Hello from another window!";

        // auto c = vk.getImguiContext();


        // igBegin("Another Window", &show_another_window, 0);   // Pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)
        // igText("Hello from another window!");
        // if (igButton("Close Me", ImVec2(0,0)))
        //     show_another_window = false;
        // igEnd();


        textAndButtons();
        windowWithTables();
        menu();
        treeWindow();
        tabs();
        drawingWindow();
        combo();

        memoryEditor.DrawWindow("RAM", ram.ptr, ram.length, 0);

        if(igIsKeyPressed_Bool(ImGuiKey_0, false)) {
            log("zero");
        }

        vk.imguiRenderEnd(frame);
    }

    MemoryEditor memoryEditor;
    bool isOpen = true;
    bool cb1 = false;
    char[] buf = "Hello World!".as!(char[]);
    char[] buf2 = "".as!(char[]);
    char[16] userData;
    float[4] colour = [0,0,0,0];
    bool flag;
    bool flag2;
    int intValue;
    float ff = 0.75;
    int item_current = 0;
    int i0, i1, i2;
    float f0 = 0, f1 = 0, f2 = 0;
    float angle = 0;
    int listBoxItem = 1;
    extern(C) ImGuiInputTextCallback textCallback = (ImGuiInputTextCallbackData* data) {
            log("char = %s", data.EventChar);
            return 0;
        };

    int combo_item_selected_idx = 0;  

    void combo() {
        immutable(char)*[] items = [ "AAAA", "BBBB", "CCCC", "DDDD", "EEEE", "FFFF", "GGGG", "HHHH", "IIII", "JJJJ", "KKKK", "LLLLLLL", "MMMM", "OOOOOOO" ];

        // Pass in the preview value visible before opening the combo (it could technically be different contents or not pulled from items[])
        immutable(char)* combo_preview_value = items[combo_item_selected_idx];

        if (igBeginCombo("combo 1", combo_preview_value, ImGuiComboFlags_HeightLargest))
        {
            for (int n = 0; n < items.length; n++)
            {
                const bool is_selected = (combo_item_selected_idx == n);
                if (igSelectable_Bool(items[n], is_selected, ImGuiSelectableFlags_None, ImVec2(0,0)))
                    combo_item_selected_idx = n;

                // Set the initial focus when opening the combo (scrolling + keyboard navigation focus)
                if (is_selected)
                    igSetItemDefaultFocus();
            }
            igEndCombo();
        }
    }

    void textAndButtons() {
        enum AUTO_SIZE = ImVec2(0,0);

        ImVec2 center;
        ImGuiViewport_GetCenter(&center, igGetMainViewport());
        igSetNextWindowPos(center, ImGuiCond_Always, ImVec2(0,0));
        igSetNextWindowSize(ImVec2(400, 200), ImGuiCond_FirstUseEver);

        // e.g. Leave a fixed amount of width for labels (by passing a negative value), the rest goes to widgets.
        //igPushItemWidth(igGetFontSize() * -12);

        auto flags = 0
            | ImGuiWindowFlags_NoSavedSettings
            | ImGuiWindowFlags_NoMove
            | ImGuiWindowFlags_NoCollapse
            ;
        if(!igBegin("Window 1", &isOpen, flags)) {
            igEnd();
            return;
        }

        {
        // void igText(const(char)* fmt, ...);
        igText("Hello");  

        //void igTextColored(const ImVec4 col, const(char)* fmt, ...);
        igTextColored(ImVec4(1,1,0,1), "Hello");

        // bool igButton(const(char)* label, const ImVec2 size);
        if(igButton("One", AUTO_SIZE)) {
            log("One");
        }

        // bool igSmallButton(const(char)* label);
        if(igSmallButton("Small One")) {
            log("Small one");
        }

        igColorEdit4("Edit Colour", &colour, ImGuiColorEditFlags_None);

        // bool (immutable(char)* str_id, ImGuiDir dir, ImVec2 size_arg, ImGuiButtonFlags flags)
        if(igArrowButtonEx("left", ImGuiDir_Left, ImVec2(25, 25), ImGuiItemFlags_ButtonRepeat)) {
            log("Left arrow");
        }
        igSameLine(0, 4);
        if(igArrowButtonEx("right", ImGuiDir_Right, ImVec2(25, 25), ImGuiItemFlags_ButtonRepeat)) {
            log("Right arrow");
        }


        // bool igCheckbox(const(char)* label, bool* v);
        igCheckbox("Tick 1", &cb1);

        igSpacing();

        igBulletText("Item 1");
        //igBullet();
        igBulletText("Item 2");

        if (igCollapsingHeader("Configuration", ImGuiTreeNodeFlags_None)) {

            if (igTreeNode_Str("Node")) {

                igCheckbox("Tick me 1", &flag);
                igCheckbox("Tick me 2", &flag2);
                igTreePop();
            }
        }

        // bool igRadioButtonBool(const(char)* label, bool active);
        // bool igRadioButtonIntPtr(const(char)* label, int* v, int v_button);
        igRadioButton_IntPtr("radio a", &intValue, 0); igSameLine(0, 5);
        igRadioButton_IntPtr("radio b", &intValue, 1); igSameLine(0, 5);
        igRadioButton_IntPtr("radio c", &intValue, 2);

        //igEndChild();
        }


        {
            auto citems = [ "AAAA", "BBBB", "CCCC", "DDDD", "EEEE", "FFFF", "GGGG", "HHHH", "IIIIIII", "JJJJ", "KKKKKKK" ];
            igCombo("Combo box", citems, &item_current, 4);

            string[] lbitems = [
                //"Apple", "Banana", "Cherry", "Kiwi",
                "Mango", "Orange", "Pineapple", "Strawberry", "Watermelon"
            ];
            igListBox(
                "listbox",
                lbitems,
                &listBoxItem,
                4);
        }
        {
            // int function(ImGuiInputTextCallbackData* data)
            //bool igInputText(const(char)* label, char* buf, size_t buf_size, ImGuiInputTextFlags flags, ImGuiInputTextCallback callback, void* user_data);

            igInputText("Edit me",
                cast(immutable(char)*)buf.ptr,
                buf.length,
                ImGuiInputTextFlags_None,
                null,
                null);

            igSameLine(0,5);
            igHelpMarker("Help ...");

            buf2.length = 32;
            //buf2[] = 0;
            buf2[0] = 0;
            igInputTextWithHint(
                "input text (w/ hint)",
                "enter text here",
                cast(immutable(char)*)buf2.ptr,
                buf2.length,
                ImGuiInputTextFlags_None,
                null,
                null);

            igInputInt(
                "input int",
                &i0,
                1,
                5,
                ImGuiInputTextFlags_None);

            igInputFloat(
                "input float",
                &f0,
                0.1,
                1,
                "%.3f",
                ImGuiInputTextFlags_None);

            igDragInt(
                "drag int",
                &i1,
                10,
                1,
                100,
                "%d",
                ImGuiSliderFlags_AlwaysClamp);

            igDragFloat(
                "drag float",
                &f1,
                0.005f,
                0,
                1000,
                "%02f",
                ImGuiSliderFlags_AlwaysClamp);

            igSliderInt(
                "slider int",
                &i2,
                -1,
                3,
                "%d",
                ImGuiSliderFlags_AlwaysClamp);

            igSliderFloat(
                "slider float",
                &f2,
                0f,
                10f,
                "%.2f",
                ImGuiSliderFlags_None);

            igSliderAngle(
                "slider angle",
                &angle,
                0,
                360,
                "%.1f",
                ImGuiSliderFlags_None);
        }

        igSeparatorEx(ImGuiSeparatorFlags_Horizontal, 1.0f);

        igEnd();
    }
    void menu() {
        bool my_tool_active;
        if(igBegin("A Menu Example", &my_tool_active, ImGuiWindowFlags_MenuBar)) {
            if(igBeginMenuBar()) {
                if(igBeginMenu("File", true)) {
                    if(igMenuItem("Open..", "Ctrl+O")) {
                        log("Open clicked");
                    }
                    if(igMenuItem("Save", "Ctrl+S", true)) {
                        log("Save clicked");
                    }
                    if(igMenuItem("Close", "Ctrl+W"))  {
                        my_tool_active = false;
                    }
                    igEndMenu();
                }
                igEndMenuBar();
            }
        }
        igEnd();
    }
    void treeWindow() {

        auto vp = igGetMainViewport();
        igSetNextWindowPos(vp.WorkPos + ImVec2(0,20), ImGuiCond_Always, ImVec2(0,0));

        if(igBegin("Tree", null, ImGuiWindowFlags_None)) {

            if(igTreeNodeEx_Str("Trees", ImGuiTreeNodeFlags_DefaultOpen)) {

                if(igTreeNode_Str("Node 1")) {

                    igText("blah blah");

                    igTreePop();
                }

                igTreePop();
            }
        }
        igEnd();
    }
    void tabs() {
        if(igBegin("Tabs", null, ImGuiWindowFlags_None)) {

            auto options = ImGuiTabItemFlags_None
                | ImGuiTabBarFlags_Reorderable
                ;

            if (igBeginTabBar("MyTabBar", options)) {

                auto flags = ImGuiTabItemFlags_None;
                    //ImGuiTabItemFlags_UnsavedDocument;
                    //| ImGuiTabItemFlags_SetSelected;

                if (igBeginTabItem("Avocado", null, flags))
                {
                    igText("This is the Avocado tab!\nblah blah blah blah blah");
                    igEndTabItem();
                }
                if (igBeginTabItem("Broccoli", null, ImGuiTabItemFlags_None)) {
                    igText("This is the Broccoli tab!\nblah blah blah blah blah");
                    igEndTabItem();
                }
                if (igBeginTabItem("Cucumber", null, ImGuiTabItemFlags_None)) {
                    igText("This is the Cucumber tab!\nblah blah blah blah blah");
                    igEndTabItem();
                }
                igEndTabBar();
            }
        }
        igEnd();
    }
    void windowWithTables() {
        if(igBegin("Window With Tables", null, ImGuiWindowFlags_None)) {

            // bool igBeginTable(const(char)* name, int columns_count, ImGuiTableFlags flags, const ImVec2 outer_size, float inner_width);

            auto numCols = 3;
            auto tableFlags = ImGuiTableRowFlags_None
                // | ImGuiTableFlags_BordersH
                // | ImGuiTableFlags_BordersV
                | ImGuiTableFlags_Borders
                | ImGuiTableFlags_RowBg;

        
            if(igBeginTable("table1", numCols, tableFlags, ImVec2(0,0), 0)) {

                // Headers
                igTableSetupColumn("ONE", ImGuiTableColumnFlags_PreferSortAscending, 0, 0);
                igTableSetupColumn("TWO",  ImGuiTableColumnFlags_None, 0, 0);
                igTableSetupColumn("THREE",  ImGuiTableColumnFlags_None, 0, 0);
                igTableHeadersRow();

                // row 0
                igTableNextRow(ImGuiTableRowFlags_None, 10);
                igTableSetColumnIndex(0);
                igText("one");
                igTableSetColumnIndex(1);
                igButton("two", ImVec2(0,0));
                igTableSetColumnIndex(2);
                igText("three");

                // row 1
                igTableNextRow(ImGuiTableRowFlags_None, 10);
                igTableSetColumnIndex(0);
                igText("One");
                igTableSetColumnIndex(1);
                igText("Two");
                igTableSetColumnIndex(2);
                igText("Three");

                // row 2
                igTableNextRow(ImGuiTableRowFlags_None, 10);
                igTableSetColumnIndex(0);
                igText("1");
                igTableSetColumnIndex(1);
                igText("2");
                igTableSetColumnIndex(2);
                igText("3");
                

                igEndTable();
            }
            
        }
        igEnd();
    }
    void drawingWindow() {
        if(igBegin("Drawing Window", null, ImGuiWindowFlags_None)) {

            // void igPlotLinesFloatPtr(const(char)* label, const float* values, int values_count,
            //      int values_offset, const(char)* overlay_text,
            //      float scale_min, float scale_max,
            //      ImVec2 graph_size, int stride);


            float[] arr = [ 0.6f, 0.1f, 1.0f, 0.5f, 0.92f, 0.1f, 0.2f ];
            igPlotLines_FloatPtr("Some lines", arr.ptr, arr.length.as!int,
                0, "Overlay",
                float.max, float.max,
                ImVec2(0,0), float.sizeof.as!int);


            // void igPlotHistogramFloatPtr(const(char)* label, const float* values,
            //          int values_count, int values_offset, const(char)* overlay_text,
            //          float scale_min, float scale_max, ImVec2 graph_size, int stride);

            igPlotHistogram_FloatPtr("Histogram", arr.ptr, arr.length.as!int,
                0, null, 0.0f, 1.0f, ImVec2(0, 80.0f), float.sizeof.as!int);


            // Progress bar

            //void igProgressBar(float fraction, const ImVec2 size_arg, const(char)* overlay);

            __gshared float progress = 0.5;

            igProgressBar(progress, ImVec2(0.0f, 0.0f), toStringz("%.0f%%".format(progress*100)));

            // Vertical sliders
            __gshared int v1 = 0, v2 = 5, v3 = 25;
            igPushStyleColor_Vec4(ImGuiCol_SliderGrab, cast(ImVec4)HSV(1 / 7.0f, 0.9f, 0.9f));
            igPushStyleColor_Vec4(ImGuiCol_FrameBg, cast(ImVec4)HSV(1 / 7.0f, 0.5f, 0.5f));
            igPushStyleColor_Vec4(ImGuiCol_FrameBgActive, cast(ImVec4)HSV(1 / 7.0f, 0.7f, 0.5f));
            igPushStyleColor_Vec4(ImGuiCol_FrameBgHovered, cast(ImVec4)HSV(1 / 7.0f, 0.6f, 0.5f));

            igVSliderInt("##int", ImVec2(18, 160), &v1, 0, 5, "%d", ImGuiSliderFlags_None);

            if (igIsItemActive() || igIsItemHovered(ImGuiHoveredFlags_None))
                igSetTooltip("%.3f", v1);

            igSameLine(0, 5);
            igPushStyleColor_Vec4(ImGuiCol_FrameBg, cast(ImVec4)HSV(2 / 7.0f, 0.5f, 0.5f));
            igVSliderInt("##int", ImVec2(18, 160), &v2, 0, 50, "%d", ImGuiSliderFlags_None);

            igSameLine(0, 5);
            igPushStyleColor_Vec4(ImGuiCol_FrameBg, cast(ImVec4)HSV(3 / 7.0f, 0.5f, 0.5f));
            igVSliderInt("##int", ImVec2(18, 160), &v3, 0, 100, "%d", ImGuiSliderFlags_None);



            igPopStyleColor(6);

        }
        igEnd();
    }
}

