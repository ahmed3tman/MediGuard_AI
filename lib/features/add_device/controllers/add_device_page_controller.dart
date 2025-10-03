import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../edit_patient_info/model/patient_info_model.dart'
    show PatientInfo, Gender;
import '../cubit/add_device_cubit.dart';
import '../view/widgets/qr_scanner_dialog.dart';
import '../view/widgets/manual_device_id_dialog.dart';
import '../../../core/shared/widgets/widgets.dart';
import '../../../core/shared/utils/localized_data.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../devices/services/device_service.dart'
    show DeviceNotFoundException;

/// Controller that holds controllers and simple state for the Add Device page.
/// Keeps UI (the Widget) thin by moving logic here.
class AddDevicePageController {
  final formKey = GlobalKey<FormState>();

  final deviceIdController = TextEditingController();
  final patientNameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final notesController = TextEditingController();

  Gender selectedGender = Gender.male;
  String selectedBloodType = '';
  List<String> selectedChronicDiseases = [];

  void dispose() {
    deviceIdController.dispose();
    patientNameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    notesController.dispose();
  }

  Future<void> scanQRCode(BuildContext context) async {
    try {
      await showDialog<String>(
        context: context,
        builder: (c) => QRScannerDialog(
          onCodeScanned: (code) {
            deviceIdController.text = code;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(
                    context,
                  ).deviceIdScannedSuccessfully(code),
                  style: const TextStyle(fontFamily: 'NeoSansArabic'),
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      );
    } catch (_) {
      // rethrow to let caller decide; UI screens may fallback to manual entry
      rethrow;
    }
  }

  Future<void> enterManualId(BuildContext context) async {
    await showDialog<String>(
      context: context,
      builder: (c) => ManualDeviceIdDialog(
        onDeviceIdEntered: (deviceId) {
          deviceIdController.text = deviceId;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).deviceIdEnteredManually(deviceId),
                style: const TextStyle(fontFamily: 'NeoSansArabic'),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  /// Validate form and build PatientInfo model.
  PatientInfo? buildPatientInfo(BuildContext context) {
    if (!formKey.currentState!.validate()) return null;

    final patientId = deviceIdController.text.trim();
    final patientName = patientNameController.text.trim();
    final age = int.tryParse(ageController.text.trim()) ?? 0;
    final phoneNumber = phoneController.text.trim();
    final notes = notesController.text.trim();

    final effectiveBloodType = selectedBloodType.isEmpty
        ? LocalizedData.getUnspecifiedBloodType(context)
        : selectedBloodType;

    final effectiveChronicDiseases = selectedChronicDiseases.isEmpty
        ? [LocalizedData.getNoDiseases(context)]
        : selectedChronicDiseases;

    final now = DateTime.now();

    return PatientInfo(
      deviceId: patientId,
      patientName: patientName.isEmpty ? null : patientName,
      age: age,
      gender: selectedGender,
      bloodType:
          LocalizedData.isBloodTypeUnspecified(effectiveBloodType, context)
          ? null
          : effectiveBloodType,
      phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
      chronicDiseases:
          LocalizedData.hasNoChronicDiseases(effectiveChronicDiseases, context)
          ? []
          : effectiveChronicDiseases,
      notes: notes.isEmpty ? null : notes,
      createdAt: now,
      updatedAt: now,
      device: null,
    );
  }

  /// Orchestrates the add device + save patient flow by calling the AddDeviceCubit
  /// through the BuildContext (cubits must be provided by the caller).
  Future<void> submit(BuildContext context) async {
    final patientInfo = buildPatientInfo(context);
    if (patientInfo == null) return;

    try {
      await context.read<AddDeviceCubit>().addDeviceAndPatient(
        context: context,
        patientInfo: patientInfo,
      );
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      if (e is DeviceNotFoundException) {
        FloatingSnackBar.showError(
          context,
          message: l10n.deviceSerialNotFound(e.deviceId),
        );
      } else {
        FloatingSnackBar.showError(context, message: e.toString());
      }
    }
  }
}
