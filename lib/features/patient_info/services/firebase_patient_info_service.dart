import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/patient_info_model.dart';

/// Firebase service for patient information
/// Stores patient data in Firebase Realtime Database for cross-device sync
class FirebasePatientInfoService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Save patient information to Firebase
  static Future<void> savePatientInfo(PatientInfo patientInfo) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    if (patientInfo.deviceId.trim().isEmpty) {
      throw Exception('Invalid patient/device ID');
    }
    final normalizedId = patientInfo.deviceId.trim();

    try {
      final rootRef = _database.ref(
        'users/$currentUserId/patients/$normalizedId',
      );
      // New structure: store only patient metadata (no nested device readings)
      await rootRef.set(
        patientInfo.copyWith(deviceId: normalizedId).toProfileJson(),
      );
      print('Patient info saved to Firebase: $normalizedId');
    } catch (e) {
      throw Exception('Failed to save patient info to Firebase: $e');
    }
  }

  /// Get patient information by device ID from Firebase
  static Future<PatientInfo?> getPatientInfo(String deviceId) async {
    if (currentUserId == null) return null;

    try {
      final rootRef = _database.ref('users/$currentUserId/patients/$deviceId');
      final snapshot = await rootRef.get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return PatientInfo.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting patient info from Firebase: $e');
      return null;
    }
  }

  /// Update patient information in Firebase
  static Future<void> updatePatientInfo(PatientInfo patientInfo) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    if (patientInfo.deviceId.trim().isEmpty) {
      throw Exception('Invalid patient/device ID');
    }
    final normalizedId = patientInfo.deviceId.trim();

    try {
      final rootRef = _database.ref(
        'users/$currentUserId/patients/$normalizedId',
      );

      // التحقق من وجود البيانات قبل التحديث
      final existingSnapshot = await rootRef.get();

      final updatedPatientInfo = patientInfo.copyWith(
        updatedAt: DateTime.now(),
      );

      if (!existingSnapshot.exists) {
        // إذا لم تكن البيانات موجودة، احفظها بدلاً من التحديث
        await savePatientInfo(updatedPatientInfo);
        return;
      }

      // استخدام update بدلاً من set للحفاظ على البيانات الأخرى
      // Update only info; device updated if provided
      await rootRef.update(updatedPatientInfo.toProfileJson());

      // التحقق من نجاح التحديث
      final verifySnapshot = await rootRef.get();
      if (verifySnapshot.exists) {
        print('Patient info successfully updated in Firebase: $normalizedId');
      } else {
        throw Exception(
          'Update operation failed - data not found after update',
        );
      }
    } catch (e) {
      throw Exception('Failed to update patient info in Firebase: $e');
    }
  }

  /// Delete patient information from Firebase
  static Future<void> deletePatientInfo(String deviceId) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    if (deviceId.trim().isEmpty) return; // nothing to delete
    deviceId = deviceId.trim();

    try {
      final rootRef = _database.ref('users/$currentUserId/patients/$deviceId');

      // التحقق من وجود البيانات قبل الحذف
      final snapshot = await rootRef.get();
      if (!snapshot.exists) {
        print('Patient info already deleted or does not exist: $deviceId');
        return;
      }

      await rootRef.remove();

      // التحقق من نجاح الحذف
      final verifySnapshot = await rootRef.get();
      if (!verifySnapshot.exists) {
        print('Patient info successfully deleted from Firebase: $deviceId');
      } else {
        throw Exception('Delete operation failed - data still exists');
      }
    } catch (e) {
      throw Exception('Failed to delete patient info from Firebase: $e');
    }
  }

  /// Get all patient information records from Firebase
  static Future<List<PatientInfo>> getAllPatientInfo() async {
    if (currentUserId == null) return [];

    try {
      final patientsRef = _database.ref('users/$currentUserId/patients');
      final snapshot = await patientsRef.get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        final patients = <PatientInfo>[];
        data.forEach((key, value) {
          final k = key.toString();
          // Basic invalid key filter similar to DeviceService
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
          if (k.trim().isEmpty || invalidKeys.contains(k)) return;
          if (value is Map) {
            try {
              final mapData = Map<String, dynamic>.from(value);
              final pi = PatientInfo.fromJson(mapData);
              if (pi.deviceId.trim().isEmpty) return; // skip malformed
              patients.add(pi);
            } catch (_) {}
          }
        });
        return patients;
      }
      return [];
    } catch (e) {
      print('Error getting all patient info from Firebase: $e');
      return [];
    }
  }

  /// Check if patient info exists for device in Firebase
  static Future<bool> hasPatientInfo(String deviceId) async {
    try {
      final patientInfo = await getPatientInfo(deviceId);
      return patientInfo != null;
    } catch (e) {
      return false;
    }
  }

  /// Listen to real-time patient info changes
  static Stream<PatientInfo?> getPatientInfoStream(String deviceId) {
    if (currentUserId == null) {
      return Stream.value(null);
    }

    return _database.ref('users/$currentUserId/patients/$deviceId').onValue.map(
      (event) {
        final data = event.snapshot.value;
        if (data == null) return null;
        try {
          return PatientInfo.fromJson(Map<String, dynamic>.from(data as Map));
        } catch (e) {
          print('Error parsing patient info from stream: $e');
          return null;
        }
      },
    );
  }

  /// Listen to all patients changes in real-time
  static Stream<List<PatientInfo>> getAllPatientsStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _database.ref('users/$currentUserId/patients').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <PatientInfo>[];

      try {
        final patientsMap = Map<dynamic, dynamic>.from(data as Map);
        return patientsMap.values.map((patientData) {
          final mapData = Map<String, dynamic>.from(patientData as Map);
          return PatientInfo.fromJson(mapData);
        }).toList();
      } catch (e) {
        print('Error parsing patients from stream: $e');
        return <PatientInfo>[];
      }
    });
  }
}
