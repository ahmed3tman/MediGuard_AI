import 'package:equatable/equatable.dart';

class CriticalCase extends Equatable {
  final String deviceId;
  final String name;
  final double temperature;
  final double ecg;
  final double spo2;
  final Map<String, int> bloodPressure;
  final DateTime lastUpdated;

  const CriticalCase({
    required this.deviceId,
    required this.name,
    required this.temperature,
    required this.ecg,
    required this.spo2,
    required this.bloodPressure,
    required this.lastUpdated,
  });

  factory CriticalCase.fromJson(Map<String, dynamic> json) {
    return CriticalCase(
      deviceId: json['deviceId'] as String,
      name: json['name'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      ecg: (json['ecg'] as num).toDouble(),
      spo2: (json['spo2'] as num).toDouble(),
      bloodPressure: Map<String, int>.from(json['bloodPressure'] as Map),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'name': name,
    'temperature': temperature,
    'ecg': ecg,
    'spo2': spo2,
    'bloodPressure': bloodPressure,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  bool get isTemperatureNormal => temperature >= 36.5 && temperature <= 37.5;
  bool get isEcgNormal => ecg >= 60 && ecg <= 100;
  bool get isSpo2Normal => spo2 >= 95;
  bool get isBloodPressureNormal {
    final systolic = bloodPressure['systolic']!;
    final diastolic = bloodPressure['diastolic']!;
    return systolic >= 90 &&
        systolic <= 120 &&
        diastolic >= 60 &&
        diastolic <= 80;
  }

  @override
  List<Object?> get props => [
    deviceId,
    name,
    temperature,
    ecg,
    spo2,
    bloodPressure,
    lastUpdated,
  ];
}
