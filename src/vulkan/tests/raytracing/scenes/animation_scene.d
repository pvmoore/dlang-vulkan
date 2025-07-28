module vulkan.tests.raytracing.scenes.animation_scene;

import vulkan.tests.raytracing.test_ray_tracing;

/**
 * Create:
 *   ----------------------------------------
 *   1  A ring of rotating spheres: 
 *      BLAS contains a single sphere AABB
 *      TLAS contains multiple instances
 *      Update the TLAS instance transforms  
 *      Rebuild the TLAS every N frames 
 *   ----------------------------------------
 *   2  A ring of rotating cubes:
 *      BLAS containing a single cube geometry,
 *      TLAS contains multiple instances
 *      Update the TLAS instance transforms
 *      Rebuild the TLAS every N frames   
 *   ----------------------------------------
 *   3  A ring of rotating cubes:
 *      BLAS contains multiple cube geometries, 
 *      TLAS contains a single instance
 *      Update the BLAS transforms
 *      Rebuild the BLAS every N frames
 */
final class AnimationScene : Scene {
public:
    enum Option {
        SPHERES_TLASn_BLAS1 = 1,
        CUBES_TLASn_BLAS1   = 2,
        CUBES_TLAS1_BLASn   = 3
    }
    enum MoveStyle {
        ALL_ANTICLOCKWISE = 0,
        HALF_OPPOSITE     = 1
    }

    this(VulkanContext context, VkCommandPool traceCP, FrameResource[] frameResources, Option option, bool preferFastTrace) {
        super(context, traceCP, frameResources);
        this.numObjects = 200;
        this.option = option;
        this.preferFastTrace = preferFastTrace;

        if(option == Option.SPHERES_TLASn_BLAS1) {
            this.numInstances = numObjects;
        } else if(option == Option.CUBES_TLASn_BLAS1) {
            this.numInstances = numObjects;
        } else if(option == Option.CUBES_TLAS1_BLASn) {
            this.numInstances = 1;
        } else {
            throwIf(true, "implement me");
        }

        if(preferFastTrace) {
            buildFlags = VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR |
                         VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_UPDATE_BIT_KHR;
        } else {
            buildFlags = VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_BUILD_BIT_KHR |
                         VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_UPDATE_BIT_KHR;
        }
    }

    override string name() { 
        string b = preferFastTrace ? "fast trace)" : "fast build)";
        if(option == Option.SPHERES_TLASn_BLAS1) return "Animation (TLAS spheres - " ~ b;
        if(option == Option.CUBES_TLASn_BLAS1) return "Animation (TLAS cubes - " ~ b;
        if(option == Option.CUBES_TLAS1_BLASn) return "Animation (BLAS cubes - " ~ b;
        assert(false);
    }
    override string description() {
        if(option == Option.SPHERES_TLASn_BLAS1) return "%s TLAS instances, single BLAS sphere".format(numObjects); 
        if(option == Option.CUBES_TLASn_BLAS1) return "%s TLAS instances, single BLAS cube".format(numObjects); 
        if(option == Option.CUBES_TLAS1_BLASn) return "Single TLAS instance, %s BLAS cubes".format(numObjects);
        assert(false); 
    }

