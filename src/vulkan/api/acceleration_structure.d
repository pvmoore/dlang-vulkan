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

/**
 * Multiply 'dest' by 'b' and store the result in 'dest'
 */
void multiply(ref VkTransformMatrixKHR dest, VkTransformMatrixKHR b) {
    VkTransformMatrixKHR result = { matrix: [
        [0.0f, 0.0f, 0.0f, 0.0f],
        [0.0f, 0.0f, 0.0f, 0.0f],
        [0.0f, 0.0f, 0.0f, 0.0f]]
    };

    for(int i = 0; i < 3; i++) {
        for(int j = 0; j < 4; j++) {
            for(int k = 0; k < 3; k++) {
                result.matrix[i][j] += dest.matrix[i][k] * b.matrix[k][j];
            }
        }
    }

    dest = result;
}

/** Display in row-major order */
string toString(VkTransformMatrixKHR t) {
    return format("%.2f %.2f %.2f %.2f\n%.2f %.2f %.2f %.2f\n%.2f %.2f %.2f %.2f", 
        t.matrix[0][0], t.matrix[0][1], t.matrix[0][2], t.matrix[0][3],
        t.matrix[1][0], t.matrix[1][1], t.matrix[1][2], t.matrix[1][3],
        t.matrix[2][0], t.matrix[2][1], t.matrix[2][2], t.matrix[2][3]);
}

/**
 * Translate the matrix m
 */
void translate(ref VkTransformMatrixKHR m, float3 t) {
    m.matrix[0][3] += t.x;
    m.matrix[1][3] += t.y;
    m.matrix[2][3] += t.z;
}
/**
 * Scale the matrix m
 */
void scale(ref VkTransformMatrixKHR m, float3 s) {
    m.matrix[0][0] *= s.x;
    m.matrix[1][1] *= s.y;
    m.matrix[2][2] *= s.z;
}
/**
 * Rotate the matrix m around the X axis
 */
 void rotateX(ref VkTransformMatrixKHR m, float radians) {
    float c = cos(radians);
    float s = sin(radians);

    VkTransformMatrixKHR rotation = { matrix: [
        [1, 0,  0, 0],
        [0, c, -s, 0],
        [0, s,  c, 0]]
    };
    multiply(m, rotation);
}
/**
 * Rotate the matrix m around the Y axis
 */
 void rotateY(ref VkTransformMatrixKHR m, float radians) {
    float c = cos(radians);
    float s = sin(radians);

    VkTransformMatrixKHR rotation = { matrix: [
        [ c, 0, s, 0],
        [ 0, 1, 0, 0],
        [-s, 0, c, 0]]
    };
    multiply(m, rotation);
}
/**
 * Rotate the matrix m around the Z axis
 */
 void rotateZ(ref VkTransformMatrixKHR m, float radians) {
    float c = cos(radians);
    float s = sin(radians);

    VkTransformMatrixKHR rotation = { matrix: [
        [c, -s, 0, 0],
        [s,  c, 0, 0],
        [0,  0, 1, 0]]
    };
    multiply(m, rotation);
}

/**
 * Rotate the matrix m
 */
 void rotate(ref VkTransformMatrixKHR m, float radians, float3 axis) {
    float c = cos(radians);
    float s = sin(radians);
    float t = 1.0f - c;

    float x = axis.x;
    float y = axis.y;
    float z = axis.z;

    VkTransformMatrixKHR rotation = { matrix: [
        [t * x * x + c,     t * x * y - s * z, t * x * z + s * y, 0],
        [t * x * y + s * z, t * y * y + c,     t * y * z - s * x, 0],
        [t * x * z - s * y, t * y * z + s * x, t * z * z + c,     0]]
    };
    multiply(m, rotation);
}
