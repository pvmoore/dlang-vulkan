module vulkan.api.pipeline;
/**
 *  Standard stages:
        TOP_OF_PIPE_BIT
        DRAW_INDIRECT_BIT
        VERTEX_INPUT_BIT
        VERTEX_SHADER_BIT
        TESSELLATION_CONTROL_SHADER_BIT
        TESSELLATION_EVALUATION_SHADER_BIT
        GEOMETRY_SHADER_BIT
        FRAGMENT_SHADER_BIT
        EARLY_FRAGMENT_TESTS_BIT
        LATE_FRAGMENT_TESTS_BIT
        COLOR_ATTACHMENT_OUTPUT_BIT
        TRANSFER_BIT            - copy commands
        COMPUTE_SHADER_BIT      - execution of a compute shader
        BOTTOM_OF_PIPE_BIT

    Special stages:
        HOST_BIT            - execution on the host of reads/writes of device memory
        ALL_GRAPHICS_BIT    - all graphics stages
        ALL_COMMANDS_BIT    - every stage allowed on queue

 */
import vulkan.all;

/*
vkCreateComputePipelines
vkCreatePipelineCache
vkDestroyPipelineCache
vkGetPipelineCacheData
vkMergePipelineCaches
*/

VkPipeline createGraphicsPipeline(
    VkDevice device,
    VkPipelineLayout layout,
    VkRenderPass renderPass,
    uint subpassIndex,
    VkPipelineShaderStageCreateInfo[] shaderStages,
    VkPipelineVertexInputStateCreateInfo* vertexInputState,
    VkPipelineInputAssemblyStateCreateInfo* inputAssemblyState,
    VkPipelineTessellationStateCreateInfo* tesselationState,
    VkPipelineViewportStateCreateInfo* viewportState,
    VkPipelineRasterizationStateCreateInfo* rasterizationState,
    VkPipelineMultisampleStateCreateInfo* multisampleState,
    VkPipelineDepthStencilStateCreateInfo* depthStencilState,
    VkPipelineColorBlendStateCreateInfo* colorBlendState,
    VkPipelineDynamicStateCreateInfo* dynamicState)
{
    VkPipeline pipeline;
    //VkPipelineCache cache;

    VkGraphicsPipelineCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO;
    with(VkPipelineCreateFlagBits) {
        // VK_PIPELINE_CREATE_DISABLE_OPTIMIZATION_BIT
        // VK_PIPELINE_CREATE_ALLOW_DERIVATIVES_BIT
        // VK_PIPELINE_CREATE_DERIVATIVE_BIT
        info.flags = 0;
    }

    info.stageCount = cast(uint)shaderStages.length;
    info.pStages    = shaderStages.ptr;

    info.pVertexInputState      = vertexInputState;
    info.pInputAssemblyState    = inputAssemblyState;
    info.pTessellationState     = tesselationState;
    info.pViewportState         = viewportState;
    info.pRasterizationState    = rasterizationState;
    info.pMultisampleState      = multisampleState;
    info.pDepthStencilState     = depthStencilState;
    info.pColorBlendState       = colorBlendState;
    info.pDynamicState          = dynamicState;

    info.layout     = layout;
    info.renderPass = renderPass;
    info.subpass    = subpassIndex;

    info.basePipelineHandle = null;
    info.basePipelineIndex  = -1;

    check(vkCreateGraphicsPipelines(
        device,
        null,   // cache
        1,
        &info,
        null,
        &pipeline
    ));

    return pipeline;
}
void destroy(VkDevice device, VkPipeline pipeline) {
    vkDestroyPipeline(device, pipeline, null);
}
auto createComputePipeline(VkDevice device,
                           VkPipelineLayout layout,
                           VkPipelineShaderStageCreateInfo shaderStage)
{
    VkPipeline pipeline;
    VkComputePipelineCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO;
    with(VkPipelineCreateFlagBits) {
        // VK_PIPELINE_CREATE_DISABLE_OPTIMIZATION_BIT
        // VK_PIPELINE_CREATE_ALLOW_DERIVATIVES_BIT
        // VK_PIPELINE_CREATE_DERIVATIVE_BIT
        info.flags = 0;
    }
    info.stage              = shaderStage;
    info.layout             = layout;
    info.basePipelineHandle = null;
    info.basePipelineIndex  = -1;

    check(vkCreateComputePipelines(
        device,
        null,   // cache
        1,
        &info,
        null,
        &pipeline
    ));
    return pipeline;
}

