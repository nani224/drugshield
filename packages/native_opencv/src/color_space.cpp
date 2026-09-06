#include "color_space.h"
#include <cmath>
#include <vector>
#include <algorithm>

#if HAVE_OPENCV
#include <opencv2/opencv.hpp>
#endif

ColorSpace::ColorSpace() {}
ColorSpace::~ColorSpace() {}

// Standard D65 reference white points
static const double Xn = 95.0489;
static const double Yn = 100.000;
static const double Zn = 108.8840;

static inline double f_lab(double t) {
    const double delta = 6.0 / 29.0;
    const double delta_cube = delta * delta * delta;
    if (t > delta_cube) {
        return std::cbrt(t);
    } else {
        return (t / (3.0 * delta * delta)) + (4.0 / 29.0);
    }
}

LabColor ColorSpace::rgbToLab(uint8_t r_byte, uint8_t g_byte, uint8_t b_byte) {
    // 1. sRGB gamma correction to linear sRGB
    double r_lin = r_byte / 255.0;
    double g_lin = g_byte / 255.0;
    double b_lin = b_byte / 255.0;

    auto pivot_rgb = [](double c) -> double {
        return (c > 0.04045) ? std::pow((c + 0.055) / 1.055, 2.4) : (c / 12.92);
    };

    r_lin = pivot_rgb(r_lin) * 100.0;
    g_lin = pivot_rgb(g_lin) * 100.0;
    b_lin = pivot_rgb(b_lin) * 100.0;

    // 2. Linear RGB to CIE XYZ (D65)
    double X = r_lin * 0.4124564 + g_lin * 0.3575761 + b_lin * 0.1804375;
    double Y = r_lin * 0.2126729 + g_lin * 0.7151522 + b_lin * 0.0721750;
    double Z = r_lin * 0.0193339 + g_lin * 0.1191920 + b_lin * 0.9503041;

    // 3. XYZ to CIE L*a*b*
    double fx = f_lab(X / Xn);
    double fy = f_lab(Y / Yn);
    double fz = f_lab(Z / Zn);

    LabColor result;
    result.L = static_cast<float>(116.0 * fy - 16.0);
    result.a = static_cast<float>(500.0 * (fx - fy));
    result.b = static_cast<float>(200.0 * (fy - fz));

    return result;
}

float ColorSpace::deltaE(const LabColor& c1, const LabColor& c2) {
    float dL = c1.L - c2.L;
    float da = c1.a - c2.a;
    float db = c1.b - c2.b;
    return std::sqrt(dL * dL + da * da + db * db);
}

int ColorSpace::extractLabRoi(
    const uint8_t* calibrated_image,
    int width,
    int height,
    int roi_x,
    int roi_y,
    int roi_w,
    int roi_h,
    float* out_lab_mean
) {
    if (!calibrated_image || !out_lab_mean || width <= 0 || height <= 0) {
        return -1;
    }

    // Clamp ROI inside bounds
    int start_x = std::max(0, std::min(roi_x, width - 1));
    int start_y = std::max(0, std::min(roi_y, height - 1));
    int end_x = std::max(start_x + 1, std::min(roi_x + roi_w, width));
    int end_y = std::max(start_y + 1, std::min(roi_y + roi_h, height));

    std::vector<float> L_values;
    std::vector<float> a_values;
    std::vector<float> b_values;

    L_values.reserve((end_x - start_x) * (end_y - start_y));
    a_values.reserve((end_x - start_x) * (end_y - start_y));
    b_values.reserve((end_x - start_x) * (end_y - start_y));

    for (int y = start_y; y < end_y; ++y) {
        for (int x = start_x; x < end_x; ++x) {
            int idx = (y * width + x) * 3;
            uint8_t r = calibrated_image[idx];
            uint8_t g = calibrated_image[idx + 1];
            uint8_t b = calibrated_image[idx + 2];

            LabColor lab = rgbToLab(r, g, b);
            L_values.push_back(lab.L);
            a_values.push_back(lab.a);
            b_values.push_back(lab.b);
        }
    }

    if (L_values.empty()) {
        return -2;
    }

    // Compute median for robustness against specular highlights and noise
    size_t mid = L_values.size() / 2;
    std::nth_element(L_values.begin(), L_values.begin() + mid, L_values.end());
    std::nth_element(a_values.begin(), a_values.begin() + mid, a_values.end());
    std::nth_element(b_values.begin(), b_values.begin() + mid, b_values.end());

    LabColor medianLab = { L_values[mid], a_values[mid], b_values[mid] };

    // Baseline unreacted reagent reference (neutral translucent liquid L*=78, a*=-2, b*=4)
    LabColor baselineReagent = { 78.0f, -2.0f, 4.0f };
    float dE = deltaE(medianLab, baselineReagent);

    out_lab_mean[0] = medianLab.L;
    out_lab_mean[1] = medianLab.a;
    out_lab_mean[2] = medianLab.b;
    out_lab_mean[3] = dE;

    return 0;
}
