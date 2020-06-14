module vulkan.enums;

import vulkan.all;

enum VAccess {
    NONE                           = 0,
    INDIRECT_COMMAND_READ          = VkAccessFlagBits.VK_ACCESS_INDIRECT_COMMAND_READ_BIT,
    INDEX_READ                     = VkAccessFlagBits.VK_ACCESS_INDEX_READ_BIT,
    VERTEX_ATTRIBUTE_READ          = VkAccessFlagBits.VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT,
    UNIFORM_READ                   = VkAccessFlagBits.VK_ACCESS_UNIFORM_READ_BIT,
    INPUT_ATTACHMENT_READ          = VkAccessFlagBits.VK_ACCESS_INPUT_ATTACHMENT_READ_BIT,
    SHADER_READ                    = VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
    SHADER_WRITE                   = VkAccessFlagBits.VK_ACCESS_SHADER_WRITE_BIT,
    COLOR_ATTACHMENT_READ          = VkAccessFlagBits.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT,
    COLOR_ATTACHMENT_WRITE         = VkAccessFlagBits.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT,
    DEPTH_STENCIL_ATTACHMENT_READ  = VkAccessFlagBits.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT,
    DEPTH_STENCIL_ATTACHMENT_WRITE = VkAccessFlagBits.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT,
    TRANSFER_READ                  = VkAccessFlagBits.VK_ACCESS_TRANSFER_READ_BIT,
    TRANSFER_WRITE                 = VkAccessFlagBits.VK_ACCESS_TRANSFER_WRITE_BIT,
    HOST_READ                      = VkAccessFlagBits.VK_ACCESS_HOST_READ_BIT,
    HOST_WRITE                     = VkAccessFlagBits.VK_ACCESS_HOST_WRITE_BIT,
    MEMORY_READ                    = VkAccessFlagBits.VK_ACCESS_MEMORY_READ_BIT,
    MEMORY_WRITE                   = VkAccessFlagBits.VK_ACCESS_MEMORY_WRITE_BIT,
}
enum VAttachmentLoadOp {
    LOAD      = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_LOAD,
    CLEAR     = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_CLEAR,
    DONT_CARE = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE
}
enum VAttachmentStoreOp {
    STORE     = VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE,
    DONT_CARE = VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE
}
enum VBlendFactor {
    ZERO                     = VkBlendFactor.VK_BLEND_FACTOR_ZERO,
    ONE                      = VkBlendFactor.VK_BLEND_FACTOR_ONE,
    SRC_COLOR                = VkBlendFactor.VK_BLEND_FACTOR_SRC_COLOR,
    ONE_MINUS_SRC_COLOR      = VkBlendFactor.VK_BLEND_FACTOR_ONE_MINUS_SRC_COLOR,
    DST_COLOR                = VkBlendFactor.VK_BLEND_FACTOR_DST_COLOR,
    ONE_MINUS_DST_COLOR      = VkBlendFactor.VK_BLEND_FACTOR_ONE_MINUS_DST_COLOR,
    SRC_ALPHA                = VkBlendFactor.VK_BLEND_FACTOR_SRC_ALPHA,
    ONE_MINUS_SRC_ALPHA      = VkBlendFactor.VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
    DST_ALPHA                = VkBlendFactor.VK_BLEND_FACTOR_DST_ALPHA,
    ONE_MINUS_DST_ALPHA      = VkBlendFactor.VK_BLEND_FACTOR_ONE_MINUS_DST_ALPHA,
    CONSTANT_COLOR           = VkBlendFactor.VK_BLEND_FACTOR_CONSTANT_COLOR,
    ONE_MINUS_CONSTANT_COLOR = VkBlendFactor.VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_COLOR,
    CONSTANT_ALPHA           = VkBlendFactor.VK_BLEND_FACTOR_CONSTANT_ALPHA,
    ONE_MINUS_CONSTANT_ALPHA = VkBlendFactor.VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_ALPHA,
    SRC_ALPHA_SATURATE       = VkBlendFactor.VK_BLEND_FACTOR_SRC_ALPHA_SATURATE,
    SRC1_COLOR               = VkBlendFactor.VK_BLEND_FACTOR_SRC1_COLOR,
    ONE_MINUS_SRC1_COLOR     = VkBlendFactor.VK_BLEND_FACTOR_ONE_MINUS_SRC1_COLOR,
    SRC1_ALPHA               = VkBlendFactor.VK_BLEND_FACTOR_SRC1_ALPHA,
    ONE_MINUS_SRC1_ALPHA     = VkBlendFactor.VK_BLEND_FACTOR_ONE_MINUS_SRC1_ALPHA
}
enum VBlendOp {
    ADD              = VkBlendOp.VK_BLEND_OP_ADD,
    SUBTRACT         = VkBlendOp.VK_BLEND_OP_SUBTRACT,
    REVERSE_SUBTRACT = VkBlendOp.VK_BLEND_OP_REVERSE_SUBTRACT,
    MIN              = VkBlendOp.VK_BLEND_OP_MIN,
    MAX              = VkBlendOp.VK_BLEND_OP_MAX
}

