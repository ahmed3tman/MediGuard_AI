import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/patient_info_model.dart';
import 'firebase_patient_info_service.dart';
import '../../devices/services/device_service.dart';
import '../../devices/model/data_model.dart';

class PatientInfoService {
  static const String _keyPrefix = 'patient_info_';

  /// Save patient information to both Firebase and local storage
  /// Firebase is primary, local is backup for offline use
  static Future<void> savePatientInfo(PatientInfo patientInfo) async {
    try {
      // Save to Firebase first (primary storage)
      // Ensure patient has nested device if not provided (initial structure)
      final enriched = patientInfo.device != null
          ? patientInfo
          : patientInfo.copyWith(
              device: Device(
                deviceId: patientInfo.deviceId,
                name:
                    patientInfo.patientName ?? 'Device ${patientInfo.deviceId}',
                readings: {
                  'temperature': 0.0,
                  'heartRate': 0.0,
                  'respiratoryRate': 0.0,
                  'spo2': 0.0,
                  'bloodPressure': {'systolic': 0, 'diastolic': 0},
                  'ecg': 0.0,
                },
                lastUpdated: null,
              ),
            );

      await FirebasePatientInfoService.savePatientInfo(enriched);

      // Also save locally as backup for offline use
      await _saveToLocal(patientInfo);

      // مزامنة اسم الجهاز مع اسم المريض
      if (patientInfo.patientName != null &&
          patientInfo.patientName!.isNotEmpty) {
        try {
          await DeviceService.updateDeviceName(
            patientInfo.deviceId,
            patientInfo.patientName!,
          );
        } catch (e) {
          print('Failed to sync device name during save: $e');
        }
      }
    } catch (firebaseError) {
      print('Firebase save failed, saving locally: $firebaseError');
      // If Firebase fails, still save locally
      await _saveToLocal(patientInfo);

      // حاول مزامنة اسم الجهاز حتى لو فشل Firebase
      if (patientInfo.patientName != null &&
          patientInfo.patientName!.isNotEmpty) {
        try {
          await DeviceService.updateDeviceName(
            patientInfo.deviceId,
            patientInfo.patientName!,
          );
        } catch (e) {
          print('Failed to sync device name locally during save: $e');
        }
      }
    }
  }

  /// Get patient information (Firebase first, local fallback)
  static Future<PatientInfo?> getPatientInfo(String deviceId) async {
    try {
      // Try Firebase first
      final firebaseInfo = await FirebasePatientInfoService.getPatientInfo(
        deviceId,
      );
      if (firebaseInfo != null) {
        // Also update local storage with Firebase data
        await _saveToLocal(firebaseInfo);
        return firebaseInfo;
      }
    } catch (e) {
      print('Firebase fetch failed, trying local: $e');
    }

    // Fallback to local storage
    return await _getFromLocal(deviceId);
  }

  /// Update patient information
  static Future<void> updatePatientInfo(PatientInfo patientInfo) async {
    try {
      final updatedPatientInfo = patientInfo.copyWith(
        updatedAt: DateTime.now(),
      );

      // Update Firebase first
      final enriched = updatedPatientInfo.device != null
          ? updatedPatientInfo.copyWith(
              device: updatedPatientInfo.device!.copyWith(
                name:
                    updatedPatientInfo.patientName ??
                    updatedPatientInfo.device!.name,
              ),
            )
          : updatedPatientInfo.copyWith(
              device: Device(
                deviceId: updatedPatientInfo.deviceId,
                name:
                    updatedPatientInfo.patientName ??
                    'Device ${updatedPatientInfo.deviceId}',
                readings:
                    updatedPatientInfo.device?.readings ??
                    {
                      'temperature': 0.0,
                      'heartRate': 0.0,
                      'respiratoryRate': 0.0,
                      'spo2': 0.0,
                      'bloodPressure': {'systolic': 0, 'diastolic': 0},
                      'ecg': 0.0,
                    },
                lastUpdated: null,
              ),
            );

      await FirebasePatientInfoService.updatePatientInfo(enriched);

      // Also update locally
      await _saveToLocal(updatedPatientInfo);

      // مزامنة اسم الجهاز مع اسم المريض
      if (updatedPatientInfo.patientName != null &&
          updatedPatientInfo.patientName!.isNotEmpty) {
        try {
          // تحديث اسم الجهاز ليطابق اسم المريض
          await DeviceService.updateDeviceName(
            updatedPatientInfo.deviceId,
            updatedPatientInfo.patientName!,
          );
        } catch (e) {
          print('Failed to sync device name: $e');
          // لا نرمي خطأ هنا لأن تحديث معلومات المريض نجح
        }
      }
    } catch (firebaseError) {
      print('Firebase update failed, updating locally: $firebaseError');
      // If Firebase fails, still update locally
      final localUpdate = patientInfo.copyWith(updatedAt: DateTime.now());
      await _saveToLocal(localUpdate);

      // حاول مزامنة اسم الجهاز حتى لو فشل Firebase
      if (localUpdate.patientName != null &&
          localUpdate.patientName!.isNotEmpty) {
        try {
          await DeviceService.updateDeviceName(
            localUpdate.deviceId,
            localUpdate.patientName!,
          );
        } catch (e) {
          print('Failed to sync device name locally: $e');
        }
      }
    }
  }

