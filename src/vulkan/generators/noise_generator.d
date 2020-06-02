module vulkan.generators.noise_generator;
/**
 *  Generator 1,2 or 3D noise textures.
 */
import vulkan.all;

final class NoiseGenerator {
    VulkanContext context;
    VkDevice device;

    Mt19937 rng;
    uint[] dimensions;
    uint octaves;
    float wavelength;
    float randomSeed;
    VImageUsage usage;
    VImageLayout layout;
    DeviceImage image;

    this(VulkanContext context, uint[] dimensions) {
        this.context    = context;
        this.device     = context.device;
        this.dimensions = dimensions;
        this.octaves    = 5;
        this.wavelength = 1.0f/50;
        this.usage      = VImageUsage.NONE;
        this.layout     = VImageLayout.SHADER_READ_ONLY_OPTIMAL;
        this.rng.seed(unpredictableSeed);
        this.randomSeed = uniform01(rng);
    }
    auto withOctaves(int o) {
        this.octaves = o;
        return this;
    }
    auto withRandomSeed(float seed) {
        this.randomSeed = seed;
        return this;
    }
    auto withWavelength(float w) {
        this.wavelength = w;
        return this;
    }
    auto withUsage(VImageUsage usage) {
        this.usage = usage;
        return this;
    }
    auto withLayout(VImageLayout layout) {
        this.layout = layout;
        return this;
    }
    DeviceImage generate() {
        doGenerate();
        return image;
    }
private:
    void doGenerate() {
        static struct Spec {
            int x; int y; int z;
        }
        static struct Push {
            float randomSeed;
            int octaves;
            float wavelength;
        }
        auto push = Push(randomSeed, octaves, wavelength);
        uint[3] groups;
        Spec spec;
        VkShaderModule shader;
        VImageViewType type;

        switch(dimensions.length) {
            default:
                type   = VImageViewType._1D;
                groups = [dimensions[0]/64, 1, 1];
                spec   = Spec(64,1,1);
                shader = context.vk.shaderCompiler.getModule("noise_gen1D_comp.spv");
                break;
            case 2 :
                type   = VImageViewType._2D;
                groups = [dimensions[0]/8, dimensions[1]/8, 1];
                spec   = Spec(8,8,1);
                shader = context.vk.shaderCompiler.getModule("noise_gen2D_comp.spv");
                break;
            case 3 :
                type   = VImageViewType._3D;
                groups = [dimensions[0]/64, 1, 1];
                spec   = Spec(64,1,1);
                shader = context.vk.shaderCompiler.getModule("noise_gen3D_comp.spv");
                break;
        }

        ImageGenerator gen = new ImageGenerator(context, "Noise", dimensions, groups);

        image = gen.withFormat(VFormat.R32_SFLOAT)
                   .withUsage(usage)
                   .withLayout(layout)
                   .withShader!Spec(shader, &spec)
                   .withPushConstants!Push(&push)
                   .generate();

        gen.destroy();
    }
}

