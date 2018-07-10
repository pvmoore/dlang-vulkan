module vulkan.pipelines.graphics_pipeline;
/**
 *
 */
import vulkan.all;

private struct None { int a; }

final class GraphicsPipeline {
private:
    Vulkan vk;
    VkDevice device;
    VkRenderPass renderPass;

    VkViewport[] viewports;
    VkRect2D[] scissors;
    VPrimitiveTopology primitiveTopology;
    VkPipelineVertexInputStateCreateInfo vertexInputState;
    VkPipelineRasterizationStateCreateInfo rasterisationState;
    VkPipelineMultisampleStateCreateInfo multisampleState;
    VkPipelineDepthStencilStateCreateInfo depthStencilState;
    VkPipelineColorBlendStateCreateInfo colorBlendState;
    VkPipelineDynamicStateCreateInfo dynamicState;
    string vertexShaderFilename;
    string geometryShaderFilename;
    string fragmentShaderFilename;
    VkDescriptorSetLayout[] dsLayouts;
    VkPushConstantRange[] pcRanges;
    uint subpass;
    bool hasDepthStencilState;
    bool hasDynamicState;
    bool hasVertexSpecialisationInfo;
    bool hasGeometrySpecialisationInfo;
    bool hasFragmentSpecialisationInfo;
    VkSpecializationInfo vertexSpecialisationInfo;
    VkSpecializationInfo geometrySpecialisationInfo;
    VkSpecializationInfo fragmentSpecialisationInfo;

public:
    VkPipeline pipeline;
    VkPipelineLayout layout;

