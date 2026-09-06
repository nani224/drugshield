import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:native_opencv/native_opencv.dart';
import '../../core/theme.dart';
import '../auth/auth_provider.dart';
import '../ndps_checklist/checklist_model.dart';

class CalibrationPreviewScreen extends ConsumerWidget {
  final PouchCalibrationResult calibrationResult;

  const CalibrationPreviewScreen({
    super.key,
    required this.calibrationResult,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final checklist = ref.watch(ndpsChecklistProvider);
    final lab = calibrationResult.labData;

    return Scaffold(
      backgroundColor: DSColors.bgAbyssal,
      appBar: AppBar(
        title: const Text('Optical Calibration & Lab ROI'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DSColors.textPrimary),
          onPressed: () => context.go('/camera-hud'),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DSColors.accentEmerald.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: DSColors.accentEmerald.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: DSColors.accentEmerald, size: 14),
                const SizedBox(width: 6),
                Text(
                  'CCM NORMALIZED',
                  style: DSTypography.monoSmall.copyWith(
                    color: DSColors.accentEmerald,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Warped Pouch Canvas Container ──
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: DSColors.surfaceCarbon,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DSColors.hudCyan, width: 1.5),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Reagent reaction well visualization
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(0xFF00E5FF),
                                        const Color(0xFF007799),
                                        DSColors.surfaceCarbon,
                                      ],
                                      stops: const [0.0, 0.7, 1.0],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: DSColors.hudCyan.withOpacity(0.3),
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'NORMALIZED 800×600 PLANAR POUCH',
                                  style: DSTypography.monoSmall.copyWith(
                                    color: DSColors.hudCyan,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Text(
                                  'Homography Warp: cv::warpPerspective',
                                  style: DSTypography.monoSmall.copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                          ),

                          // Top-right resolution badge
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: DSColors.bgAbyssal,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: DSColors.surfaceBorder),
                              ),
                              child: Text(
                                '${calibrationResult.width}×${calibrationResult.height} RGB',
                                style: DSTypography.monoSmall.copyWith(fontSize: 9),
                              ),
                            ),
                          ),

                          // Bottom Macbeth strip indicator
                          Positioned(
                            bottom: 8,
                            left: 24,
                            right: 24,
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFFFFF),
                                    Color(0xFFC0C0C0),
                                    Color(0xFF909090),
                                    Color(0xFF606060),
                                    Color(0xFF303030),
                                    Color(0xFF101010),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── CIE L*a*b* Colorimetric Decomposition ──
                    Text(
                      'CIE L*a*b* COLORIMETRIC DECOMPOSITION (D65)',
                      style: DSTypography.label.copyWith(fontSize: 11, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        _LabMetricCard(
                          label: 'L* (Luminance)',
                          value: lab.L.toStringAsFixed(1),
                          unit: '0..100',
                          color: DSColors.textPrimary,
                        ),
                        const SizedBox(width: 8),
                        _LabMetricCard(
                          label: 'a* (Green/Red)',
                          value: lab.a >= 0
                              ? '+${lab.a.toStringAsFixed(1)}'
                              : lab.a.toStringAsFixed(1),
                          unit: '-128..127',
                          color: lab.a >= 0 ? const Color(0xFFFF5252) : const Color(0xFF69F0AE),
                        ),
                        const SizedBox(width: 8),
                        _LabMetricCard(
                          label: 'b* (Blue/Yellow)',
                          value: lab.b >= 0
                              ? '+${lab.b.toStringAsFixed(1)}'
                              : lab.b.toStringAsFixed(1),
                          unit: '-128..127',
                          color: lab.b >= 0 ? const Color(0xFFFFD740) : const Color(0xFF40C4FF),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Euclidean Distance Delta E* Card ──
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: DSColors.surfaceCarbon,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DSColors.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EUCLIDEAN CHROMATICITY DISTANCE (ΔE*)',
                                style: DSTypography.label.copyWith(fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Relative to unreacted baseline reagent well',
                                style: DSTypography.monoSmall.copyWith(fontSize: 10),
                              ),
                            ],
                          ),
                          Text(
                            'ΔE* ${lab.deltaE.toStringAsFixed(2)}',
                            style: DSTypography.mono.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: DSColors.accentEmerald,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Case Procedural Telemetry ──
                    Text(
                      'SEIZURE METADATA & CHAIN OF CUSTODY',
                      style: DSTypography.label.copyWith(fontSize: 11, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: DSColors.surfaceCarbon,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DSColors.surfaceBorder),
                      ),
                      child: Column(
                        children: [
                          _DataRow(label: 'CASE / FIR NUMBER', value: checklist.firNumber),
                          const Divider(height: 16),
                          _DataRow(
                            label: 'SELECTED REAGENT',
                            value: checklist.selectedReagent.displayName,
                          ),
                          const Divider(height: 16),
                          _DataRow(
                            label: 'TARGET CLASS',
                            value: checklist.selectedReagent.targetSubstances,
                          ),
                          const Divider(height: 16),
                          _DataRow(label: 'INVESTIGATING OFFICER', value: authState.badgeId),
                          const Divider(height: 16),
                          _DataRow(
                            label: 'GPS POSITION',
                            value:
                                '${checklist.latitude?.toStringAsFixed(4)}° N, ${checklist.longitude?.toStringAsFixed(4)}° E',
                          ),
                          const Divider(height: 16),
                          _DataRow(
                            label: 'PANCH WITNESSES',
                            value:
                                '${checklist.witness1.name.isNotEmpty ? checklist.witness1.name : "Witness 1"} & ${checklist.witness2.name.isNotEmpty ? checklist.witness2.name : "Witness 2"} (Signed)',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Pinned Bottom CTA ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: DSColors.bgAbyssal,
                border: Border(top: BorderSide(color: DSColors.surfaceBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        context.go('/camera-hud');
                      },
                      child: const Text('RETAKE'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: DSColors.surfaceCarbon,
                            content: Text(
                              'Phase 1 complete! Calibrated CIE Lab: L*=${lab.L.toStringAsFixed(1)}, a*=${lab.a.toStringAsFixed(1)}, b*=${lab.b.toStringAsFixed(1)} (ΔE*=${lab.deltaE.toStringAsFixed(2)}) ready for Phase 2 LiteRT classifier.',
                              style: DSTypography.body.copyWith(
                                color: DSColors.accentEmerald,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text('STAGE 2: READY FOR AI'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _LabMetricCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: DSColors.surfaceCarbon,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: DSColors.surfaceBorder),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: DSTypography.monoSmall.copyWith(fontSize: 10),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: DSTypography.mono.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              unit,
              style: DSTypography.monoSmall.copyWith(fontSize: 9, color: DSColors.textDisabled),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;

  const _DataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: DSTypography.monoSmall.copyWith(fontSize: 10)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: DSTypography.mono.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: DSColors.textPrimary,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
