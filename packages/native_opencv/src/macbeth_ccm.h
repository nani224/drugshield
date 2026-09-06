#ifndef MACBETH_CCM_H
#define MACBETH_CCM_H

#include <stdint.h>

class MacbethCCM {
public:
    MacbethCCM();
    ~MacbethCCM();

    /**
     * Samples reference color patches from the warped pouch image,
     * calculates a 3x3 Color Correction Matrix (CCM) using Moore-Penrose pseudo-inverse regression,
     * and produces an illumination-normalized calibrated RGB image.
     */
    int calibrate(
        const uint8_t* warped_pouch,
        int width,
        int height,
        const float* reference_patches,
        uint8_t* out_calibrated
    );

private:
    void compute3x3CCM(
        const float observed[6][3],
        const float target[6][3],
        float ccm[3][3]
    );
};

#endif // MACBETH_CCM_H