  /// Delete patient information
  static Future<void> deletePatientInfo(String deviceId) async {
    try {
      // Delete from Firebase
      await FirebasePatientInfoService.deletePatientInfo(deviceId);
    } catch (e) {
      print('Firebase delete failed: $e');
    }

    // Always delete locally regardless
    await _deleteFromLocal(deviceId);
  }

  /// Get all patient information records
  static Future<List<PatientInfo>> getAllPatientInfo() async {
    try {
      // Try Firebase first
      final firebasePatients =
          await FirebasePatientInfoService.getAllPatientInfo();
      if (firebasePatients.isNotEmpty) {
        // Update local storage with Firebase data
        for (final patient in firebasePatients) {
          await _saveToLocal(patient);
        }
        return firebasePatients;
      }
    } catch (e) {
      print('Firebase get all failed, trying local: $e');
    }

    // Fallback to local storage
    return await _getAllFromLocal();
  }

  /// Check if patient info exists for device
  static Future<bool> hasPatientInfo(String deviceId) async {
    try {
      // Check Firebase first
      return await FirebasePatientInfoService.hasPatientInfo(deviceId);
    } catch (e) {
      // Fallback to local check
      final localInfo = await _getFromLocal(deviceId);
      return localInfo != null;
    }
  }

  /// Sync local data to Firebase (called when connection restored)
  static Future<void> syncToFirebase() async {
    try {
      final localPatients = await _getAllFromLocal();
      for (final patient in localPatients) {
        try {
          await FirebasePatientInfoService.savePatientInfo(patient);
        } catch (e) {
          print('Failed to sync patient ${patient.deviceId}: $e');
        }
      }
    } catch (e) {
      print('Sync to Firebase failed: $e');
    }
  }

  // Private methods for local storage operations
  static Future<void> _saveToLocal(PatientInfo patientInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyPrefix + patientInfo.deviceId;
      final jsonString = jsonEncode(patientInfo.toJson());
      await prefs.setString(key, jsonString);
    } catch (e) {
      throw Exception('Failed to save patient info locally: $e');
    }
  }

  static Future<PatientInfo?> _getFromLocal(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyPrefix + deviceId;
      final jsonString = prefs.getString(key);

      if (jsonString == null) return null;

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return PatientInfo.fromJson(jsonMap);
    } catch (e) {
      print('Failed to load patient info locally: $e');
      return null;
    }
  }

  static Future<void> _deleteFromLocal(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyPrefix + deviceId;
      await prefs.remove(key);
    } catch (e) {
      print('Failed to delete patient info locally: $e');
    }
  }

  static Future<List<PatientInfo>> _getAllFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));

      final List<PatientInfo> patientInfoList = [];
      for (final key in keys) {
        final jsonString = prefs.getString(key);
        if (jsonString != null) {
          final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
          patientInfoList.add(PatientInfo.fromJson(jsonMap));
        }
      }

      return patientInfoList;
    } catch (e) {
      print('Failed to load all patient info locally: $e');
      return [];
    }
  }
}
