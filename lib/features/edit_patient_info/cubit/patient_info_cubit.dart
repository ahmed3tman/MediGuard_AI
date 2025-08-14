import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/patient_info_model.dart';
import '../services/patient_info_service.dart';
import 'patient_info_state.dart';

class PatientInfoCubit extends Cubit<PatientInfoState> {
  PatientInfoCubit() : super(PatientInfoInitial());

  /// Load patient information by device ID
  Future<void> loadPatientInfo(String deviceId) async {
    emit(PatientInfoLoading());
    try {
      final patientInfo = await PatientInfoService.getPatientInfo(deviceId);
      emit(PatientInfoLoaded(patientInfo));
    } catch (e) {
      emit(PatientInfoError('Failed to load patient info: ${e.toString()}'));
    }
  }

  /// Save new patient information
  Future<void> savePatientInfo({
    required String deviceId,
    String? patientName,
    required int age,
    required Gender gender,
    String? bloodType,
    String? phoneNumber,
    required List<String> chronicDiseases,
    String? notes,
  }) async {
    emit(PatientInfoSaving());
    try {
      final now = DateTime.now();
      final patientInfo = PatientInfo(
        deviceId: deviceId,
        patientName: patientName?.trim().isEmpty == true
            ? null
            : patientName?.trim(),
        age: age,
        gender: gender,
        bloodType: bloodType == 'غير محدد' ? null : bloodType,
        phoneNumber: phoneNumber?.trim().isEmpty == true
            ? null
            : phoneNumber?.trim(),
        chronicDiseases: chronicDiseases.contains('لا يوجد')
            ? []
            : chronicDiseases,
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await PatientInfoService.savePatientInfo(patientInfo);
      emit(PatientInfoSaved());
      emit(PatientInfoLoaded(patientInfo));
    } catch (e) {
      emit(PatientInfoError('Failed to save patient info: ${e.toString()}'));
    }
  }

  /// Update existing patient information
  Future<void> updatePatientInfo({
    required String deviceId,
    String? patientName,
    required int age,
    required Gender gender,
    String? bloodType,
    String? phoneNumber,
    required List<String> chronicDiseases,
    String? notes,
  }) async {
    emit(PatientInfoSaving());
    try {
      // Get existing patient info to preserve creation date
      final existingInfo = await PatientInfoService.getPatientInfo(deviceId);

      final patientInfo = PatientInfo(
        deviceId: deviceId,
        patientName: patientName?.trim().isEmpty == true
            ? null
            : patientName?.trim(),
        age: age,
        gender: gender,
        bloodType: bloodType == 'غير محدد' ? null : bloodType,
        phoneNumber: phoneNumber?.trim().isEmpty == true
            ? null
            : phoneNumber?.trim(),
        chronicDiseases: chronicDiseases.contains('لا يوجد')
            ? []
            : chronicDiseases,
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
        createdAt: existingInfo?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await PatientInfoService.updatePatientInfo(patientInfo);
      emit(PatientInfoSaved());
      emit(PatientInfoLoaded(patientInfo));
    } catch (e) {
      emit(PatientInfoError('Failed to update patient info: ${e.toString()}'));
    }
  }

  /// Delete patient information
  Future<void> deletePatientInfo(String deviceId) async {
    try {
      await PatientInfoService.deletePatientInfo(deviceId);
      emit(const PatientInfoLoaded(null));
    } catch (e) {
      emit(PatientInfoError('Failed to delete patient info: ${e.toString()}'));
    }
  }

  /// Check if patient info exists
  Future<bool> hasPatientInfo(String deviceId) async {
    try {
      return await PatientInfoService.hasPatientInfo(deviceId);
    } catch (e) {
      return false;
    }
  }

  /// Reset state
  void reset() {
    emit(PatientInfoInitial());
  }
}