    override void destroy() {
        super.destroy();
        if(ubo) ubo.destroy();
        if(sphereData) sphereData.destroy();
        if(cubeData) cubeData.destroy();
        if(instanceData) instanceData.destroy();
        if(blasTransformData) blasTransformData.destroy();
        if(blas) blas.destroy();
    }
    override VkCommandBuffer getCommandBuffer(uint index) { 

        auto fr = frameResources[index];
        auto cmd = cmdBuffers[index];

        cmd.beginOneTimeSubmit();

        cmd.resetQueryPool(queryPool, index*4, 4);        

        cmd.writeTimestamp(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, queryPool, index*4); 

        cmd.bindPipeline(rtPipeline);
        cmd.bindDescriptorSets(
            VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR,
            rtPipeline.layout,
            0,
            [descriptors.getSet(0, index.as!uint)],
            null
        );

        // Upload the latest TLAS instance data
        instanceData.upload(cmd);

        if(option == Option.CUBES_TLAS1_BLASn) {
            // Upload the latest BLAS transform data
            blasTransformData.upload(cmd);
        }

        blas.update(cmd);
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
                    fr.traceTarget.handle,
                    VK_ACCESS_SHADER_READ_BIT,
                    VK_ACCESS_SHADER_WRITE_BIT,
                    VK_IMAGE_LAYOUT_UNDEFINED,
                    VK_IMAGE_LAYOUT_GENERAL
                )
            ]
        );

        cmd.writeTimestamp(VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR, queryPool, index*4+1); 

        // Trace rays to traceTarget image
        cmd.traceRays(
            &rtPipeline.raygenStridedDeviceAddressRegion,
            &rtPipeline.missStridedDeviceAddressRegion,
            &rtPipeline.hitStridedDeviceAddressRegion,
            &rtPipeline.callableStridedDeviceAddressRegion,
            windowSize.x, windowSize.y, 1);

        cmd.writeTimestamp(VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR, queryPool, index*4+2);     

        // Prepare the traceTarget image to be used in the Quad fragment shader
        cmd.pipelineBarrier(
            VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
            VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    fr.traceTarget.handle,
                    VK_ACCESS_SHADER_WRITE_BIT,
                    VK_ACCESS_SHADER_READ_BIT,
                    VK_IMAGE_LAYOUT_GENERAL,
                    VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
                )
            ]
        );

        cmd.writeTimestamp(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT, queryPool, index*4+3); 

        cmd.end();

        return cmd; 
    }
    override void imguiFrame(Frame frame) {
        auto vp = igGetMainViewport();
        igSetNextWindowPos(vp.WorkPos + ImVec2(5,500), ImGuiCond_Always, ImVec2(0.0, 0.0));
        igSetNextWindowSize(ImVec2(250, 0), ImGuiCond_Always);
        if(igBegin("Animation", null, ImGuiWindowFlags_None)) {

            igText("Fast %s", (preferFastTrace ? "trace" : "build").toStringz());

            igPushItemWidth(235);

            string[] moveStyleNames = ["All rotate anticlockwise", "Half rotate opposite"];

            igoCombo("##animation_combo", moveStyleNames[moveStyle.as!uint], moveStyleNames, moveStyle.as!uint, (i, name) {
                moveStyle = i.as!MoveStyle;
            });

            igPopItemWidth();

            if(igButton("Rebuild", ImVec2(0,0))) {
               triggerRebuild = true;
            }

        }
        igEnd();
    }
//──────────────────────────────────────────────────────────────────────────────────────────────────
protected:
//──────────────────────────────────────────────────────────────────────────────────────────────────    
    override void subclassInitialise() {
        moveCamera();
        createDataBuffers();
        createObjects();
        createBLAS();
        createTLAS();
        createUBO();
        createDescriptors();
        createPipeline();
        
        // Allocate some command buffers
        foreach(i, fr; frameResources) {
            auto cmd = device.allocFrom(traceCP);
            cmdBuffers ~= cmd;
        }
    }
    override void subclassUpdate(Frame frame, float3 lightPos) {
        auto cmd = frame.resource.adhocCB;

        if(camera3d.wasModified()) {
            camera3d.resetModifiedState();
            updateUBO();
        }

        ubo.write((u) {
            u.lightPos = lightPos;
        });

        angleOverTime += frame.perSecond * 10;

        moveObjects();

        ubo.upload(cmd);
        sphereData.upload(cmd);
        cubeData.upload(cmd);
    }
