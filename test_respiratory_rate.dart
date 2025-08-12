// Test file to verify respiratory rate implementation

import 'package:flutter_test/flutter_test.dart';
import 'lib/features/devices/model/data_model.dart';
import 'lib/features/patient_detail/model/patient_vital_signs.dart';

void main() {
  group('Respiratory Rate Tests', () {
    test('Device model should include respiratory rate', () {
      final readings = {
        'temperature': 36.8,
        'heartRate': 75.0,
        'respiratoryRate': 16.0,
        'spo2': 98.0,
        'bloodPressure': {'systolic': 120, 'diastolic': 80},
        'ecg': 75.0,
      };

      final device = Device(
        deviceId: 'TEST001',
        name: 'Test Device',
        readings: readings,
        lastUpdated: DateTime.now(),
      );

      expect(device.respiratoryRate, 16.0);
      expect(device.isRespiratoryRateNormal, true); // 16 is within 12-20 range
    });

    test('PatientVitalSigns should include respiratory rate', () {
      final vitalSigns = PatientVitalSigns(
        deviceId: 'TEST001',
        patientName: 'Test Patient',
        temperature: 36.8,
        heartRate: 75.0,
        respiratoryRate: 16.0,
        bloodPressure: {'systolic': 120, 'diastolic': 80},
        spo2: 98.0,
        timestamp: DateTime.now(),
        ecgReadings: [],
      );

      expect(vitalSigns.respiratoryRate, 16.0);
      expect(vitalSigns.isRespiratoryRateNormal, true);
      expect(vitalSigns.hasValidRespiratoryRate, true);
    });

    test('Respiratory rate normal range validation', () {
      // Test low respiratory rate
      final lowRateDevice = Device(
        deviceId: 'TEST001',
        name: 'Test Device',
        readings: {'respiratoryRate': 10.0},
        lastUpdated: DateTime.now(),
      );
      expect(lowRateDevice.isRespiratoryRateNormal, false);

      // Test normal respiratory rate
      final normalRateDevice = Device(
        deviceId: 'TEST001',
        name: 'Test Device',
        readings: {'respiratoryRate': 16.0},
        lastUpdated: DateTime.now(),
      );
      expect(normalRateDevice.isRespiratoryRateNormal, true);

      // Test high respiratory rate
      final highRateDevice = Device(
        deviceId: 'TEST001',
        name: 'Test Device',
        readings: {'respiratoryRate': 25.0},
        lastUpdated: DateTime.now(),
      );
      expect(highRateDevice.isRespiratoryRateNormal, false);
    });
  });
}
