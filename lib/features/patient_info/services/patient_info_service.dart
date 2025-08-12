import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/patient_info_model.dart';

class PatientInfoService {
  static const String _keyPrefix = 'patient_info_';

  /// Save patient information locally
  static Future<void> savePatientInfo(PatientInfo patientInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyPrefix + patientInfo.deviceId;
      final jsonString = jsonEncode(patientInfo.toJson());
      await prefs.setString(key, jsonString);
    } catch (e) {
      throw Exception('Failed to save patient info: $e');
    }
  }

  /// Get patient information by device ID
  static Future<PatientInfo?> getPatientInfo(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyPrefix + deviceId;
      final jsonString = prefs.getString(key);

      if (jsonString == null) return null;

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return PatientInfo.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Failed to load patient info: $e');
    }
  }

  /// Update patient information
  static Future<void> updatePatientInfo(PatientInfo patientInfo) async {
    try {
      final updatedPatientInfo = patientInfo.copyWith(
        updatedAt: DateTime.now(),
      );
      await savePatientInfo(updatedPatientInfo);
    } catch (e) {
      throw Exception('Failed to update patient info: $e');
    }
  }

  /// Delete patient information
  static Future<void> deletePatientInfo(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyPrefix + deviceId;
      await prefs.remove(key);
    } catch (e) {
      throw Exception('Failed to delete patient info: $e');
    }
  }

  /// Get all patient information records
  static Future<List<PatientInfo>> getAllPatientInfo() async {
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
      throw Exception('Failed to load all patient info: $e');
    }
  }

  /// Check if patient info exists for device
  static Future<bool> hasPatientInfo(String deviceId) async {
    try {
      final patientInfo = await getPatientInfo(deviceId);
      return patientInfo != null;
    } catch (e) {
      return false;
    }
  }
}
