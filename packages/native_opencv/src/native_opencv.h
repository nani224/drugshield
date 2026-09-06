#ifndef NATIVE_OPENCV_H
#define NATIVE_OPENCV_H

#include <stdint.h>

#if defined(_WIN32)
    #if defined(BUILDING_NATIVE_OPENCV_DLL)
        #define NATIVE_OPENCV_EXPORT __declspec(dllexport)
    #else
        #define NATIVE_OPENCV_EXPORT __declspec(dllimport)
    #endif
#else
    #define NATIVE_OPENCV_EXPORT __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Detect 4 corner ArUco fiducial markers (DICT_4X4_50) on the test kit pouch.
 * @param image_bytes Raw RGB/RGBA image buffer
 * @param width Image width in pixels
 * @param height Image height in pixels
 * @param out_corners Output array of 8 floats: [x0, y0, x1, y1, x2, y2, x3, y3]
 *                    representing ordered corners (Top-Left, Top-Right, Bottom-Right, Bottom-Left).
 * @return Number of markers detected (4 = full planar lock, <4 = incomplete)
 */
NATIVE_OPENCV_EXPORT int detect_aruco_markers(
    const uint8_t* image_bytes,
    int width,
    int height,
    float* out_corners
);

/**
 * Apply perspective homography warp to unskew the angled photo into a flat planar 800x600 pouch image.
 * @param image_bytes Source RGB image buffer
 * @param width Source image width
 * @param height Source image height
 * @param corners 4 source corner points [x0, y0, x1, y1, x2, y2, x3, y3]
 * @param target_w Destination width (typically 800)
 * @param target_h Destination height (typically 600)
 * @param out_image Destination buffer of size (target_w * target_h * 3) bytes
 * @return 0 on success, non-zero on failure
 */
NATIVE_OPENCV_EXPORT int warp_pouch_perspective(
    const uint8_t* image_bytes,
    int width,
    int height,
    const float* corners,
    int target_w,
    int target_h,
    uint8_t* out_image
);

/**
 * Calibrate color using 3x3 Color Correction Matrix (CCM) computed via
 * Moore-Penrose pseudo-inverse regression on standard reference color patches.
 * @param warped_pouch Flat unskewed pouch image (RGB)
 * @param width Pouch image width
 * @param height Pouch image height
 * @param reference_patches Target reference RGB values for known patches
 * @param out_calibrated Output calibrated RGB image buffer
 * @return 0 on success, non-zero on failure
 */
NATIVE_OPENCV_EXPORT int calibrate_macbeth_ccm(
    const uint8_t* warped_pouch,
    int width,
    int height,
    const float* reference_patches,
    uint8_t* out_calibrated
);

/**
 * Extract Region of Interest (chemical reaction well), convert RGB to CIE L*a*b*,
 * and compute median L*, a*, b* chromaticity and Euclidean Delta E*.
 * @param calibrated_image Calibrated RGB image buffer
 * @param width Image width
 * @param height Image height
 * @param roi_x ROI bounding box X
 * @param roi_y ROI bounding box Y
 * @param roi_w ROI bounding box Width
 * @param roi_h ROI bounding box Height
 * @param out_lab_mean Output array of 4 floats: [L*, a*, b*, DeltaE]
 * @return 0 on success, non-zero on failure
 */
NATIVE_OPENCV_EXPORT int extract_cie_lab_roi(
    const uint8_t* calibrated_image,
    int width,
    int height,
    int roi_x,
    int roi_y,
    int roi_w,
    int roi_h,
    float* out_lab_mean
);

#ifdef __cplusplus
}
#endif

#endif // NATIVE_OPENCV_H