    this(Vulkan vk, VkRenderPass renderPass) {
        this.vk     = vk;
        this.device = vk.device;
        this.renderPass = renderPass;
        this.viewports = [VkViewport(
            0,0,
            vk.windowSize.width, vk.windowSize.height,
            0.0f, 1.0f
        )];
        this.scissors = [VkRect2D(
            VkOffset2D(0,0),
            vk.windowSize.toVkExtent2D
        )];
        this.subpass = 0;
        this.rasterisationState = .rasterizationState();
        this.multisampleState   = .multisampleState(1);
        this.depthStencilState  = .depthStencilState(false, false);
        this.colorBlendState    = .colorBlendState([colorBlendAttachment()]);
    }
    void destroy() {
        if(layout) device.destroy(layout);
        if(pipeline) device.destroy(pipeline);
    }
    auto withDSLayouts(VkDescriptorSetLayout[] dsLayouts) {
        this.dsLayouts = dsLayouts;
        return this;
    }
    auto withSubpass(uint s) {
        this.subpass = s;
        return this;
    }
    auto withViewports(VkViewport[] v) {
        this.viewports = v;
        return this;
    }
    auto withScissors(VkRect2D[] s) {
        scissors = s;
        return this;
    }
    auto withVertexInputState(T)(VPrimitiveTopology prim) {
        this.primitiveTopology = prim;
        uint binding = 0;
        VkVertexInputAttributeDescription[] attribs;
        foreach(int i,m; __traits(allMembers, T)) {
            attribs ~= VkVertexInputAttributeDescription(
                i,
                binding,
                is(int==typeof(__traits(getMember, T, m))) ? VFormat.R32_SINT :
                is(uint==typeof(__traits(getMember, T, m))) ? VFormat.R32_UINT :
                is(float==typeof(__traits(getMember, T, m))) ? VFormat.R32_SFLOAT :
                is(vec2==typeof(__traits(getMember, T, m))) ? VFormat.R32G32_SFLOAT :
                is(vec3==typeof(__traits(getMember, T, m))) ? VFormat.R32G32B32_SFLOAT :
                is(vec4==typeof(__traits(getMember, T, m))) ? VFormat.R32G32B32A32_SFLOAT :
                is(ivec2==typeof(__traits(getMember, T, m))) ? VFormat.R32G32_SINT :
                is(ivec3==typeof(__traits(getMember, T, m))) ? VFormat.R32G32B32_SINT :
                is(ivec4==typeof(__traits(getMember, T, m))) ? VFormat.R32G32B32A32_SINT :
                is(uvec2==typeof(__traits(getMember, T, m))) ? VFormat.R32G32_UINT :
                is(uvec3==typeof(__traits(getMember, T, m))) ? VFormat.R32G32B32_UINT :
                is(uvec4==typeof(__traits(getMember, T, m))) ? VFormat.R32G32B32A32_UINT :
                VFormat.UNDEFINED,
                __traits(getMember, T, m).offsetof
            );
            expect(attribs[$-1].format!=0);
        }
        this.vertexInputState = .vertexInputState([
            bindingDescription(binding, T.sizeof, true)
        ], attribs);
        return this;
    }
    auto withRasterisationState(void delegate(VkPipelineRasterizationStateCreateInfo*) call) {
        call(&rasterisationState);
        return this;
    }
    auto withMultisampleState(void delegate(VkPipelineMultisampleStateCreateInfo*) call) {
        call(&multisampleState);
        return this;
    }
    auto withDepthStencilState(void delegate(VkPipelineDepthStencilStateCreateInfo*) call) {
        call(&depthStencilState);
        hasDepthStencilState = true;
        return this;
    }
    auto withColorBlendState(
        VkPipelineColorBlendAttachmentState[] attachments,
        void delegate(VkPipelineColorBlendStateCreateInfo*) call=null)
    {
        colorBlendState.attachmentCount = cast(uint)attachments.length;
        colorBlendState.pAttachments    = attachments.ptr;
        if(call) call(&colorBlendState);
        return this;
    }
    auto withVertexShader(T=None)(string filename, T* specInfo=null) {
        this.vertexShaderFilename = filename;
        if(specInfo) {
            this.vertexSpecialisationInfo    = .specialisationInfo!T(specInfo);
            this.hasVertexSpecialisationInfo = true;
        }
        return this;
    }
    auto withGeometryShader(T=None)(string filename, T* specInfo=null) {
        this.geometryShaderFilename = filename;
        if(specInfo) {
            this.geometrySpecialisationInfo    = .specialisationInfo!T(specInfo);
            this.hasGeometrySpecialisationInfo = true;
        }
        return this;
    }
    auto withFragmentShader(T=None)(string filename, T* specInfo=null) {
        this.fragmentShaderFilename = filename;
        if(specInfo) {
            this.fragmentSpecialisationInfo    = .specialisationInfo!T(specInfo);
            this.hasFragmentSpecialisationInfo = true;
        }
        return this;
    }
    auto withPushConstantRange(T)(VShaderStage stages, uint offset = 0) {
        auto pcRange = VkPushConstantRange(
            stages,
            offset,
            T.sizeof    // size
        );
        pcRanges ~= pcRange;
        return this;
    }
    auto withDynamicState(VkDynamicState[] states) {
        this.dynamicState    = .dynamicState(states);
        this.hasDynamicState = true;
        return this;
    }
    auto build() {
        expect(vertexInputState.vertexBindingDescriptionCount>0);
        expect(vertexInputState.vertexAttributeDescriptionCount>0);

        auto inputAssemblyState  = inputAssemblyState(primitiveTopology);
        auto viewportState       = viewportState(viewports, scissors);

        VkShaderModule vertexShader;
        VkShaderModule geometryShader;
        VkShaderModule fragmentShader;
        VkPipelineShaderStageCreateInfo[] shaderStages;

        if(vertexShaderFilename !is null) {
            vertexShader  = createShaderModule(device, vertexShaderFilename);
            shaderStages ~= shaderStage(
                VShaderStage.VERTEX,
                vertexShader,
                "main",
                hasVertexSpecialisationInfo ? &vertexSpecialisationInfo : null
            );
        }
        if(geometryShaderFilename !is null) {
            geometryShader = createShaderModule(device, geometryShaderFilename);
            shaderStages  ~= shaderStage(
                VShaderStage.GEOMETRY,
                geometryShader,
                "main",
                hasGeometrySpecialisationInfo ? &geometrySpecialisationInfo : null
            );
        }
        if(fragmentShaderFilename !is null) {
            fragmentShader  = createShaderModule(device, fragmentShaderFilename);
            shaderStages   ~= shaderStage(
                VShaderStage.FRAGMENT,
                fragmentShader,
                "main",
                hasFragmentSpecialisationInfo ? &fragmentSpecialisationInfo : null
            );
        }

        layout = createPipelineLayout(
            device,
            dsLayouts,         // VkDescriptorSetLayout[]
            pcRanges           // VkPushConstantRange[]
        );

        pipeline = createGraphicsPipeline(
            device,
            layout,
            renderPass,
            subpass,              // subpass
            shaderStages,         // shader stages
            &vertexInputState,
            &inputAssemblyState,
            null,               // tesselation state
            &viewportState,
            &rasterisationState,
            &multisampleState,
            hasDepthStencilState ? &depthStencilState : null,
            &colorBlendState,
            hasDynamicState ? &dynamicState : null
        );

        if(fragmentShader) device.destroy(fragmentShader);
        if(geometryShader) device.destroy(geometryShader);
        if(vertexShader) device.destroy(vertexShader);
        return this;
    }
}

