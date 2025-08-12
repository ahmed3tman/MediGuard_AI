import 'package:equatable/equatable.dart';

class CriticalCase extends Equatable {
  CriticalCase copyWith({
    String? deviceId,
    String? name,
    double? temperature,
    double? heartRate,
    double? respiratoryRate,
    List<double>? ecgData,
    double? spo2,
    Map<String, int>? bloodPressure,
    DateTime? lastUpdated,
  }) {
    return CriticalCase(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      temperature: temperature ?? this.temperature,
      heartRate: heartRate ?? this.heartRate,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      ecgData: ecgData ?? this.ecgData,
      spo2: spo2 ?? this.spo2,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  final String deviceId;
  final String name;
  final double temperature;
  final double heartRate;
  final double respiratoryRate;
  final List<double> ecgData;
  final double spo2;
  final Map<String, int> bloodPressure;
  final DateTime lastUpdated;

  const CriticalCase({
    required this.deviceId,
    required this.name,
    required this.temperature,
    required this.heartRate,
    required this.respiratoryRate,
    required this.ecgData,
    required this.spo2,
    required this.bloodPressure,
    required this.lastUpdated,
  });

  factory CriticalCase.fromJson(Map<String, dynamic> json) {
    return CriticalCase(
      deviceId: json['deviceId'] as String,
      name: json['name'] as String,
      temperature: (json['temperature'] is num ? json['temperature'] : 0.0)
          .toDouble(),
      heartRate: (json['heartRate'] is num ? json['heartRate'] : 0.0)
          .toDouble(),
      respiratoryRate:
          (json['respiratoryRate'] is num ? json['respiratoryRate'] : 0.0)
              .toDouble(),
      ecgData:
          (json['ecgData'] as List?)
              ?.where((e) => e != null)
              .map((e) => (e as num).toDouble())
              .toList() ??
          <double>[],
      spo2: (json['spo2'] is num ? json['spo2'] : 0.0).toDouble(),
      bloodPressure: Map<String, int>.from(
        json['bloodPressure'] as Map? ?? {'systolic': 0, 'diastolic': 0},
      ),
      lastUpdated:
          DateTime.tryParse(json['lastUpdated'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'name': name,
    'temperature': temperature,
    'heartRate': heartRate,
    'respiratoryRate': respiratoryRate,
    'ecgData': ecgData,
    'spo2': spo2,
    'bloodPressure': bloodPressure,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  bool get isTemperatureNormal => temperature >= 36.5 && temperature <= 37.5;
  bool get isHeartRateNormal => heartRate >= 60 && heartRate <= 100;
  bool get isRespiratoryRateNormal =>
      respiratoryRate >= 12 && respiratoryRate <= 20;
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
    heartRate,
    respiratoryRate,
    ecgData,
    spo2,
    bloodPressure,
    lastUpdated,
  ];
}
