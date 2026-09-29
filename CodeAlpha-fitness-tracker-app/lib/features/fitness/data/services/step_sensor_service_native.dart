import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import 'step_sensor_models.dart';

class StepSensorService {
  final _readings = StreamController<StepSensorReading>.broadcast();
  StreamSubscription<StepCount>? _stepSubscription;
  StreamSubscription<PedestrianStatus>? _statusSubscription;
  String _status = 'unknown';

  Stream<StepSensorReading> get readings => _readings.stream;

  Future<StepSensorConnection> connect() async {
    await disconnect();

    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return const StepSensorConnection(
        available: false,
        isDemo: false,
        message: 'Live physical step sensors are available on Android and iOS.',
      );
    }

    final permission = await Permission.activityRecognition.request();
    if (!permission.isGranted) {
      return const StepSensorConnection(
        available: false,
        isDemo: false,
        message: 'Motion permission is required for live step tracking.',
      );
    }

    try {
      final statusStream = Pedometer.pedestrianStatusStream;
      final stepStream = Pedometer.stepCountStream;

      _statusSubscription = statusStream.listen(
        (event) => _status = event.status,
        onError: (_) => _status = 'unknown',
      );
      _stepSubscription = stepStream.listen(
        (event) {
          _readings.add(
            StepSensorReading(
              totalSinceBoot: event.steps,
              timestamp: event.timeStamp,
              status: _status,
            ),
          );
        },
        onError: (Object error) => _readings.addError(error),
      );

      return const StepSensorConnection(
        available: true,
        isDemo: false,
        message: 'Phone pedometer connected.',
      );
    } catch (_) {
      return const StepSensorConnection(
        available: false,
        isDemo: false,
        message: 'This device does not expose a compatible step sensor.',
      );
    }
  }

  Future<void> disconnect() async {
    await _stepSubscription?.cancel();
    await _statusSubscription?.cancel();
    _stepSubscription = null;
    _statusSubscription = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _readings.close();
  }
}
