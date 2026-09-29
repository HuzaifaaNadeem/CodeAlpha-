import 'dart:async';

import 'step_sensor_models.dart';

class StepSensorService {
  final _readings = StreamController<StepSensorReading>.broadcast();
  Timer? _demoTimer;
  int _demoTotal = 5000;

  Stream<StepSensorReading> get readings => _readings.stream;

  Future<StepSensorConnection> connect() async {
    await disconnect();
    _demoTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _demoTotal += 4;
      _readings.add(
        StepSensorReading(
          totalSinceBoot: _demoTotal,
          timestamp: DateTime.now(),
          status: 'walking',
        ),
      );
    });
    return const StepSensorConnection(
      available: true,
      isDemo: true,
      message:
          'Browser demo connected. Android/iOS uses the physical pedometer.',
    );
  }

  Future<void> disconnect() async {
    _demoTimer?.cancel();
    _demoTimer = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _readings.close();
  }
}
