import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:native_opencv/native_opencv.dart';
import '../features/ai_inference/ai_result_screen.dart';
import '../features/ai_inference/evidence_vault_screen.dart';
import '../features/ai_inference/prediction_model.dart';
import '../features/auth/biometric_auth_screen.dart';
import '../features/camera_hud/calibration_preview_screen.dart';
import '../features/camera_hud/camera_hud_screen.dart';
import '../features/ndps_checklist/checklist_model.dart';
import '../features/ndps_checklist/ndps_checklist_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'auth',
      builder: (context, state) => const BiometricAuthScreen(),
    ),
    GoRoute(
      path: '/ndps-checklist',
      name: 'ndps-checklist',
      builder: (context, state) => const NDPSChecklistScreen(),
    ),
    GoRoute(
      path: '/camera-hud',
      name: 'camera-hud',
      builder: (context, state) => const CameraHudScreen(),
    ),
    GoRoute(
      path: '/calibration-preview',
      name: 'calibration-preview',
      builder: (context, state) {
        final result = state.extra as PouchCalibrationResult? ??
            PouchCalibrationResult(
              warpedImageBytes: Uint8List(800 * 600 * 3),
              calibratedImageBytes: Uint8List(800 * 600 * 3),
              labData: const LabColorData(
                L: 58.0,
                a: -18.5,
                b: -42.0,
                deltaE: 52.4,
              ),
              width: 800,
              height: 600,
            );
        return CalibrationPreviewScreen(calibrationResult: result);
      },
    ),
    GoRoute(
      path: '/ai-result',
      name: 'ai-result',
      builder: (context, state) {
        final result = state.extra as PouchCalibrationResult? ??
            PouchCalibrationResult(
              warpedImageBytes: Uint8List(800 * 600 * 3),
              calibratedImageBytes: Uint8List(800 * 600 * 3),
              labData: const LabColorData(
                L: 58.0,
                a: -18.5,
                b: -42.0,
                deltaE: 52.4,
              ),
              width: 800,
              height: 600,
            );
        return AIResultScreen(calibrationResult: result);
      },
    ),
    GoRoute(
      path: '/evidence-vault',
      name: 'evidence-vault',
      builder: (context, state) {
        final extraMap = state.extra as Map<String, dynamic>?;
        final calibration = extraMap?['calibration'] as PouchCalibrationResult? ??
            PouchCalibrationResult(
              warpedImageBytes: Uint8List(800 * 600 * 3),
              calibratedImageBytes: Uint8List(800 * 600 * 3),
              labData: const LabColorData(
                L: 58.0,
                a: -18.5,
                b: -42.0,
                deltaE: 52.4,
              ),
              width: 800,
              height: 600,
            );

        final result = extraMap?['result'] as DrugClassificationResult? ??
            DrugClassificationResult.fromReagent(
              ReagentType.scott,
              calibration.labData,
            );

        return EvidenceVaultScreen(
          result: result,
          calibrationResult: calibration,
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF000000),
    body: Center(
      child: Text(
        'Navigation Route Error: ${state.error}',
        style: const TextStyle(color: Color(0xFFFF1744)),
      ),
    ),
  ),
);
