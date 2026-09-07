import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ReagentType {
  marquis,
  mecke,
  mandelin,
  scott,
  duquenoisLevine,
}

extension ReagentTypeExt on ReagentType {
  String get displayName {
    switch (this) {
      case ReagentType.marquis:
        return 'Marquis Reagent';
      case ReagentType.mecke:
        return 'Mecke Reagent';
      case ReagentType.mandelin:
        return 'Mandelin Reagent';
      case ReagentType.scott:
        return 'Scott / Cobalt Reagent';
      case ReagentType.duquenoisLevine:
        return 'Duquenois-Levine Reagent';
    }
  }

  String get targetSubstances {
    switch (this) {
      case ReagentType.marquis:
        return 'Opioids / Amphetamines / MDMA';
      case ReagentType.mecke:
        return 'Heroin / Morphine';
      case ReagentType.mandelin:
        return 'Methadone / Amphetamines';
      case ReagentType.scott:
        return 'Cocaine HCl / Crack Cocaine';
      case ReagentType.duquenoisLevine:
        return 'Cannabis / THC / Hashish';
    }
  }

  String get expectedReactionColor {
    switch (this) {
      case ReagentType.marquis:
        return 'Purple to Black (Opioid) / Orange (Amphetamine)';
      case ReagentType.mecke:
        return 'Deep Blue-Green';
      case ReagentType.mandelin:
        return 'Olive Green to Dark Brown';
      case ReagentType.scott:
        return 'Intense Turquoise Blue';
      case ReagentType.duquenoisLevine:
        return 'Violet-Indigo in Chloroform Layer';
    }
  }
}

class PanchWitness {
  final String name;
  final String idNumber;
  final String contact;
  final bool hasSignature;
  final String? signatureHash;

  const PanchWitness({
    this.name = '',
    this.idNumber = '',
    this.contact = '',
    this.hasSignature = false,
    this.signatureHash,
  });

  PanchWitness copyWith({
    String? name,
    String? idNumber,
    String? contact,
    bool? hasSignature,
    String? signatureHash,
  }) {
    return PanchWitness(
      name: name ?? this.name,
      idNumber: idNumber ?? this.idNumber,
      contact: contact ?? this.contact,
      hasSignature: hasSignature ?? this.hasSignature,
      signatureHash: signatureHash ?? this.signatureHash,
    );
  }
}

class NdpsChecklistState {
  final String firNumber;
  final String gdEntryNumber;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final DateTime timestamp;
  final bool isSection50Informed;
  final PanchWitness witness1;
  final PanchWitness witness2;
  final ReagentType selectedReagent;
  final String evidenceSealBarcode;
  final bool isLocatingGps;

  const NdpsChecklistState({
    required this.firNumber,
    required this.gdEntryNumber,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    required this.timestamp,
    required this.isSection50Informed,
    required this.witness1,
    required this.witness2,
    required this.selectedReagent,
    this.evidenceSealBarcode = 'NCB-SEAL-2026-0842',
    this.isLocatingGps = false,
  });

  bool get isMandatoryComplete =>
      firNumber.trim().isNotEmpty &&
      gdEntryNumber.trim().isNotEmpty &&
      isSection50Informed &&
      witness1.hasSignature &&
      witness2.hasSignature;

  factory NdpsChecklistState.initial() => NdpsChecklistState(
        firNumber: 'NDPS/2026/FIR-842',
        gdEntryNumber: 'GD-1904/A',
        latitude: 28.6139,
        longitude: 77.2090,
        accuracyMeters: 3.2,
        timestamp: DateTime.now(),
        isSection50Informed: false,
        witness1: const PanchWitness(name: 'Ramesh Kumar', idNumber: 'AADHAAR-8912-XXXX'),
        witness2: const PanchWitness(name: 'Suresh Patel', idNumber: 'AADHAAR-4401-XXXX'),
        selectedReagent: ReagentType.scott,
        evidenceSealBarcode: 'NCB-SEAL-2026-0842',
      );

  NdpsChecklistState copyWith({
    String? firNumber,
    String? gdEntryNumber,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    DateTime? timestamp,
    bool? isSection50Informed,
    PanchWitness? witness1,
    PanchWitness? witness2,
    ReagentType? selectedReagent,
    String? evidenceSealBarcode,
    bool? isLocatingGps,
  }) {
    return NdpsChecklistState(
      firNumber: firNumber ?? this.firNumber,
      gdEntryNumber: gdEntryNumber ?? this.gdEntryNumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      timestamp: timestamp ?? this.timestamp,
      isSection50Informed: isSection50Informed ?? this.isSection50Informed,
      witness1: witness1 ?? this.witness1,
      witness2: witness2 ?? this.witness2,
      selectedReagent: selectedReagent ?? this.selectedReagent,
      evidenceSealBarcode: evidenceSealBarcode ?? this.evidenceSealBarcode,
      isLocatingGps: isLocatingGps ?? this.isLocatingGps,
    );
  }
}

class NdpsChecklistNotifier extends StateNotifier<NdpsChecklistState> {
  NdpsChecklistNotifier() : super(NdpsChecklistState.initial());

  void setFirNumber(String val) => state = state.copyWith(firNumber: val);
  void setGdEntry(String val) => state = state.copyWith(gdEntryNumber: val);
  void setEvidenceSealBarcode(String val) => state = state.copyWith(evidenceSealBarcode: val);
  void toggleSection50(bool val) => state = state.copyWith(isSection50Informed: val);
  void selectReagent(ReagentType reagent) => state = state.copyWith(selectedReagent: reagent);

  void updateLocation({required double lat, required double lng, required double acc}) {
    state = state.copyWith(
      latitude: lat,
      longitude: lng,
      accuracyMeters: acc,
      isLocatingGps: false,
    );
  }

  void setLocatingGps(bool val) => state = state.copyWith(isLocatingGps: val);

  void updateWitness1(PanchWitness witness) => state = state.copyWith(witness1: witness);
  void updateWitness2(PanchWitness witness) => state = state.copyWith(witness2: witness);
}

final ndpsChecklistProvider =
    StateNotifierProvider<NdpsChecklistNotifier, NdpsChecklistState>((ref) {
  return NdpsChecklistNotifier();
});
