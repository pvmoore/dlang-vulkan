module vulkan.imgui.components.imgui_histogram;

import vulkan.all;

final class Histogram {
public:
    this(int numDataPoints, string fmt, ImVec2 size) {
        this.id = ids++;
        this.NUM_DATAPOINTS = numDataPoints;
        this.fmt = fmt ~ "\0";
        this.size = size;
        this.buf = new ContiguousCircularBuffer!float(NUM_DATAPOINTS);
        this.avgBuf = new ContiguousCircularBuffer!float(NUM_DATAPOINTS);

        // pre-fill with zeroes
        foreach(i; 0..NUM_DATAPOINTS) {
            buf.add(0);
        }
        foreach(i; 0..NUM_DATAPOINTS) {
            buf.take();
        }

        // Set the colour. Should probably expose this at some point
        igGetStyle().Colors[ImGuiCol_PlotHistogram] = ImVec4(0.7f, 0.9f, 0.0f, 1.0f);
        igGetStyle().Colors[ImGuiCol_PlotLines]     = ImVec4(1.0f, 0.0f, 1.0f, 1.0f);
    }
    void tick(float value) {

        float sub = 0;

        if(buf.size() == NUM_DATAPOINTS) {
            sub = buf.take();
        }
        buf.add(value);

        averageTotal += value;
        averageTotal -= sub;

        average = averageTotal/buf.size();
        if(avgBuf.size() == NUM_DATAPOINTS) {
            avgBuf.take();
        }
        avgBuf.add(average);

        if(average*1.1 > maximum) {
            maximum = average*1.1;
        }
    }
    void render() {
        igPlotHistogram_FloatPtr(
            "##histogram%s".format(id).toStringz(),
            buf.slice().ptr,
            NUM_DATAPOINTS,
            0,              // offset into values
            "",
            0,              // scale min
            maximum,        // scale max
            size,
            float.sizeof
        );

        igSameLine(-3, 0);

        igPlotLines_FloatPtr(
            "##average%s".format(id).toStringz(),
            avgBuf.slice().ptr,
            NUM_DATAPOINTS,
            0,
            fmt.format(average).ptr,
            0,
            maximum,
            size,
            float.sizeof
        );
    }
private:
    static uint ids = 0;
    const uint id;
    const int NUM_DATAPOINTS;
    string fmt;
    ImVec2 size;

    ContiguousCircularBuffer!float buf;
    ContiguousCircularBuffer!float avgBuf;

    float value = 0;
    float maximum = 0.001;
    float average = 0;
    float averageTotal = 0; 
}
