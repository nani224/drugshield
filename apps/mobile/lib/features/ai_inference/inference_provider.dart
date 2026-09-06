import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:native_opencv/native_opencv.dart';
import '../ndps_checklist/checklist_model.dart';
import 'inference_service.dart';
import 'prediction_model.dart';

class InferenceState {
  final bool isLoading;
  final DrugClassificationResult? result;
  final String? error;

  const InferenceState({
    required this.isLoading,
    this.result,
    this.error,
  });

  factory InferenceState.initial() => const InferenceState(
        isLoading: false,
        result: null,
      );

  InferenceState copyWith({
    bool? isLoading,
    DrugClassificationResult? result,
    String? error,
  }) {
    return InferenceState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error,
    );
  }
}

class InferenceNotifier extends StateNotifier<InferenceState> {
  final InferenceService _service = InferenceService();

  InferenceNotifier() : super(InferenceState.initial()) {
    _service.loadModel();
  }

  Future<DrugClassificationResult> runInference({
    required PouchCalibrationResult calibrationResult,
    required ReagentType selectedReagent,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final res = await _service.classifyCalibratedPouch(
        calibratedImageBytes: calibrationResult.calibratedImageBytes,
        labData: calibrationResult.labData,
        selectedReagent: selectedReagent,
      );

      state = state.copyWith(
        isLoading: false,
        result: res,
      );

      return res;
    } catch (e) {
      final fallback = DrugClassificationResult.fromReagent(
        selectedReagent,
        calibrationResult.labData,
      );

      state = state.copyWith(
        isLoading: false,
        result: fallback,
      );

      return fallback;
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

final inferenceProvider =
    StateNotifierProvider<InferenceNotifier, InferenceState>((ref) {
  return InferenceNotifier();
});
