#include "native_opencv.h"
#include "aruco_detector.h"
#include "homography_warper.h"
#include "macbeth_ccm.h"
#include "color_space.h"

static ArucoDetector g_aruco_detector;
static HomographyWarper g_homography_warper;
static MacbethCCM g_macbeth_ccm;
static ColorSpace g_color_space;

extern "C" {

NATIVE_OPENCV_EXPORT int detect_aruco_markers(
    const uint8_t* image_bytes,
    int width,
    int height,
    float* out_corners
) {
    return g_aruco_detector.detectMarkers(image_bytes, width, height, out_corners);
}

NATIVE_OPENCV_EXPORT int warp_pouch_perspective(
    const uint8_t* image_bytes,
    int width,
    int height,
    const float* corners,
    int target_w,
    int target_h,
    uint8_t* out_image
) {
    return g_homography_warper.warpPerspective(
        image_bytes,
        width,
        height,
        corners,
        target_w,
        target_h,
        out_image
    );
}

NATIVE_OPENCV_EXPORT int calibrate_macbeth_ccm(
    const uint8_t* warped_pouch,
    int width,
    int height,
    const float* reference_patches,
    uint8_t* out_calibrated
) {
    return g_macbeth_ccm.calibrate(
        warped_pouch,
        width,
        height,
        reference_patches,
        out_calibrated
    );
}

NATIVE_OPENCV_EXPORT int extract_cie_lab_roi(
    const uint8_t* calibrated_image,
    int width,
    int height,
    int roi_x,
    int roi_y,
    int roi_w,
    int roi_h,
    float* out_lab_mean
) {
    return g_color_space.extractLabRoi(
        calibrated_image,
        width,
        height,
        roi_x,
        roi_y,
        roi_w,
        roi_h,
        out_lab_mean
    );
}

} // extern "C"
