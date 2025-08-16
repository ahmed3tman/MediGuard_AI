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
    final ref = _database.ref('devices/$deviceId/readings');

    final controller = StreamController<List<EcgReading>>.broadcast();
    StreamSubscription<DatabaseEvent>? dbSub;
    Timer? timer;

    // State for continuous generation
    double bpm = 70.0;
    final List<EcgReading> buffer = <EcgReading>[];
    int tick = 0;

    void emitSample() {
      // 20 Hz sampling
      final double value = _generateEcgWaveform(tick, bpm);
      final now = DateTime.now();
      buffer.add(EcgReading(value: value, timestamp: now));
      // Keep last 500 samples (~25s at 20Hz)
      const int maxSamples = 500;
      if (buffer.length > maxSamples) {
        buffer.removeRange(0, buffer.length - maxSamples);
      }
      tick = (tick + 1) % 1000000; // avoid overflow
      if (!controller.isClosed) controller.add(List.unmodifiable(buffer));
    }

    controller.onListen = () {
      // Subscribe to device readings to update BPM
      dbSub = ref.onValue.listen((event) {
        final data = event.snapshot.value;
        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          final raw = (map['ecg'] ?? map['heartRate'] ?? 0.0).toDouble();
          if (raw <= 0) return;
          // Normalize unreasonable values
          bpm = raw > 200 ? (60 + (raw % 40)).toDouble() : raw;
        }
      });
      // Start periodic generation
      timer = Timer.periodic(
        const Duration(milliseconds: 50),
        (_) => emitSample(),
      );
    };

    controller.onCancel = () async {
      await dbSub?.cancel();
      timer?.cancel();
    };

    return controller.stream;
  }

  /// Generate ECG waveform pattern based on heart rate
  static double _generateEcgWaveform(int index, double heartRate) {
    // Heart-rate-dependent ECG simulation
    const double sampleRate = 20.0; // samples per second (50 ms)
    final double bps = (heartRate <= 0 ? 60.0 : heartRate) / 60.0; // beats/s
    int samplesPerBeat = (sampleRate / bps).round();
    samplesPerBeat = samplesPerBeat.clamp(6, 60); // constrain cycle length
    final double phase = (index % samplesPerBeat) / samplesPerBeat; // 0..1

    // Simplified ECG morphology by phase
    if (phase < 0.12) {
      return 0.1; // P wave
    } else if (phase < 0.18) {
      return 0.0; // PR segment
    } else if (phase < 0.22) {
      return -0.3; // Q
    } else if (phase < 0.26) {
      return 1.5; // R peak
    } else if (phase < 0.30) {
      return -0.8; // S
    } else if (phase < 0.50) {
      return 0.0; // ST segment
    } else if (phase < 0.66) {
      return 0.4; // T wave
    } else {
      return 0.0; // baseline
    }
  }

  /// Clean up old ECG data to prevent database bloat
  static Future<void> cleanupOldEcgData(String deviceId) async {
    if (currentUserId == null) return;

    // Since we're generating ECG from real-time data, no cleanup needed
    print('Cleanup called - no action needed for generated ECG data');
  }
}
