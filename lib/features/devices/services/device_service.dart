import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/data_model.dart';

class DeviceService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get currentUserId => _auth.currentUser?.uid;

  // ---------------- Add / Link Device ----------------
  // Link existing physical device to current user (no readings duplication)
  static Future<void> addDevice(String deviceId, String deviceName) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    if (deviceId.trim().isEmpty) {
      throw Exception('Device ID cannot be empty');
    }
    // Basic normalization
    deviceId = deviceId.trim();

    // Ensure physical device exists at /devices/{deviceId}
    final physicalRef = _database.ref('devices/$deviceId');
    final physicalSnap = await physicalRef.get();
    if (!physicalSnap.exists) {
      throw Exception('Device not found on network (devices/$deviceId)');
    }

    // Create patient link (metadata only) if absent
    final patientRef = _database.ref('users/$currentUserId/patients/$deviceId');
    final existing = await patientRef.get();
    if (existing.exists) {
      // Already linked – optionally update patientName if provided
      await patientRef.update({
        'patientName': deviceName,
        'updatedAt': ServerValue.timestamp,
      });
      return;
    }

    final now = ServerValue.timestamp;
    await patientRef.set({
      'deviceId': deviceId,
      'patientName': deviceName,
      'age': 0,
      'gender': 'male', // default placeholder; real form sets later
      'chronicDiseases': <String>[],
      'createdAt': now,
      'updatedAt': now,
    });
  }

  // ---------------- Devices Stream (merged) ----------------
  // Internally manages per-device listeners for /devices/{id}/readings
  static Stream<List<Device>> getDevicesStream() {
    if (currentUserId == null) return Stream.value([]);

    final patientsRef = _database.ref('users/$currentUserId/patients');
    final controller = StreamController<List<Device>>.broadcast();
    final Map<String, StreamSubscription<DatabaseEvent>> readingSubs = {};
    final Map<String, Device> latestDevices = {};

    Future<void> emitDevices() async {
      controller.add(latestDevices.values.toList());
    }

    void attachReadingListener(String deviceId) {
      if (readingSubs.containsKey(deviceId)) return;
      final readingsRef = _database.ref('devices/$deviceId/readings');
      readingSubs[deviceId] = readingsRef.onValue.listen((event) {
        final readingsData = event.snapshot.value;
        Map<String, dynamic> readingsMap = {};
        DateTime? lastUpdated;
        if (readingsData is Map) {
          final m = Map<String, dynamic>.from(readingsData);
          // Extract lastUpdated from nested readings path
          final lu = m['lastUpdated'];
          if (lu != null && lu is int) {
            lastUpdated = DateTime.fromMillisecondsSinceEpoch(lu);
          }
          readingsMap = m;
        }

        // Merge with patient meta (which we stored earlier in latestDevices under temp placeholder) if available
        final existing = latestDevices[deviceId];
        final deviceName = existing?.name ?? existing?.deviceId ?? deviceId;
        latestDevices[deviceId] = Device(
          deviceId: deviceId,
          name: deviceName,
          readings: readingsMap,
          lastUpdated: lastUpdated,
        );
        emitDevices();
      });
    }

    final patientsSub = patientsRef.onValue.listen((event) {
      final data = event.snapshot.value;
      final currentIds = <String>{};
      if (data is Map) {
        final patientsMap = Map<dynamic, dynamic>.from(data);
        for (final entry in patientsMap.entries) {
          final deviceId = entry.key.toString();
          // Skip stray meta fields mistakenly written at root (e.g., 'age', 'gender', 'id', 'deviceId', 'patientName', etc.)
          if (_isInvalidPatientRootKey(deviceId)) {
            continue;
          }
          currentIds.add(deviceId);
          final meta = Map<String, dynamic>.from(entry.value as Map);

          // If old structure still has nested device, fallback (migration phase only)
          if (meta['device'] is Map && !latestDevices.containsKey(deviceId)) {
            try {
              final legacy = Map<String, dynamic>.from(meta['device']);
              latestDevices[deviceId] = Device.fromJson(legacy);
            } catch (_) {}
          } else {
            // Ensure placeholder exists to hold name until readings arrive
            if (!latestDevices.containsKey(deviceId)) {
              final name = meta['patientName'] ?? meta['name'] ?? deviceId;
              latestDevices[deviceId] = Device(
                deviceId: deviceId,
                name: name,
                readings: const {},
                lastUpdated: null,
              );
            } else {
              // Update name if changed
              final name = meta['patientName'] ?? meta['name'] ?? deviceId;
              latestDevices[deviceId] = latestDevices[deviceId]!.copyWith(
                name: name,
              );
            }
          }
          attachReadingListener(deviceId);
        }
      }

      // Remove subscriptions for unlinked devices
      final toRemove = readingSubs.keys
          .where((id) => !currentIds.contains(id))
          .toList();
      for (final id in toRemove) {
        readingSubs[id]?.cancel();
        readingSubs.remove(id);
        latestDevices.remove(id);
      }
      emitDevices();
    });

    controller.onCancel = () async {
      await patientsSub.cancel();
      for (final sub in readingSubs.values) {
        await sub.cancel();
      }
    };

    return controller.stream;
  }

  // Helper to detect invalid root keys (not real device IDs)
  static bool _isInvalidPatientRootKey(String key) {
    const invalidKeys = {
      'age',
      'gender',
      'id',
      'deviceId',
      'patientName',
      'bloodType',
      'phoneNumber',
      'chronicDiseases',
      'notes',
      'createdAt',
      'updatedAt',
    };
    if (key.trim().isEmpty) return true;
    return invalidKeys.contains(key);
  }

  // Cleanup routine to remove stray primitive fields accidentally written inside patients root
  static Future<void> cleanupInvalidPatientNodes() async {
    if (currentUserId == null) return;
    final patientsRef = _database.ref('users/$currentUserId/patients');
    try {
      final snapshot = await patientsRef.get();
      if (!snapshot.exists || snapshot.value == null) return;
      if (snapshot.value is! Map) return;
      final map = Map<dynamic, dynamic>.from(snapshot.value as Map);
      final updates = <String, Object?>{};
      map.forEach((k, v) {
        final key = k.toString();
        // Delete primitive or invalid key nodes
        final isPrimitive = v is! Map;
        if (_isInvalidPatientRootKey(key) && isPrimitive) {
          updates[key] = null; // mark for deletion
        }
      });
      if (updates.isNotEmpty) {
        await patientsRef.update(updates);
        // print('Cleaned invalid patient nodes: ${updates.keys.toList()}');
      }
    } catch (e) {
      // print('Cleanup skipped: $e');
    }
  }

  // Single device merged stream
  static Stream<Device?> getDeviceReadingsStream(String deviceId) {
    if (currentUserId == null) return Stream.value(null);
    // Combine patient meta + readings
    final patientRef = _database.ref('users/$currentUserId/patients/$deviceId');
    final readingsRef = _database.ref('devices/$deviceId/readings');

    // Use controller to merge
    final controller = StreamController<Device?>.broadcast();
    Map<String, dynamic> meta = {};
    Map<String, dynamic> readings = {};
    DateTime? lastUpdated;

    void emit() {
      if (meta.isEmpty && readings.isEmpty) {
        // fallback legacy nested if exists inside meta['device']
        if (meta['device'] is Map) {
          try {
            controller.add(
              Device.fromJson(Map<String, dynamic>.from(meta['device'])),
            );
            return;
          } catch (_) {}
        }
        controller.add(null);
        return;
      }
      final name =
          meta['patientName'] ?? meta['name'] ?? meta['deviceId'] ?? deviceId;
      controller.add(
        Device(
          deviceId: deviceId,
          name: name,
          readings: readings,
          lastUpdated: lastUpdated,
        ),
      );
    }

    final sub1 = patientRef.onValue.listen((e) {
      final v = e.snapshot.value;
      if (v is Map) meta = Map<String, dynamic>.from(v);
      emit();
    });
    final sub2 = readingsRef.onValue.listen((e) {
      final v = e.snapshot.value;
      if (v is Map) {
        readings = Map<String, dynamic>.from(v);
        final lu = readings['lastUpdated'];
        if (lu is int) lastUpdated = DateTime.fromMillisecondsSinceEpoch(lu);
      }
      emit();
    });

    controller.onCancel = () async {
      await sub1.cancel();
      await sub2.cancel();
    };
    return controller.stream;
  }

  // External device readings (legacy path kept for backward compatibility)
  static Stream<Map<String, dynamic>?> getExternalDeviceReadings(
    String deviceId,
  ) {
    return _database.ref('device_readings/$deviceId/current').onValue.map((
      event,
    ) {
      final data = event.snapshot.value;
      if (data is Map) return Map<String, dynamic>.from(data);
      return null;
    });
  }

  // Update readings (simulation or manual) -> /devices/{id}/readings
  static Future<void> updateDeviceReadings(
    String deviceId,
    Map<String, dynamic> newReadings,
  ) async {
    final readingsRef = _database.ref('devices/$deviceId/readings');
    await readingsRef.update({
      ...newReadings,
      'lastUpdated': ServerValue.timestamp,
    });
  }

  static Future<void> updateDeviceWithExternalReadings(
    String deviceId,
    Map<String, dynamic> externalReadings,
  ) async {
    await updateDeviceReadings(deviceId, externalReadings);
  }

  static Future<void> updateDeviceName(String deviceId, String newName) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    final patientRef = _database.ref('users/$currentUserId/patients/$deviceId');
    await patientRef.update({
      'patientName': newName,
      'updatedAt': ServerValue.timestamp,
    });
  }

  static Future<void> deleteDevice(String deviceId) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    final patientRef = _database.ref('users/$currentUserId/patients/$deviceId');
    await patientRef.remove(); // unlink only
  }

  static Future<void> simulateDeviceData(String deviceId) async {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final simulatedReadings = {
      'temperature': 36.5 + (random % 20) / 10,
      'heartRate': 60 + (random % 40),
      'respiratoryRate': 12 + (random % 9),
      'ecg': 70 + (random % 40), // treat as heartRate-based ecg scalar
      'spo2': 95 + (random % 6),
      'bloodPressure': {
        'systolic': 110 + (random % 30),
        'diastolic': 70 + (random % 20),
      },
    };
    await updateDeviceReadings(deviceId, simulatedReadings);
  }
}
