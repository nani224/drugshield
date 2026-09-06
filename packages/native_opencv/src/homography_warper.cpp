#include "homography_warper.h"
#include <cmath>
#include <cstring>
#include <algorithm>

#if HAVE_OPENCV
#include <opencv2/opencv.hpp>
#endif

HomographyWarper::HomographyWarper() {}
HomographyWarper::~HomographyWarper() {}

void HomographyWarper::computeHomography(
    const float* src_pts,
    const float* dst_pts,
    double H[9]
) {
    // Standard Direct Linear Transformation (DLT) for 4 correspondences
    // Ah = 0 where A is 8x8 matrix
    double A[8][8];
    double B[8];

    for (int i = 0; i < 4; ++i) {
        double xs = src_pts[i * 2];
        double ys = src_pts[i * 2 + 1];
        double xd = dst_pts[i * 2];
        double yd = dst_pts[i * 2 + 1];

        A[i * 2][0] = xs;
        A[i * 2][1] = ys;
        A[i * 2][2] = 1.0;
        A[i * 2][3] = 0.0;
        A[i * 2][4] = 0.0;
        A[i * 2][5] = 0.0;
        A[i * 2][6] = -xs * xd;
        A[i * 2][7] = -ys * xd;
        B[i * 2] = xd;

        A[i * 2 + 1][0] = 0.0;
        A[i * 2 + 1][1] = 0.0;
        A[i * 2 + 1][2] = 0.0;
        A[i * 2 + 1][3] = xs;
        A[i * 2 + 1][4] = ys;
        A[i * 2 + 1][5] = 1.0;
        A[i * 2 + 1][6] = -xs * yd;
        A[i * 2 + 1][7] = -ys * yd;
        B[i * 2 + 1] = yd;
    }

    // Solve A * h = B using Gaussian elimination with partial pivoting
    for (int i = 0; i < 8; ++i) {
        int max_row = i;
        double max_val = std::abs(A[i][i]);
        for (int k = i + 1; k < 8; ++k) {
            if (std::abs(A[k][i]) > max_val) {
                max_val = std::abs(A[k][i]);
                max_row = k;
            }
        }

        if (max_row != i) {
            for (int k = 0; k < 8; ++k) {
                std::swap(A[i][k], A[max_row][k]);
            }
            std::swap(B[i], B[max_row]);
        }

        double pivot = A[i][i];
        if (std::abs(pivot) < 1e-9) continue;

        for (int j = i; j < 8; ++j) {
            A[i][j] /= pivot;
        }
        B[i] /= pivot;

        for (int k = 0; k < 8; ++k) {
            if (k != i) {
                double factor = A[k][i];
                for (int j = i; j < 8; ++j) {
                    A[k][j] -= factor * A[i][j];
                }
                B[k] -= factor * B[i];
            }
        }
    }

    H[0] = B[0]; H[1] = B[1]; H[2] = B[2];
    H[3] = B[3]; H[4] = B[4]; H[5] = B[5];
    H[6] = B[6]; H[7] = B[7]; H[8] = 1.0;
}

bool HomographyWarper::invertMatrix(const double src[9], double dst[9]) {
    double det = src[0] * (src[4] * src[8] - src[5] * src[7]) -
                 src[1] * (src[3] * src[8] - src[5] * src[6]) +
                 src[2] * (src[3] * src[7] - src[4] * src[6]);

    if (std::abs(det) < 1e-12) return false;

    double invdet = 1.0 / det;
    dst[0] =  (src[4] * src[8] - src[5] * src[7]) * invdet;
    dst[1] = -(src[1] * src[8] - src[2] * src[7]) * invdet;
    dst[2] =  (src[1] * src[5] - src[2] * src[4]) * invdet;
    dst[3] = -(src[3] * src[8] - src[5] * src[6]) * invdet;
    dst[4] =  (src[0] * src[8] - src[2] * src[6]) * invdet;
    dst[5] = -(src[0] * src[5] - src[2] * src[3]) * invdet;
    dst[6] =  (src[3] * src[7] - src[4] * src[6]) * invdet;
    dst[7] = -(src[0] * src[7] - src[1] * src[6]) * invdet;
    dst[8] =  (src[0] * src[4] - src[1] * src[3]) * invdet;

    return true;
}