enum VBufferUsage {
    VERTEX       = VkBufferUsageFlagBits.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT,
    INDEX        = VkBufferUsageFlagBits.VK_BUFFER_USAGE_INDEX_BUFFER_BIT,
    UNIFORM      = VkBufferUsageFlagBits.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT,
    STORAGE      = VkBufferUsageFlagBits.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT,
    TRANSFER_SRC = VkBufferUsageFlagBits.VK_BUFFER_USAGE_TRANSFER_SRC_BIT,
    TRANSFER_DST = VkBufferUsageFlagBits.VK_BUFFER_USAGE_TRANSFER_DST_BIT,
}
bool isVertex(VBufferUsage usage)       { return 0 != (usage & VBufferUsage.VERTEX); }
bool isIndex(VBufferUsage usage)        { return 0 != (usage & VBufferUsage.INDEX); }
bool isUniform(VBufferUsage usage)      { return 0 != (usage & VBufferUsage.UNIFORM); }
bool isStorage(VBufferUsage usage)      { return 0 != (usage & VBufferUsage.STORAGE); }
bool isTransferSrc(VBufferUsage usage)  { return 0 != (usage & VBufferUsage.TRANSFER_SRC); }
bool isTransferDst(VBufferUsage usage)  { return 0 != (usage & VBufferUsage.TRANSFER_DST); }

enum VCommandBufferUsage {
    NONE                 = 0,
    ONE_TIME_SUBMIT      = VkCommandBufferUsageFlagBits.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT,
    RENDER_PASS_CONTINUE = VkCommandBufferUsageFlagBits.VK_COMMAND_BUFFER_USAGE_RENDER_PASS_CONTINUE_BIT,
    SIMULTANEOUS_USE     = VkCommandBufferUsageFlagBits.VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT
}
enum VCommandPoolCreate {
    RESET_COMMAND_BUFFER = VkCommandPoolCreateFlagBits.VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT,
    TRANSIENT            = VkCommandPoolCreateFlagBits.VK_COMMAND_POOL_CREATE_TRANSIENT_BIT,
}
enum VDependency {
    BY_REGION = VkDependencyFlagBits.VK_DEPENDENCY_BY_REGION_BIT
}
enum VDescriptorType : VkDescriptorType {
    SAMPLER                = VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLER,
    COMBINED_IMAGE_SAMPLER = VkDescriptorType.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
    SAMPLED_IMAGE          = VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,
    STORAGE_IMAGE          = VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
    UNIFORM_BUFFER         = VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
    STORAGE_BUFFER         = VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
    STORAGE_BUFFER_DYNAMIC = VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC,
}
enum VFilter {
    LINEAR  = VkFilter.VK_FILTER_LINEAR,
    NEAREST = VkFilter.VK_FILTER_NEAREST,
}
enum VFormat {
    UNDEFINED               = VkFormat.VK_FORMAT_UNDEFINED,
    R8_UNORM                = VkFormat.VK_FORMAT_R8_UNORM,
    R8_SNORM                = VkFormat.VK_FORMAT_R8_SNORM,

