import 'package:equatable/equatable.dart';

class Device extends Equatable {
  final String deviceId;
  final String name;
  // Readings map containing temperature, heart rate, ECG data, SPO2, and blood pressure
  final Map<String, dynamic> readings;
  final DateTime? lastUpdated;

  const Device({
    required this.deviceId,
    required this.name,
    required this.readings,
    this.lastUpdated,
  });

  // Convert from JSON to Object
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['deviceId'] ?? '',
      name: json['name'] ?? '',
      readings: Map<String, dynamic>.from(
        json['readings'] ??
            {
              'temperature': 0.0, // Temperature in Celsius
              'heartRate': 0.0, // Heart Rate (BPM)
              'respiratoryRate': 0.0, // Respiratory Rate (BPM)
              'ecgData': 0.0, // ECG waveform data
              'spo2': 0.0, // Oxygen saturation percentage
              'bloodPressure': {
                // Blood pressure values
                'systolic': 0, // Systolic in mmHg
                'diastolic': 0, // Diastolic in mmHg
              },
            },
      ),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastUpdated'])
          : null,
    );
  }

  // Convert from Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'name': name,
      'readings': readings,
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
    };
  }

  // Helper getters for easier access to readings
  double get temperature => (readings['temperature'] ?? 0.0).toDouble();
  double get heartRate => (readings['heartRate'] ?? 0.0).toDouble();
  double get respiratoryRate => (readings['respiratoryRate'] ?? 0.0).toDouble();
  double get ecgData {
    final value = readings['ecgData'];
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  double get spo2 => (readings['spo2'] ?? 0.0).toDouble();

  Map<String, int> get bloodPressure {
    final bp = readings['bloodPressure'];
    if (bp is Map) {
      return {
        'systolic': (bp['systolic'] ?? 0).toInt(),
        'diastolic': (bp['diastolic'] ?? 0).toInt(),
      };
    }
    return {'systolic': 0, 'diastolic': 0};
  }

  // Helper methods to check if readings are normal
  bool get isTemperatureNormal => temperature >= 36.1 && temperature <= 37.2;
  bool get isRespiratoryRateNormal =>
      respiratoryRate >= 12 && respiratoryRate <= 20;
  bool get isSpo2Normal => spo2 >= 95;
  bool get isBloodPressureNormal {
    final bp = bloodPressure;
    return bp['systolic']! >= 90 &&
        bp['systolic']! <= 120 &&
        bp['diastolic']! >= 60 &&
        bp['diastolic']! <= 80;
  }

  // Check if device has recent data (within last 5 minutes)
  bool get hasRecentData {
    if (lastUpdated == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastUpdated!);
    return difference.inMinutes < 5;
  }

  // Check if device is completely disconnected (no data for over 10 minutes)
  bool get isDisconnected {
    if (lastUpdated == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastUpdated!);
    return difference.inMinutes > 10;
  }

  // Get connection status as string
  String get connectionStatus {
    if (isDisconnected) return 'Not Connected';
    if (hasRecentData) return 'Connected';
    return 'Connection Issues';
  }

  // Check if readings are valid (not zero values)
  bool get hasValidReadings =>
      temperature > 0 ||
      heartRate > 0 ||
      respiratoryRate > 0 ||
      spo2 > 0 ||
      bloodPressure['systolic']! > 0 ||
      bloodPressure['diastolic']! > 0;

  // Copy with method for state management
  Device copyWith({
    String? deviceId,
    String? name,
    Map<String, dynamic>? readings,
    DateTime? lastUpdated,
    bool forceLastUpdated = false,
  }) {
    return Device(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      readings: readings ?? this.readings,
      lastUpdated: forceLastUpdated
          ? lastUpdated
          : (lastUpdated ?? this.lastUpdated),
    );
  }

  @override
  List<Object?> get props => [deviceId, name, readings, lastUpdated];
}
