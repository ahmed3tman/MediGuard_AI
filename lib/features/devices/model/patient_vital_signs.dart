import 'package:equatable/equatable.dart';
import 'data_model.dart';

/// Model for ECG data points
class EcgReading extends Equatable {
  final double value;
  final DateTime timestamp;

  const EcgReading({required this.value, required this.timestamp});

  factory EcgReading.fromJson(Map<String, dynamic> json) {
    return EcgReading(
      value: (json['value'] ?? 0.0).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'timestamp': timestamp.millisecondsSinceEpoch};
  }

  @override
  List<Object?> get props => [value, timestamp];
}

/// Model for patient vital signs with extended ECG data
class PatientVitalSigns extends Equatable {
  final String deviceId;
  final String patientName;
  final double temperature;
  final double heartRate;
  final Map<String, int> bloodPressure;
  final double spo2;
  final DateTime timestamp;
  final List<EcgReading> ecgReadings;

  const PatientVitalSigns({
    required this.deviceId,
    required this.patientName,
    required this.temperature,
    required this.heartRate,
    required this.bloodPressure,
    required this.spo2,
    required this.timestamp,
    required this.ecgReadings,
  });

  factory PatientVitalSigns.fromDevice(Device device) {
    return PatientVitalSigns(
      deviceId: device.deviceId,
      patientName: device.name,
      temperature: device.temperature,
      heartRate: device.ecg,
      bloodPressure: device.bloodPressure,
      spo2: device.spo2,
      timestamp: device.lastUpdated ?? DateTime.now(),
      ecgReadings: const [], // Will be populated from Firebase
    );
  }

  factory PatientVitalSigns.fromJson(Map<String, dynamic> json) {
    return PatientVitalSigns(
      deviceId: json['deviceId'] ?? '',
      patientName: json['patientName'] ?? '',
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      heartRate: (json['heartRate'] ?? 0.0).toDouble(),
      bloodPressure: {
        'systolic': (json['bloodPressure']?['systolic'] ?? 0).toInt(),
        'diastolic': (json['bloodPressure']?['diastolic'] ?? 0).toInt(),
      },
      spo2: (json['spo2'] ?? 0.0).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      ecgReadings:
          (json['ecgReadings'] as List?)
              ?.map((e) => EcgReading.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'patientName': patientName,
      'temperature': temperature,
      'heartRate': heartRate,
      'bloodPressure': bloodPressure,
      'spo2': spo2,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'ecgReadings': ecgReadings.map((e) => e.toJson()).toList(),
    };
  }

  // Helper methods for health status
  bool get isTemperatureNormal => temperature >= 36.1 && temperature <= 37.2;
  bool get isHeartRateNormal => heartRate >= 60 && heartRate <= 100;
  bool get isSpo2Normal => spo2 >= 95;
  bool get isBloodPressureNormal {
    return bloodPressure['systolic']! >= 90 &&
        bloodPressure['systolic']! <= 120 &&
        bloodPressure['diastolic']! >= 60 &&
        bloodPressure['diastolic']! <= 80;
  }

  @override
  List<Object?> get props => [
    deviceId,
    patientName,
    temperature,
    heartRate,
    bloodPressure,
    spo2,
    timestamp,
    ecgReadings,
  ];
}
