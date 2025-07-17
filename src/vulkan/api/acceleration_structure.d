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
    VkTransformMatrixKHR transform;

    float* fp = (&transform).as!(float*);
    fp[0..VkTransformMatrixKHR.sizeof/4] = 0.0f;

    transform.matrix[0][0] = 1;
    transform.matrix[1][1] = 1;
    transform.matrix[2][2] = 1;
    return transform;
}
