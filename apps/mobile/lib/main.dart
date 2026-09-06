import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';

/// ============================================================================
/// DrugShield — Main Application Entry Point
/// SIH26231: Digital Companion for Field Drug Testing
///
/// A production-grade mobile companion for narcotics field officers.
/// Features:
///   - NDPS Act Section 50 compliant procedural workflow
///   - OpenCV ArUco-based camera calibration (via Dart FFI)
///   - On-device MobileNetV3 INT8 drug classification (Google LiteRT)
///   - Hardware-backed ECDSA evidence signing (StrongBox / Secure Enclave)
///   - Offline-first encrypted storage with blockchain sync
/// ============================================================================

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode — field officers use the app one-handed
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Immersive system UI — maximize camera viewfinder real estate
  SystemChrome.setSystemUIOverlayStyle(const SystemUIOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: DSColors.bgAbyssal,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const DrugShieldApp());
}

class DrugShieldApp extends StatelessWidget {
  const DrugShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DrugShield',
      debugShowCheckedModeBanner: false,
      theme: DSTheme.dark,
      home: const HomeScreen(),
    );
  }
}

/// Temporary home screen — will be replaced by auth flow in Phase 1
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // ── Shield Icon ──
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: DSColors.accentEmerald.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: DSColors.accentEmerald.withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: DSColors.accentEmerald,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ──
              Text('DrugShield', style: DSTypography.headline1),
              const SizedBox(height: 8),
              Text(
                'Digital Companion for Field Drug Testing',
                style: DSTypography.body,
              ),
              const SizedBox(height: 4),
              Text(
                'SIH26231 • Blockchain & Cybersecurity',
                style: DSTypography.monoSmall,
              ),

              const Spacer(),

              // ── System Status Cards ──
              _StatusCard(
                icon: Icons.camera_alt_outlined,
                label: 'Camera & CV Engine',
                status: 'OpenCV ArUco + Homography',
                color: DSColors.hudCyan,
              ),
              const SizedBox(height: 12),
              _StatusCard(
                icon: Icons.psychology_outlined,
                label: 'Edge AI Model',
                status: 'MobileNetV3 INT8 (3.8 MB)',
                color: DSColors.accentAmber,
              ),
              const SizedBox(height: 12),
              _StatusCard(
                icon: Icons.link_outlined,
                label: 'Blockchain Network',
                status: 'Hyperledger Fabric 3.0',
                color: DSColors.accentEmerald,
              ),

              const Spacer(),

              // ── Primary Action ──
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to biometric auth screen
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fingerprint, size: 22),
                    SizedBox(width: 12),
                    Text('AUTHENTICATE & BEGIN'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Version ──
              Center(
                child: Text(
                  'v1.0.0-alpha • NDPS Act Compliant',
                  style: DSTypography.monoSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final Color color;

  const _StatusCard({
    required this.icon,
    required this.label,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DSColors.surfaceCarbon,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DSColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: DSTypography.label),
                const SizedBox(height: 2),
                Text(status, style: DSTypography.monoSmall),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