pragma(inline,true)
auto createPipelineLayout(VkDevice device,
                          VkDescriptorSetLayout[] descriptorSetLayouts,
                          VkPushConstantRange[] pushConstantRanges)
{
    VkPipelineLayout layout;
    VkPipelineLayoutCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO;
    info.flags = 0;

    info.setLayoutCount = cast(uint)descriptorSetLayouts.length;
    info.pSetLayouts    = descriptorSetLayouts.ptr;

    info.pushConstantRangeCount = cast(uint)pushConstantRanges.length;
    info.pPushConstantRanges    = pushConstantRanges.ptr;

    check(vkCreatePipelineLayout(
        device,
        &info,
        null,
        &layout
    ));
    return layout;
}
void destroy(VkDevice device, VkPipelineLayout layout) {
    vkDestroyPipelineLayout(device, layout, null);
}
pragma(inline,true)
auto vertexInputState(
    VkVertexInputBindingDescription[] bindings,
    VkVertexInputAttributeDescription[] attributes)
{
    VkPipelineVertexInputStateCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO;
    info.flags = 0;

    info.vertexBindingDescriptionCount   = cast(uint)bindings.length;
    info.pVertexBindingDescriptions      = bindings.ptr;

    info.vertexAttributeDescriptionCount = cast(uint)attributes.length;
    info.pVertexAttributeDescriptions    = attributes.ptr;

    return info;
}
pragma(inline,true)
auto bindingDescription(uint binding, uint stride, bool isVertex) {
    VkVertexInputBindingDescription b;
    b.binding   = binding;
    b.stride    = stride;
    b.inputRate = isVertex ? VkVertexInputRate.VK_VERTEX_INPUT_RATE_VERTEX :
                             VkVertexInputRate.VK_VERTEX_INPUT_RATE_INSTANCE;
    return b;
}
pragma(inline,true)
auto attributeDescription(uint location, uint binding, VkFormat format, uint offset) {
    VkVertexInputAttributeDescription a;
    a.location = location;
    a.binding  = binding;
    a.format   = format;
    a.offset   = offset;
    return a;
}
pragma(inline,true)
auto triangleListInputAssemblyState() {
    return inputAssemblyState(VPrimitiveTopology.TRIANGLE_LIST);
}
pragma(inline,true)
auto inputAssemblyState(
    VPrimitiveTopology topology,
    bool primitiveRestart=false)
{
    VkPipelineInputAssemblyStateCreateInfo info;
    info.sType    = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO;
    info.flags    = 0;
    info.topology = topology;
    info.primitiveRestartEnable = primitiveRestart.toVkBool32;
    return info;
}
pragma(inline,true)
auto viewportState(VkViewport[] viewports, VkRect2D[] scissors) {
    VkPipelineViewportStateCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO;
    info.flags = 0;

    info.viewportCount = cast(uint)viewports.length;
    info.pViewports    = viewports.ptr;
    info.scissorCount  = cast(uint)scissors.length;
    info.pScissors     = scissors.ptr;
    return info;
}
pragma(inline,true)
auto rasterizationState(
    void delegate(VkPipelineRasterizationStateCreateInfo*) call=null)
{
    VkPipelineRasterizationStateCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO;
    info.flags = 0;

    info.depthClampEnable        = false;
    info.rasterizerDiscardEnable = false;

    with(VkPolygonMode) {
        // VK_POLYGON_MODE_FILL
        // VK_POLYGON_MODE_LINE
        // VK_POLYGON_MODE_POINT
        info.polygonMode = VK_POLYGON_MODE_FILL;
    }
    with(VkCullModeFlagBits) {
        // VK_CULL_MODE_NONE
        // VK_CULL_MODE_FRONT_BIT
        // VK_CULL_MODE_BACK_BIT
        // VK_CULL_MODE_FRONT_AND_BACK
        info.cullMode = VK_CULL_MODE_NONE;
    }
    with(VkFrontFace) {
        // VK_FRONT_FACE_COUNTER_CLOCKWISE
        // VK_FRONT_FACE_CLOCKWISE
        info.frontFace = VK_FRONT_FACE_CLOCKWISE;
    }
    info.depthBiasEnable         = VK_FALSE;
    info.depthBiasConstantFactor = 0;
    info.depthBiasClamp          = 0;
    info.depthBiasSlopeFactor    = 0;
    info.lineWidth               = 1;
    if(call) call(&info);
    return info;
}
pragma(inline,true)
auto multisampleState(
    uint samples,
    void delegate(VkPipelineMultisampleStateCreateInfo*) call=null)
{
    VkPipelineMultisampleStateCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO;
    info.flags = 0;

    // per sample if true, otherwise per fragment
    info.sampleShadingEnable   = false;
    info.rasterizationSamples  = cast(VkSampleCountFlagBits)samples;
    info.minSampleShading      = 1.0f;
    info.pSampleMask           = null;
    info.alphaToCoverageEnable = false;
    info.alphaToOneEnable      = false;
    if(call) call(&info);
    return info;
}
pragma(inline,true)
auto depthStencilState(
    bool depthTest,
    bool stencilTest,
    void delegate(VkPipelineDepthStencilStateCreateInfo*) call=null)
{
    VkPipelineDepthStencilStateCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO;
    info.flags = 0;

    info.depthTestEnable  = depthTest.toVkBool32;
    info.depthWriteEnable = false;
    with(VkCompareOp) {
        // VK_COMPARE_OP_NEVER
        // VK_COMPARE_OP_LESS
        // VK_COMPARE_OP_EQUAL
        // VK_COMPARE_OP_LESS_OR_EQUAL
        // VK_COMPARE_OP_GREATER
        // VK_COMPARE_OP_NOT_EQUAL
        // VK_COMPARE_OP_GREATER_OR_EQUAL
        // VK_COMPARE_OP_ALWAYS
        info.depthCompareOp = VK_COMPARE_OP_NEVER;
    }
    info.depthBoundsTestEnable = false;

    info.stencilTestEnable = stencilTest.toVkBool32;
    info.front = VkStencilOpState();
    info.back  = VkStencilOpState();
    info.minDepthBounds = 0;
    info.maxDepthBounds = 1;
    if(call) call(&info);
    return info;
}
pragma(inline,true)
auto colorBlendAttachment(
    void delegate(VkPipelineColorBlendAttachmentState*) call=null)
{
    VkPipelineColorBlendAttachmentState info;
    info.blendEnable = VK_FALSE;
    with(VkBlendFactor) {
        // VK_BLEND_FACTOR_ZERO
        // VK_BLEND_FACTOR_ONE
        // VK_BLEND_FACTOR_SRC_COLOR
        // VK_BLEND_FACTOR_ONE_MINUS_SRC_COLOR
        // VK_BLEND_FACTOR_DST_COLOR
        // VK_BLEND_FACTOR_ONE_MINUS_DST_COLOR
        // VK_BLEND_FACTOR_SRC_ALPHA
        // VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA
        // VK_BLEND_FACTOR_DST_ALPHA
        // VK_BLEND_FACTOR_ONE_MINUS_DST_ALPHA
        // VK_BLEND_FACTOR_CONSTANT_COLOR
        // VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_COLOR
        // VK_BLEND_FACTOR_CONSTANT_ALPHA
        // VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_ALPHA
        // VK_BLEND_FACTOR_SRC_ALPHA_SATURATE
        // VK_BLEND_FACTOR_SRC1_COLOR
        // VK_BLEND_FACTOR_ONE_MINUS_SRC1_COLOR
        // VK_BLEND_FACTOR_SRC1_ALPHA
        // VK_BLEND_FACTOR_ONE_MINUS_SRC1_ALPHA
        info.srcColorBlendFactor = VK_BLEND_FACTOR_ONE;
        info.dstColorBlendFactor = VK_BLEND_FACTOR_ZERO;
        info.srcAlphaBlendFactor = VK_BLEND_FACTOR_ONE;
        info.dstAlphaBlendFactor = VK_BLEND_FACTOR_ZERO;
    }
    with(VkBlendOp) {
        // VK_BLEND_OP_ADD
        // VK_BLEND_OP_SUBTRACT
        // VK_BLEND_OP_REVERSE_SUBTRACT
        // VK_BLEND_OP_MIN
        // VK_BLEND_OP_MAX
        info.colorBlendOp = VK_BLEND_OP_ADD;
        info.alphaBlendOp = VK_BLEND_OP_ADD;
    }
    with(VkColorComponentFlagBits) {
        info.colorWriteMask =
            VK_COLOR_COMPONENT_R_BIT |
            VK_COLOR_COMPONENT_G_BIT |
            VK_COLOR_COMPONENT_B_BIT |
            VK_COLOR_COMPONENT_A_BIT;

    }
    if(call) call(&info);
    return info;
}
pragma(inline,true)
auto colorBlendState(
    VkPipelineColorBlendAttachmentState[] attachments,
    void delegate(VkPipelineColorBlendStateCreateInfo*) call=null)
{
    VkPipelineColorBlendStateCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO;
    info.flags = 0;

    info.logicOpEnable = VK_FALSE;
    with(VkLogicOp) {
        // VK_LOGIC_OP_CLEAR
        // VK_LOGIC_OP_AND
        // VK_LOGIC_OP_AND_REVERSE
        // VK_LOGIC_OP_COPY
        // VK_LOGIC_OP_AND_INVERTED
        // VK_LOGIC_OP_NO_OP
        // VK_LOGIC_OP_XOR
        // VK_LOGIC_OP_OR
        // VK_LOGIC_OP_NOR
        // VK_LOGIC_OP_EQUIVALENT
        // VK_LOGIC_OP_INVERT
        // VK_LOGIC_OP_OR_REVERSE
        // VK_LOGIC_OP_COPY_INVERTED
        // VK_LOGIC_OP_OR_INVERTED
        // VK_LOGIC_OP_NAND
        // VK_LOGIC_OP_SET
        info.logicOp = VK_LOGIC_OP_COPY;
    }
    info.attachmentCount = cast(uint)attachments.length;
    info.pAttachments    = attachments.ptr;
    info.blendConstants  = [0.0f,0,0,0];
    if(call) call(&info);
    return info;
}
pragma(inline,true)
auto dynamicState(VkDynamicState[] dynamicStates) {
    VkPipelineDynamicStateCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO;
    info.flags = 0;

    info.dynamicStateCount = cast(uint)dynamicStates.length;
    info.pDynamicStates    = dynamicStates.ptr;
    return info;
}
pragma(inline,true)
auto shaderStage(
    VkShaderStageFlagBits stage,
    VkShaderModule shader,
    string funcName="main",
    VkSpecializationInfo* specialisation=null)
{
    VkPipelineShaderStageCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
    info.flags = 0;
    with(VkShaderStageFlagBits) {
        // VK_SHADER_STAGE_VERTEX_BIT
        // VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT
        // VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT
        // VK_SHADER_STAGE_GEOMETRY_BIT
        // VK_SHADER_STAGE_FRAGMENT_BIT
        // VK_SHADER_STAGE_COMPUTE_BIT
        // VK_SHADER_STAGE_ALL_GRAPHICS
        // VK_SHADER_STAGE_ALL
        info.stage = stage;
    }
    info.module_             = shader;
    info.pName               = funcName.ptr;
    info.pSpecializationInfo = specialisation;
    return info;
}
