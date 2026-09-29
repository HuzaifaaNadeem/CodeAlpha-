import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/step_sensor_models.dart';
import '../../data/services/step_sensor_service.dart';
import 'fitness_controller.dart';

class StepSensorState {
  const StepSensorState({
    this.isConnecting = false,
    this.connected = false,
    this.isDemo = false,
    this.status = 'offline',
    this.message = 'Live steps not connected',
    this.lastReading,
  });

  final bool isConnecting;
  final bool connected;
  final bool isDemo;
  final String status;
  final String message;
  final int? lastReading;

  StepSensorState copyWith({
    bool? isConnecting,
    bool? connected,
    bool? isDemo,
    String? status,
    String? message,
    int? lastReading,
  }) {
    return StepSensorState(
      isConnecting: isConnecting ?? this.isConnecting,
      connected: connected ?? this.connected,
      isDemo: isDemo ?? this.isDemo,
      status: status ?? this.status,
      message: message ?? this.message,
      lastReading: lastReading ?? this.lastReading,
    );
  }
}

final stepSensorServiceProvider = Provider<StepSensorService>((ref) {
  final service = StepSensorService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

final stepSensorControllerProvider =
    StateNotifierProvider<StepSensorController, StepSensorState>((ref) {
  return StepSensorController(
    service: ref.watch(stepSensorServiceProvider),
    fitness: ref.read(fitnessControllerProvider.notifier),
  );
});

class StepSensorController extends StateNotifier<StepSensorState> {
  StepSensorController({
    required StepSensorService service,
    required FitnessController fitness,
  })  : _service = service,
        _fitness = fitness,
        super(const StepSensorState());

  final StepSensorService _service;
  final FitnessController _fitness;
  StreamSubscription<StepSensorReading>? _subscription;
  int? _lastPlatformTotal;

  Future<void> connect() async {
    state = state.copyWith(isConnecting: true, message: 'Connecting sensor…');
    final connection = await _service.connect();
    if (!connection.available) {
      state = StepSensorState(
        connected: false,
        isDemo: false,
        status: 'unavailable',
        message: connection.message,
      );
      return;
    }

    await _subscription?.cancel();
    _lastPlatformTotal = null;
    _subscription = _service.readings.listen(
      _handleReading,
      onError: (Object error) {
        state = state.copyWith(
          connected: false,
          isConnecting: false,
          status: 'error',
          message: 'Step sensor interrupted. Tap to reconnect.',
        );
      },
    );

    state = StepSensorState(
      connected: true,
      isDemo: connection.isDemo,
      status: 'connected',
      message: connection.message,
    );
  }

  void _handleReading(StepSensorReading reading) {
    final previous = _lastPlatformTotal;
    _lastPlatformTotal = reading.totalSinceBoot;
    if (previous != null) {
      final delta = reading.totalSinceBoot - previous;
      if (delta > 0 && delta < 500) {
        _fitness.addSteps(delta);
      }
    }
    state = state.copyWith(
      connected: true,
      isConnecting: false,
      status: reading.status,
      lastReading: reading.totalSinceBoot,
    );
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _service.disconnect();
    _lastPlatformTotal = null;
    state = const StepSensorState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
