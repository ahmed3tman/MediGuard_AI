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
    if (currentUserId == null) {
      return Stream.value(null);
    }

    return _database.ref('users/$currentUserId/devices/$deviceId').onValue.map((
      event,
    ) {
      final data = event.snapshot.value;
      if (data == null) return null;

      final deviceData = Map<String, dynamic>.from(data as Map);

      // Only use real data from Firebase, no simulation
      return PatientVitalSigns(
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
    });
  }

  /// Listen to real-time ECG readings for chart display
  /// Firebase path: /ecg_data/{deviceId}/readings
  static Stream<List<EcgReading>> getEcgReadingsStream(String deviceId) {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _database
        .ref('ecg_data/$deviceId/readings')
        .limitToLast(50) // Last 50 ECG readings for chart
        .onValue
        .map((event) {
          final data = event.snapshot.value;
          if (data == null) return <EcgReading>[];

          final Map<dynamic, dynamic> readingsMap =
              data as Map<dynamic, dynamic>;
          final List<EcgReading> readings = [];

          readingsMap.forEach((key, value) {
            if (value is Map) {
              try {
                readings.add(
                  EcgReading.fromJson(Map<String, dynamic>.from(value)),
                );
              } catch (e) {
                print('Error parsing ECG reading: $e');
              }
            }
          });

          // Sort by timestamp
          readings.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return readings;
        });
  }

  /// Clean up old ECG data to prevent database bloat
  static Future<void> cleanupOldEcgData(String deviceId) async {
    if (currentUserId == null) return;

    final ecgRef = _database.ref('ecg_data/$deviceId/readings');
    final cutoffTime = DateTime.now().subtract(const Duration(hours: 1));

    // Query for old data and remove it
    final snapshot = await ecgRef
        .orderByChild('timestamp')
        .endBefore(cutoffTime.millisecondsSinceEpoch)
        .get();

    if (snapshot.exists && snapshot.value != null) {
      final oldData = snapshot.value as Map<dynamic, dynamic>;
      for (final key in oldData.keys) {
        await ecgRef.child(key).remove();
      }
    }
  }
}