    R16_UINT                = VkFormat.VK_FORMAT_R16_UINT,
    R16_SINT                = VkFormat.VK_FORMAT_R16_SINT,
    R16_SFLOAT              = VkFormat.VK_FORMAT_R16_SFLOAT,

    R32_UINT                = VkFormat.VK_FORMAT_R32_UINT,
    R32_SINT                = VkFormat.VK_FORMAT_R32_SINT,
    R32_SFLOAT              = VkFormat.VK_FORMAT_R32_SFLOAT,

    R64_UINT                = VkFormat.VK_FORMAT_R64_UINT,
    R64_SINT                = VkFormat.VK_FORMAT_R64_SINT,
    R64_SFLOAT              = VkFormat.VK_FORMAT_R64_SFLOAT,

    R32G32_SFLOAT           = VkFormat.VK_FORMAT_R32G32_SFLOAT,
    R32G32B32_SFLOAT        = VkFormat.VK_FORMAT_R32G32B32_SFLOAT,
    R32G32B32A32_SFLOAT     = VkFormat.VK_FORMAT_R32G32B32A32_SFLOAT,
    R32G32_SINT             = VkFormat.VK_FORMAT_R32G32_SINT,
    R32G32B32_SINT          = VkFormat.VK_FORMAT_R32G32B32_SINT,
    R32G32B32A32_SINT       = VkFormat.VK_FORMAT_R32G32B32A32_SINT,
    R32G32_UINT             = VkFormat.VK_FORMAT_R32G32_UINT,
    R32G32B32_UINT          = VkFormat.VK_FORMAT_R32G32B32_UINT,
    R32G32B32A32_UINT       = VkFormat.VK_FORMAT_R32G32B32A32_UINT,
    R8G8B8_UNORM            = VkFormat.VK_FORMAT_R8G8B8_UNORM,          /*RGB*/
    B8G8R8_UNORM            = VkFormat.VK_FORMAT_B8G8R8_UNORM,          /*BGR*/
    R8G8B8A8_UNORM          = VkFormat.VK_FORMAT_R8G8B8A8_UNORM,        /*RGBA*/
    B8G8R8A8_UNORM          = VkFormat.VK_FORMAT_B8G8R8A8_UNORM,        /*BGRA*/

    D16_UNORM               = VkFormat.VK_FORMAT_D16_UNORM,             // depth = ushort
    D32_SFLOAT              = VkFormat.VK_FORMAT_D32_SFLOAT,            // depth = int
    S8_UINT                 = VkFormat.VK_FORMAT_S8_UINT,               // stencil = ubyte
    D16_UNORM_S8_UINT       = VkFormat.VK_FORMAT_D16_UNORM_S8_UINT,     // depth = ushort, stencil = ubyte
    D24_UNORM_S8_UINT       = VkFormat.VK_FORMAT_D24_UNORM_S8_UINT,     // depth = 24 bits, stencil = ubyte
    D32_SFLOAT_S8_UINT      = VkFormat.VK_FORMAT_D32_SFLOAT_S8_UINT,    // depth = int, stencil = ubyte

    BC1_RGB_UNORM_BLOCK     = VkFormat.VK_FORMAT_BC1_RGB_UNORM_BLOCK,
    BC2_UNORM_BLOCK         = VkFormat.VK_FORMAT_BC2_UNORM_BLOCK,
    BC3_UNORM_BLOCK         = VkFormat.VK_FORMAT_BC3_UNORM_BLOCK,

    ETC2_R8G8B8A1_UNORM_BLOCK = VkFormat.VK_FORMAT_ETC2_R8G8B8A1_UNORM_BLOCK,
    ETC2_R8G8B8A8_UNORM_BLOCK = VkFormat.VK_FORMAT_ETC2_R8G8B8A8_UNORM_BLOCK,

