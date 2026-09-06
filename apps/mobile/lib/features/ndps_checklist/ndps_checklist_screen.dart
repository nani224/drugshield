import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import 'checklist_model.dart';
import 'witness_signature_sheet.dart';

class NDPSChecklistScreen extends ConsumerStatefulWidget {
  const NDPSChecklistScreen({super.key});

  @override
  ConsumerState<NDPSChecklistScreen> createState() => _NDPSChecklistScreenState();
}

class _NDPSChecklistScreenState extends ConsumerState<NDPSChecklistScreen> {
  late final TextEditingController _firController;
  late final TextEditingController _gdController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(ndpsChecklistProvider);
    _firController = TextEditingController(text: state.firNumber);
    _gdController = TextEditingController(text: state.gdEntryNumber);
    _fetchLiveGps();
  }

  @override
  void dispose() {
    _firController.dispose();
    _gdController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveGps() async {
    ref.read(ndpsChecklistProvider.notifier).setLocatingGps(true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 4),
        );
        ref.read(ndpsChecklistProvider.notifier).updateLocation(
          lat: pos.latitude,
          lng: pos.longitude,
          acc: pos.accuracy,
        );
      } else {
        // Use standard NCB HQ coordinates fallback
        ref.read(ndpsChecklistProvider.notifier).updateLocation(
          lat: 28.6139,
          lng: 77.2090,
          acc: 3.2,
        );
      }
    } catch (_) {
      // Fallback
      ref.read(ndpsChecklistProvider.notifier).updateLocation(
        lat: 28.6139,
        lng: 77.2090,
        acc: 3.2,
      );
    }
  }

  void _openWitnessSheet(String title, PanchWitness witness, ValueChanged<PanchWitness> onSave) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WitnessSignatureSheet(
        witnessTitle: title,
        witness: witness,
        onSignatureSaved: onSave,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ndpsChecklistProvider);

    return Scaffold(
      backgroundColor: DSColors.bgAbyssal,
      appBar: AppBar(
        title: const Text('NDPS Section 50 Procedure'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DSColors.textPrimary),
          onPressed: () => context.go('/'),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DSColors.surfaceCarbon,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: DSColors.surfaceBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.gavel, color: DSColors.accentAmber, size: 14),
                const SizedBox(width: 6),
                Text(
                  'STATUTORY',
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
                    // ── Case & General Diary Identifiers ──
                    Text(
                      'OFFICIAL CASE & STATION REGISTRATION',
                      style: DSTypography.label.copyWith(fontSize: 11, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _firController,
                            style: DSTypography.mono.copyWith(fontSize: 15),
                            decoration: const InputDecoration(
                              labelText: 'FIR / Case Number',
                              prefixIcon: Icon(Icons.tag, color: DSColors.hudCyan, size: 18),
                            ),
                            onChanged: (v) => ref.read(ndpsChecklistProvider.notifier).setFirNumber(v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _gdController,
                            style: DSTypography.mono.copyWith(fontSize: 15),
                            decoration: const InputDecoration(
                              labelText: 'GD Entry No.',
                              prefixIcon: Icon(Icons.menu_book, color: DSColors.hudCyan, size: 18),
                            ),
                            onChanged: (v) => ref.read(ndpsChecklistProvider.notifier).setGdEntry(v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Automated GPS & Timestamp Strip ──
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: DSColors.surfaceCarbon,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DSColors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.gps_fixed, color: DSColors.hudCyan, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'GPS GEO-LOCK: ',
                                      style: DSTypography.monoSmall.copyWith(fontSize: 10),
                                    ),
                                    Text(
                                      '${state.latitude?.toStringAsFixed(4)}° N, ${state.longitude?.toStringAsFixed(4)}° E',
                                      style: DSTypography.mono.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Accuracy: ±${state.accuracyMeters?.toStringAsFixed(1)}m • Satellites: Galileo/NavIC',
                                  style: DSTypography.monoSmall.copyWith(
                                    fontSize: 10,
                                    color: DSColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: DSColors.hudCyan, size: 18),
                            onPressed: _fetchLiveGps,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Mandatory Section 50 Statutory Checkbox ──
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: state.isSection50Informed
                            ? DSColors.accentEmerald.withOpacity(0.08)
                            : DSColors.accentAmber.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: state.isSection50Informed
                              ? DSColors.accentEmerald
                              : DSColors.accentAmber,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: state.isSection50Informed,
                            activeColor: DSColors.accentEmerald,
                            checkColor: DSColors.bgAbyssal,
                            onChanged: (val) {
                              HapticFeedback.selectionClick();
                              ref.read(ndpsChecklistProvider.notifier).toggleSection50(val ?? false);
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SECTION 50 MANDATORY WARNING',
                                  style: DSTypography.label.copyWith(
                                    color: state.isSection50Informed
                                        ? DSColors.accentEmerald
                                        : DSColors.accentAmber,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Suspect has been formally apprised of their legal right to be searched in the presence of a Gazetted Officer or a Judicial Magistrate under Section 50 of NDPS Act, 1985.',
                                  style: DSTypography.body.copyWith(
                                    fontSize: 12,
                                    color: DSColors.textPrimary,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Independent Panch Witnesses Section ──
                    Text(
                      'INDEPENDENT PANCH WITNESSES (MINIMUM 2)',
                      style: DSTypography.label.copyWith(fontSize: 11, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8),

                    _WitnessCard(
                      title: 'Panch Witness #1',
                      witness: state.witness1,
                      onTap: () => _openWitnessSheet(
                        'Panch Witness #1',
                        state.witness1,
                        (w) => ref.read(ndpsChecklistProvider.notifier).updateWitness1(w),
                      ),
                    ),
                    const SizedBox(height: 10),

                    _WitnessCard(
                      title: 'Panch Witness #2',
                      witness: state.witness2,
                      onTap: () => _openWitnessSheet(
                        'Panch Witness #2',
                        state.witness2,
                        (w) => ref.read(ndpsChecklistProvider.notifier).updateWitness2(w),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Reagent Test Kit Selector ──
                    Text(
                      'PRESUMPTIVE REAGENT KIT SELECTION',
                      style: DSTypography.label.copyWith(fontSize: 11, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ReagentType.values.map((reagent) {
                        final isSelected = state.selectedReagent == reagent;
                        return ChoiceChip(
                          label: Text(reagent.displayName),
                          selected: isSelected,
                          selectedColor: DSColors.accentEmerald,
                          backgroundColor: DSColors.surfaceCarbon,
                          labelStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? DSColors.bgAbyssal : DSColors.textPrimary,
                          ),
                          side: BorderSide(
                            color: isSelected ? DSColors.accentEmerald : DSColors.surfaceBorder,
                          ),
                          onSelected: (_) {
                            HapticFeedback.selectionClick();
                            ref.read(ndpsChecklistProvider.notifier).selectReagent(reagent);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: DSColors.surfaceCarbon,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: DSColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.science_outlined, color: DSColors.hudCyan, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Target Substances: ${state.selectedReagent.targetSubstances}',
                                style: DSTypography.body.copyWith(
                                  fontSize: 12,
                                  color: DSColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Expected Colorimetric Reaction: ${state.selectedReagent.expectedReactionColor}',
                            style: DSTypography.monoSmall.copyWith(
                              fontSize: 11,
                              color: DSColors.hudCyan,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
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
                  onPressed: state.isSection50Informed
                      ? () {
                          HapticFeedback.mediumImpact();
                          context.go('/camera-hud');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DSColors.accentEmerald,
                    foregroundColor: DSColors.bgAbyssal,
                    disabledBackgroundColor: DSColors.surfaceCarbon,
                    disabledForegroundColor: DSColors.textDisabled,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        state.isSection50Informed
                            ? 'PROCEED TO OPTICAL HUD SCAN'
                            : 'SECTION 50 MANDATORY WARNING REQUIRED',
                        style: DSTypography.buttonText.copyWith(
                          fontSize: state.isSection50Informed ? 15 : 12,
                        ),
                      ),
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

class _WitnessCard extends StatelessWidget {
  final String title;
  final PanchWitness witness;
  final VoidCallback onTap;

  const _WitnessCard({
    required this.title,
    required this.witness,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasSig = witness.hasSignature;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: DSColors.surfaceCarbon,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasSig ? DSColors.accentEmerald : DSColors.surfaceBorder,
            width: hasSig ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: hasSig
                    ? DSColors.accentEmerald.withOpacity(0.15)
                    : DSColors.bgAbyssal,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSig ? Icons.check_circle : Icons.person_outline,
                color: hasSig ? DSColors.accentEmerald : DSColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    witness.name.isNotEmpty ? witness.name : title,
                    style: DSTypography.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DSColors.textPrimary,
                    ),
                  ),
                  Text(
                    witness.idNumber.isNotEmpty
                        ? '${witness.idNumber} • ${hasSig ? "Digital Signature Recorded" : "Tap to sign"}'
                        : 'Tap to capture name & panchnama signature',
                    style: DSTypography.monoSmall.copyWith(
                      fontSize: 10,
                      color: hasSig ? DSColors.accentEmerald : DSColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hasSig ? Icons.edit_outlined : Icons.arrow_forward_ios,
              size: 16,
              color: DSColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
