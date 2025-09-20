import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../edit_patient_info/cubit/patient_info_cubit.dart';
import '../../edit_patient_info/model/patient_info_model.dart';
import '../../devices/services/device_service.dart';

/// Small helper to centralize the DB operations used when adding a device + patient.
///
/// This keeps the screen free of raw DB calls while still delegating state
/// management to the existing `PatientInfoCubit` (called via the provided
/// BuildContext) so the UI listeners and loading states remain unchanged.
class AddDeviceService {
  /// Links the physical device and saves the patient metadata.
  ///
  /// Throws any exception from the underlying services.
  static Future<void> addDeviceAndSavePatient(
    BuildContext context,
    PatientInfo patientInfo,
  ) async {
    // Ensure device exists and is linked to the current user
    await DeviceService.addDevice(
      patientInfo.deviceId,
      patientInfo.patientName ?? 'Device ${patientInfo.deviceId}',
    );

    // Delegate the patient metadata save to the PatientInfoCubit so that
    // existing loading/success/error flows and listeners continue to work.
    // We intentionally don't await here because cubit returns a Future; keep
    // behavior consistent by awaiting to surface any thrown exceptions.
    await context.read<PatientInfoCubit>().savePatientInfo(
      deviceId: patientInfo.deviceId,
      patientName: patientInfo.patientName,
      age: patientInfo.age,
      gender: patientInfo.gender,
      bloodType: patientInfo.bloodType,
      phoneNumber: patientInfo.phoneNumber,
      chronicDiseases: patientInfo.chronicDiseases,
      notes: patientInfo.notes,
    );
  }
}
