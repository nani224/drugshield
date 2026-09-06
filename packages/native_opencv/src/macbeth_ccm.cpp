#include "macbeth_ccm.h"
#include <cmath>
#include <cstring>
#include <algorithm>

#if HAVE_OPENCV
#include <opencv2/opencv.hpp>
#include <opencv2/mcc.hpp>
#endif

MacbethCCM::MacbethCCM() {}
MacbethCCM::~MacbethCCM() {}

// Standard 6-patch neutral/primary references for color calibration
static const float DEFAULT_TARGET_PATCHES[6][3] = {
    { 240.0f, 240.0f, 240.0f }, // White
    { 200.0f, 200.0f, 200.0f }, // Neutral 8
    { 160.0f, 160.0f, 160.0f }, // Neutral 6.5
    { 120.0f, 120.0f, 120.0f }, // Neutral 5
    {  80.0f,  80.0f,  80.0f }, // Neutral 3.5
    {  30.0f,  30.0f,  30.0f }  // Black
};

void MacbethCCM::compute3x3CCM(
    const float observed[6][3],
    const float target[6][3],
    float ccm[3][3]
) {
    // We want to find M (3x3) such that X * M ~= Y
    // Normal equations: (X^T * X) * M = X^T * Y
    // Let A = X^T * X (3x3), B = X^T * Y (3x3)
    double A[3][3] = {0};
    double B[3][3] = {0};

    for (int k = 0; k < 6; ++k) {
        for (int i = 0; i < 3; ++i) {
            for (int j = 0; j < 3; ++j) {
                A[i][j] += observed[k][i] * observed[k][j];
                B[i][j] += observed[k][i] * target[k][j];
            }
        }
    }

    // Invert A (3x3 matrix)
    double det = A[0][0] * (A[1][1] * A[2][2] - A[1][2] * A[2][1]) -
                 A[0][1] * (A[1][0] * A[2][2] - A[1][2] * A[2][0]) +
                 A[0][2] * (A[1][0] * A[2][1] - A[1][1] * A[2][0]);

    if (std::abs(det) < 1e-9) {
        // Fallback to identity matrix if singular
        for (int i = 0; i < 3; ++i) {
            for (int j = 0; j < 3; ++j) {
                ccm[i][j] = (i == j) ? 1.0f : 0.0f;
            }
        }
        return;
    }

    double invA[3][3];
    double invDet = 1.0 / det;
    invA[0][0] = (A[1][1] * A[2][2] - A[1][2] * A[2][1]) * invDet;
    invA[0][1] = (A[0][2] * A[2][1] - A[0][1] * A[2][2]) * invDet;
    invA[0][2] = (A[0][1] * A[1][2] - A[0][2] * A[1][1]) * invDet;

    invA[1][0] = (A[1][2] * A[2][0] - A[1][0] * A[2][2]) * invDet;
    invA[1][1] = (A[0][0] * A[2][2] - A[0][2] * A[2][0]) * invDet;
    invA[1][2] = (A[0][2] * A[1][0] - A[0][0] * A[1][2]) * invDet;

    invA[2][0] = (A[1][0] * A[2][1] - A[1][1] * A[2][0]) * invDet;
    invA[2][1] = (A[0][1] * A[2][0] - A[0][0] * A[2][1]) * invDet;
    invA[2][2] = (A[0][0] * A[1][1] - A[0][1] * A[1][0]) * invDet;

    // M = invA * B
    for (int i = 0; i < 3; ++i) {
        for (int j = 0; j < 3; ++j) {
            double sum = 0.0;
            for (int k = 0; k < 3; ++k) {
                sum += invA[i][k] * B[k][j];
            }
            ccm[i][j] = static_cast<float>(sum);
        }
    }
}

int MacbethCCM::calibrate(
    const uint8_t* warped_pouch,
    int width,
    int height,
    const float* reference_patches,
    uint8_t* out_calibrated
) {
    if (!warped_pouch || !out_calibrated || width <= 0 || height <= 0) {
        return -1;
    }

    // Sample 6 reference patches along the calibrated patch strip of the normalized pouch
    // Standard pouch layout: calibration strip is at 85% height, across 6 horizontal steps
    float observed[6][3];
    int stripY = static_cast<int>(height * 0.88f);
    int patchWidth = width / 7;

    for (int i = 0; i < 6; ++i) {
        int sampleX = (i + 1) * patchWidth;
        int sampleIdx = (stripY * width + sampleX) * 3;

        observed[i][0] = static_cast<float>(warped_pouch[sampleIdx]);     // R
        observed[i][1] = static_cast<float>(warped_pouch[sampleIdx + 1]); // G
        observed[i][2] = static_cast<float>(warped_pouch[sampleIdx + 2]); // B
    }

    float targets[6][3];
    if (reference_patches) {
        for (int i = 0; i < 6; ++i) {
            targets[i][0] = reference_patches[i * 3];
            targets[i][1] = reference_patches[i * 3 + 1];
            targets[i][2] = reference_patches[i * 3 + 2];
        }
    } else {
        std::memcpy(targets, DEFAULT_TARGET_PATCHES, sizeof(DEFAULT_TARGET_PATCHES));
    }

    float ccm[3][3];
    compute3x3CCM(observed, targets, ccm);

    // Apply CCM to each pixel: [R', G', B'] = [R, G, B] * CCM
    int totalPixels = width * height;
    for (int i = 0; i < totalPixels; ++i) {
        int idx = i * 3;
        float r = static_cast<float>(warped_pouch[idx]);
        float g = static_cast<float>(warped_pouch[idx + 1]);
        float b = static_cast<float>(warped_pouch[idx + 2]);

        float newR = r * ccm[0][0] + g * ccm[1][0] + b * ccm[2][0];
        float newG = r * ccm[0][1] + g * ccm[1][1] + b * ccm[2][1];
        float newB = r * ccm[0][2] + g * ccm[1][2] + b * ccm[2][2];

        out_calibrated[idx]     = static_cast<uint8_t>(std::clamp(newR, 0.0f, 255.0f));
        out_calibrated[idx + 1] = static_cast<uint8_t>(std::clamp(newG, 0.0f, 255.0f));
        out_calibrated[idx + 2] = static_cast<uint8_t>(std::clamp(newB, 0.0f, 255.0f));
    }

    return 0;
}
