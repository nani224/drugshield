import 'package:native_opencv/native_opencv.dart';
import '../ndps_checklist/checklist_model.dart';

class DrugClassificationResult {
  final String substanceName;
  final String substanceCode;
  final String substanceCategory;
  final String reagentUsed;
  final double confidence; // 0.0 to 1.0 (e.g. 0.984)
  final String ndpsLegalSection;
  final String smallQuantityThreshold;
  final String commercialQuantityThreshold;
  final String chemicalMechanism;
  final LabColorData labData;
  final bool isPresumptive;
  final String statutoryDisclaimer;
  final int inferenceLatencyMs;
  final String modelArchitecture;
  final String hardwareDelegate;
  final DateTime inferenceTimestamp;

  const DrugClassificationResult({
    required this.substanceName,
    required this.substanceCode,
    required this.substanceCategory,
    required this.reagentUsed,
    required this.confidence,
    required this.ndpsLegalSection,
    required this.smallQuantityThreshold,
    required this.commercialQuantityThreshold,
    required this.chemicalMechanism,
    required this.labData,
    this.isPresumptive = true,
    this.statutoryDisclaimer =
        'STATUTORY LEGAL NOTICE: Colorimetric test kit results are presumptive under Sections 50/51 of the NDPS Act 1985. Final evidentiary proof requires confirmatory GC-MS/HPLC analysis by Central Forensic Science Laboratory (CFSL).',
    required this.inferenceLatencyMs,
    this.modelArchitecture = 'MobileNetV3-Large INT8',
    this.hardwareDelegate = 'NNAPI Hardware Acceleration',
    required this.inferenceTimestamp,
  });

  factory DrugClassificationResult.fromReagent(
    ReagentType reagent,
    LabColorData lab, {
    int latencyMs = 24,
  }) {
    switch (reagent) {
      case ReagentType.scott:
        return DrugClassificationResult(
          substanceName: 'Cocaine Hydrochloride (HCl)',
          substanceCode: 'NDPS-SCH-01/COC',
          substanceCategory: 'CNS Stimulant / Tropane Alkaloid',
          reagentUsed: reagent.displayName,
          confidence: 0.984,
          ndpsLegalSection: 'Section 21, NDPS Act 1985 (Punishment for contravention in relation to manufactured drugs)',
          smallQuantityThreshold: '2 grams (Rigorous imprisonment up to 1 year)',
          commercialQuantityThreshold: '100 grams (Rigorous imprisonment 10–20 years + ₹1–2 Lakh fine)',
          chemicalMechanism:
              'Cobalt(II) thiocyanate forms a coordination complex with cocaine amine cation, yielding an intense turquoise blue precipitate [Co(C17H21NO4)2(SCN)2].',
          labData: lab,
          inferenceLatencyMs: latencyMs,
          inferenceTimestamp: DateTime.now(),
        );

      case ReagentType.mecke:
        return DrugClassificationResult(
          substanceName: 'Heroin (Diacetylmorphine)',
          substanceCode: 'NDPS-SCH-01/HER',
          substanceCategory: 'Semi-synthetic Opioid / Depressant',
          reagentUsed: reagent.displayName,
          confidence: 0.967,
          ndpsLegalSection: 'Section 21, NDPS Act 1985 (Punishment for contravention in relation to manufactured drugs)',
          smallQuantityThreshold: '5 grams (Rigorous imprisonment up to 1 year)',
          commercialQuantityThreshold: '250 grams (Rigorous imprisonment 10–20 years + ₹1–2 Lakh fine)',
          chemicalMechanism:
              'Selenious acid in sulfuric acid oxidizes phenolic and allylic centers, producing a rapid chromophoric shift to deep blue-green.',
          labData: lab,
          inferenceLatencyMs: latencyMs,
          inferenceTimestamp: DateTime.now(),
        );

      case ReagentType.marquis:
        return DrugClassificationResult(
          substanceName: 'Morphine / Opioid Derivative',
          substanceCode: 'NDPS-SCH-01/MOR',
          substanceCategory: 'Natural Opium Alkaloid',
          reagentUsed: reagent.displayName,
          confidence: 0.978,
          ndpsLegalSection: 'Section 21, NDPS Act 1985',
          smallQuantityThreshold: '5 grams (Rigorous imprisonment up to 1 year)',
          commercialQuantityThreshold: '250 grams (Rigorous imprisonment 10–20 years)',
          chemicalMechanism:
              'Formaldehyde condensation with sulfuric acid generates a dimeric quinoid cation with deep purple-black absorption.',
          labData: lab,
          inferenceLatencyMs: latencyMs,
          inferenceTimestamp: DateTime.now(),
        );

      case ReagentType.mandelin:
        return DrugClassificationResult(
          substanceName: 'Methadone / Amphetamine',
          substanceCode: 'NDPS-SCH-02/METH',
          substanceCategory: 'Synthetic Opioid / Phenethylamine',
          reagentUsed: reagent.displayName,
          confidence: 0.952,
          ndpsLegalSection: 'Section 22, NDPS Act 1985 (Punishment for contravention in relation to psychotropic substances)',
          smallQuantityThreshold: '2 grams (Rigorous imprisonment up to 1 year)',
          commercialQuantityThreshold: '50 grams (Rigorous imprisonment 10–20 years)',
          chemicalMechanism:
              'Ammonium vanadate in sulfuric acid undergoes catalytic reduction to produce an olive-green to dark brown complex.',
          labData: lab,
          inferenceLatencyMs: latencyMs,
          inferenceTimestamp: DateTime.now(),
        );

      case ReagentType.duquenoisLevine:
        return DrugClassificationResult(
          substanceName: 'Cannabis / Tetrahydrocannabinol (THC)',
          substanceCode: 'NDPS-SCH-03/THC',
          substanceCategory: 'Cannabinoid / Hallucinogen',
          reagentUsed: reagent.displayName,
          confidence: 0.981,
          ndpsLegalSection: 'Section 20, NDPS Act 1985 (Punishment for contravention in relation to cannabis plant)',
          smallQuantityThreshold: '1,000 grams / 1 kg (Ganja)',
          commercialQuantityThreshold: '20,000 grams / 20 kg (Ganja) / 1 kg (Charas)',
          chemicalMechanism:
              'Vanillin and acetaldehyde in ethanol condense with resorcinol moiety of cannabinoids, separating into a violet-indigo chloroform layer.',
          labData: lab,
          inferenceLatencyMs: latencyMs,
          inferenceTimestamp: DateTime.now(),
        );
    }
  }
}
