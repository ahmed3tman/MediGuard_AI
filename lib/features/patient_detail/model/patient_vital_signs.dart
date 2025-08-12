import 'package:equatable/equatable.dart';
import '../../devices/model/data_model.dart';

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

/// Model for patient vital signs with extended ECG data and device connection status
class PatientVitalSigns extends Equatable {
  final String deviceId;
  final String patientName;
  final double temperature;
  final double heartRate;
  final double respiratoryRate;
  final Map<String, int> bloodPressure;
  final double spo2;
  final DateTime timestamp;
  final List<EcgReading> ecgReadings;
  final bool isDeviceConnected;
  final DateTime? lastDataReceived;

  const PatientVitalSigns({
    required this.deviceId,
    required this.patientName,
    required this.temperature,
    required this.heartRate,
    required this.respiratoryRate,
    required this.bloodPressure,
    required this.spo2,
    required this.timestamp,
    required this.ecgReadings,
    this.isDeviceConnected = false,
    this.lastDataReceived,
  });

  factory PatientVitalSigns.fromDevice(Device device) {
    return PatientVitalSigns(
      deviceId: device.deviceId,
      patientName: device.name,
      temperature: device.temperature,
      heartRate: device.heartRate,
      respiratoryRate: device.respiratoryRate,
      bloodPressure: device.bloodPressure,
      spo2: device.spo2,
      timestamp: device.lastUpdated ?? DateTime.now(),
      ecgReadings: const [], // Will be populated from Firebase
      isDeviceConnected: device.hasRecentData,
      lastDataReceived: device.lastUpdated,
    );
  }

  factory PatientVitalSigns.fromJson(Map<String, dynamic> json) {
    return PatientVitalSigns(
      deviceId: json['deviceId'] ?? '',
      patientName: json['patientName'] ?? '',
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      heartRate: (json['heartRate'] ?? 0.0).toDouble(),
      respiratoryRate: (json['respiratoryRate'] ?? 0.0).toDouble(),
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
      isDeviceConnected: json['isDeviceConnected'] ?? false,
      lastDataReceived: json['lastDataReceived'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastDataReceived'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'patientName': patientName,
      'temperature': temperature,
      'heartRate': heartRate,
      'respiratoryRate': respiratoryRate,
      'bloodPressure': bloodPressure,
      'spo2': spo2,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'ecgReadings': ecgReadings.map((e) => e.toJson()).toList(),
      'isDeviceConnected': isDeviceConnected,
      'lastDataReceived': lastDataReceived?.millisecondsSinceEpoch,
    };
  }

  // Helper methods for health status
  bool get isTemperatureNormal => temperature >= 36.1 && temperature <= 37.2;
  bool get isHeartRateNormal => heartRate >= 60 && heartRate <= 100;
  bool get isRespiratoryRateNormal =>
      respiratoryRate >= 12 && respiratoryRate <= 20;
  bool get isSpo2Normal => spo2 >= 95;
  bool get isBloodPressureNormal {
    return bloodPressure['systolic']! >= 90 &&
        bloodPressure['systolic']! <= 120 &&
        bloodPressure['diastolic']! >= 60 &&
        bloodPressure['diastolic']! <= 80;
  }

  // Device connection status helpers
  bool get hasValidTemperature => temperature > 0;
  bool get hasValidHeartRate => heartRate > 0;
  bool get hasValidRespiratoryRate => respiratoryRate > 0;
  bool get hasValidSpo2 => spo2 > 0;
  bool get hasValidBloodPressure =>
      bloodPressure['systolic']! > 0 && bloodPressure['diastolic']! > 0;

  // يعتبر الجهاز متصل فقط إذا كانت هناك بيانات حديثة وواحدة على الأقل من القيم الحيوية ليست صفر
  bool get isActuallyConnected {
    if (lastDataReceived == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastDataReceived!);
    final hasAnyData =
        hasValidTemperature ||
        hasValidHeartRate ||
        hasValidRespiratoryRate ||
        hasValidSpo2 ||
        hasValidBloodPressure;
    return (difference.inMinutes < 2) && hasAnyData;
  }

  String get connectionStatus {
    if (!isActuallyConnected) return 'غير متصل';
    return 'متصل';
  }

  String get connectionStatusEnglish {
    if (!isActuallyConnected) return 'Disconnected';
    return 'Connected';
  }

  @override
  List<Object?> get props => [
    deviceId,
    patientName,
    temperature,
    heartRate,
    respiratoryRate,
    bloodPressure,
    spo2,
    timestamp,
    ecgReadings,
    isDeviceConnected,
    lastDataReceived,
  ];
}
