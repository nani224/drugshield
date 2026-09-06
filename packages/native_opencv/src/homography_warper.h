#ifndef HOMOGRAPHY_WARPER_H
#define HOMOGRAPHY_WARPER_H

#include <stdint.h>

class HomographyWarper {
public:
    HomographyWarper();
    ~HomographyWarper();

    /**
     * Computes the homography matrix from 4 corners and unskews the source image
     * into a normalized target_w x target_h flat planar image.
     */
    int warpPerspective(
        const uint8_t* src_image,
        int src_w,
        int src_h,
        const float* corners,
        int target_w,
        int target_h,
        uint8_t* out_image
    );

private:
    void computeHomography(
        const float* src_pts,
        const float* dst_pts,
        double H[9]
    );

    bool invertMatrix(
        const double src[9],
        double dst[9]
    );
};

#endif // HOMOGRAPHY_WARPER_H