//──────────────────────────────────────────────────────────────────────────────────────────────────
private:
//──────────────────────────────────────────────────────────────────────────────────────────────────
    BLAS blas;
    GPUData!UBO ubo;
    GPUData!Sphere sphereData;
    GPUData!Cube cubeData;
    GPUData!VkAccelerationStructureInstanceKHR instanceData;
    GPUData!VkTransformMatrixKHR blasTransformData;

    Option option;
    MoveStyle moveStyle;
    uint numObjects;
    uint numInstances;

    Sphere[] spheres;
    Cube[] cubes;
    AABB[] aabbs;

    static float angleOverTime = 0; 
    bool triggerRebuild = false;

    bool preferFastTrace;
    VkBuildAccelerationStructureFlagBitsKHR buildFlags;

    static struct UBO { 
        mat4 viewInverse;
        mat4 projInverse;
        float3 lightPos;
        uint option;
    }
    void moveCamera() {
        this.camera3d.movePositionAbsolute(float3(0,0,-400));
    }
    void createObjects() {
        if(option == Option.SPHERES_TLASn_BLAS1) {

            // Create a ring of Spheres, rotating around the Z axis

            // A single BLAS AABB at the origin
            aabbs ~= AABB(float3(-1, -1, -1), float3(1, 1, 1));

            // Multiple TLAS instances with different transforms
            foreach(i; 0..numObjects) {
                float angle     = i * (360.0 / numObjects);
                float3 centre   = float3(0, 200, 0).rotatedAroundZ(angle.degrees());
                float radius    = 6;
                float3 colour   = float3(uniform01(rng), uniform01(rng), uniform01(rng)).max(float3(0.3));

                Sphere sph = Sphere(centre, radius, colour);
                spheres ~= sph;

                VkTransformMatrixKHR transform = identityTransformMatrix();
                transform.translate(sph.centre);
                transform.scale(float3(sph.radius));

                instanceData.write((instance) {
                    instance.transform = transform;
                    // Sphere hit group 1
                    instance.setInstanceShaderBindingTableRecordOffset(1);
                    instance.setInstanceCustomIndex(0);
                    instance.setMask(0xFF);
                    instance.setFlags(
                        VK_GEOMETRY_INSTANCE_FORCE_OPAQUE_BIT_KHR | 
                        VK_GEOMETRY_INSTANCE_TRIANGLE_FACING_CULL_DISABLE_BIT_KHR);
                }, i);

            }
        } else if(option == Option.CUBES_TLASn_BLAS1) {

            // Create a ring of Cubes, rotating around the Z axis
 
            // Multiple TLAS instances with different transforms
            foreach(i; 0..numObjects) {
                float angle     = i * (360.0 / numObjects);
                float3 centre   = float3(0, 200, 0).rotatedAroundZ(angle.degrees());
                float radius    = 6;
                float3 colour   = float3(uniform01(rng), uniform01(rng), uniform01(rng)).max(float3(0.3));

                Cube cube = Cube(centre, radius, colour);
                cubes ~= cube;

                VkTransformMatrixKHR transform = identityTransformMatrix();
                transform.translate(cube.centre);
                transform.scale(float3(cube.radius));

                instanceData.write((instance) {
                    instance.transform = transform;
                    // Cube hit group 0
                    instance.setInstanceShaderBindingTableRecordOffset(0);
                    instance.setInstanceCustomIndex(0);
                    instance.setMask(0xFF);
                    instance.setFlags(
                        VK_GEOMETRY_INSTANCE_FORCE_OPAQUE_BIT_KHR | 
                        VK_GEOMETRY_INSTANCE_TRIANGLE_FACING_CULL_DISABLE_BIT_KHR);
                }, i);
            }
        } else if(option == Option.CUBES_TLAS1_BLASn) {

            // Create a ring of Cubes, rotating around the Z axis

            // A single TLAS instance
            instanceData.write((instance) {
                instance.transform = identityTransformMatrix();
                // Cube hit group 0
                instance.setInstanceShaderBindingTableRecordOffset(0);
                instance.setInstanceCustomIndex(0);
                instance.setMask(0xFF);
                instance.setFlags(
                    VK_GEOMETRY_INSTANCE_FORCE_OPAQUE_BIT_KHR | 
                    VK_GEOMETRY_INSTANCE_TRIANGLE_FACING_CULL_DISABLE_BIT_KHR);
            }, 0);

            // Multiple TLAS instances with different transforms
            VkTransformMatrixKHR* ptr = blasTransformData.map();

            foreach(i; 0..numObjects) {
                float angle     = i * (360.0 / numObjects);
                float3 centre   = float3(0, 200, 0).rotatedAroundZ(angle.degrees());
                float radius    = 6;
                float3 colour   = float3(uniform01(rng), uniform01(rng), uniform01(rng)).max(float3(0.3));

                Cube cube = Cube(centre, radius, colour);
                cubes ~= cube;

                VkTransformMatrixKHR transform = identityTransformMatrix();
                transform.translate(cube.centre);
                transform.scale(float3(cube.radius));

                *ptr++ = transform;
            }

            blasTransformData.setDirtyRange();

        } else {
            throwIf(true, "implement me");
        }
        if(spheres.length > 0) sphereData.write(spheres);
        if(cubes.length > 0) cubeData.write(cubes);
    }
    void moveObjects() {
        import std.math : trunc;

        uint mod = numObjects / 10;
        uint mul = 200 / mod;

        if(option == Option.SPHERES_TLASn_BLAS1) {
            foreach(i, ref sph; spheres) {
                float angle = angleOverTime + i * (360.0 / numObjects);
                float distance = (i % mod + 1) * mul;

                if(moveStyle == MoveStyle.HALF_OPPOSITE && (i&1)) {
                    angle = -angle;
                }

                sph.centre = float3(0, distance, 0).rotatedAroundZ(angle.degrees());

                VkTransformMatrixKHR transform = identityTransformMatrix();
                transform.translate(sph.centre);
                transform.scale(float3(sph.radius));

                instanceData.write((it) {
                    it.transform = transform;
                }, i.as!uint);
            }
            instanceData.setDirtyRange();
            sphereData.write(spheres);
            tlas.setGeometriesModified(triggerRebuild);
            
        } else if(option == Option.CUBES_TLASn_BLAS1) {
            foreach(i, ref cube; cubes) {
                float angle = angleOverTime + i * (360.0 / numObjects);
                float distance = (i % mod + 1) * mul;

                if(moveStyle == MoveStyle.HALF_OPPOSITE && (i&1)) {
                    angle = -angle;
                }

                cube.centre = float3(0, distance, 0).rotatedAroundZ(angle.degrees());

                VkTransformMatrixKHR transform = identityTransformMatrix();
                transform.translate(cube.centre);
                transform.scale(float3(cube.radius));

                instanceData.write((it) {
                    it.transform = transform;
                }, i.as!uint);
            }
            instanceData.setDirtyRange();
            cubeData.write(cubes);
            tlas.setGeometriesModified(triggerRebuild);

        } else if(option == Option.CUBES_TLAS1_BLASn) {

            VkTransformMatrixKHR* ptr = blasTransformData.map();

            foreach(i, ref cube; cubes) {
                float angle = angleOverTime + i * (360.0 / numObjects);
                float distance = (i % mod + 1) * mul;

                if(moveStyle == MoveStyle.HALF_OPPOSITE && (i&1)) {
                    angle = -angle;
                }

                cube.centre = float3(0, distance, 0).rotatedAroundZ(angle.degrees());

                VkTransformMatrixKHR transform = identityTransformMatrix();
                transform.translate(cube.centre);
                transform.scale(float3(cube.radius));

                *ptr++ = transform;
            }

            blasTransformData.setDirtyRange();
            cubeData.write(cubes);
            blas.setGeometriesModified(triggerRebuild);

        } else {
            throwIf(true, "implement me");
        }

        triggerRebuild = false;
    }
    void updateUBO() {
        ubo.write((u) {
            u.viewInverse = camera3d.V().inversed();
            u.projInverse = camera3d.P().inversed();
            u.option = option;
        });
    }
    void createUBO() {
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

        updateUBO();
    }
    void createDataBuffers() {
        sphereData = new GPUData!Sphere(context, RT_STORAGE, true, numObjects)
            .withUploadStrategy(GPUDataUploadStrategy.ALL)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR
            ))
            .initialise();
            
        cubeData = new GPUData!Cube(context, RT_STORAGE, true, numObjects)
            .withUploadStrategy(GPUDataUploadStrategy.ALL)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR
            ))
            .initialise();

        instanceData = new GPUData!VkAccelerationStructureInstanceKHR(context, RT_INSTANCES, true, numInstances)
            .withUploadStrategy(GPUDataUploadStrategy.ALL)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                VkAccessFlagBits.VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR,
                VkAccessFlagBits.VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR | VK_ACCESS_SHADER_READ_BIT,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR
            ))
            .initialise();

        blasTransformData = new GPUData!VkTransformMatrixKHR(context, RT_TRANSFORMS, true, numObjects)
            .withUploadStrategy(GPUDataUploadStrategy.ALL)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                VkAccessFlagBits.VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR,
                VkAccessFlagBits.VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR | VK_ACCESS_SHADER_READ_BIT,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VkPipelineStageFlagBits.VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR
            ))
            .initialise();
    }
    void createDescriptors() {
        // 0 -> acceleration structure
        // 1 -> target image
        // 2 -> uniform buffer (ubo)
        // 3 -> storage buffer (cubeData)
        // 4 -> storage buffer (sphereData)
        this.descriptors = new Descriptors(context)
            .createLayout()
                .accelerationStructure(VK_SHADER_STAGE_RAYGEN_BIT_KHR)
                .storageImage(VK_SHADER_STAGE_RAYGEN_BIT_KHR)
                .uniformBuffer(VK_SHADER_STAGE_RAYGEN_BIT_KHR | VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR | VK_SHADER_STAGE_INTERSECTION_BIT_KHR)
                .storageBuffer(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR | VK_SHADER_STAGE_INTERSECTION_BIT_KHR)
                .storageBuffer(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR | VK_SHADER_STAGE_INTERSECTION_BIT_KHR)
                .sets(vk.swapchain.numImages());
        descriptors.build();

        foreach(res; frameResources) {
            auto view = res.traceTarget.view;

            descriptors.createSetFromLayout(0)
                    .add(tlas.handle)
                    .add(view, VK_IMAGE_LAYOUT_GENERAL)
                    .add(ubo)
                    .add(cubeData)
                    .add(sphereData)
                    .write();
        }
    }
    void createPipeline() {
        this.rtPipeline = new RayTracingPipeline(context)
            .withDSLayouts(descriptors.getAllLayouts())
            .withRaygenGroup(0)   
            .withMissGroup(1)  
            // Cube hit group  
            .withHitGroup(VK_RAY_TRACING_SHADER_GROUP_TYPE_TRIANGLES_HIT_GROUP_KHR,
                2,                      // closest
                VK_SHADER_UNUSED_KHR,   // any
                VK_SHADER_UNUSED_KHR    // intersection
            )
            // Sphere hit group
            .withHitGroup(VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_KHR,
                3,                      // closest
                VK_SHADER_UNUSED_KHR,   // any
                4                       // intersection
            );

        auto slangModule = context.shaders.getModule("vulkan/test/raytracing/animation/rt_animation.slang");

        rtPipeline.withShader(VK_SHADER_STAGE_RAYGEN_BIT_KHR, slangModule, null, "raygen")
                  .withShader(VK_SHADER_STAGE_MISS_BIT_KHR, slangModule, null, "miss")
                  .withShader(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR, slangModule, null, "closesthitCube")
                  .withShader(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR, slangModule, null, "closesthitSphere")
                  .withShader(VK_SHADER_STAGE_INTERSECTION_BIT_KHR, slangModule, null, "intersection"); 
       
        rtPipeline.build();
    }

    void createBLAS() {

        this.blas = new BLAS(context, "blas_animation1", buildFlags);

        if(option == Option.SPHERES_TLASn_BLAS1) {
            // Single AABB
            auto aabbsSize = aabbs.length*AABB.sizeof;
            SubBuffer aabbsBuffer = context.buffer(RT_AABBS).alloc(aabbsSize);
            auto deviceAddress = getDeviceAddress(context.device, aabbsBuffer);
            context.transfer().from(aabbs.ptr, 0).to(aabbsBuffer).size(aabbsSize);
            
            blas.addAABBs(VK_GEOMETRY_OPAQUE_BIT_KHR, deviceAddress, AABB.sizeof, 1)
                .create();

        } else if(option == Option.CUBES_TLASn_BLAS1) {
            // Single cube

            Tuple!(float3[], ushort[]) t = createCubeVerticesAndIndices();
            float3[] vertices = t[0];
            ushort[] indices = t[1];
            VkTransformMatrixKHR transform = identityTransformMatrix();

            auto verticesSize = vertices.length * float3.sizeof;
            auto indicesSize = indices.length * ushort.sizeof;
            auto transformsSize = VkTransformMatrixKHR.sizeof;

            SubBuffer vertexBuffer = context.buffer(RT_VERTICES).alloc(verticesSize, 0);
            SubBuffer indexBuffer = context.buffer(RT_INDEXES).alloc(indicesSize, 0);
            SubBuffer transformBuffer = context.buffer(RT_TRANSFORMS).alloc(transformsSize, 0);

            auto vertexDeviceAddress = getDeviceAddress(context.device, vertexBuffer);
            auto indexDeviceAddress = getDeviceAddress(context.device, indexBuffer);
            auto transformDeviceAddress = getDeviceAddress(context.device, transformBuffer);

            context.transfer().from(vertices.ptr, 0).to(vertexBuffer).size(verticesSize);
            context.transfer().from(indices.ptr, 0).to(indexBuffer).size(indicesSize);
            context.transfer().from(&transform, 0).to(transformBuffer).size(transformsSize);

            VkAccelerationStructureGeometryTrianglesDataKHR triangles = {
                sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR,
                pNext: null,
                vertexFormat: VK_FORMAT_R32G32B32_SFLOAT,
                vertexStride: float3.sizeof,
                maxVertex: vertices.length.as!uint,
                indexType: VK_INDEX_TYPE_UINT16,
                vertexData: { deviceAddress: vertexDeviceAddress },
                indexData: { deviceAddress: indexDeviceAddress },
                transformData: { deviceAddress: transformDeviceAddress }
            };

            blas.addTriangles(VK_GEOMETRY_OPAQUE_BIT_KHR, triangles, indices.length.as!uint / 3)
                .create();

        } else if(option == Option.CUBES_TLAS1_BLASn) {

            Tuple!(float3[], ushort[]) t = createCubeVerticesAndIndices();
            float3[] vertices = t[0];
            ushort[] indices = t[1];

            auto verticesSize = vertices.length * float3.sizeof;
            auto indicesSize = indices.length * ushort.sizeof;

            SubBuffer vertexBuffer = context.buffer(RT_VERTICES).alloc(verticesSize, 0);
            SubBuffer indexBuffer = context.buffer(RT_INDEXES).alloc(indicesSize, 0);

            auto vertexDeviceAddress = getDeviceAddress(context.device, vertexBuffer);
            auto indexDeviceAddress = getDeviceAddress(context.device, indexBuffer);
            auto transformDeviceAddress = getDeviceAddress(context.device, blasTransformData.getDeviceBuffer());

            context.transfer().from(vertices.ptr, 0).to(vertexBuffer).size(verticesSize);
            context.transfer().from(indices.ptr, 0).to(indexBuffer).size(indicesSize);

            foreach(i; 0..numObjects) {

                // Adjust the transform device addresse
                transformDeviceAddress += VkTransformMatrixKHR.sizeof;
                
                // Each geometry has the same vertex and index data but a different transform
                VkAccelerationStructureGeometryTrianglesDataKHR triangles = {
                    sType: VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR,
                    pNext: null,
                    vertexFormat: VK_FORMAT_R32G32B32_SFLOAT,
                    vertexStride: float3.sizeof,
                    maxVertex: vertices.length.as!uint,
                    indexType: VK_INDEX_TYPE_UINT16,
                    vertexData: { deviceAddress: vertexDeviceAddress },
                    indexData: { deviceAddress: indexDeviceAddress },
                    transformData: { deviceAddress: transformDeviceAddress }
                };

                blas.addTriangles(VK_GEOMETRY_OPAQUE_BIT_KHR, triangles, indices.length.as!uint / 3);
            }

            blas.create();

        } else {
            throwIf(true, "implement me");
        }
    }
    void createTLAS() {

        // Set the instance BLAS references
        foreach(i; 0..numInstances) {
            instanceData.write((it) {
                it.accelerationStructureReference = blas.deviceAddress;
            }, i);
        }

        auto instancesDeviceAddress = getDeviceAddress(device, instanceData.getDeviceBuffer());

        this.tlas = new TLAS(context, "tlas_animation", buildFlags)
            .addInstances(VK_GEOMETRY_OPAQUE_BIT_KHR, instancesDeviceAddress, numInstances)
            .create();
    }
}
