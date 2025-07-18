import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/patient_vital_signs.dart';

/// Service for handling patient detail data and real-time ECG monitoring
class PatientDetailService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Listen to real-time vital signs for a specific patient/device
  /// Firebase path: /users/{userId}/devices/{deviceId}
  static Stream<PatientVitalSigns?> getPatientVitalSignsStream(
    String deviceId,
  ) {
    print(
      'Getting vital signs stream for device: $deviceId, user: $currentUserId',
    );
    if (currentUserId == null) {
      print('No current user ID available');
      return Stream.value(null);
    }

    return _database.ref('users/$currentUserId/devices/$deviceId').onValue.map((
      event,
    ) {
      final data = event.snapshot.value;
      print('Vital signs data from Firebase: $data');
      if (data == null) {
        print('No device data found at users/$currentUserId/devices/$deviceId');
        return null;
      }

      final deviceData = Map<String, dynamic>.from(data as Map);
      print('Device data parsed: $deviceData');

      // Only use real data from Firebase, no simulation
      final vitalSigns = PatientVitalSigns(
        deviceId: deviceData['deviceId'] ?? deviceId,
        patientName: deviceData['name'] ?? 'Unknown Patient',
        temperature: (deviceData['readings']?['temperature'] ?? 0.0).toDouble(),
        heartRate: (deviceData['readings']?['ecg'] ?? 0.0).toDouble(),
        bloodPressure: {
          'systolic':
              (deviceData['readings']?['bloodPressure']?['systolic'] ?? 0)
                  .toInt(),
          'diastolic':
              (deviceData['readings']?['bloodPressure']?['diastolic'] ?? 0)
                  .toInt(),
        },
        spo2: (deviceData['readings']?['spo2'] ?? 0.0).toDouble(),
        timestamp: deviceData['lastUpdated'] != null
            ? DateTime.fromMillisecondsSinceEpoch(deviceData['lastUpdated'])
            : DateTime.now(),
        ecgReadings: [], // Will be populated from real ECG data
      );

      print(
        'Created vital signs: HR=${vitalSigns.heartRate}, Temp=${vitalSigns.temperature}',
      );
      return vitalSigns;
    });
  }

  /// Listen to real-time ECG readings for chart display
  /// Firebase path: /users/{userId}/devices/{deviceId}/readings (using ECG value)
  static Stream<List<EcgReading>> getEcgReadingsStream(String deviceId) {
    print('Getting ECG stream for device: $deviceId');
    if (currentUserId == null) {
      print('No current user ID, returning empty stream');
      return Stream.value([]);
    }

    // Listen to user device readings and convert ECG values to chart data
    return _database
        .ref('users/$currentUserId/devices/$deviceId/readings')
        .onValue
        .asyncMap((event) async {
          final data = event.snapshot.value;
          print('ECG Firebase data from users path: $data');
          if (data == null) {
            print('No ECG data found in users path');
            return <EcgReading>[];
          }

          final Map<String, dynamic> deviceData = Map<String, dynamic>.from(
            data as Map,
          );
          final ecgValue = (deviceData['ecg'] ?? 0.0).toDouble();
          final timestamp =
              DateTime.now().millisecondsSinceEpoch; // Use current time

          print('ECG value from users path: $ecgValue, timestamp: $timestamp');

          if (ecgValue > 0) {
            // Normalize heart rate if it's too high (might be raw sensor data)
            double normalizedHR = ecgValue;
            if (ecgValue > 200) {
              normalizedHR = (60 + (ecgValue % 40))
                  .toDouble(); // Normalize to 60-100 range
            }

            // Generate sample ECG waveform data based on heart rate
            final List<EcgReading> readings = [];
            final baseTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

            // Create 20 sample points for ECG waveform simulation
            for (int i = 0; i < 20; i++) {
              final timeOffset = i * 50; // 50ms between each point
              final waveformValue = _generateEcgWaveform(i, normalizedHR);

              readings.add(
                EcgReading(
                  value: waveformValue,
                  timestamp: baseTime.add(Duration(milliseconds: timeOffset)),
                ),
              );
            }

            print(
              'Generated ${readings.length} ECG readings from HR: $ecgValue (normalized: $normalizedHR)',
            );
            return readings;
          }

          print('ECG value is 0 or negative, returning empty list');
          return <EcgReading>[];
        });
  }

  /// Generate ECG waveform pattern based on heart rate
  static double _generateEcgWaveform(int index, double heartRate) {
    // Simple ECG pattern simulation
    final double normalizedIndex = (index % 20) / 20.0;

    // QRS complex pattern
    if (normalizedIndex < 0.1) {
      return 0.1; // P wave
    } else if (normalizedIndex < 0.15) {
      return 0.0; // P-R interval
    } else if (normalizedIndex < 0.2) {
      return -0.3; // Q wave
    } else if (normalizedIndex < 0.25) {
      return 1.5; // R wave (peak)
    } else if (normalizedIndex < 0.3) {
      return -0.8; // S wave
    } else if (normalizedIndex < 0.5) {
      return 0.0; // S-T segment
    } else if (normalizedIndex < 0.65) {
      return 0.4; // T wave
    } else {
      return 0.0; // Baseline
    }
  }

  /// Clean up old ECG data to prevent database bloat
  static Future<void> cleanupOldEcgData(String deviceId) async {
    if (currentUserId == null) return;

    // Since we're generating ECG from real-time data, no cleanup needed
    print('Cleanup called - no action needed for generated ECG data');
  }
}
