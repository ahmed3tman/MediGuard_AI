import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/data_model.dart';

class DeviceService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // Add a new device
  static Future<void> addDevice(String deviceId, String deviceName) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    // New unified structure: users/{userId}/patients/{patientId}/device
    final deviceRef = _database.ref(
      'users/$currentUserId/patients/$deviceId/device',
    );

    // readings مع قسم ECG كرقم وليس ecgData كمصفوفة
    final readings = {
      'temperature': 0.0,
      'heartRate': 0.0,
      'respiratoryRate': 0.0,
      'spo2': 0.0,
      'bloodPressure': {'systolic': 0, 'diastolic': 0},
      'ecg': 0.0,
    };

    final device = Device(
      deviceId: deviceId,
      name: deviceName,
      readings: readings,
      lastUpdated: null, // Set to null so it shows as "Not Connected"
    );

    await deviceRef.set(device.toJson());
  }

  // Get all devices for current user with real-time readings
  static Stream<List<Device>> getDevicesStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    // Collect devices from patients subtree
    return _database.ref('users/$currentUserId/patients').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <Device>[];
      final Map<dynamic, dynamic> patientsMap = data as Map<dynamic, dynamic>;
      final List<Device> devices = [];
      for (final entry in patientsMap.entries) {
        final patientData = Map<String, dynamic>.from(entry.value as Map);
        if (patientData['device'] != null && patientData['device'] is Map) {
          devices.add(
            Device.fromJson(
              Map<String, dynamic>.from(patientData['device'] as Map),
            ),
          );
        }
      }
      return devices;
    });
  }

  // Listen to specific device readings in real-time
  static Stream<Device?> getDeviceReadingsStream(String deviceId) {
    if (currentUserId == null) {
      return Stream.value(null);
    }

    return _database
        .ref('users/$currentUserId/patients/$deviceId/device')
        .onValue
        .map((event) {
          final data = event.snapshot.value;
          if (data == null) return null;
          return Device.fromJson(Map<String, dynamic>.from(data as Map));
        });
  }

  // Listen to device readings from external source (for real devices)
  static Stream<Map<String, dynamic>?> getExternalDeviceReadings(
    String deviceId,
  ) {
    // This would listen to readings from actual medical devices
    // Path: /device_readings/{deviceId}/current
    return _database.ref('device_readings/$deviceId/current').onValue.map((
      event,
    ) {
      final data = event.snapshot.value;
      if (data == null) return null;

      return Map<String, dynamic>.from(data as Map);
    });
  }

  // Update device with external readings
  static Future<void> updateDeviceWithExternalReadings(
    String deviceId,
    Map<String, dynamic> externalReadings,
  ) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final deviceRef = _database.ref(
      'users/$currentUserId/patients/$deviceId/device',
    );

    // Merge external readings with existing device data
    await deviceRef.update({
      'readings': externalReadings,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Update device readings (simulating device data)
  static Future<void> updateDeviceReadings(
    String deviceId,
    Map<String, dynamic> newReadings,
  ) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final deviceRef = _database.ref(
      'users/$currentUserId/patients/$deviceId/device',
    );

    await deviceRef.update({
      'readings': newReadings,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Update device name
  static Future<void> updateDeviceName(String deviceId, String newName) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final deviceRef = _database.ref(
      'users/$currentUserId/patients/$deviceId/device',
    );

    await deviceRef.update({'name': newName});
  }

  // Delete a device
  static Future<void> deleteDevice(String deviceId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    // This will delete the entire patient entry, including the device and any other patient data.
    final patientRef = _database.ref('users/$currentUserId/patients/$deviceId');
    await patientRef.remove();
  }

  // Simulate real-time data updates (for testing purposes)
  static Future<void> simulateDeviceData(String deviceId) async {
    if (currentUserId == null) return;

    final random = DateTime.now().millisecondsSinceEpoch % 100;

    final simulatedReadings = {
      'temperature': 36.5 + (random % 20) / 10, // 36.5 - 38.5°C
      'heartRate': 60 + (random % 40), // 60-100 BPM
      'respiratoryRate': 12 + (random % 9), // 12-20 BPM
      'ecgData': List.generate(
        100,
        (i) => (0.5 * (i % 10)),
      ), // Dummy ECG waveform
      'spo2': 95 + (random % 6), // 95-100%
      'bloodPressure': {
        'systolic': 110 + (random % 30), // 110-140 mmHg
        'diastolic': 70 + (random % 20), // 70-90 mmHg
      },
    };

    await updateDeviceReadings(deviceId, simulatedReadings);
  }
}
