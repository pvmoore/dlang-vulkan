module vulkan.api.pipeline;
/**

From the 1.3 spec:

The graphics pipeline executes the following stages, with the logical ordering of the
stages matching the order specified here:

    VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT
    VK_PIPELINE_STAGE_2_INDEX_INPUT_BIT
    VK_PIPELINE_STAGE_2_VERTEX_ATTRIBUTE_INPUT_BIT
    VK_PIPELINE_STAGE_VERTEX_SHADER_BIT
    VK_PIPELINE_STAGE_TESSELLATION_CONTROL_SHADER_BIT
    VK_PIPELINE_STAGE_TESSELLATION_EVALUATION_SHADER_BIT
    VK_PIPELINE_STAGE_GEOMETRY_SHADER_BIT
    VK_PIPELINE_STAGE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR
    VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT
    VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT
    VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT
    VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT

For the compute pipeline, the following stages occur in this order:

    VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT
    VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT

For the transfer pipeline, the following stages occur in this order:

    VK_PIPELINE_STAGE_TRANSFER_BIT

For host operations, only one pipeline stage occurs, so no order is guaranteed:

    VK_PIPELINE_STAGE_HOST_BIT

For acceleration structure operations, only one pipeline stage occurs, so no order is guaranteed:

    VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR

For the ray tracing pipeline, the following stages occur in this order:

    VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT
    VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR

Standard stages:
    VK_PIPELINE_STAGE_NONE
    VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT
    VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT

Special stages:
    VK_PIPELINE_STAGE_ALL_GRAPHICS_BIT    - all graphics stages
    VK_PIPELINE_STAGE_ALL_COMMANDS_BIT    - every stage allowed on queue

 */
import vulkan.all;

/*
vkCreateComputePipelines
vkCreatePipelineCache
vkDestroyPipelineCache
vkGetPipelineCacheData
vkMergePipelineCaches
*/