int HomographyWarper::warpPerspective(
    const uint8_t* src_image,
    int src_w,
    int src_h,
    const float* corners,
    int target_w,
    int target_h,
    uint8_t* out_image
) {
    if (!src_image || !corners || !out_image || target_w <= 0 || target_h <= 0) {
        return -1;
    }

#if HAVE_OPENCV
    std::vector<cv::Point2f> src_pts = {
        cv::Point2f(corners[0], corners[1]),
        cv::Point2f(corners[2], corners[3]),
        cv::Point2f(corners[4], corners[5]),
        cv::Point2f(corners[6], corners[7])
    };
    std::vector<cv::Point2f> dst_pts = {
        cv::Point2f(0.0f, 0.0f),
        cv::Point2f(static_cast<float>(target_w), 0.0f),
        cv::Point2f(static_cast<float>(target_w), static_cast<float>(target_h)),
        cv::Point2f(0.0f, static_cast<float>(target_h))
    };

    cv::Mat M = cv::getPerspectiveTransform(src_pts, dst_pts);
    cv::Mat srcMat(src_h, src_w, CV_8UC3, const_cast<uint8_t*>(src_image));
    cv::Mat dstMat(target_h, target_w, CV_8UC3, out_image);

    cv::warpPerspective(srcMat, dstMat, M, cv::Size(target_w, target_h), cv::INTER_LINEAR);
    return 0;
#endif

    float dst_pts[8] = {
        0.0f, 0.0f,
        static_cast<float>(target_w - 1), 0.0f,
        static_cast<float>(target_w - 1), static_cast<float>(target_h - 1),
        0.0f, static_cast<float>(target_h - 1)
    };

    double H[9];
    computeHomography(corners, dst_pts, H);

    double H_inv[9];
    if (!invertMatrix(H, H_inv)) {
        return -2;
    }

    // Bilinear backward mapping from destination to source image
    for (int y = 0; y < target_h; ++y) {
        for (int x = 0; x < target_w; ++x) {
            double wx = H_inv[0] * x + H_inv[1] * y + H_inv[2];
            double wy = H_inv[3] * x + H_inv[4] * y + H_inv[5];
            double wz = H_inv[6] * x + H_inv[7] * y + H_inv[8];

            if (std::abs(wz) < 1e-9) continue;

            double sx = wx / wz;
            double sy = wy / wz;

            int dst_idx = (y * target_w + x) * 3;

            if (sx >= 0 && sx < src_w - 1 && sy >= 0 && sy < src_h - 1) {
                int x0 = static_cast<int>(sx);
                int y0 = static_cast<int>(sy);
                int x1 = x0 + 1;
                int y1 = y0 + 1;

                double dx = sx - x0;
                double dy = sy - y0;

                for (int c = 0; c < 3; ++c) {
                    double p00 = src_image[(y0 * src_w + x0) * 3 + c];
                    double p10 = src_image[(y0 * src_w + x1) * 3 + c];
                    double p01 = src_image[(y1 * src_w + x0) * 3 + c];
                    double p11 = src_image[(y1 * src_w + x1) * 3 + c];

                    double val = (1.0 - dx) * (1.0 - dy) * p00 +
                                 dx * (1.0 - dy) * p10 +
                                 (1.0 - dx) * dy * p01 +
                                 dx * dy * p11;

                    out_image[dst_idx + c] = static_cast<uint8_t>(std::clamp(val, 0.0, 255.0));
                }
            } else {
                out_image[dst_idx] = 0;
                out_image[dst_idx + 1] = 0;
                out_image[dst_idx + 2] = 0;
            }
        }
    }

    return 0;
}
