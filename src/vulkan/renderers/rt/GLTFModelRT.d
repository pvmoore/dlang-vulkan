module vulkan.renderers.rt.GLTFModelRT;

import vulkan.all;
import glTF = resources.models.gltf;

/**
 * TODO:
 *  - flTF uses a right handed system which needs to be converted to left handed for my camera.
 *    * Possibly change Camera3D to use a right handed system.
 *  - Some models have normals that are pointing in the opposite direction. Not sure why.
 *  - Lots of extensions are not supported.
 *  - 
 */
final class GLTFModelRT {
public:
    this(VulkanContext context, TLAS tlas, VkImage[] targetImages, VkImageView[] targetViews) {
        this.context = context;
        this.device = context.device;
        this.vk = context.vk;
        this.tlas = tlas;
        this.targetImages = targetImages;
        this.targetViews = targetViews;

        createUBOBuffer();
    }
    void destroy() {
        if(triangleData) triangleData.destroy();
        if(vertexData) vertexData.destroy();
        if(geometryData) geometryData.destroy();
        if(ubo) ubo.destroy();
        foreach(b; blases) b.destroy();
        if(descriptors) descriptors.destroy();
        if(rtPipeline) rtPipeline.destroy();
        foreach(cmd; cmdBuffers) device.free(commandPool, cmd);
        if(commandPool) device.destroyCommandPool(commandPool);
        if(sampler) device.destroySampler(sampler);
        if(images) images.destroy();
    }
    auto modelDataFromFile(string filename) {
        import std.path : baseName, stripExtension, dirName;
        this.gltfName = filename.baseName().stripExtension();
        this.gltfDirectory = dirName(filename) ~ "/";
        this.gltf = glTF.GLTF.read(filename);
        initialise();
        return this;
    }
    auto scale(float3 s) {
        this._scale = s;
        return this;
    }
    auto translate(float3 t) {
        this.translation = t;
        return this;
    }
    auto rotation(Angle!float angle, float3 axis) {
        this.rotationAxis = axis;
        this.rotationAngle = angle;
        return this;
    }
    auto lightPosition(float3 pos) {
        ubo.write((u) {
            u.lightPos = pos;
        });
        return this;
    }
    auto camera(Camera3D camera) {
        ubo.write((u) {
            u.viewInverse = camera.V().inversed();
            u.projInverse = camera.P().inversed();
            u.cameraPos = camera.position();
        });
        cameraSet = true;
        return this;
    }
    VkCommandBuffer getCommandBuffer(Frame frame) {
        uint imageIndex = frame.imageIndex;
        throwIf(!gltf || !cameraSet || !isInitialised, "Not initialised");
        throwIf(imageIndex >= cmdBuffers.length, "Invalid image index %s", imageIndex);

        auto cmd = cmdBuffers[imageIndex];
        auto windowSize = vk.windowSize();

        cmd.beginOneTimeSubmit();

        ubo.upload(cmd);
        vertexData.upload(cmd);
        triangleData.upload(cmd);
        indexData.upload(cmd);
        geometryData.upload(cmd);

        cmd.bindPipeline(rtPipeline);
        cmd.bindDescriptorSets(
            VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR,
            rtPipeline.layout,
            0,
            [descriptors.getSet(0, imageIndex)],
            null
        );

        foreach(blas; blases) {
            blas.update(cmd);
        }
        tlas.update(cmd);

        // Prepare the traceTarget image to be used in the ray tracing shaders
        cmd.pipelineBarrier(
            VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT,
            VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    targetImages[imageIndex],
                    VK_ACCESS_SHADER_READ_BIT,
                    VK_ACCESS_SHADER_WRITE_BIT,
                    VK_IMAGE_LAYOUT_UNDEFINED,
                    VK_IMAGE_LAYOUT_GENERAL
                )
            ]
        );

        // Trace rays to traceTarget image
        cmd.traceRays(
            &rtPipeline.raygenStridedDeviceAddressRegion,
            &rtPipeline.missStridedDeviceAddressRegion,
            &rtPipeline.hitStridedDeviceAddressRegion,
            &rtPipeline.callableStridedDeviceAddressRegion,
            windowSize.x, windowSize.y, 1);    

        // Prepare the traceTarget image to be used in the Quad fragment shader
        cmd.pipelineBarrier(
            VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
            VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    targetImages[imageIndex],
                    VK_ACCESS_SHADER_WRITE_BIT,
                    VK_ACCESS_SHADER_READ_BIT,
                    VK_IMAGE_LAYOUT_GENERAL,
                    VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
                )
            ]
        );

        cmd.end();

        return cmd;
    }
    void imguiFrame(Frame frame) {
        auto vp = igGetMainViewport();
        igSetNextWindowPos(vp.WorkPos + ImVec2(5,233), ImGuiCond_Always, ImVec2(0.0, 0.0));
        igSetNextWindowSize(ImVec2(400, 0), ImGuiCond_Always);

        if(igBegin("Model '%s'".format(gltfName).toStringz(), null, ImGuiWindowFlags_None)) {

            foreach(i, info; instanceInfos) {
                if(igTreeNodeEx_Str("Instance %s '%s'".format(i, info.name).toStringz(), ImGuiTreeNodeFlags_DefaultOpen)) {
                    foreach(g, geom; info.geometries) {

                        if(igTreeNodeEx_Str("Geometry %d".format(g).toStringz(), ImGuiTreeNodeFlags_DefaultOpen)) {
                            igText("Triangles: %d", geom.numTriangles);
                            igText("Vertices:  %d", geom.numVertices);
                            igTreePop();
                        }

                        //igText("Geometry %d: (%d tri, %d vert)", g, geom.numTriangles, geom.numVertices);
                    }
                    igTreePop();
                }
            }
        }
        igEnd();
    }
