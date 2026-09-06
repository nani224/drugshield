import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Telemetry metrics for phone orientation and lighting environment
class SensorTelemetry {
  final double pitchDeg;
  final double rollDeg;
  final double totalTiltDeg;
  final double ambientLux;
  final bool isTiltOk;
  final bool isLuxOk;

  const SensorTelemetry({
    required this.pitchDeg,
    required this.rollDeg,
    required this.totalTiltDeg,
    required this.ambientLux,
    required this.isTiltOk,
    required this.isLuxOk,
  });

  bool get isAlignmentOptimal => isTiltOk && isLuxOk;

  factory SensorTelemetry.initial() => const SensorTelemetry(
        pitchDeg: 0.8,
        rollDeg: 0.5,
        totalTiltDeg: 0.9,
        ambientLux: 420.0,
        isTiltOk: true,
        isLuxOk: true,
      );

  SensorTelemetry copyWith({
    double? pitchDeg,
    double? rollDeg,
    double? totalTiltDeg,
    double? ambientLux,
    bool? isTiltOk,
    bool? isLuxOk,
  }) {
    return SensorTelemetry(
      pitchDeg: pitchDeg ?? this.pitchDeg,
      rollDeg: rollDeg ?? this.rollDeg,
      totalTiltDeg: totalTiltDeg ?? this.totalTiltDeg,
      ambientLux: ambientLux ?? this.ambientLux,
      isTiltOk: isTiltOk ?? this.isTiltOk,
      isLuxOk: isLuxOk ?? this.isLuxOk,
    );
  }
}

/// Service that streams accelerometer and ambient light readings
class SensorService {
  StreamSubscription<AccelerometerEvent>? _accelerometerSub;
  final _telemetryController = StreamController<SensorTelemetry>.broadcast();

  SensorTelemetry _currentTelemetry = SensorTelemetry.initial();
  SensorTelemetry get currentTelemetry => _currentTelemetry;
  Stream<SensorTelemetry> get telemetryStream => _telemetryController.stream;

  void startListening() {
    try {
      _accelerometerSub = accelerometerEventStream().listen(
        (event) {
          // Calculate pitch and roll relative to flat horizontal plane
          // Flat horizontal: X=0, Y=0, Z=9.8
          final norm = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
          if (norm == 0) return;

          final pitch = (asin((event.y / norm).clamp(-1.0, 1.0)) * 180 / pi);
          final roll = (atan2(event.x, event.z) * 180 / pi);
          final totalTilt = sqrt(pitch * pitch + roll * roll);

          final isTiltOk = totalTilt <= 3.0; // Strict planar requirement < 3 deg
          final isLuxOk = _currentTelemetry.ambientLux >= 150.0;

          _currentTelemetry = _currentTelemetry.copyWith(
            pitchDeg: pitch,
            rollDeg: roll,
            totalTiltDeg: totalTilt,
            isTiltOk: isTiltOk,
            isLuxOk: isLuxOk,
          );

          _telemetryController.add(_currentTelemetry);
        },
        onError: (_) {
          // Keep simulated steady reading on error / non-hardware
          _telemetryController.add(_currentTelemetry);
        },
      );
    } catch (_) {
      // Hardware accelerometer not available, emit steady standard telemetry
      _telemetryController.add(_currentTelemetry);
    }
  }

  void updateLux(double lux) {
    _currentTelemetry = _currentTelemetry.copyWith(
      ambientLux: lux,
      isLuxOk: lux >= 150.0,
    );
    _telemetryController.add(_currentTelemetry);
  }

  void stopListening() {
    _accelerometerSub?.cancel();
    _accelerometerSub = null;
  }

  void dispose() {
    stopListening();
    _telemetryController.close();
  }
}

/// Riverpod provider for SensorService
final sensorServiceProvider = Provider<SensorService>((ref) {
  final service = SensorService();
  service.startListening();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Riverpod stream provider for live telemetry updates
final sensorTelemetryStreamProvider = StreamProvider<SensorTelemetry>((ref) {
  final service = ref.watch(sensorServiceProvider);
  return service.telemetryStream;
});
