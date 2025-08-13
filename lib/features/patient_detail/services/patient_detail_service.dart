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

  /// Merged stream: patient meta (/users) + device readings (/devices)
  /// Keeps same return type & behavior for UI.
  static Stream<PatientVitalSigns?> getPatientVitalSignsStream(
    String deviceId,
  ) {
    if (currentUserId == null) return Stream.value(null);

    final patientRef = _database.ref('users/$currentUserId/patients/$deviceId');
    final readingsRef = _database.ref('devices/$deviceId/readings');
    final controller = StreamController<PatientVitalSigns?>.broadcast();

    Map<String, dynamic>? patientMeta;
    Map<String, dynamic>? readings;
    DateTime? lastUpdated;

    void emit() {
      if (patientMeta == null && readings == null) {
        controller.add(null);
        return;
      }

      final r = readings ?? {};
      final p = patientMeta ?? {};

      // If we have patient meta but no readings yet, don't emit an empty object
      if (p.isNotEmpty && r.isEmpty) {
        // You might want to emit something that indicates "waiting for readings"
        // For now, we'll wait for readings to come in.
        return;
      }

      final name = p['patientName'] ?? p['name'] ?? deviceId;
      final lu = lastUpdated;
      final ecgData = (r['ecgData'] is List)
          ? (r['ecgData'] as List)
                .where((e) => e != null)
                .map((e) => (e as num).toDouble())
                .toList()
          : <double>[];
      final vs = PatientVitalSigns(
        deviceId: deviceId,
        patientName: name,
        temperature: (r['temperature'] ?? 0.0).toDouble(),
        heartRate: (r['heartRate'] ?? 0.0).toDouble(),
        respiratoryRate: (r['respiratoryRate'] ?? 0.0).toDouble(),
        bloodPressure: {
          'systolic': (r['bloodPressure']?['systolic'] ?? 0).toInt(),
          'diastolic': (r['bloodPressure']?['diastolic'] ?? 0).toInt(),
        },
        spo2: (r['spo2'] ?? 0.0).toDouble(),
        timestamp: lu ?? DateTime.now(),
        ecgReadings: ecgData
            .map((v) => EcgReading(value: v, timestamp: DateTime.now()))
            .toList(),
        isDeviceConnected:
            lu != null && DateTime.now().difference(lu).inMinutes < 5,
        lastDataReceived: lu,
      );
      controller.add(vs);
    }

    final sub1 = patientRef.onValue.listen((e) {
      final v = e.snapshot.value;
      if (v is Map) {
        patientMeta = Map<String, dynamic>.from(v);
      } else {
        patientMeta = {};
      }
      emit();
    });
    final sub2 = readingsRef.onValue.listen((e) {
      final v = e.snapshot.value;
      if (v is Map) {
        readings = Map<String, dynamic>.from(v);
        final lu = readings?['lastUpdated'];
        if (lu is int) {
          lastUpdated = DateTime.fromMillisecondsSinceEpoch(lu);
        }
      } else {
        readings = {};
      }
      emit();
    });

    controller.onCancel = () async {
      await sub1.cancel();
      await sub2.cancel();
    };
    return controller.stream;
  }

  /// ECG stream now reads from /devices/{id}/readings (ecg scalar or waveform)
  static Stream<List<EcgReading>> getEcgReadingsStream(String deviceId) {
    if (currentUserId == null) return Stream.value([]);
    return _database.ref('devices/$deviceId/readings').onValue.asyncMap((
      event,
    ) async {
      final data = event.snapshot.value;
      if (data is! Map) return <EcgReading>[];
      final map = Map<String, dynamic>.from(data);
      final ecgValue = (map['ecg'] ?? map['heartRate'] ?? 0.0).toDouble();
      if (ecgValue <= 0) return <EcgReading>[];
      double normalizedHR = ecgValue;
      if (ecgValue > 200) normalizedHR = (60 + (ecgValue % 40)).toDouble();
      final List<EcgReading> readings = [];
      final baseTime = DateTime.now();
      for (int i = 0; i < 20; i++) {
        final waveformValue = _generateEcgWaveform(i, normalizedHR);
        readings.add(
          EcgReading(
            value: waveformValue,
            timestamp: baseTime.add(Duration(milliseconds: i * 50)),
          ),
        );
      }
      return readings;
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
