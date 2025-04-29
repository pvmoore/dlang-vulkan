module vulkan.pipelines.graphics_pipeline;
/**
 *
 */
import vulkan.all;

private struct None { int a; }

final class GraphicsPipeline {
private:
    VulkanContext context;
    VkDevice device;

    VkViewport[] viewports;
    VkRect2D[] scissors;
    VkPrimitiveTopology primitiveTopology;
    VkPipelineVertexInputStateCreateInfo vertexInputState;
    VkPipelineRasterizationStateCreateInfo rasterisationState;
    VkPipelineMultisampleStateCreateInfo multisampleState;
    VkPipelineDepthStencilStateCreateInfo depthStencilState;
    VkPipelineColorBlendStateCreateInfo colorBlendState;
    VkPipelineDynamicStateCreateInfo dynamicState;
    VkDescriptorSetLayout[] dsLayouts;
    VkPushConstantRange[] pcRanges;
    uint subpass;
    bool hasDynamicState;
    
    VkShaderModule vertexShader, geometryShader, fragmentShader;
    string vsEntry, fsEntry, gsEntry;

    VkPipelineShaderStageCreateInfo[] shaderStages;
    VkSpecializationInfo[] specInfos;
public:
    VkPipeline pipeline;
    VkPipelineLayout layout;

