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
          // Handle seconds vs milliseconds epoch
          final bool looksLikeSeconds = lu < 1000000000000; // 1e12
          final millis = looksLikeSeconds ? lu * 1000 : lu;
          lastUpdated = DateTime.fromMillisecondsSinceEpoch(millis);
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

    final refs = <DatabaseReference>[
      _database.ref('devices/$deviceId/readings'),
      _database.ref('users/$currentUserId/devices/$deviceId/readings'),
      _database.ref('device_readings/$deviceId/current'),
    ];

    final controller = StreamController<List<EcgReading>>.broadcast();
    final List<StreamSubscription<DatabaseEvent>> subs = [];
    // Rolling buffer for scalar ECG values using lastUpdated timestamps
    final List<EcgReading> scalarBuffer = <EcgReading>[];
    const int scalarMaxKeep = 50 * 10; // 10 seconds at 50Hz equivalent length

    List<EcgReading> _parseWaveform(dynamic data) {
      if (data is! Map) return <EcgReading>[];
      final map = Map<String, dynamic>.from(data);

      dynamic findWaveform(dynamic m) {
        if (m is! Map) return null;
        if (m['ecgData'] is List) return m['ecgData'];
        if (m['ecg'] is List) return m['ecg'];
        if (m['waveform'] is List) return m['waveform'];
        if (m['ecgWaveform'] is List) return m['ecgWaveform'];
        if (m['current'] is Map) return findWaveform(m['current']);
        return null;
      }

      final dynamic wf = findWaveform(map);
      if (wf is List) {
        // Accept numbers or numeric strings
        final List<double> samples = [];
        for (final e in wf) {
          if (e == null) continue;
          if (e is num)
            samples.add(e.toDouble());
          else if (e is String) {
            final v = double.tryParse(e);
            if (v != null) samples.add(v);
          }
        }
        if (samples.isEmpty) return <EcgReading>[];

        // Assign relative timestamps at 50Hz
        const double sampleRateHz = 50.0;
        final int n = samples.length;
        final now = DateTime.now();
        final start = now.subtract(
          Duration(microseconds: (1e6 * n / sampleRateHz).round()),
        );
        final readings = List<EcgReading>.generate(n, (i) {
          final ts = start.add(
            Duration(microseconds: (1e6 * (i + 1) / sampleRateHz).round()),
          );
          return EcgReading(value: samples[i], timestamp: ts);
        });
        const int maxKeep = 50 * 10; // 10s
        return readings.length > maxKeep
            ? readings.sublist(readings.length - maxKeep)
            : readings;
      }

      // Also accept map<timestamp,value>
      if (map.values.isNotEmpty) {
        final entries = <MapEntry<DateTime, double>>[];
        map.forEach((k, v) {
          DateTime? ts;
          // try parse k as ISO or milliseconds
          ts = DateTime.tryParse(k);
          ts ??= int.tryParse(k) != null
              ? DateTime.fromMillisecondsSinceEpoch(int.parse(k))
              : null;
          double? val;
          if (v is num) val = v.toDouble();
          if (v is String) val = double.tryParse(v);
          if (ts != null && val != null) {
            entries.add(MapEntry(ts, val));
          }
        });
        entries.sort((a, b) => a.key.compareTo(b.key));
        return entries
            .map((e) => EcgReading(value: e.value, timestamp: e.key))
            .toList();
      }

      return <EcgReading>[];
    }

    void handle(DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data == null) return;
      final wave = _parseWaveform(data);
      if (wave.isNotEmpty) {
        if (!controller.isClosed) controller.add(wave);
        return;
      }
      // Fallback: accept scalar ecg + lastUpdated as discrete samples
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        // Seek in common containers
        Map<String, dynamic>? cur = map;
        if (map['current'] is Map) {
          cur = Map<String, dynamic>.from(map['current']);
        }
        final ecgScalar = cur['ecg'] ?? cur['heartRate'];
        final lu = cur['lastUpdated'] ?? map['lastUpdated'];
        double? val;
        if (ecgScalar is num) val = ecgScalar.toDouble();
        if (ecgScalar is String) val = double.tryParse(ecgScalar);
        if (val != null) {
          // accept only > 0
          if (val > 0) {
            DateTime ts = DateTime.now();
            if (lu is int) {
              final looksLikeSeconds = lu < 1000000000000;
              final millis = looksLikeSeconds ? lu * 1000 : lu;
              ts = DateTime.fromMillisecondsSinceEpoch(millis);
            } else if (lu is String) {
              final parsed = DateTime.tryParse(lu);
              if (parsed != null) ts = parsed;
            }
            // Append only if ts is newer than last
            if (scalarBuffer.isEmpty ||
                ts.isAfter(scalarBuffer.last.timestamp)) {
              scalarBuffer.add(EcgReading(value: val, timestamp: ts));
              // Trim window ~ last 30 seconds of samples (sparse, not 50Hz)
              while (scalarBuffer.length > scalarMaxKeep) {
                scalarBuffer.removeAt(0);
              }
              if (!controller.isClosed) {
                controller.add(List.unmodifiable(scalarBuffer));
              }
            }
          }
        }
      }
    }

    for (final r in refs) {
      subs.add(r.onValue.listen(handle));
    }

    controller.onCancel = () async {
      for (final s in subs) {
        await s.cancel();
      }
    };

    return controller.stream;
  }

  /// Clean up old ECG data to prevent database bloat
  static Future<void> cleanupOldEcgData(String deviceId) async {
    if (currentUserId == null) return;

    // Since we're generating ECG from real-time data, no cleanup needed
    print('Cleanup called - no action needed for generated ECG data');
  }
}
