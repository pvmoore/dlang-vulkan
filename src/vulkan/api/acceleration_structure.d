module vulkan.api.acceleration_structure;

import vulkan.all;

/**
 * Create and return an identity (3x4) matrix
 *
 * 1  0  0  0
 * 0  1  0  0
 * 0  0  1  0
 */
VkTransformMatrixKHR identityTransformMatrix() {

    VkTransformMatrixKHR transform = { matrix: [
        [1.0f, 0.0f, 0.0f, 0.0f],
        [0.0f, 1.0f, 0.0f, 0.0f],
        [0.0f, 0.0f, 1.0f, 0.0f]]
    };

    return transform;
}

/** Display in row-major order */
string toString(VkTransformMatrixKHR t) {
    return format("%s %s %s %s\n%s %s %s %s\n%s %s %s %s", 
        t.matrix[0][0], t.matrix[0][1], t.matrix[0][2], t.matrix[0][3],
        t.matrix[1][0], t.matrix[1][1], t.matrix[1][2], t.matrix[1][3],
        t.matrix[2][0], t.matrix[2][1], t.matrix[2][2], t.matrix[2][3]);
}

/**
 * Translate the matrix m
 */
void translate(ref VkTransformMatrixKHR m, float3 t) {
    m.matrix[0][3] = t.x;
    m.matrix[1][3] = t.y;
    m.matrix[2][3] = t.z;
}
/**
 * Scale the matrix m
 */
void scale(ref VkTransformMatrixKHR m, float3 s) {
    m.matrix[0][0] = s.x;
    m.matrix[1][1] = s.y;
    m.matrix[2][2] = s.z;
}
/**
 * Rotate the matrix m around the X axis
 * Todo: test this
 */
 void rotateX(ref VkTransformMatrixKHR m, float radians) {
    float c = cos(radians);
    float s = sin(radians);

    m.matrix[1][1] = c;
    m.matrix[1][2] = -s;
    m.matrix[2][1] = s;
    m.matrix[2][2] = c;
}
/**
 * Rotate the matrix m around the Y axis
 * Todo: test this
 */
 void rotateY(ref VkTransformMatrixKHR m, float radians) {
    float c = cos(radians);
    float s = sin(radians);

    m.matrix[0][0] = c;
    m.matrix[0][2] = s;
    m.matrix[2][0] = -s;
    m.matrix[2][2] = c;
}
/**
 * Rotate the matrix m around the Z axis
 * Todo: test this
 */
 void rotateZ(ref VkTransformMatrixKHR m, float radians) {
    float c = cos(radians);
    float s = sin(radians);

    m.matrix[0][0] = c;
    m.matrix[0][1] = -s;
    m.matrix[1][0] = s;
    m.matrix[1][1] = c;
}

/**
 * Rotate the matrix m
 * Todo: test this
 */
 void rotate(ref VkTransformMatrixKHR m, float radians, float3 axis) {
    float c = cos(radians);
    float s = sin(radians);
    float t = 1.0f - c;

    float x = axis.x;
    float y = axis.y;
    float z = axis.z;

    m.matrix[0][0] = t * x * x + c;
    m.matrix[0][1] = t * x * y - s * z;
    m.matrix[0][2] = t * x * z + s * y;

    m.matrix[1][0] = t * x * y + s * z;
    m.matrix[1][1] = t * y * y + c;
    m.matrix[1][2] = t * y * z - s * x;

    m.matrix[2][0] = t * x * z - s * y;
    m.matrix[2][1] = t * y * z + s * x;
    m.matrix[2][2] = t * z * z + c;
}
