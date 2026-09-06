#ifndef COLOR_SPACE_H
#define COLOR_SPACE_H

#include <stdint.h>

struct LabColor {
    float L; // 0 to 100
    float a; // -128 to 127 (Green to Red)
    float b; // -128 to 127 (Blue to Yellow)
};

class ColorSpace {
public:
    ColorSpace();
    ~ColorSpace();

    /**
     * Converts a single sRGB pixel (0-255) to CIE L*a*b* (D65 white point).
     */
    static LabColor rgbToLab(uint8_t r, uint8_t g, uint8_t b);

    /**
     * Calculates Euclidean color distance Delta E* (CIE76) between two Lab colors.
     */
    static float deltaE(const LabColor& c1, const LabColor& c2);

    /**
     * Extracts the reagent reaction well ROI from calibrated image,
     * calculates the median L*, a*, b* chromaticity, and Euclidean Delta E*.
     * Output array out_lab_mean receives 4 floats: [L*, a*, b*, DeltaE].
     */
    int extractLabRoi(
        const uint8_t* calibrated_image,
        int width,
        int height,
        int roi_x,
        int roi_y,
        int roi_w,
        int roi_h,
        float* out_lab_mean
    );
};

#endif // COLOR_SPACE_H