    this(VulkanContext context, bool flipY = false) {
        this.context   = context;
        this.device    = context.device;
        this.scissors = [VkRect2D(
            VkOffset2D(0,0),
            context.vk.windowSize.toVkExtent2D
        )];
        this.subpass = 0;
        this.rasterisationState = .rasterizationState();
        this.multisampleState   = .multisampleState(1);
        this.depthStencilState  = .depthStencilState(false, false);
        this.colorBlendState    = .colorBlendState([colorBlendAttachment()]);

        if(flipY) {
            /* Flip the viewport y and height (requires VK_KHR_maintenance1)
             *
             * (0,h)
             *   -------
             *   |     |
             *   |     |
             *   |     |
             *   -------
             *        (w,-h)
             */
            this.viewports = [VkViewport(
                0, context.vk.windowSize.height,
                context.vk.windowSize.width, -context.vk.windowSize.height.as!float,
                0.0f, 1.0f
            )];
        } else {
            /*
             * (0,0)
             *   -------
             *   |     |
             *   |     |
             *   |     |
             *   -------
             *        (w,h)
             */
            this.viewports = [VkViewport(
                0, 0,
                context.vk.windowSize.width, context.vk.windowSize.height,
                0.0f, 1.0f
            )];
        }
    }
    void destroy() {
        if(layout) device.destroyPipelineLayout(layout);
        if(pipeline) device.destroyPipeline(pipeline);
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
    auto withVertexInputState(T)(VkPrimitiveTopology prim) {
        this.primitiveTopology = prim;
        uint binding = 0;
        VkVertexInputAttributeDescription[] attribs;
        foreach(int i,m; __traits(allMembers, T)) {
            static if("__ctor" != m && "__dtor" != m) {
                attribs ~= VkVertexInputAttributeDescription(
                    i,
                    binding,
                    is(int==typeof(__traits(getMember, T, m)))   ? VK_FORMAT_R32_SINT :
                    is(uint==typeof(__traits(getMember, T, m)))  ? VK_FORMAT_R32_UINT :
                    is(float==typeof(__traits(getMember, T, m))) ? VK_FORMAT_R32_SFLOAT :
                    is(vec2==typeof(__traits(getMember, T, m)))  ? VK_FORMAT_R32G32_SFLOAT :
                    is(vec3==typeof(__traits(getMember, T, m)))  ? VK_FORMAT_R32G32B32_SFLOAT :
                    is(vec4==typeof(__traits(getMember, T, m)))  ? VK_FORMAT_R32G32B32A32_SFLOAT :
                    is(ivec2==typeof(__traits(getMember, T, m))) ? VK_FORMAT_R32G32_SINT :
                    is(ivec3==typeof(__traits(getMember, T, m))) ? VK_FORMAT_R32G32B32_SINT :
                    is(ivec4==typeof(__traits(getMember, T, m))) ? VK_FORMAT_R32G32B32A32_SINT :
                    is(uvec2==typeof(__traits(getMember, T, m))) ? VK_FORMAT_R32G32_UINT :
                    is(uvec3==typeof(__traits(getMember, T, m))) ? VK_FORMAT_R32G32B32_UINT :
                    is(uvec4==typeof(__traits(getMember, T, m))) ? VK_FORMAT_R32G32B32A32_UINT :

                    VK_FORMAT_UNDEFINED,
                    __traits(getMember, T, m).offsetof
                );
                if(attribs[$-1].format==0) {
                    this.log("Vertex input type %s not yet implemented", typeof(__traits(getMember, T, m)).stringof);
                    throwIf(true);
                }
            }
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
    auto withStdColorBlendState() {
        withColorBlendState([
            colorBlendAttachment((info) {
                info.blendEnable         = VK_TRUE;
                info.srcColorBlendFactor = VK_BLEND_FACTOR_SRC_ALPHA;
                info.dstColorBlendFactor = VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA;
                info.srcAlphaBlendFactor = VK_BLEND_FACTOR_ONE;
                info.dstAlphaBlendFactor = VK_BLEND_FACTOR_ZERO;
                info.colorBlendOp        = VK_BLEND_OP_ADD;
                info.alphaBlendOp        = VK_BLEND_OP_ADD;
            })
        ]);
        return this;
    }
    auto withShader(T=None)(VkShaderStageFlagBits stage, VkShaderModule shader, T* specInfo=null, string entry="main") {
        VkSpecializationInfo* specialisation = null;
        if(specInfo) {
            specInfos ~= .specialisationInfo!T(specInfo);
            specialisation = &specInfos[$-1];
        }
        shaderStages ~= shaderStage(stage, shader, entry, specialisation);
        return this;
    }
    auto withVertexShader(T=None)(VkShaderModule shader, T* specInfo=null, string entry="main") {
        withShader!T(VK_SHADER_STAGE_VERTEX_BIT, shader, specInfo, entry);
        return this;
    }
    auto withGeometryShader(T=None)(VkShaderModule shader, T* specInfo=null, string entry="main") {
        withShader!T(VK_SHADER_STAGE_GEOMETRY_BIT, shader, specInfo, entry);
        return this;
    }
    auto withFragmentShader(T=None)(VkShaderModule shader, T* specInfo=null, string entry="main") {
        withShader!T(VK_SHADER_STAGE_FRAGMENT_BIT, shader, specInfo, entry);
        return this;
    }
    auto withPushConstantRange(T)(VkShaderStageFlags stages, uint offset = 0) {
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
        throwIf(vertexInputState.vertexBindingDescriptionCount == 0);
        throwIf(vertexInputState.vertexAttributeDescriptionCount == 0);

        auto inputAssemblyState  = inputAssemblyState(primitiveTopology);
        auto viewportState       = viewportState(viewports, scissors);

        layout = createPipelineLayout(
            device,
            dsLayouts,         // VkDescriptorSetLayout[]
            pcRanges           // VkPushConstantRange[]
        );

        VkGraphicsPipelineCreateInfo info = {
            sType: VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO,
            flags               : 0,    // VkPipelineCreateFlagBits
            stageCount          : shaderStages.length.as!uint,
            pStages             : shaderStages.ptr,
            pVertexInputState   : &vertexInputState,
            pInputAssemblyState : &inputAssemblyState,
            pTessellationState  : null,
            pViewportState      : &viewportState,
            pRasterizationState : &rasterisationState,
            pMultisampleState   : &multisampleState,
            pDepthStencilState  : &depthStencilState,
            pColorBlendState    : &colorBlendState,
            pDynamicState       : hasDynamicState ? &dynamicState : null,
            layout              : layout,
            renderPass          : context.renderPass,
            subpass             : subpass,
            basePipelineHandle  : null,
            basePipelineIndex   : -1   
        };

        if(hasDynamicState) {
            import common.utils.static_utils : toString;
            VkDynamicState[] ds = dynamicState.pDynamicStates[0..dynamicState.dynamicStateCount];
            this.log("Setting dynamic state: %s", ds);
        }

        // Dymnamic rendering
        if(context.vprops().useDynamicRendering) {
            throwIf(context.renderPass !is null);
            VkPipelineRenderingCreateInfo renderingInfo = {
                sType: VK_STRUCTURE_TYPE_PIPELINE_RENDERING_CREATE_INFO,
                viewMask: 0,
                colorAttachmentCount: 1,
                pColorAttachmentFormats: &context.swapchain().colorFormat,
                depthAttachmentFormat: VK_FORMAT_UNDEFINED,
                stencilAttachmentFormat: VK_FORMAT_UNDEFINED
            };
            info.pNext = &renderingInfo;
        }

        check(vkCreateGraphicsPipelines(
            device,
            null,   // VkPipelineCache
            1,
            &info,
            null,   // VkAllocationCallbacks
            &pipeline
        ));

        return this;
    }
}

