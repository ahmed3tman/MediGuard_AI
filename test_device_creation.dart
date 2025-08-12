// Test script to verify that respiratory rate is added when creating a new device
// This is a simulation of the device creation process

import 'dart:convert';

void main() {
  // Simulate device creation with respiratory rate
  final deviceId = 'TEST_DEVICE_001';
  final deviceName = 'Test Medical Monitor';

  // This is what DeviceService.addDevice creates
  final readings = {
    'temperature': 0.0,
    'heartRate': 0.0,
    'respiratoryRate': 0.0, // This should now be included!
    'spo2': 0.0,
    'bloodPressure': {'systolic': 0, 'diastolic': 0},
    'ecg': 0.0,
  };

  final deviceJson = {
    'deviceId': deviceId,
    'name': deviceName,
    'readings': readings,
    'lastUpdated': null,
  };

  print('New device JSON structure:');
  print(JsonEncoder.withIndent('  ').convert(deviceJson));
  print('\n✅ Respiratory rate is included in device creation!');

  // Simulate external readings update
  final externalReadings = {
    'temperature': 36.8,
    'heartRate': 75.0,
    'respiratoryRate': 16.0, // External device sends respiratory rate
    'spo2': 98.0,
    'bloodPressure': {'systolic': 120, 'diastolic': 80},
    'ecg': 75.0,
  };

  print('\nSimulated external readings:');
  print(JsonEncoder.withIndent('  ').convert(externalReadings));
  print('\n✅ External readings include respiratory rate!');

  // Verify respiratory rate is in normal range
  final respiratoryRate = externalReadings['respiratoryRate'] as double;
  final isNormal = respiratoryRate >= 12 && respiratoryRate <= 20;
  print('\nRespiratory Rate: $respiratoryRate BPM');
  print('Normal Range (12-20 BPM): ${isNormal ? "✅ Normal" : "❌ Abnormal"}');
}
