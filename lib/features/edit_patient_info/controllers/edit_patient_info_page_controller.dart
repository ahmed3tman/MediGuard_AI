import 'package:flutter/material.dart';
// no services import required
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/shared/utils/localized_data.dart';
import '../model/patient_info_model.dart';
import '../cubit/patient_info_cubit.dart';

class EditPatientInfoPageController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  Gender selectedGender = Gender.male;
  String selectedBloodType = '';
  List<String> selectedChronicDiseases = [];

  bool _isInitialized = false;

  void initializeIfNeeded(BuildContext context, PatientInfo? patientInfo) {
    if (_isInitialized) return;
    _isInitialized = true;

    final bloodTypes = LocalizedData.getBloodTypes(context);
    final diseases = LocalizedData.getChronicDiseases(context);

    if (patientInfo != null) {
      final info = patientInfo;
      patientNameController.text = info.patientName ?? '';
      ageController.text = info.age.toString();
      phoneController.text = info.phoneNumber ?? '';
      notesController.text = info.notes ?? '';
      selectedGender = info.gender;
      selectedBloodType = info.bloodType ?? bloodTypes.first;
      selectedChronicDiseases = info.chronicDiseases.isEmpty
          ? [diseases.last]
          : info.chronicDiseases;
    } else {
      selectedBloodType = bloodTypes.first;
      selectedChronicDiseases = [diseases.last];
    }
  }

  void dispose() {
    patientNameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    notesController.dispose();
  }

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  PatientInfo buildPatientInfo(String deviceId, BuildContext context) {
    final age = int.tryParse(ageController.text.trim()) ?? 0;
    final phoneNumber = phoneController.text.trim();
    final patientName = patientNameController.text.trim();
    final notes = notesController.text.trim();

    final effectiveBloodType =
        LocalizedData.isBloodTypeUnspecified(selectedBloodType, context)
        ? null
        : selectedBloodType;

    final effectiveChronicDiseases =
        LocalizedData.hasNoChronicDiseases(selectedChronicDiseases, context)
        ? <String>[]
        : selectedChronicDiseases;

    final now = DateTime.now();

    return PatientInfo(
      deviceId: deviceId,
      patientName: patientName.isEmpty ? null : patientName,
      age: age,
      gender: selectedGender,
      bloodType: effectiveBloodType,
      phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
      chronicDiseases: effectiveChronicDiseases,
      notes: notes.isEmpty ? null : notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  void saveChanges(BuildContext context, String deviceId) {
    if (!validateForm()) return;
    final patientInfo = buildPatientInfo(deviceId, context);

    // Expect the screen to provide PatientInfoCubit (it wraps with BlocProvider if none exists)
    context.read<PatientInfoCubit>().updatePatientInfo(
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
