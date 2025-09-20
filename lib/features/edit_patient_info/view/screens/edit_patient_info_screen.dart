import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/widgets/widgets.dart';
import '../../../../core/shared/theme/theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../model/patient_info_model.dart';
import '../../cubit/patient_info_cubit.dart';
import '../../cubit/patient_info_state.dart';
import '../../controllers/edit_patient_info_page_controller.dart';

class EditPatientInfoScreen extends StatefulWidget {
  final String deviceId;
  final PatientInfo? patientInfo;

  const EditPatientInfoScreen({
    super.key,
    required this.deviceId,
    this.patientInfo,
  });

  @override
  State<EditPatientInfoScreen> createState() => _EditPatientInfoScreenState();
}

class _EditPatientInfoScreenState extends State<EditPatientInfoScreen> {
  final EditPatientInfoPageController controller =
      EditPatientInfoPageController();
  PatientInfoCubit? _providedCubit;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller.initializeIfNeeded(context, widget.patientInfo);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // حاول إعادة استخدام PatientInfoCubit إن وجد وإلا أنشئ واحداً محلياً
    try {
      _providedCubit = context.read<PatientInfoCubit>();
    } catch (_) {
      _providedCubit = null;
    }

    // localized data will be requested by reusable widgets when needed

    final content = Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context).editPatientInfo),
      body: BlocListener<PatientInfoCubit, PatientInfoState>(
        listener: (context, state) {
          if (state is PatientInfoSaved) {
            FloatingSnackBar.showSuccess(
              context,
              message: AppLocalizations.of(
                context,
              ).patientInfoUpdatedSuccessfully,
            );
            Navigator.of(context).pop(true);
          } else if (state is PatientInfoError) {
            FloatingSnackBar.showError(context, message: state.message);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GradientHeader(
                    icon: Icons.person_outline,
                    title: AppLocalizations.of(context).updatePatientInfo,
                    subtitle:
                        '${AppLocalizations.of(context).deviceIdDisplay} ${widget.deviceId}',
                  ),
                  const SizedBox(height: 24),

                  // Patient name
                  TextFormField(
                    controller: controller.patientNameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).patientName,
                      hintText: AppLocalizations.of(context).enterPatientName,
                      prefixIcon: const Icon(
                        Icons.person,
                        color: AppColors.primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'NeoSansArabic'),
                  ),
                  const SizedBox(height: 16),

                  // Age
                  TextFormField(
                    controller: controller.ageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).patientAge,
                      hintText: AppLocalizations.of(context).enterPatientAge,
                      prefixIcon: const Icon(
                        Icons.cake,
                        color: AppColors.primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'NeoSansArabic'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(
                          context,
                        ).pleaseEnterPatientAge;
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 1 || age > 150) {
                        return AppLocalizations.of(context).validAgeRange;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  GenderSelector(
                    value: controller.selectedGender,
                    onChanged: (g) =>
                        setState(() => controller.selectedGender = g),
                  ),
                  const SizedBox(height: 16),

                  // Blood type
                  BloodTypeDropdown(
                    selected: controller.selectedBloodType,
                    onChanged: (v) =>
                        setState(() => controller.selectedBloodType = v),
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  TextFormField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      ).phoneNumberOptional,
                      hintText: AppLocalizations.of(context).enterPhoneNumber,
                      prefixIcon: const Icon(
                        Icons.phone,
                        color: AppColors.primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'NeoSansArabic'),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (value.length != 10) {
                          return AppLocalizations.of(context).validPhoneNumber;
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Chronic diseases
                  ChronicDiseasesSelector(
                    selectedDiseases: controller.selectedChronicDiseases,
                    onSelectionChanged: (diseases) {
                      setState(() {
                        controller.selectedChronicDiseases = diseases;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  TextFormField(
                    controller: controller.notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).notes,
                      hintText: AppLocalizations.of(context).addPatientNotes,
                      prefixIcon: const Icon(
                        Icons.note_outlined,
                        color: AppColors.primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'NeoSansArabic'),
                  ),
                  const SizedBox(height: 32),

                  // Save
                  BlocBuilder<PatientInfoCubit, PatientInfoState>(
                    builder: (context, state) {
                      final isLoading = state is PatientInfoSaving;
                      return CustomButton(
                        text: AppLocalizations.of(context).saveChanges,
                        onPressed: isLoading
                            ? null
                            : () => controller.saveChanges(
                                context,
                                widget.deviceId,
                              ),
                        isLoading: isLoading,
                        width: double.infinity,
                        fontFamily: 'NeoSansArabic',
                        fontWeight: FontWeight.bold,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (_providedCubit != null) return content;
    return BlocProvider<PatientInfoCubit>(
      create: (_) => PatientInfoCubit(),
      child: content,
    );
  }
}
