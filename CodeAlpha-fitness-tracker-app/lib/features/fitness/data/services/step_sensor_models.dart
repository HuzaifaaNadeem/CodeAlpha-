class StepSensorReading {
  const StepSensorReading({
    required this.totalSinceBoot,
    required this.timestamp,
    required this.status,
  });

  final int totalSinceBoot;
  final DateTime timestamp;
  final String status;
}

class StepSensorConnection {
  const StepSensorConnection({
    required this.available,
    required this.isDemo,
    required this.message,
  });

  final bool available;
  final bool isDemo;
  final String message;
}
