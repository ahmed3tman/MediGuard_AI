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

    try {
      final patientRef = _database.ref(
        'users/$currentUserId/patients/${patientInfo.deviceId}',
      );
      await patientRef.set(patientInfo.toJson());
      print('Patient info saved to Firebase: ${patientInfo.deviceId}');
    } catch (e) {
      throw Exception('Failed to save patient info to Firebase: $e');
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

  /// Update patient information in Firebase
  static Future<void> updatePatientInfo(PatientInfo patientInfo) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final updatedPatientInfo = patientInfo.copyWith(
        updatedAt: DateTime.now(),
      );
      await savePatientInfo(updatedPatientInfo);
    } catch (e) {
      throw Exception('Failed to update patient info in Firebase: $e');
    }
  }

  /// Delete patient information from Firebase
  static Future<void> deletePatientInfo(String deviceId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final patientRef = _database.ref(
        'users/$currentUserId/patients/$deviceId',
      );
      await patientRef.remove();
      print('Patient info deleted from Firebase: $deviceId');
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
        return patientsMap.values
            .map(
              (patientData) => PatientInfo.fromJson(
                Map<String, dynamic>.from(patientData as Map),
              ),
            )
            .toList();
      } catch (e) {
        print('Error parsing patients from stream: $e');
        return <PatientInfo>[];
      }
    });
  }
}