//──────────────────────────────────────────────────────────────────────────────────────────────────
private:
    @Borrowed VulkanContext context;
    @Borrowed Vulkan vk;
    @Borrowed VkDevice device;
    @Borrowed TLAS tlas;
    @Borrowed VkImage[] targetImages;
    @Borrowed VkImageView[] targetViews;

    enum {
        MAX_TEXTURES = 16,
    }

    static struct UBO { 
        mat4 viewInverse;
        mat4 projInverse;
        float3 cameraPos;
        float3 lightPos;
    }
    static struct Triangle {
        float3 normal;
        float3 colour;
    }
    static struct Vertex {
        float3 pos;
        float3 normal;
        float4 tangent;
        float3 colour;
        float2 uv;
    }
    static struct Geometry {
        uint triangleOffset;
        uint vertexOffset;

        // Material
        float4 baseColourFactor = float4(1);

        // Texture indexes
        uint baseColourTexture = uint.max;          // uint.max if no texture
        uint normalTexture = uint.max;              // uint.max if no texture
        uint occlusionTexture = uint.max;           // uint.max if no texture
        uint metallicRoughnessTexture = uint.max;   // uint.max if no texture
        uint emissiveTexture = uint.max;            // uint.max if no texture
    }
    static struct GeometryInfoUI {
        uint numTriangles;
        uint numVertices;
    }
    static struct InstanceInfoUI {
        string name;
        GeometryInfoUI[] geometries;
    }
    InstanceInfoUI[] instanceInfos;

    GPUData!UBO ubo;
    GPUData!Triangle triangleData;
    GPUData!Vertex vertexData;
    GPUData!uint indexData;
    GPUData!Geometry geometryData;

    AccelerationStructure[] blases;
    Descriptors descriptors;
    RayTracingPipeline rtPipeline;
    VkCommandBuffer[] cmdBuffers;
    VkCommandPool commandPool;
    Images images;
    VkSampler sampler;

    glTF.GLTF gltf; 
    string gltfDirectory;
    string gltfName;
    bool isInitialised;
    bool cameraSet;
    float3 _scale = float3(1,1,1);
    float3 translation = float3(0,0,0);
    float3 rotationAxis = float3(0,0,0);
    Angle!float rotationAngle = 0.radians;
    ImageMeta[] textures;

    void initialise() {
        throwIf(isInitialised, "Already initialised");
        createImageLoader();
        createSampler();
        loadModel();
        createDescriptors();
        createPipeline();
        createCommandBuffers();
        isInitialised = true;
    }
    void createUBOBuffer() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true)
            .withUploadStrategy(GPUDataUploadStrategy.ALL)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                VkAccessFlagBits.VK_ACCESS_UNIFORM_READ_BIT,
                VkAccessFlagBits.VK_ACCESS_UNIFORM_READ_BIT,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR
            ))
            .initialise();

        ubo.write((u) {
            u.lightPos = float3(100, 100, -100);
        });
    }
    void createBuffers(uint maxTriangles, uint maxGeometries) {
        this.triangleData = new GPUData!Triangle(context, BufID.STORAGE, true, maxTriangles)
            .withUploadStrategy(GPUDataUploadStrategy.ALL)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR
            ))
            .initialise();

        this.vertexData = new GPUData!Vertex(context, BufID.STORAGE, true, maxTriangles*3)
            .withUploadStrategy(GPUDataUploadStrategy.ALL)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR
                ))
            .initialise();

        this.indexData = new GPUData!uint(context, BufID.STORAGE, true, maxTriangles*3)
            .withUploadStrategy(GPUDataUploadStrategy.ALL)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR
                ))
            .initialise();

        this.geometryData = new GPUData!Geometry(context, BufID.STORAGE, true, maxGeometries)
            .withUploadStrategy(GPUDataUploadStrategy.ALL)  
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR
                ))
            .initialise();      
    }
    void createImageLoader() {
        this.images = new Images(context, ".");
        this.images.setDestinationQueueFamily(vk.getGraphicsQueueFamily().index);
    }
    void createSampler() {
        this.sampler = context.device.createSampler(samplerCreateInfo((info) {
            info.addressModeU = VK_SAMPLER_ADDRESS_MODE_REPEAT;
            info.addressModeV = VK_SAMPLER_ADDRESS_MODE_REPEAT;
        }));
    }
    void createDescriptors() {
        // Bindings:
        //  0 - acceleration structure
        //  1 - target image
        //  2 - uniform buffer (ubo)
        //  3 - storage buffer (triangles)
        //  4 - storage buffer (vertices)
        //  5 - storage buffer (indices)
        //  6 - storage buffer (geometries)
        //  7 - combined image sampler array
        this.descriptors = new Descriptors(context)
            .createLayout()
                .accelerationStructure(VK_SHADER_STAGE_RAYGEN_BIT_KHR)
                .storageImage(VK_SHADER_STAGE_RAYGEN_BIT_KHR)
                .uniformBuffer(VK_SHADER_STAGE_RAYGEN_BIT_KHR | VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR)
                .storageBuffer(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR)
                .storageBuffer(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR)
                .storageBuffer(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR)
                .storageBuffer(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR)
                .combinedImageSampler(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR, MAX_TEXTURES)
                .sets(vk.swapchain.numImages())
                .build();

        foreach(view; targetViews) {
            auto set = descriptors.createSetFromLayout(0);
            set.add(tlas.handle)
                .add(view, VK_IMAGE_LAYOUT_GENERAL)
                .add(ubo)
                .add(triangleData)
                .add(vertexData)
                .add(indexData)
                .add(geometryData);

            if(textures.length > 0) {
                VkImageView[] views = textures.map!(t => t.image.view(t.format, VK_IMAGE_VIEW_TYPE_2D)).array();
                set.add(sampler, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, views);
            }

            set.write();
        }
    }
    void createPipeline() {
        // SBT:
        //  0 - raygen
        //  1 - miss
        //  2 - closest hit | (any)UNUSED | (intersection)UNUSED
        this.rtPipeline = new RayTracingPipeline(context)
            .withDSLayouts(descriptors.getAllLayouts())
            .withRaygenGroup(0)   
            .withMissGroup(1)    
            .withHitGroup(VK_RAY_TRACING_SHADER_GROUP_TYPE_TRIANGLES_HIT_GROUP_KHR,
                2,                      // closest
                VK_SHADER_UNUSED_KHR,   // any
                VK_SHADER_UNUSED_KHR    // intersection
            );

        auto slangModule = context.shaders.getModule("vulkan/gltfmodel/gltfmodel.slang");

        rtPipeline.withShader(VK_SHADER_STAGE_RAYGEN_BIT_KHR, slangModule, null, "raygen")
                  .withShader(VK_SHADER_STAGE_MISS_BIT_KHR, slangModule, null, "miss")
                  .withShader(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR, slangModule, null, "closesthit")
                  .withMaxRecursionDepth(4);
       
        rtPipeline.build();
    }
    void createCommandBuffers() {
        // We will use the graphics queue for the moment
        commandPool = device.createCommandPool(
            vk.getGraphicsQueueFamily().index,
            VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT
        );

        foreach(i; 0..vk.swapchain.numImages()) {
            auto cmd = device.allocFrom(commandPool);
            cmdBuffers ~= cmd;
        }
    }
    void loadModel() {
        this.log("======================================================================");
        this.log("Loading model");
        this.log("======================================================================");

        VkAccelerationStructureInstanceKHR[] instances;
        uint[] allIndices;
        Triangle[] allTriangles;
        Vertex[] allVertices;
        Geometry[] geometries;

        this.textures = loadModelTextures();

        this.log("Found %s mesh(es)", gltf.meshes.length);

        foreach(i, mesh; gltf.meshes) {
            this.log("Mesh %s has %s primitive(s)", i, mesh.primitives.length);

            uint geometriesIndex = geometries.length.as!uint;
            
            InstanceInfoUI instanceInfo = {
                name: mesh.name
            };

            // Create a single BLAS for the Mesh to contain the primitive geometries (1..n geometries)
            auto blas = new BLAS(context, "blas_" ~ mesh.name, VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR);
            blases ~= blas;

            foreach(g, prim; mesh.primitives) {
                this.log("---------------------------------------------- Instance %s, Geometry %s", i, g);

                auto geom = createGeometry(mesh, i.as!uint, prim);
                uint[] indices = geom.indices;
                Vertex[] vertices = geom.vertices;
                Triangle[] triangles = geom.triangles;
                VkAccelerationStructureGeometryTrianglesDataKHR geometryTrianglesData = geom.geometryTrianglesData;

                blas.addTriangles(VK_GEOMETRY_OPAQUE_BIT_KHR, geometryTrianglesData, triangles.length.as!uint);

                Geometry geometry = {
                    triangleOffset: allTriangles.length.as!uint, 
                    vertexOffset: allVertices.length.as!uint,
                    baseColourFactor: geom.baseColourFactor,
                    baseColourTexture: geom.baseColourTexture,
                    normalTexture: geom.normalTexture,
                    occlusionTexture: geom.occlusionTexture,
                    metallicRoughnessTexture: geom.metallicRoughnessTexture,
                    emissiveTexture: geom.emissiveTexture
                };
                geometries ~= geometry;

                instanceInfo.geometries ~= GeometryInfoUI(triangles.length.as!uint, vertices.length.as!uint);
                this.log("Mesh %s Prim %s -> %s", i, g, geometries[$-1]);

                allIndices ~= indices;
                allVertices ~= vertices;
                allTriangles ~= triangles;
            }

            // Create the BLAS with n geometries
            blas.create();

            // Create the TLAS instance 
            VkTransformMatrixKHR instanceTransform = identityTransformMatrix();

            // Apply transformations to the instance transform (in order: scale, rotate, translate)
            instanceTransform.scale(_scale);
            if(rotationAxis.max() > 0) {
                instanceTransform.rotate(rotationAngle.radians, rotationAxis);
            }
            instanceTransform.translate(translation);

            VkAccelerationStructureInstanceKHR instance = {
                transform: instanceTransform,
                accelerationStructureReference: blas.deviceAddress
            };
            instance.setMask(0xFF);
            instance.setInstanceShaderBindingTableRecordOffset(0);

            // Set the Geometry[] array index for this instance
            instance.setInstanceCustomIndex(geometriesIndex);
            this.log("instance Geometry index = %s", instance.getInstanceCustomIndex());

            instance.setFlags(
                VK_GEOMETRY_INSTANCE_FORCE_OPAQUE_BIT_KHR | 
                VK_GEOMETRY_INSTANCE_TRIANGLE_FACING_CULL_DISABLE_BIT_KHR);
            instances ~= instance;
            instanceInfos ~= instanceInfo;
        }

        // Write all the storage buffer data to the staging buffers
        createBuffers(allTriangles.length.as!uint, geometries.length.as!uint);
        indexData.write(allIndices);
        vertexData.write(allVertices);
        triangleData.write(allTriangles);
        geometryData.write(geometries);

        // Create the TLAS instances, upload them and build the TLAS
        auto instancesSize = VkAccelerationStructureInstanceKHR.sizeof * instances.length;
        SubBuffer instancesBuffer = context.buffer(BufID.RT_INSTANCES).alloc(instancesSize);
        auto instancesDeviceAddress = getDeviceAddress(device, instancesBuffer);
        context.transfer().from(instances.ptr, 0).to(instancesBuffer).size(instancesSize);

        tlas.addInstances(VK_GEOMETRY_OPAQUE_BIT_KHR, instancesDeviceAddress, instances.length.as!uint);

        if(tlas.handle is null) {
            tlas.create();
        } else {
            throwIf(true, "Handle TLAS with existing instances");
        }

        this.log("Textures.length = %s", textures.length);
    }
    ImageMeta[] loadModelTextures() {
        ImageMeta[] temp;
        foreach(t; gltf.textures) {
            uint source = t.source;
            auto image = gltf.images[source];
            string path = gltfDirectory ~  image.uri;
            this.log("  Image.path = %s", path);

            temp ~= images.get(path);
        }
        this.log("Got %s textures", temp.length);
        throwIf(temp.length > MAX_TEXTURES, "Max textures exceeded");
        return temp;
    }

    static struct CreatedGeometry {
        uint[] indices;
        Vertex[] vertices;  
        Triangle[] triangles;

        float4 baseColourFactor = float4(1);
        
        uint baseColourTexture = uint.max;
        uint normalTexture = uint.max;
        uint occlusionTexture = uint.max;
        uint metallicRoughnessTexture = uint.max;
        uint emissiveTexture = uint.max;

        VkAccelerationStructureGeometryTrianglesDataKHR geometryTrianglesData;
    }
    /**
     * Create geometry for the specified mesh primitive.
     */
    CreatedGeometry createGeometry(glTF.Mesh mesh, uint meshIndex, glTF.MeshPrimitive prim) in {
        // Only support triangles so far
        throwIf(prim.mode != glTF.MeshPrimitive.Mode.TRIANGLES, "Unsupported primitive mode %s", prim.mode);
        // Only suuport indices
        throwIf(prim.indices.isNull(), "No indices");
    } do {
        CreatedGeometry created;
        VkTransformMatrixKHR transform = identityTransformMatrix();

        SubBuffer transformBuffer = context.buffer(BufID.RT_TRANSFORMS).alloc(VkTransformMatrixKHR.sizeof, 16);
        auto transformDeviceAddress = getDeviceAddress(context.device, transformBuffer);
        context.transfer().from(&transform, 0).to(transformBuffer).size(VkTransformMatrixKHR.sizeof);

        VkAccelerationStructureGeometryTrianglesDataKHR geometry = {
            sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR,
            pNext: null,
            vertexFormat: VK_FORMAT_R32G32B32_SFLOAT,
            vertexStride: float3.sizeof,
            transformData: { deviceAddress: transformDeviceAddress },
            indexType: VK_INDEX_TYPE_UINT32
        };

        float3 colour = float3(1,1,1);

        // Material 
        if(!prim.material.isNull()) {
            uint materialIndex = prim.material.get();
            auto material = gltf.materials[materialIndex];

            if(!material.normalTexture.isNull()) {
                created.normalTexture = material.normalTexture.get().index; 
            }
            if(!material.occlusionTexture.isNull()) {
                created.occlusionTexture = material.occlusionTexture.get().index; 
            }
            if(!material.emissiveTexture.isNull()) {
                created.emissiveTexture = material.emissiveTexture.get().index; 
            }

            if(!material.pbrMetallicRoughness.isNull()) {
                float[] bcf = material.pbrMetallicRoughness.get().baseColorFactor;
                created.baseColourFactor = *(bcf.ptr.as!(float4*));
                colour = created.baseColourFactor.rgb;

                if(!material.pbrMetallicRoughness.get().baseColorTexture.isNull()) {
                    created.baseColourTexture = material.pbrMetallicRoughness.get().baseColorTexture.get().index;
                }
                if(!material.pbrMetallicRoughness.get().metallicRoughnessTexture.isNull()) {
                    created.metallicRoughnessTexture = material.pbrMetallicRoughness.get().metallicRoughnessTexture.get().index;
                }
            }
        }

        this.log("  baseColourFactor = %s", created.baseColourFactor);
        this.log("  baseColourTexture = %s", created.baseColourTexture);
        this.log("  normalTexture = %s", created.normalTexture);
        this.log("  occlusionTexture = %s", created.occlusionTexture);
        this.log("  metallicRoughnessTexture = %s", created.metallicRoughnessTexture);
        this.log("  emissiveTexture = %s", created.emissiveTexture);

        Vertex[] vertices;
        Triangle[] triangles;

        uint[] indices = getIndices(prim);
        float3[] positions = getAttributeData!float3(prim, "POSITION");
        float3[] normals = getAttributeData!float3(prim, "NORMAL");
        float4[] tangents = getAttributeData!float4(prim, "TANGENT");
        float2[] uvs = getAttributeData!float2(prim, "TEXCOORD_0");

        // Check Nodes for transformations
        foreach(n; gltf.nodes) {

            // Apply matrix to the following nodes
            foreach(ch; n.children) {
                auto node = gltf.nodes[ch];
                if(!node.mesh.isNull()) {
                    uint childMeshIndex = node.mesh.get();
                    if(childMeshIndex == meshIndex) {
                        // This is our current mesh
                        this.log("Applying matrix to mesh %s vertices %s", childMeshIndex, n.matrix);
                        applyMatrix(positions, n.matrix);
                        applyMatrix(normals, n.matrix);
                        applyMatrix(tangents, n.matrix);
                    }
                }
            }
        }

        convertToLeftHanded(positions);
        convertToLeftHanded(normals);
        convertToLeftHanded(tangents);

        //this.log("uvs = %s", uvs);

        // Flip the Y axis of the UVs
        if(false) {
            foreach(ref uv; uvs) {
                uv.y = 1 - uv.y;
            }
        }
        if(false) {
            foreach(ref uv; uvs) {
                uv.x = 1 - uv.x;
            }
        }

        this.log("indices   = %s", indices.length);
        this.log("positions = %s", positions.length);
        this.log("normals   = %s", normals.length);
        this.log("tangents  = %s", tangents.length);
        this.log("uvs       = %s", uvs.length);

        auto indicesSize = indices.length * uint.sizeof;
        auto numTriangles = indices.length / 3;

        // Upload vertices and indices to the GPU
        auto verticesSize = positions.length * float3.sizeof;
        SubBuffer vertexBuffer = context.buffer(BufID.RT_VERTICES).alloc(verticesSize, 16);
        auto vertexDeviceAddress = getDeviceAddress(context.device, vertexBuffer);
        context.transfer().from(positions.ptr, 0).to(vertexBuffer).size(verticesSize);

        SubBuffer indexBuffer = context.buffer(BufID.RT_INDEXES).alloc(indicesSize, 16);
        auto indexDeviceAddress = getDeviceAddress(context.device, indexBuffer);
        context.transfer().from(indices.ptr, 0).to(indexBuffer).size(indicesSize);

        // Create Vertices
        foreach(i; 0..positions.length) {
            auto col = colour;
            float2 uv = uvs.length == 0 ? float2(0) : uvs[i];
            float4 tang = tangents.length == 0 ? float4(0) : tangents[i];

            vertices ~= Vertex(positions[i], normals[i], tang, col, uv);
        }

        // Create Triangles
        foreach(k; 0..numTriangles) {
            uint a = indices[k*3+0];
            uint b = indices[k*3+1];
            uint c = indices[k*3+2];
            float3 normal = float3(0,1,0);
            float3 col = colour;

            // if(k == 10 || k == 11) {
            //     col = float3(1,1,1);
            // }

            // Take the normal from the first vertex
            if(normals.length > 0) {
                normal = normals[a];
            }
            triangles ~= Triangle(normal, col);
            //this.log("Triangle %s: %s, %s, %s normal = %s", k, a,b,c, normal);
        }

        geometry.vertexData.deviceAddress = vertexDeviceAddress;
        geometry.indexData.deviceAddress = indexDeviceAddress;
        geometry.maxVertex = positions.length.as!uint - 1;

        created.indices = indices;
        created.vertices = vertices;
        created.triangles = triangles;
        created.geometryTrianglesData = geometry;

        return created;
    }
    /**
     * Fetch indices and convert to uint[] if not already.
     * (Optimise by using ushort[] later)
     */
    uint[] getIndices(glTF.MeshPrimitive prim) {
        auto indexData = glTF.getIndices(gltf, prim);
        throwIfNot(indexData.hasData(), "No indices");

        if(indexData.stride == 2) {
            ushort* ptr = indexData.data.ptr.as!(ushort*);
            return ptr[0..indexData.count()]
                                    .map!(a => a.as!uint)
                                    .array();
        }
        if(indexData.stride == 4) {
            return indexData.data.ptr.as!(uint*)[0..indexData.count()];
        }
        throwIf(true, "Unsupported index stride %s", indexData.stride);
        return null;
    }
    T[] getAttributeData(T)(glTF.MeshPrimitive prim, string name) {
        auto attrs = glTF.getAttributeData(gltf, prim, name);
        if(attrs.hasData()) {
            glTF.Accessor a = gltf.accessors[attrs.accessorIndex];

            static if(is(T == float2)) {
                throwIfNot(a.isFloat2(), "Expecting float2 type");
            }
            static if(is(T == float3)) {
                throwIfNot(a.isFloat3(), "Expecting float3 type");
            }
            static if(is(T == float4)) {
                throwIfNot(a.isFloat4(), "Expecting float4 type");
            }

            return attrs.data.ptr.as!(T*)[0..a.count];
        }
        return null;
    }
    void convertToLeftHanded(T)(T[] positions) {
        foreach(i; 0..positions.length) {
            positions[i].x = -positions[i].x;
        }
    }
    void negate(T)(T[] array) {
        foreach(i; 0..array.length) {
            array[i] = -array[i];
        }
    }
    void applyMatrix(float3[] array, float[16] m) {
        mat4 m2 = mat4.columnMajor(m);
        foreach(i; 0..array.length) {
            float4 result = m2 * float4(array[i], 1);
            array[i] = result.xyz;
        }
    }
    void applyMatrix(float4[] array, float[16] m) {
        mat4 m2 = mat4.columnMajor(m);
        foreach(i; 0..array.length) {
            float4 result = m2 * array[i];
            array[i] = result;
        }
    }
}
