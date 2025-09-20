import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/widgets/widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../edit_patient_info/cubit/patient_info_cubit.dart';
import '../../../edit_patient_info/cubit/patient_info_state.dart';
// DB operations are delegated to the AddDeviceCubit/AddDeviceService
import '../../../add_device/cubit/add_device_cubit.dart';
import '../../controllers/add_device_page_controller.dart';
import '../widgets/patient_information_section.dart';
import '../widgets/info_card.dart';
import '../widgets/add_device_submit_button.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  // Use a controller to hold form controllers and simple page state
  late final AddDevicePageController controller;

  @override
  void initState() {
    super.initState();
    controller = AddDevicePageController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PatientInfoCubit()),
        BlocProvider(create: (_) => AddDeviceCubit()),
      ],
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            appBar: CustomAppBar(
              title: AppLocalizations.of(innerContext).addDeviceScreen,
            ),
            body: BlocListener<PatientInfoCubit, PatientInfoState>(
              listener: (ctx, state) {
                if (state is PatientInfoSaved) {
                  FloatingSnackBar.showSuccess(
                    ctx,
                    message: AppLocalizations.of(
                      ctx,
                    ).deviceAddedAndPatientSaved,
                  );
                  Navigator.of(ctx).pop();
                } else if (state is PatientInfoError) {
                  FloatingSnackBar.showError(ctx, message: state.message);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: controller.formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header illustration
                        const Padding(
                          padding: EdgeInsets.only(bottom: 0),
                          child: GradientHeader(icon: Icons.medical_services),
                        ),
                        const SizedBox(height: 24),

                        // Device ID field with QR scanner (UI-only)
                        DeviceIdField(
                          controller: controller.deviceIdController,
                          onScanPressed: () async {
                            try {
                              await controller.scanQRCode(context);
                            } catch (_) {
                              await controller.enterManualId(context);
                            }
                          },
                          onManualPressed: () =>
                              controller.enterManualId(context),
                        ),
                        const SizedBox(height: 32),

                        // Patient Information Section (extracted)
                        PatientInformationSection(
                          patientNameController:
                              controller.patientNameController,
                          ageController: controller.ageController,
                          phoneController: controller.phoneController,
                          notesController: controller.notesController,
                          selectedGender: controller.selectedGender,
                          onGenderChanged: (g) =>
                              setState(() => controller.selectedGender = g),
                          selectedBloodType: controller.selectedBloodType,
                          onBloodTypeChanged: (v) =>
                              setState(() => controller.selectedBloodType = v),
                          selectedChronicDiseases:
                              controller.selectedChronicDiseases,
                          onChronicDiseasesChanged: (d) => setState(
                            () => controller.selectedChronicDiseases = d,
                          ),
                        ),
                        const SizedBox(height: 24),

                        const AddDeviceInfoCard(),
                        const SizedBox(height: 32),

                        AddDeviceSubmitButton(
                          onPressed: () => controller.submit(innerContext),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _addDeviceAndPatient(BuildContext context) {
    controller.submit(context);
  }
}
