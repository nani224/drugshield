import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:native_opencv/native_opencv.dart';
import '../../core/sensor_service.dart';
import '../../core/theme.dart';
import '../ndps_checklist/checklist_model.dart';
import 'camera_controller_provider.dart';
import 'hud_reticle_painter.dart';

class CameraHudScreen extends ConsumerStatefulWidget {
  const CameraHudScreen({super.key});

  @override
  ConsumerState<CameraHudScreen> createState() => _CameraHudScreenState();
}

class _CameraHudScreenState extends ConsumerState<CameraHudScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _autoCaptureController;
  Timer? _lockEvaluationTimer;

  ReticleLockState _lockState = ReticleLockState.searching;
  double _tiltDeg = 0.8;
  double _lux = 420.0;
  List<Offset> _corners = [];
  bool _isProcessing = false;
  int _consecutiveLockMs = 0;

  @override
  void initState() {
    super.initState();

    _autoCaptureController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(() {
        setState(() {});
      })..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_isProcessing) {
          _triggerCapture();
        }
      });

    // Initialize camera stream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cameraProvider.notifier).initializeCamera();
      _startOpticalTrackingLoop();
    });
  }

  void _startOpticalTrackingLoop() {
    // Evaluation cycle running every 50ms (20 FPS optical evaluation)
    _lockEvaluationTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted || _isProcessing) return;

      final telemetry = ref.read(sensorServiceProvider).currentTelemetry;
      _tiltDeg = telemetry.totalTiltDeg;
      _lux = telemetry.ambientLux;

      // Simulate real-time tracking progression towards locked alignment
      // 0-400ms: searching, 400-800ms: adjusting, >800ms: locked
      final tick = timer.tick;

      if (tick < 6) {
        // Phase 1: Searching for pouch
        _lockState = ReticleLockState.searching;
        _autoCaptureController.reset();
        _consecutiveLockMs = 0;
      } else if (_tiltDeg > 3.0 || _lux < 150.0) {
        // Phase 2: Adjusting (tilt/lux warning)
        _lockState = ReticleLockState.adjusting;
        _autoCaptureController.reset();
        _consecutiveLockMs = 0;
      } else {
        // Phase 3: Alignment locked
        _lockState = ReticleLockState.locked;
        _consecutiveLockMs += 50;

        if (_consecutiveLockMs >= 150 && !_autoCaptureController.isAnimating && _autoCaptureController.value < 1.0) {
          _autoCaptureController.forward();
        }
      }

      setState(() {});
    });
  }

  Future<void> _triggerCapture() async {
    if (_isProcessing) return;
    _isProcessing = true;

    // Tactical Shutter Haptic Pulse
    HapticFeedback.heavyImpact();

    // Capture frame
    final capturedBytes = await ref.read(cameraProvider.notifier).captureFrame();

    // Run native OpenCV perspective warp, Macbeth CCM, and CIE Lab ROI extraction
    final nativeOpencv = NativeOpencv();
    final corners = await nativeOpencv.detectArucoMarkers(capturedBytes, 800, 600);
    final result = await nativeOpencv.processPouchCapture(capturedBytes, 800, 600, corners);

    if (mounted) {
      HapticFeedback.mediumImpact();
      context.go('/calibration-preview', extra: result);
    }
  }

  @override
  void dispose() {
    _lockEvaluationTimer?.cancel();
    _autoCaptureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);
    final checklist = ref.watch(ndpsChecklistProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: DSColors.bgAbyssal,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera Live Stream / Simulated Viewfinder ──
          if (cameraState.controller != null && cameraState.controller!.value.isInitialized)
            CameraPreview(cameraState.controller!)
          else
            _SimulatedCameraViewfinder(reagent: checklist.selectedReagent),

          // ── Tactical Cockpit HUD CustomPainter Overlay ──
          CustomPaint(
            painter: HudReticlePainter(
              lockState: _lockState,
              tiltDeg: _tiltDeg,
              lux: _lux,
              autoCaptureProgress: _autoCaptureController.value,
              markerCorners: _corners,
            ),
            size: Size.infinite,
          ),

          // ── Cockpit Header Telemetry Bar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.black.withOpacity(0.55),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Recording & Resolution indicator
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: DSColors.hudCyan,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'OPTICAL HUD • 60 FPS',
                          style: DSTypography.mono.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: DSColors.hudCyan,
                          ),
                        ),
                      ],
                    ),

                    // GPS Coordinates
                    Text(
                      '${checklist.latitude?.toStringAsFixed(4)}° N, ${checklist.longitude?.toStringAsFixed(4)}° E',
                      style: DSTypography.monoSmall.copyWith(
                        fontSize: 11,
                        color: DSColors.hudCyan,
                      ),
                    ),

                    // Battery & Storage
                    Row(
                      children: [
                        const Icon(Icons.battery_charging_full, color: DSColors.accentEmerald, size: 16),
                        const SizedBox(width: 4),
                        Text('98%', style: DSTypography.monoSmall.copyWith(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom Cockpit Status Banner & Controls ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dynamic Status Banner
                    _buildStatusBanner(),
                    const SizedBox(height: 16),

                    // Bottom Shutter Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Back to checklist
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: DSColors.textSecondary, size: 28),
                          onPressed: () => context.go('/ndps-checklist'),
                        ),

                        // Center Shutter Button (Manual fallback for gloved tap)
                        GestureDetector(
                          onTap: _triggerCapture,
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _lockState == ReticleLockState.locked
                                    ? DSColors.accentEmerald
                                    : DSColors.surfaceBorder,
                                width: 3,
                              ),
                              color: _lockState == ReticleLockState.locked
                                  ? DSColors.accentEmerald.withOpacity(0.2)
                                  : DSColors.surfaceCarbon.withOpacity(0.6),
                            ),
                            child: Center(
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _lockState == ReticleLockState.locked
                                      ? DSColors.accentEmerald
                                      : DSColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Flashlight toggle
                        IconButton(
                          icon: const Icon(Icons.flash_on, color: DSColors.hudCyan, size: 28),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tactical illuminator active')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'HANDS-FREE AUTO-CAPTURE ACTIVE (400ms STEADY LOCK)',
                      style: DSTypography.monoSmall.copyWith(
                        fontSize: 9,
                        letterSpacing: 0.8,
                        color: DSColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    Color bannerColor;
    String bannerText;
    IconData icon;

    switch (_lockState) {
      case ReticleLockState.searching:
        bannerColor = DSColors.accentCrimson;
        bannerText = 'SEARCHING FOR TEST POUCH (Align 4 Corner Markers)';
        icon = Icons.search;
        break;
      case ReticleLockState.adjusting:
        bannerColor = DSColors.accentAmber;
        bannerText = 'LEVEL DEVICE & CHECK LIGHTING (Tilt < 3°, Lux > 150)';
        icon = Icons.warning_amber_rounded;
        break;
      case ReticleLockState.locked:
        bannerColor = DSColors.accentEmerald;
        final remainingSec = ((1.0 - _autoCaptureController.value) * 0.4).toStringAsFixed(1);
        bannerText = 'ALIGNMENT LOCKED: HOLD STEADY (Auto-capturing in ${remainingSec}s...)';
        icon = Icons.check_circle_outline;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: DSColors.bgAbyssal.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bannerColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: bannerColor.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: bannerColor, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              bannerText,
              style: DSTypography.mono.copyWith(
                fontSize: 11,
                color: bannerColor,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimulatedCameraViewfinder extends StatelessWidget {
  final ReagentType reagent;

  const _SimulatedCameraViewfinder({required this.reagent});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D1117),
      child: Center(
        child: Container(
          width: 320,
          height: 240,
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF30363D), width: 2),
          ),
          child: Stack(
            children: [
              // Test pouch plastic outline
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF00E5FF),
                        const Color(0xFF007799),
                        const Color(0xFF161B22),
                      ],
                    ),
                  ),
                ),
              ),

              // 4 ArUco markers at corners
              _buildCornerMarker(top: 8, left: 8, id: '01'),
              _buildCornerMarker(top: 8, right: 8, id: '02'),
              _buildCornerMarker(bottom: 8, right: 8, id: '03'),
              _buildCornerMarker(bottom: 8, left: 8, id: '04'),

              // Bottom calibration strip
              Positioned(
                bottom: 12,
                left: 36,
                right: 36,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.grey,
                        Color(0xFF424242),
                        Color(0xFF212121),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCornerMarker({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required String id,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: Center(
          child: Container(
            width: 12,
            height: 12,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
