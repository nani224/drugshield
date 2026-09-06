#ifndef ARUCO_DETECTOR_H
#define ARUCO_DETECTOR_H

#include <stdint.h>
#include <vector>

struct Point2D {
    float x;
    float y;
};

class ArucoDetector {
public:
    ArucoDetector();
    ~ArucoDetector();

    /**
     * Detects 4 corner ArUco markers on the pouch.
     * Fills out_corners with 8 floats: [TL_x, TL_y, TR_x, TR_y, BR_x, BR_y, BL_x, BL_y]
     * Returns count of valid corners identified (4 for full lock).
     */
    int detectMarkers(
        const uint8_t* image_bytes,
        int width,
        int height,
        float* out_corners
    );
};

#endif // ARUCO_DETECTOR_H