    EAC_R11_UNORM_BLOCK     = VkFormat.VK_FORMAT_EAC_R11_UNORM_BLOCK,
    EAC_R11_SNORM_BLOCK     = VkFormat. VK_FORMAT_EAC_R11_SNORM_BLOCK
}
enum VImageAspect {
    COLOR    = VkImageAspectFlagBits.VK_IMAGE_ASPECT_COLOR_BIT,
    DEPTH    = VkImageAspectFlagBits.VK_IMAGE_ASPECT_DEPTH_BIT,
    STENCIL  = VkImageAspectFlagBits.VK_IMAGE_ASPECT_STENCIL_BIT,
    METADATA = VkImageAspectFlagBits.VK_IMAGE_ASPECT_METADATA_BIT
}
enum VImageLayout : VkImageLayout {
    UNDEFINED                        = VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED,
    GENERAL                          = VkImageLayout.VK_IMAGE_LAYOUT_GENERAL,
    COLOR_ATTACHMENT_OPTIMAL         = VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
    DEPTH_STENCIL_ATTACHMENT_OPTIMAL = VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
    DEPTH_STENCIL_READ_ONLY_OPTIMAL  = VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL,
    SHADER_READ_ONLY_OPTIMAL         = VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
    TRANSFER_SRC_OPTIMAL             = VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
    TRANSFER_DST_OPTIMAL             = VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
    PREINITIALIZED                   = VkImageLayout.VK_IMAGE_LAYOUT_PREINITIALIZED,
    PRESENT_SRC_KHR                  = VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR
}
enum VImageTiling {
    LINEAR  = VkImageTiling.VK_IMAGE_TILING_LINEAR,
    OPTIMAL = VkImageTiling.VK_IMAGE_TILING_OPTIMAL,
}
enum VImageUsage {
    NONE                     = 0,
    TRANSFER_SRC             = VkImageUsageFlagBits.VK_IMAGE_USAGE_TRANSFER_SRC_BIT,
    TRANSFER_DST             = VkImageUsageFlagBits.VK_IMAGE_USAGE_TRANSFER_DST_BIT,
    SAMPLED                  = VkImageUsageFlagBits.VK_IMAGE_USAGE_SAMPLED_BIT,
    STORAGE                  = VkImageUsageFlagBits.VK_IMAGE_USAGE_STORAGE_BIT,
    COLOR_ATTACHMENT         = VkImageUsageFlagBits.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
    DEPTH_STENCIL_ATTACHMENT = VkImageUsageFlagBits.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT,
    TRANSIENT_ATTACHMENT     = VkImageUsageFlagBits.VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT,
    INPUT_ATTACHMENT         = VkImageUsageFlagBits.VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT
}
enum VImageViewType {
    _1D        = VkImageViewType.VK_IMAGE_VIEW_TYPE_1D,
    _2D        = VkImageViewType.VK_IMAGE_VIEW_TYPE_2D,
    _3D        = VkImageViewType.VK_IMAGE_VIEW_TYPE_3D,
    CUBE       = VkImageViewType.VK_IMAGE_VIEW_TYPE_CUBE,
    _1D_ARRAY  = VkImageViewType.VK_IMAGE_VIEW_TYPE_1D_ARRAY,
    _2D_ARRAY  = VkImageViewType.VK_IMAGE_VIEW_TYPE_2D_ARRAY,
    CUBE_ARRAY = VkImageViewType.VK_IMAGE_VIEW_TYPE_CUBE_ARRAY
}
enum VMemoryProperty {
    NONE             = 0,
    DEVICE_LOCAL     = VkMemoryPropertyFlagBits.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT,
    HOST_VISIBLE     = VkMemoryPropertyFlagBits.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT,
    HOST_COHERENT    = VkMemoryPropertyFlagBits.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT,
    HOST_CACHED      = VkMemoryPropertyFlagBits.VK_MEMORY_PROPERTY_HOST_CACHED_BIT,
    LAZILY_ALLOCATED = VkMemoryPropertyFlagBits.VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT,
}
enum VPipelineBindPoint {
    COMPUTE  = VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_COMPUTE,
    GRAPHICS = VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS,
}
enum VPipelineStage {
    TOP_OF_PIPE                    = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT,
    DRAW_INDIRECT                  = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT,
    VERTEX_INPUT                   = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_VERTEX_INPUT_BIT,
    VERTEX_SHADER                  = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_VERTEX_SHADER_BIT,
    TESSELLATION_CONTROL_SHADER    = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_TESSELLATION_CONTROL_SHADER_BIT,
    TESSELLATION_EVALUATION_SHADER = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_TESSELLATION_EVALUATION_SHADER_BIT,
    GEOMETRY_SHADER                = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_GEOMETRY_SHADER_BIT,
    FRAGMENT_SHADER                = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT,
    EARLY_FRAGMENT_TESTS           = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT,
    LATE_FRAGMENT_TESTS            = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT,
    COLOR_ATTACHMENT_OUTPUT        = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
    COMPUTE_SHADER                 = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
    TRANSFER                       = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_TRANSFER_BIT,
    BOTTOM_OF_PIPE                 = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
    HOST                           = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_HOST_BIT,
    ALL_GRAPHICS                   = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_ALL_GRAPHICS_BIT,
    ALL_COMMANDS                   = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT,
}
enum VPrimitiveTopology {
    POINT_LIST                    = VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_POINT_LIST,
    LINE_LIST                     = VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_LINE_LIST,
    LINE_STRIP                    = VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_LINE_STRIP,
    TRIANGLE_LIST                 = VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST,
    TRIANGLE_STRIP                = VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP,
    TRIANGLE_FAN                  = VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_FAN,
    LINE_LIST_WITH_ADJACENCY      = VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_LINE_LIST_WITH_ADJACENCY,
    LINE_STRIP_WITH_ADJACENCY     = VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_LINE_STRIP_WITH_ADJACENCY,
    TRIANGLE_LIST_WITH_ADJACENCY  = VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST_WITH_ADJACENCY,
    TRIANGLE_STRIP_WITH_ADJACENCY = VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP_WITH_ADJACENCY,
    PATCH_LIST                    = VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_PATCH_LIST
}
enum VQueryPipelineStatistic {
    NONE                        = 0,
    INPUT_ASSEMBLY_VERTICES     = VkQueryPipelineStatisticFlagBits.VK_QUERY_PIPELINE_STATISTIC_INPUT_ASSEMBLY_VERTICES_BIT,
    INPUT_ASSEMBLY_PRIMITIVES   = VkQueryPipelineStatisticFlagBits.VK_QUERY_PIPELINE_STATISTIC_INPUT_ASSEMBLY_PRIMITIVES_BIT,
    VERTEX_SHADER_INVOCATIONS   = VkQueryPipelineStatisticFlagBits.VK_QUERY_PIPELINE_STATISTIC_VERTEX_SHADER_INVOCATIONS_BIT,
    GEOMETRY_SHADER_INVOCATIONS = VkQueryPipelineStatisticFlagBits.VK_QUERY_PIPELINE_STATISTIC_GEOMETRY_SHADER_INVOCATIONS_BIT,
    GEOMETRY_SHADER_PRIMITIVES  = VkQueryPipelineStatisticFlagBits.VK_QUERY_PIPELINE_STATISTIC_GEOMETRY_SHADER_PRIMITIVES_BIT,
    CLIPPING_INVOCATIONS        = VkQueryPipelineStatisticFlagBits.VK_QUERY_PIPELINE_STATISTIC_CLIPPING_INVOCATIONS_BIT,
    CLIPPING_PRIMITIVES         = VkQueryPipelineStatisticFlagBits.VK_QUERY_PIPELINE_STATISTIC_CLIPPING_PRIMITIVES_BIT,
    FRAGMENT_SHADER_INVOCATIONS = VkQueryPipelineStatisticFlagBits.VK_QUERY_PIPELINE_STATISTIC_FRAGMENT_SHADER_INVOCATIONS_BIT,
    TESSELLATION_CONTROL_SHADER_PATCHES = VkQueryPipelineStatisticFlagBits.VK_QUERY_PIPELINE_STATISTIC_TESSELLATION_CONTROL_SHADER_PATCHES_BIT,
    TESSELLATION_EVALUATION_SHADER_INVOCATIONS = VkQueryPipelineStatisticFlagBits.VK_QUERY_PIPELINE_STATISTIC_TESSELLATION_EVALUATION_SHADER_INVOCATIONS_BIT,
    COMPUTE_SHADER_INVOCATIONS  = VkQueryPipelineStatisticFlagBits.VK_QUERY_PIPELINE_STATISTIC_COMPUTE_SHADER_INVOCATIONS_BIT
}
enum VQueryResult {
    _64_BIT             = VkQueryResultFlagBits.VK_QUERY_RESULT_64_BIT,
    WAIT                = VkQueryResultFlagBits.VK_QUERY_RESULT_WAIT_BIT,
    WITH_AVAILABILITY   = VkQueryResultFlagBits.VK_QUERY_RESULT_WITH_AVAILABILITY_BIT,
    PARTIAL             = VkQueryResultFlagBits.VK_QUERY_RESULT_PARTIAL_BIT,
}
enum VQueryType {
    OCCLUSION           = VkQueryType.VK_QUERY_TYPE_OCCLUSION,
    PIPELINE_STATISTICS = VkQueryType.VK_QUERY_TYPE_PIPELINE_STATISTICS,
    TIMESTAMP           = VkQueryType.VK_QUERY_TYPE_TIMESTAMP
}
enum VSampleCount {
    _1  = VkSampleCountFlagBits.VK_SAMPLE_COUNT_1_BIT,
    _2  = VkSampleCountFlagBits.VK_SAMPLE_COUNT_2_BIT,
    _4  = VkSampleCountFlagBits.VK_SAMPLE_COUNT_4_BIT,
    _8  = VkSampleCountFlagBits.VK_SAMPLE_COUNT_8_BIT,
    _16 = VkSampleCountFlagBits.VK_SAMPLE_COUNT_16_BIT,
    _32 = VkSampleCountFlagBits.VK_SAMPLE_COUNT_32_BIT,
    _64 = VkSampleCountFlagBits.VK_SAMPLE_COUNT_64_BIT,
}
enum VSamplerAddressMode {
    REPEAT               = VkSamplerAddressMode.VK_SAMPLER_ADDRESS_MODE_REPEAT,
    MIRRORED_REPEAT      = VkSamplerAddressMode.VK_SAMPLER_ADDRESS_MODE_MIRRORED_REPEAT,
    CLAMP_TO_EDGE        = VkSamplerAddressMode.VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
    CLAMP_TO_BORDER      = VkSamplerAddressMode.VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
    MIRROR_CLAMP_TO_EDGE = VkSamplerAddressMode.VK_SAMPLER_ADDRESS_MODE_MIRROR_CLAMP_TO_EDGE
}
enum VSamplerMipmapMode {
    LINEAR  = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR,
    NEAREST = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_NEAREST,
}
enum VShaderStage : VkShaderStageFlagBits {
    VERTEX                  = VkShaderStageFlagBits.VK_SHADER_STAGE_VERTEX_BIT,
    TESSELLATION_CONTROL    = VkShaderStageFlagBits.VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT,
    TESSELLATION_EVALUATION = VkShaderStageFlagBits.VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT,
    GEOMETRY                = VkShaderStageFlagBits.VK_SHADER_STAGE_GEOMETRY_BIT,
    FRAGMENT                = VkShaderStageFlagBits.VK_SHADER_STAGE_FRAGMENT_BIT,
    COMPUTE                 = VkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT,
    ALL_GRAPHICS            = VkShaderStageFlagBits.VK_SHADER_STAGE_ALL_GRAPHICS,
    ALL                     = VkShaderStageFlagBits.VK_SHADER_STAGE_ALL
}
enum VSharingMode {
    CONCURRENT = VkSharingMode.VK_SHARING_MODE_CONCURRENT,
    EXCLUSIVE  = VkSharingMode.VK_SHARING_MODE_EXCLUSIVE,
}
enum VSubpassContents {
    INLINE                    = VkSubpassContents.VK_SUBPASS_CONTENTS_INLINE,
    SECONDARY_COMMAND_BUFFERS = VkSubpassContents.VK_SUBPASS_CONTENTS_SECONDARY_COMMAND_BUFFERS
}
