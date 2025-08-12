import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/patient_info_model.dart';

/// Enhanced Firebase service for patient information
/// Provides improved error handling and retry mechanisms for better reliability
class FirebasePatientInfoServiceEnhanced {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Save patient information to Firebase with retry mechanism
  static Future<void> savePatientInfo(PatientInfo patientInfo) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final patientRef = _database.ref(
          'users/$currentUserId/patients/${patientInfo.deviceId}',
        );

        final dataToSave = patientInfo.toJson();
        dataToSave['lastUpdated'] = ServerValue.timestamp;

        await patientRef.set(dataToSave);

        // التحقق من نجاح الحفظ
        final verifySnapshot = await patientRef.get();
        if (verifySnapshot.exists) {
          print(
            'Patient info successfully saved to Firebase: ${patientInfo.deviceId}',
          );
          return;
        } else {
          throw Exception('Save operation failed - data not found after save');
        }
      } catch (e) {
        retryCount++;
        print('Attempt $retryCount failed to save patient info: $e');

        if (retryCount >= maxRetries) {
          throw Exception(
            'Failed to save patient info to Firebase after $maxRetries attempts: $e',
          );
        }

        // انتظار قبل إعادة المحاولة
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
  }

  /// Get patient information by device ID from Firebase
  static Future<PatientInfo?> getPatientInfo(String deviceId) async {
    if (currentUserId == null) return null;

    try {
      final patientRef = _database.ref(
        'users/$currentUserId/patients/$deviceId',
      );
      final snapshot = await patientRef.get();

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

  /// Update patient information in Firebase with enhanced validation
  static Future<void> updatePatientInfo(PatientInfo patientInfo) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final patientRef = _database.ref(
          'users/$currentUserId/patients/${patientInfo.deviceId}',
        );

        // التحقق من وجود البيانات قبل التحديث
        final existingSnapshot = await patientRef.get();
        if (!existingSnapshot.exists) {
          // إذا لم تكن البيانات موجودة، احفظها بدلاً من التحديث
          await savePatientInfo(patientInfo);
          return;
        }

        final updatedPatientInfo = patientInfo.copyWith(
          updatedAt: DateTime.now(),
        );

        final dataToUpdate = updatedPatientInfo.toJson();
        dataToUpdate['lastUpdated'] = ServerValue.timestamp;

        await patientRef.update(dataToUpdate);

        // التحقق من نجاح التحديث
        final verifySnapshot = await patientRef.get();
        if (verifySnapshot.exists) {
          print(
            'Patient info successfully updated in Firebase: ${patientInfo.deviceId}',
          );
          return;
        } else {
          throw Exception(
            'Update operation failed - data not found after update',
          );
        }
      } catch (e) {
        retryCount++;
        print('Attempt $retryCount failed to update patient info: $e');

        if (retryCount >= maxRetries) {
          throw Exception(
            'Failed to update patient info in Firebase after $maxRetries attempts: $e',
          );
        }

        // انتظار قبل إعادة المحاولة
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
  }

  /// Delete patient information from Firebase with enhanced verification
  static Future<void> deletePatientInfo(String deviceId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final patientRef = _database.ref(
          'users/$currentUserId/patients/$deviceId',
        );

        // التحقق من وجود البيانات قبل الحذف
        final snapshot = await patientRef.get();
        if (!snapshot.exists) {
          print('Patient info already deleted or does not exist: $deviceId');
          return;
        }

        // محاولة الحذف
        await patientRef.remove();

        // التحقق من نجاح الحذف
        final verifySnapshot = await patientRef.get();
        if (!verifySnapshot.exists) {
          print('Patient info successfully deleted from Firebase: $deviceId');
          return;
        } else {
          throw Exception('Delete operation did not complete');
        }
      } catch (e) {
        retryCount++;
        print('Attempt $retryCount failed to delete patient info: $e');

        if (retryCount >= maxRetries) {
          throw Exception(
            'Failed to delete patient info from Firebase after $maxRetries attempts: $e',
          );
        }

        // انتظار قبل إعادة المحاولة
        await Future.delayed(Duration(seconds: retryCount));
      }
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
        return data.values
            .map(
              (patientData) => PatientInfo.fromJson(
                Map<String, dynamic>.from(patientData as Map),
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting all patient info from Firebase: $e');
      return [];
    }
  }

  /// Check if patient info exists for device with retry
  static Future<bool> hasPatientInfo(String deviceId) async {
    if (currentUserId == null) return false;

    try {
      final patientRef = _database.ref(
        'users/$currentUserId/patients/$deviceId',
      );
      final snapshot = await patientRef.get();
      return snapshot.exists;
    } catch (e) {
      print('Error checking if patient info exists: $e');
      return false;
    }
  }

  /// Listen to real-time patient info changes
  static Stream<List<PatientInfo>> getPatientInfoStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _database.ref('users/$currentUserId/patients').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <PatientInfo>[];

      try {
        final patientsMap = Map<dynamic, dynamic>.from(data as Map);
        return patientsMap.values
            .map(
              (patientData) => PatientInfo.fromJson(
                Map<String, dynamic>.from(patientData as Map),
              ),
            )
            .toList();
      } catch (e) {
        print('Error parsing patient info from stream: $e');
        return <PatientInfo>[];
      }
    });
  }

  /// Listen to specific patient info changes
  static Stream<PatientInfo?> getPatientInfoStreamByDevice(String deviceId) {
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

  /// Batch update multiple patient info records with transaction
  static Future<void> batchUpdatePatientInfo(List<PatientInfo> patients) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final updates = <String, dynamic>{};
      for (final patient in patients) {
        final dataToUpdate = patient.toJson();
        dataToUpdate['lastUpdated'] = ServerValue.timestamp;
        updates['users/$currentUserId/patients/${patient.deviceId}'] =
            dataToUpdate;
      }

      await _database.ref().update(updates);
      print('Batch updated ${patients.length} patient info records');

      // التحقق من نجاح التحديث الجماعي
      for (final patient in patients) {
        final verifyRef = _database.ref(
          'users/$currentUserId/patients/${patient.deviceId}',
        );
        final verifySnapshot = await verifyRef.get();
        if (!verifySnapshot.exists) {
          print(
            'Warning: Patient info ${patient.deviceId} not found after batch update',
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to batch update patient info: $e');
    }
  }

  /// Force sync all patient info to ensure data consistency
  static Future<void> forceSyncPatientInfo(
    List<PatientInfo> localPatients,
  ) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      // حذف جميع بيانات المرضى الموجودة في Firebase
      final patientsRef = _database.ref('users/$currentUserId/patients');
      await patientsRef.remove();

      // إعادة حفظ جميع البيانات المحلية
      final updates = <String, dynamic>{};
      for (final patient in localPatients) {
        final dataToSave = patient.toJson();
        dataToSave['lastUpdated'] = ServerValue.timestamp;
        updates['users/$currentUserId/patients/${patient.deviceId}'] =
            dataToSave;
      }

      if (updates.isNotEmpty) {
        await _database.ref().update(updates);
      }

      print(
        'Force synced ${localPatients.length} patient info records to Firebase',
      );
    } catch (e) {
      throw Exception('Failed to force sync patient info: $e');
    }
  }
}
