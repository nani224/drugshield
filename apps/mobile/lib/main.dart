import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
import 'core/theme.dart';

/// ============================================================================
/// DrugShield — Main Application Entry Point
/// SIH26231: Digital Companion for Field Drug Testing
///
/// Production-grade mobile companion for narcotics field officers.
/// Phase 1 Architecture:
///   - Tactical High-Contrast HUD (OLED #000000, Inter + JetBrains Mono)
///   - Hardware KeyStore (StrongBox / Secure Enclave) Biometric Unlock
///   - NDPS Act Section 50 mandatory statutory checklist & panch witnesses
///   - CameraX 1080p60 Cockpit HUD with ArUco fiducial reticle & tilt/lux tracking
///   - Native OpenCV C++ FFI homography planar unskewing & Macbeth CCM CIE L*a*b*
/// ============================================================================

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode — field officers operate the device one-handed
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Immersive system UI — pitch black bars maximizing camera HUD viewport
  SystemChrome.setSystemUIOverlayStyle(const SystemUIOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: DSColors.bgAbyssal,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    const ProviderScope(
      child: DrugShieldApp(),
    ),
  );
}

class DrugShieldApp extends StatelessWidget {
  const DrugShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DrugShield',
      debugShowCheckedModeBanner: false,
      theme: DSTheme.dark,
      routerConfig: appRouter,
    );
  }
}
