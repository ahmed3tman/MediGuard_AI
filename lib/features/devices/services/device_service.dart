import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/data_model.dart';

class DeviceNotFoundException implements Exception {
  final String deviceId;

  DeviceNotFoundException(this.deviceId);

  @override
  String toString() => 'DeviceNotFoundException: Device $deviceId not found';
}

class DeviceService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _localDemoStorageKey = 'local_demo_devices_v1';
  static Map<String, Device> _localDemoDevices = {};
  static bool _localDemoLoaded = false;
  static Future<void>? _localDemoLoading;
  static final StreamController<void> _localDemoChanges =
      StreamController<void>.broadcast();

  static String? get currentUserId => _auth.currentUser?.uid;

  // Normalize various timestamp formats (ms epoch, s epoch, ISO string)
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    try {
      if (value is int) {
        // If it's too small to be millis, treat as seconds
        final bool looksLikeSeconds = value < 1000000000000; // 1e12
        final int millis = looksLikeSeconds ? value * 1000 : value;
        return DateTime.fromMillisecondsSinceEpoch(millis);
      }
      if (value is num) {
        final doubleVal = value.toDouble();
        final int intVal = doubleVal.round();
        final bool looksLikeSeconds = intVal < 1000000000000;
        final millis = looksLikeSeconds ? intVal * 1000 : intVal;
        return DateTime.fromMillisecondsSinceEpoch(millis);
      }
      if (value is String) {
        // Numeric string
        final intVal = int.tryParse(value);
        if (intVal != null) {
          final bool looksLikeSeconds = intVal < 1000000000000;
          final int millis = looksLikeSeconds ? intVal * 1000 : intVal;
          return DateTime.fromMillisecondsSinceEpoch(millis);
        }
        // ISO datetime string
        final iso = DateTime.tryParse(value);
        if (iso != null) return iso;
      }
    } catch (_) {}
    return null;
  }

  // ---------------- Add / Link Device ----------------
  // Link existing physical device to current user (no readings duplication)
  static Future<void> addDevice(
    String deviceId,
    String deviceName, {
    bool createPlaceholderIfMissing = false,
  }) async {
    deviceId = deviceId.trim();
    if (deviceId.isEmpty) {
      throw Exception('Device ID cannot be empty');
    }

    if (createPlaceholderIfMissing) {
      await _addLocalDemoDevice(deviceId, deviceName);
      return;
    }

    if (currentUserId == null) throw Exception('User not authenticated');

    // Ensure physical device exists at /devices/{deviceId}
    final physicalRef = _database.ref('devices/$deviceId');
    final physicalSnap = await physicalRef.get();

    if (!physicalSnap.exists) {
      throw DeviceNotFoundException(deviceId);
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
    final controller = StreamController<List<Device>>.broadcast();
    final localLoad = _ensureLocalDemoLoaded();

    if (currentUserId == null) {
      StreamSubscription<void>? localSub;

      Future<void> emitLocal() async {
        await localLoad;
        controller.add(_localDemoDevices.values.toList());
      }

      localSub = _localDemoChanges.stream.listen((_) {
        emitLocal();
      });

      localLoad.then((_) => emitLocal());

      controller.onCancel = () async {
        await localSub?.cancel();
      };

      return controller.stream;
    }

    final patientsRef = _database.ref('users/$currentUserId/patients');
    final Map<String, StreamSubscription<DatabaseEvent>> readingSubs = {};
    final Map<String, Device> latestDevices = {};
    StreamSubscription<void>? localSub;
    var patientSnapshotReceived = false;

    Future<void> emitDevices({bool force = false}) async {
      await localLoad;
      if (!force && !patientSnapshotReceived && _localDemoDevices.isEmpty) {
        return;
      }
      final combined = <String, Device>{};
      combined.addAll(latestDevices);
      _localDemoDevices.forEach((id, device) {
        combined.putIfAbsent(id, () => device);
      });
      controller.add(combined.values.toList());
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
          lastUpdated = _parseTimestamp(lu);
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
        emitDevices(force: true);
      });
    }

    final patientsSub = patientsRef.onValue.listen((event) {
      final data = event.snapshot.value;
      final currentIds = <String>{};
      patientSnapshotReceived = true;
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
            final name = meta['patientName'] ?? meta['name'] ?? deviceId;
            final existing = latestDevices[deviceId];
            if (existing == null) {
              latestDevices[deviceId] = Device(
                deviceId: deviceId,
                name: name,
                readings: const {},
                lastUpdated: null,
              );
            } else {
              // Update only the name; keep readings and lastUpdated intact
              latestDevices[deviceId] = existing.copyWith(name: name);
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
      emitDevices(force: true);
    });

    localSub = _localDemoChanges.stream.listen((_) {
      emitDevices(force: _localDemoDevices.isNotEmpty);
    });

    localLoad.then((_) => emitDevices(force: _localDemoDevices.isNotEmpty));

    controller.onCancel = () async {
      await patientsSub.cancel();
      await localSub?.cancel();
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
    StreamSubscription? patientSub;
    StreamSubscription? readingsSub;
    StreamSubscription<void>? localSub;
    late final StreamController<Device?> controller;
    controller = StreamController<Device?>.broadcast(
      onListen: () {
        _initDeviceStream(deviceId, controller, (sub1, sub2, local) {
          patientSub = sub1;
          readingsSub = sub2;
          localSub = local;
        });
      },
      onCancel: () async {
        await patientSub?.cancel();
        await readingsSub?.cancel();
        await localSub?.cancel();
      },
    );

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
      if (data is Map) {
        // Some feeds wrap under { current: { ... } }
        Map<String, dynamic> readings;
        if (data['current'] is Map) {
          readings = Map<String, dynamic>.from(
            Map<String, dynamic>.from(data)['current'] as Map,
          );
        } else {
          readings = Map<String, dynamic>.from(data);
        }
        // Accept common timestamp aliases
        final rawTs =
            readings['lastUpdated'] ??
            readings['updatedAt'] ??
            readings['timestamp'] ??
            readings['ts'];
        // Normalize lastUpdated if present (support seconds/ms/ISO)
        final normalized = _parseTimestamp(rawTs);
        if (normalized != null) {
          readings['lastUpdated'] = normalized.millisecondsSinceEpoch;
        } // If no timestamp at all, leave it absent; do not inject a fake 'now'
        return readings;
      }
      return null;
    });
  }

  // Update readings (simulation or manual) -> /devices/{id}/readings
  static Future<void> updateDeviceReadings(
    String deviceId,
    Map<String, dynamic> newReadings,
  ) async {
    await _ensureLocalDemoLoaded();
    final providedTs = _parseTimestamp(newReadings['lastUpdated']);
    final localMillis =
        providedTs?.millisecondsSinceEpoch ??
        DateTime.now().millisecondsSinceEpoch;

    if (_localDemoDevices.containsKey(deviceId)) {
      final existing = _localDemoDevices[deviceId]!;
      final updatedReadings = Map<String, dynamic>.from(existing.readings);
      updatedReadings.addAll(newReadings);
      updatedReadings['lastUpdated'] = localMillis;

      _localDemoDevices[deviceId] = existing.copyWith(
        readings: updatedReadings,
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(localMillis),
        forceLastUpdated: true,
      );

      await _persistLocalDemoDevices();
      _notifyLocalDemoListeners();
      return;
    }

    final readingsRef = _database.ref('devices/$deviceId/readings');
    final payload = Map<String, dynamic>.from(newReadings);
    payload['lastUpdated'] =
        providedTs?.millisecondsSinceEpoch ?? ServerValue.timestamp;
    await readingsRef.update(payload);
  }

  static Future<void> updateDeviceWithExternalReadings(
    String deviceId,
    Map<String, dynamic> externalReadings,
  ) async {
    // Ensure lastUpdated is carried and normalized
    final m = Map<String, dynamic>.from(externalReadings);
    final ts = _parseTimestamp(m['lastUpdated']);
    if (ts != null) {
      m['lastUpdated'] = ts.millisecondsSinceEpoch;
    }
    await updateDeviceReadings(deviceId, m);
  }

  static Future<void> updateDeviceName(String deviceId, String newName) async {
    await _ensureLocalDemoLoaded();
    if (_localDemoDevices.containsKey(deviceId)) {
      final existing = _localDemoDevices[deviceId]!;
      _localDemoDevices[deviceId] = existing.copyWith(name: newName);
      await _persistLocalDemoDevices();
      _notifyLocalDemoListeners();
      return;
    }

    if (currentUserId == null) throw Exception('User not authenticated');
    final patientRef = _database.ref('users/$currentUserId/patients/$deviceId');
    await patientRef.update({
      'patientName': newName,
      'updatedAt': ServerValue.timestamp,
    });
  }

  static Future<void> deleteDevice(String deviceId) async {
    await _ensureLocalDemoLoaded();
    if (_localDemoDevices.remove(deviceId) != null) {
      await _persistLocalDemoDevices();
      _notifyLocalDemoListeners();
      return;
    }

    if (currentUserId == null) throw Exception('User not authenticated');
    final patientRef = _database.ref('users/$currentUserId/patients/$deviceId');
    await patientRef.remove(); // unlink only
  }

  static Future<void> simulateDeviceData(String deviceId) async {
    await _ensureLocalDemoLoaded();
    if (_localDemoDevices.containsKey(deviceId)) {
      final now = DateTime.now();
      final simulatedReadings = _generateDemoReadings(now);
      await updateDeviceReadings(deviceId, simulatedReadings);
      return;
    }

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

  static Future<void> _ensureLocalDemoLoaded() async {
    if (_localDemoLoaded) return;
    if (_localDemoLoading != null) {
      await _localDemoLoading;
      return;
    }
    _localDemoLoading = _loadLocalDemoDevices();
    await _localDemoLoading;
  }

  static Future<void> _loadLocalDemoDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_localDemoStorageKey);
      if (jsonString == null || jsonString.isEmpty) {
        _localDemoDevices = {};
        return;
      }
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        final loaded = <String, Device>{};
        for (final entry in decoded) {
          if (entry is Map) {
            try {
              final device = Device.fromJson(Map<String, dynamic>.from(entry));
              loaded[device.deviceId] = device;
            } catch (_) {}
          }
        }
        _localDemoDevices = loaded;
      } else {
        _localDemoDevices = {};
      }
    } catch (_) {
      _localDemoDevices = {};
    } finally {
      _localDemoLoaded = true;
      _localDemoLoading = null;
    }
  }

  static Future<void> _persistLocalDemoDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _localDemoDevices.values
          .map((device) => device.toJson())
          .toList();
      await prefs.setString(_localDemoStorageKey, jsonEncode(list));
    } catch (_) {}
  }

  static void _notifyLocalDemoListeners() {
    if (!_localDemoChanges.isClosed) {
      _localDemoChanges.add(null);
    }
  }

  static Map<String, dynamic> _generateDemoReadings(DateTime now) {
    final base = now.millisecondsSinceEpoch % 20;
    return {
      'temperature': 36.5 + (base % 5) / 10,
      'heartRate': 70 + (base % 15),
      'respiratoryRate': 14 + (base % 6),
      'spo2': 96 + (base % 4),
      'bloodPressure': {
        'systolic': 115 + (base % 10),
        'diastolic': 75 + (base % 6),
      },
      'source': 'demo',
      'isDemo': true,
      'lastUpdated': now.millisecondsSinceEpoch,
    };
  }

  static Future<void> _addLocalDemoDevice(
    String deviceId,
    String deviceName,
  ) async {
    await _ensureLocalDemoLoaded();
    final now = DateTime.now();
    final device = Device(
      deviceId: deviceId,
      name: deviceName,
      readings: _generateDemoReadings(now),
      lastUpdated: now,
    );
    _localDemoDevices[deviceId] = device;
    await _persistLocalDemoDevices();
    _notifyLocalDemoListeners();
  }

  static Future<void> _initDeviceStream(
    String deviceId,
    StreamController<Device?> controller,
    void Function(
      StreamSubscription<DatabaseEvent>?,
      StreamSubscription<DatabaseEvent>?,
      StreamSubscription<void>?,
    )
    registerSubs,
  ) async {
    await _ensureLocalDemoLoaded();

    if (_localDemoDevices.containsKey(deviceId)) {
      void emitLocal() {
        controller.add(_localDemoDevices[deviceId]);
      }

      emitLocal();
      final localSub = _localDemoChanges.stream.listen((_) {
        emitLocal();
      });
      registerSubs(null, null, localSub);
      return;
    }

    if (currentUserId == null) {
      controller.add(null);
      registerSubs(null, null, null);
      return;
    }

    final patientRef = _database.ref('users/$currentUserId/patients/$deviceId');
    final readingsRef = _database.ref('devices/$deviceId/readings');

    Map<String, dynamic> meta = {};
    Map<String, dynamic> readings = {};
    DateTime? lastUpdated;

    void emitRemote() {
      if (meta.isEmpty && readings.isEmpty) {
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

    final patientSub = patientRef.onValue.listen((event) {
      final v = event.snapshot.value;
      if (v is Map) {
        meta = Map<String, dynamic>.from(v);
      }
      emitRemote();
    });

    final readingsSub = readingsRef.onValue.listen((event) {
      final v = event.snapshot.value;
      if (v is Map) {
        readings = Map<String, dynamic>.from(v);
        final lu = readings['lastUpdated'];
        lastUpdated = _parseTimestamp(lu);
      }
      emitRemote();
    });

    registerSubs(patientSub, readingsSub, null);
  }
}
