import 'dart:ffi';
import 'dart:io';

// ── Native C function types ──
typedef DetectArucoMarkersC = Int32 Function(
  Pointer<Uint8> imageBytes,
  Int32 width,
  Int32 height,
  Pointer<Float> outCorners,
);

typedef WarpPouchPerspectiveC = Int32 Function(
  Pointer<Uint8> imageBytes,
  Int32 width,
  Int32 height,
  Pointer<Float> corners,
  Int32 targetW,
  Int32 targetH,
  Pointer<Uint8> outImage,
);

typedef CalibrateMacbethCcmC = Int32 Function(
  Pointer<Uint8> warpedPouch,
  Int32 width,
  Int32 height,
  Pointer<Float> referencePatches,
  Pointer<Uint8> outCalibrated,
);

typedef ExtractCieLabRoiC = Int32 Function(
  Pointer<Uint8> calibratedImage,
  Int32 width,
  Int32 height,
  Int32 roiX,
  Int32 roiY,
  Int32 roiW,
  Int32 roiH,
  Pointer<Float> outLabMean,
);

// ── Dart function signatures ──
typedef DetectArucoMarkersDart = int Function(
  Pointer<Uint8> imageBytes,
  int width,
  int height,
  Pointer<Float> outCorners,
);

typedef WarpPouchPerspectiveDart = int Function(
  Pointer<Uint8> imageBytes,
  int width,
  int height,
  Pointer<Float> corners,
  int targetW,
  int targetH,
  Pointer<Uint8> outImage,
);

typedef CalibrateMacbethCcmDart = int Function(
  Pointer<Uint8> warpedPouch,
  int width,
  int height,
  Pointer<Float> referencePatches,
  Pointer<Uint8> outCalibrated,
);

typedef ExtractCieLabRoiDart = int Function(
  Pointer<Uint8> calibratedImage,
  int width,
  int height,
  int roiX,
  int roiY,
  int roiW,
  int roiH,
  Pointer<Float> outLabMean,
);

class NativeOpencvBindings {
  late final DynamicLibrary? _dylib;

  DetectArucoMarkersDart? _detectArucoMarkers;
  WarpPouchPerspectiveDart? _warpPouchPerspective;
  CalibrateMacbethCcmDart? _calibrateMacbethCcm;
  ExtractCieLabRoiDart? _extractCieLabRoi;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  NativeOpencvBindings() {
    _initLibrary();
  }

  void _initLibrary() {
    try {
      if (Platform.isAndroid) {
        _dylib = DynamicLibrary.open('libnative_opencv.so');
      } else if (Platform.isIOS || Platform.isMacOS) {
        _dylib = DynamicLibrary.process();
      } else if (Platform.isWindows) {
        _dylib = DynamicLibrary.open('native_opencv.dll');
      } else if (Platform.isLinux) {
        _dylib = DynamicLibrary.open('libnative_opencv.so');
      } else {
        _dylib = null;
      }

      if (_dylib != null) {
        _detectArucoMarkers = _dylib!
            .lookup<NativeFunction<DetectArucoMarkersC>>('detect_aruco_markers')
            .asFunction<DetectArucoMarkersDart>();

        _warpPouchPerspective = _dylib!
            .lookup<NativeFunction<WarpPouchPerspectiveC>>('warp_pouch_perspective')
            .asFunction<WarpPouchPerspectiveDart>();

        _calibrateMacbethCcm = _dylib!
            .lookup<NativeFunction<CalibrateMacbethCcmC>>('calibrate_macbeth_ccm')
            .asFunction<CalibrateMacbethCcmDart>();

        _extractCieLabRoi = _dylib!
            .lookup<NativeFunction<ExtractCieLabRoiC>>('extract_cie_lab_roi')
            .asFunction<ExtractCieLabRoiDart>();

        _isAvailable = true;
      }
    } catch (_) {
      _dylib = null;
      _isAvailable = false;
    }
  }

  int detectArucoMarkers(
    Pointer<Uint8> imageBytes,
    int width,
    int height,
    Pointer<Float> outCorners,
  ) {
    if (_detectArucoMarkers != null) {
      return _detectArucoMarkers!(imageBytes, width, height, outCorners);
    }
    return 0;
  }

  int warpPouchPerspective(
    Pointer<Uint8> imageBytes,
    int width,
    int height,
    Pointer<Float> corners,
    int targetW,
    int targetH,
    Pointer<Uint8> outImage,
  ) {
    if (_warpPouchPerspective != null) {
      return _warpPouchPerspective!(imageBytes, width, height, corners, targetW, targetH, outImage);
    }
    return -1;
  }

  int calibrateMacbethCcm(
    Pointer<Uint8> warpedPouch,
    int width,
    int height,
    Pointer<Float> referencePatches,
    Pointer<Uint8> outCalibrated,
  ) {
    if (_calibrateMacbethCcm != null) {
      return _calibrateMacbethCcm!(warpedPouch, width, height, referencePatches, outCalibrated);
    }
    return -1;
  }

  int extractCieLabRoi(
    Pointer<Uint8> calibratedImage,
    int width,
    int height,
    int roiX,
    int roiY,
    int roiW,
    int roiH,
    Pointer<Float> outLabMean,
  ) {
    if (_extractCieLabRoi != null) {
      return _extractCieLabRoi!(calibratedImage, width, height, roiX, roiY, roiW, roiH, outLabMean);
    }
    return -1;
  }
}
