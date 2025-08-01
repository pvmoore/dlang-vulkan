#language slang 2026

[require(GL_EXT_debug_printf)]

import common;
import sdf;

[[vk::binding(3, 0)]] StructuredBuffer<Shape, ScalarDataLayout> shapes;
[[vk::binding(4, 0)]] Sampler2D sampler0;

// sphere
[shader("intersection")]
void intersection0() {
    struct SphereScene : Scene {
        override float maxSteps() { return 1000; }

        float map(float3 p) {
            return sdfSphere(p, 1);
        }
        override float2 getUV(float3 hit, float3 normal) {
            return sphereUV(normal);
        }
    }
    let scene = SphereScene();

    intersectionScene(scene);
}

// box
[shader("intersection")]
void intersection1() {
    struct BoxScene : Scene {
        override float maxSteps() { return 2000; } 
        override float stepMutiplier() { return 1; }

        float map(float3 p) {
            return sdfBox(p, 1);
        }
        override float2 getUV(float3 hit, float3 normal) {
            return boxUV(hit, normal);
        }
    }
    let scene = BoxScene();

    intersectionScene(scene);
}

// cone
[shader("intersection")]
void intersection2() {
    struct ConeScene : Scene {
        override float maxSteps() { return 1000; }

        float map(float3 p) {
            return sdfCone(p, 1, 0, 0.5);
        }
    }
    let scene = ConeScene();

    intersectionScene(scene);
}

// cylinder
[shader("intersection")]
void intersection3() {
    struct CylinderScene : Scene {
        override float maxSteps() { return 1000; }

        float map(float3 p) {
            return sdfCylinder(p, 1, 0.5);
        }
    }
    let scene = CylinderScene();

    intersectionScene(scene); 
}

// Rounded box
[shader("intersection")]
void intersection4() {
    struct TheScene : Scene {
        override float maxSteps() { return 5000; }

        float map(float3 p) {
            let a = sdfRoundedBox(sdfMove(p, float3(0,-0.5,0)), float3(1, 0.5, 1), 0.2);
            let b = sdfCylinder(p, 1, 0.5);
            return opUnionSmooth(a, b, 0.3);
        }
    }
    let scene = TheScene();

    intersectionScene(scene);
}

// torus
[shader("intersection")] 
void intersection5() {
    struct TheScene : Scene {
        override float maxSteps() { return 2000; }
        override float stepMutiplier() { return 0.5; }

        float map(float3 p) {
            rotateX(p, (90.0).degrees());
            return sdfRing(p, 0.2, 0.8);
        }
    }
    let scene = TheScene();

    intersectionScene(scene);
}

// Displaced box
[shader("intersection")]
void intersection6() {
    struct TheScene : Scene {
        override float maxSteps() { return 5000; }
        override float stepMutiplier() { return 0.5; }

        float map(float3 p) {
            let a = sdfDisplacedBox(p, float3(1), sampler0);
            return a;
        }
    }
    let scene = TheScene();

    intersectionScene(scene);
}

// sdCutHollowSphere
[shader("intersection")]
void intersection7() { 
    struct TheScene : Scene {
        override float maxSteps() { return 2000; }
        override float stepMutiplier() { return 1; }

        float map(float3 p) {
            return sdCutHollowSphere(p, 0.9, 0.2, 0.1);
        }
    }
    let scene = TheScene();

    intersectionScene(scene);
}

void intersectionScene(Scene scene) {
    Shape shape = shapes[InstanceIndex()];

    // Shapes are in object space
    AABB objectAabb = AABB(float3(-1), float3(1));

    Ray ray = { ObjectRayOrigin(), ObjectRayDirection() };

    float2 nearFar = intersectAABB(ray, objectAabb);
    float near = nearFar.x;
    float far  = nearFar.y;

    //printf("aabb: %1.3v3f .. %1.3v3f\n", objectAabb.min, objectAabb.max);
    //printf("ray: origin:%1.3v3f, dir:%1.3v3f t", ray.origin, ray.direction);

    //printf("near: %f, far: %f", near, far);

    // RayTCurrent is the maximum distance
    // if(near < RayTMin() || near > RayTCurrent()) {
    //     //return;
    // }

    // March the ray in object space
    float t = near;
    if(march(scene, ray, far, t)) {

        HitAttributes attribs;
        attribs.normal = scene.calcNormal(ray.origin + ray.direction*t);
        attribs.uv = scene.getUV(ray.origin + ray.direction*t, attribs.normal);

        ReportHit(t, 0, attribs);
    }
} 

bool march(Scene scene, Ray ray, float maxDistance, inout float t) {
   int steps = 0;
   do{
       float dist = scene.map(ray.origin + ray.direction*t);
       if(dist <= EPSILON) {
           t += dist;
           return true;
       }
       t += dist * scene.stepMutiplier();
   }while(t < maxDistance && ++steps < scene.maxSteps());

   return false;
}