VkPipeline createGraphicsPipeline(VkDevice device,
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
auto createComputePipeline(VkDevice device,
                           VkPipelineLayout layout,
                           VkPipelineShaderStageCreateInfo shaderStage)
{
    VkPipeline pipeline;
    VkComputePipelineCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO;

    // VK_PIPELINE_CREATE_DISABLE_OPTIMIZATION_BIT
    // VK_PIPELINE_CREATE_ALLOW_DERIVATIVES_BIT
    // VK_PIPELINE_CREATE_DERIVATIVE_BIT
    // VK_PIPELINE_CREATE_LINK_TIME_OPTIMIZATION_BIT_EXT
    // etc...
    info.flags = 0;

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

auto createRayTracingPipeline(VkDevice device,
                              VkPipelineLayout layout,
                              VkPipelineShaderStageCreateInfo[] stageInfos,
                              VkRayTracingShaderGroupCreateInfoKHR[] groupInfos)
{

    // Ray tracing specific flags
    // VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_ANY_HIT_SHADERS_BIT_KHR = 0x00004000,
	// VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_CLOSEST_HIT_SHADERS_BIT_KHR = 0x00008000,
	// VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_MISS_SHADERS_BIT_KHR = 0x00010000,
	// VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_INTERSECTION_SHADERS_BIT_KHR = 0x00020000,
	// VK_PIPELINE_CREATE_RAY_TRACING_SKIP_TRIANGLES_BIT_KHR = 0x00001000,
	// VK_PIPELINE_CREATE_RAY_TRACING_SKIP_AABBS_BIT_KHR = 0x00002000,
	// VK_PIPELINE_CREATE_RAY_TRACING_SHADER_GROUP_HANDLE_CAPTURE_REPLAY_BIT_KHR = 0x00080000,
	// VK_PIPELINE_CREATE_RAY_TRACING_ALLOW_MOTION_BIT_NV = 0x00100000,

    VkPipeline pipeline;
    VkRayTracingPipelineCreateInfoKHR info = {
        sType: VK_STRUCTURE_TYPE_RAY_TRACING_PIPELINE_CREATE_INFO_KHR,
        flags: 0,
        stageCount: stageInfos.length.as!uint,
        pStages: stageInfos.ptr,
        groupCount: groupInfos.length.as!uint,
        pGroups: groupInfos.ptr,
        maxPipelineRayRecursionDepth: 1,
        pLibraryInfo: null,
        pLibraryInterface: null,
        pDynamicState: null,
        layout: layout
    };

    check(vkCreateRayTracingPipelinesKHR(
        device,
        null,           // deferredOperation
        null,           // cache
        1,
        &info,
        null,
        &pipeline
    ));
    return pipeline;
}

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
auto vertexInputState(VkVertexInputBindingDescription[] bindings,
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
auto bindingDescription(uint binding, uint stride, bool isVertex) {
    VkVertexInputBindingDescription b;
    b.binding   = binding;
    b.stride    = stride;
    b.inputRate = isVertex ? VkVertexInputRate.VK_VERTEX_INPUT_RATE_VERTEX :
                             VkVertexInputRate.VK_VERTEX_INPUT_RATE_INSTANCE;
    return b;
}
auto attributeDescription(uint location, uint binding, VkFormat format, uint offset) {
    VkVertexInputAttributeDescription a;
    a.location = location;
    a.binding  = binding;
    a.format   = format;
    a.offset   = offset;
    return a;
}
auto triangleListInputAssemblyState() {
    return inputAssemblyState(VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST);
}
auto inputAssemblyState(VkPrimitiveTopology topology,
                        bool primitiveRestart = false)
{
    VkPipelineInputAssemblyStateCreateInfo info;
    info.sType    = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO;
    info.flags    = 0;
    info.topology = topology;
    info.primitiveRestartEnable = primitiveRestart.toVkBool32;
    return info;
}
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
auto rasterizationState(void delegate(VkPipelineRasterizationStateCreateInfo*) call = null) {
    VkPipelineRasterizationStateCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO;
    info.flags = 0;

    info.depthClampEnable        = false;
    info.rasterizerDiscardEnable = false;

    // VK_POLYGON_MODE_FILL
    // VK_POLYGON_MODE_LINE
    // VK_POLYGON_MODE_POINT
    info.polygonMode = VK_POLYGON_MODE_FILL;

    // VK_CULL_MODE_NONE
    // VK_CULL_MODE_FRONT_BIT
    // VK_CULL_MODE_BACK_BIT
    // VK_CULL_MODE_FRONT_AND_BACK
    info.cullMode = VK_CULL_MODE_NONE;

    // VK_FRONT_FACE_COUNTER_CLOCKWISE
    // VK_FRONT_FACE_CLOCKWISE
    info.frontFace = VK_FRONT_FACE_CLOCKWISE;

    info.depthBiasEnable         = VK_FALSE;
    info.depthBiasConstantFactor = 0;
    info.depthBiasClamp          = 0;
    info.depthBiasSlopeFactor    = 0;
    info.lineWidth               = 1;
    if(call) call(&info);
    return info;
}
auto multisampleState(uint samples,
                      void delegate(VkPipelineMultisampleStateCreateInfo*) call = null)
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
auto depthStencilState(bool depthTest,
                       bool stencilTest,
                       void delegate(VkPipelineDepthStencilStateCreateInfo*) call = null)
{
    VkPipelineDepthStencilStateCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO;
    info.flags = 0;

    info.depthTestEnable  = depthTest.toVkBool32;
    info.depthWriteEnable = false;

    // VK_COMPARE_OP_NEVER
    // VK_COMPARE_OP_LESS
    // VK_COMPARE_OP_EQUAL
    // VK_COMPARE_OP_LESS_OR_EQUAL
    // VK_COMPARE_OP_GREATER
    // VK_COMPARE_OP_NOT_EQUAL
    // VK_COMPARE_OP_GREATER_OR_EQUAL
    // VK_COMPARE_OP_ALWAYS
    info.depthCompareOp = VK_COMPARE_OP_NEVER;

    info.depthBoundsTestEnable = false;

    info.stencilTestEnable = stencilTest.toVkBool32;
    info.front = VkStencilOpState();
    info.back  = VkStencilOpState();
    info.minDepthBounds = 0;
    info.maxDepthBounds = 1;
    if(call) call(&info);
    return info;
}
auto colorBlendAttachment(void delegate(VkPipelineColorBlendAttachmentState*) call = null) {
    VkPipelineColorBlendAttachmentState info;
    info.blendEnable = VK_FALSE;

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

    // VK_BLEND_OP_ADD
    // VK_BLEND_OP_SUBTRACT
    // VK_BLEND_OP_REVERSE_SUBTRACT
    // VK_BLEND_OP_MIN
    // VK_BLEND_OP_MAX
    info.colorBlendOp = VK_BLEND_OP_ADD;
    info.alphaBlendOp = VK_BLEND_OP_ADD;

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
auto colorBlendState(VkPipelineColorBlendAttachmentState[] attachments,
                     void delegate(VkPipelineColorBlendStateCreateInfo*) call = null)
{
    VkPipelineColorBlendStateCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO;
    info.flags = 0;

    info.logicOpEnable = VK_FALSE;

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

    info.attachmentCount = attachments.length.as!uint;
    info.pAttachments    = attachments.ptr;
    info.blendConstants  = [0.0f,0,0,0];
    if(call) call(&info);
    return info;
}
auto dynamicState(VkDynamicState[] dynamicStates) {
    VkPipelineDynamicStateCreateInfo info;
    info.sType = VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO;
    info.flags = 0;

    info.dynamicStateCount = cast(uint)dynamicStates.length;
    info.pDynamicStates    = dynamicStates.ptr;
    return info;
}
auto shaderStage(VkShaderStageFlagBits stage,
                 VkShaderModule shader,
                 string funcName = "main",
                 VkSpecializationInfo* specialisation = null)
{
    VkPipelineShaderStageCreateInfo info;
    info.sType               = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
    info.flags               = 0;
    info.stage               = stage;
    info.module_             = shader;
    info.pName               = funcName.ptr;
    info.pSpecializationInfo = specialisation;
    return info;
}
