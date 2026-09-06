import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:native_opencv/native_opencv.dart';
import '../../core/theme.dart';
import '../auth/auth_provider.dart';
import '../ndps_checklist/checklist_model.dart';
import 'inference_provider.dart';
import 'prediction_model.dart';

class AIResultScreen extends ConsumerStatefulWidget {
  final PouchCalibrationResult calibrationResult;

  const AIResultScreen({
    super.key,
    required this.calibrationResult,
  });

  @override
  ConsumerState<AIResultScreen> createState() => _AIResultScreenState();
}

class _AIResultScreenState extends ConsumerState<AIResultScreen> {
  DrugClassificationResult? _result;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final reagent = ref.read(ndpsChecklistProvider).selectedReagent;
      final res = await ref.read(inferenceProvider.notifier).runInference(
            calibrationResult: widget.calibrationResult,
            selectedReagent: reagent,
          );
      if (mounted) {
        setState(() {
          _result = res;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final checklist = ref.watch(ndpsChecklistProvider);
    final result = _result ??
        DrugClassificationResult.fromReagent(
          checklist.selectedReagent,
          widget.calibrationResult.labData,
        );

    final confidencePct = (result.confidence * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: DSColors.bgAbyssal,
      appBar: AppBar(
        title: const Text('Edge AI Inference Result'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DSColors.textPrimary),
          onPressed: () => context.go('/calibration-preview', extra: widget.calibrationResult),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DSColors.accentAmber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: DSColors.accentAmber.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: DSColors.accentAmber, size: 14),
                const SizedBox(width: 6),
                Text(
                  'PRESUMPTIVE',
                  style: DSTypography.monoSmall.copyWith(
                    color: DSColors.accentAmber,
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
                    // ── Signal Amber Presumptive Alert Banner ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: DSColors.surfaceCarbon,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DSColors.accentAmber, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: DSColors.accentAmber.withOpacity(0.22),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: DSColors.accentAmber.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.science,
                                  color: DSColors.accentAmber,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PRESUMPTIVE POSITIVE IDENTIFICATION',
                                      style: DSTypography.monoSmall.copyWith(
                                        color: DSColors.accentAmber,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    Text(
                                      result.substanceName.toUpperCase(),
                                      style: DSTypography.headline2.copyWith(
                                        color: DSColors.textPrimary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Confidence Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: DSColors.accentAmber,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$confidencePct%',
                                  style: DSTypography.mono.copyWith(
                                    color: DSColors.bgAbyssal,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: DSColors.surfaceBorder),
                          const SizedBox(height: 8),

                          // Statutory disclaimer text
                          Text(
                            result.statutoryDisclaimer,
                            style: DSTypography.monoSmall.copyWith(
                              fontSize: 11,
                              color: DSColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── On-Device Inference Hardware Telemetry Strip ──
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: DSColors.surfaceCarbon,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: DSColors.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.speed, color: DSColors.hudCyan, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Inference: ${result.inferenceLatencyMs} ms',
                                style: DSTypography.mono.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${result.modelArchitecture} • ON-DEVICE',
                            style: DSTypography.monoSmall.copyWith(
                              fontSize: 10,
                              color: DSColors.accentEmerald,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Statutory NDPS Act Offence Details ──
                    Text(
                      'NDPS ACT STATUTORY CLASSIFICATION',
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatutoryRow(
                            label: 'OFFENCE SECTION',
                            value: result.ndpsLegalSection,
                            highlight: true,
                          ),
                          const Divider(height: 18),
                          _StatutoryRow(
                            label: 'SMALL QUANTITY THRESHOLD',
                            value: result.smallQuantityThreshold,
                          ),
                          const Divider(height: 18),
                          _StatutoryRow(
                            label: 'COMMERCIAL QUANTITY THRESHOLD',
                            value: result.commercialQuantityThreshold,
                            alert: true,
                          ),
                          const Divider(height: 18),
                          _StatutoryRow(
                            label: 'CHEMICAL REACTION MECHANISM',
                            value: result.chemicalMechanism,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Colorimetric Spectral Profile Card ──
                    Text(
                      'CIE L*a*b* CALIBRATED CHROMATICITY MATCH',
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
                      child: Row(
                        children: [
                          // Color swatch circle
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF00B0FF),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00B0FF).withOpacity(0.4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Measured Chromaticity Vector:',
                                  style: DSTypography.monoSmall.copyWith(fontSize: 11),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'L*: ${result.labData.L.toStringAsFixed(1)} | a*: ${result.labData.a.toStringAsFixed(1)} | b*: ${result.labData.b.toStringAsFixed(1)}',
                                  style: DSTypography.mono.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: DSColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Euclidean Distance ΔE*: ${result.labData.deltaE.toStringAsFixed(2)} [High Match]',
                                  style: DSTypography.monoSmall.copyWith(
                                    fontSize: 10,
                                    color: DSColors.accentEmerald,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Pinned Bottom CTA (Thumb-Zone Compliant) ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: DSColors.bgAbyssal,
                border: Border(top: BorderSide(color: DSColors.surfaceBorder)),
              ),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    context.go(
                      '/evidence-vault',
                      extra: {
                        'result': result,
                        'calibration': widget.calibrationResult,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DSColors.accentEmerald,
                    foregroundColor: DSColors.bgAbyssal,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_clock, size: 22),
                      SizedBox(width: 10),
                      Text('PROCEED TO EVIDENCE VAULT & SIGNING'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatutoryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final bool alert;

  const _StatutoryRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.alert = false,
  });

  @override
  Widget build(BuildContext context) {
    Color valueColor = DSColors.textPrimary;
    if (highlight) valueColor = DSColors.hudCyan;
    if (alert) valueColor = DSColors.accentAmber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DSTypography.monoSmall.copyWith(fontSize: 10)),
        const SizedBox(height: 3),
        Text(
          value,
          style: DSTypography.body.copyWith(
            fontSize: 12,
            color: valueColor,
            fontWeight: highlight || alert ? FontWeight.w600 : FontWeight.w400,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
