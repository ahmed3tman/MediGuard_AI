import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/widgets/widgets.dart';
import '../../../../core/shared/theme/theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../patient_info/cubit/patient_info_cubit.dart';
import '../../../patient_info/cubit/patient_info_state.dart';
import '../../../patient_info/model/patient_info_model.dart';
import '../../../devices/model/data_model.dart';
import '../widgets/chronic_diseases_selector.dart';
import '../widgets/qr_scanner_dialog.dart';
import '../widgets/manual_device_id_dialog.dart';

/// شاشة محدثة لإنشاء مريض + جهاز (متداخل) مرة واحدة بدون تكرار في Firebase
class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceIdController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  Gender _selectedGender = Gender.male;
  String _selectedBloodType = 'غير محدد';
  List<String> _selectedChronicDiseases = ['لا يوجد'];

  @override
  void dispose() {
    _deviceIdController.dispose();
    _patientNameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _scanQRCode() async {
    try {
      await showDialog<String>(
        context: context,
        builder: (context) => QRScannerDialog(
          onCodeScanned: (code) {
            setState(() {
              _deviceIdController.text = code;
            });
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
    } catch (e) {
      // If QR scanner fails, show manual input dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).cameraNotAccessible,
            style: const TextStyle(fontFamily: 'NeoSansArabic'),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      _enterManualId();
    }
  }

  void _enterManualId() async {
    await showDialog<String>(
      context: context,
      builder: (context) => ManualDeviceIdDialog(
        onDeviceIdEntered: (deviceId) {
          setState(() {
            _deviceIdController.text = deviceId;
          });
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => PatientInfoCubit())],
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
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header illustration
                        GradientContainer(
                          height: 120,
                          colors: [
                            AppColors.primaryColor.withOpacity(0.1),
                            AppColors.primaryColor.withOpacity(0.05),
                          ],
                          borderRadius: BorderRadius.circular(12),
                          child: const Center(
                            child: Icon(
                              Icons.medical_services,
                              size: 60,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Device ID field with QR scanner
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _deviceIdController,
                                    labelText: AppLocalizations.of(
                                      context,
                                    ).deviceId,
                                    hintText: AppLocalizations.of(
                                      context,
                                    ).enterDeviceId,
                                    prefixIcon: Icons.qr_code,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return AppLocalizations.of(
                                          context,
                                        ).pleaseEnterDeviceId;
                                      }
                                      if (value.trim().length < 3) {
                                        return AppLocalizations.of(
                                          context,
                                        ).deviceIdMinLength;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  height: 56,
                                  width: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryColor
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    onPressed: _scanQRCode,
                                    icon: const Icon(
                                      Icons.qr_code_scanner,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    tooltip: AppLocalizations.of(
                                      context,
                                    ).qrScannerTooltip,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Device ID info alert
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue[700],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context).deviceIdInfo,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue[700],
                                        fontFamily: 'NeoSansArabic',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Patient Information Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_add,
                                    color: AppColors.primaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    ).patientInformation,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'NeoSansArabic',
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Patient name field
                              TextFormField(
                                controller: _patientNameController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(
                                    context,
                                  ).patientName,
                                  hintText: AppLocalizations.of(
                                    context,
                                  ).enterPatientName,
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
                                style: const TextStyle(
                                  fontFamily: 'NeoSansArabic',
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Age field
                              TextFormField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(
                                    context,
                                  ).patientAge,
                                  hintText: AppLocalizations.of(
                                    context,
                                  ).enterPatientAge,
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
                                style: const TextStyle(
                                  fontFamily: 'NeoSansArabic',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    ).pleaseEnterPatientAge;
                                  }
                                  final age = int.tryParse(value);
                                  if (age == null || age < 1 || age > 150) {
                                    return AppLocalizations.of(
                                      context,
                                    ).validAgeRange;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Gender selection
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context).gender,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                        fontFamily: 'NeoSansArabic',
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.person_outline,
                                          color: AppColors.primaryColor,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: RadioListTile<Gender>(
                                                  title: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    ).male,
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          'NeoSansArabic',
                                                    ),
                                                  ),
                                                  value: Gender.male,
                                                  groupValue: _selectedGender,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedGender = value!;
                                                    });
                                                  },
                                                  activeColor:
                                                      AppColors.primaryColor,
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                ),
                                              ),
                                              Expanded(
                                                child: RadioListTile<Gender>(
                                                  title: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    ).female,
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          'NeoSansArabic',
                                                    ),
                                                  ),
                                                  value: Gender.female,
                                                  groupValue: _selectedGender,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedGender = value!;
                                                    });
                                                  },
                                                  activeColor:
                                                      AppColors.primaryColor,
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Blood type dropdown
                              DropdownButtonFormField<String>(
                                value: _selectedBloodType,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(
                                    context,
                                  ).bloodType,
                                  prefixIcon: const Icon(
                                    Icons.water_drop_outlined,
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
                                items: BloodTypes.types.map((bloodType) {
                                  return DropdownMenuItem(
                                    value: bloodType,
                                    child: Text(
                                      bloodType,
                                      style: const TextStyle(
                                        fontFamily: 'NeoSansArabic',
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedBloodType = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              // Phone number field
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(
                                    context,
                                  ).phoneNumberOptional,
                                  hintText: AppLocalizations.of(
                                    context,
                                  ).enterPhoneNumber,
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
                                style: const TextStyle(
                                  fontFamily: 'NeoSansArabic',
                                ),
                                validator: (value) {
                                  if (value != null &&
                                      value.trim().isNotEmpty) {
                                    if (value.length != 10) {
                                      return AppLocalizations.of(
                                        context,
                                      ).validPhoneNumber;
                                    }
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Chronic diseases selector
                              ChronicDiseasesSelector(
                                selectedDiseases: _selectedChronicDiseases,
                                onSelectionChanged: (diseases) {
                                  setState(() {
                                    _selectedChronicDiseases = diseases;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              // Notes field
                              TextFormField(
                                controller: _notesController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).notes,
                                  hintText: AppLocalizations.of(
                                    context,
                                  ).addPatientNotes,
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
                                style: const TextStyle(
                                  fontFamily: 'NeoSansArabic',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Info card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.amber[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context).patientDataInfo,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'NeoSansArabic',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        BlocBuilder<PatientInfoCubit, PatientInfoState>(
                          builder: (ctx, patientState) {
                            final isPatientLoading =
                                patientState is PatientInfoSaving;
                            return CustomButton(
                              text: AppLocalizations.of(
                                ctx,
                              ).addDeviceAndPatient,
                              onPressed: () =>
                                  _addDeviceAndPatient(innerContext),
                              isLoading: isPatientLoading,
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
        },
      ),
    );
  }

  void _addDeviceAndPatient(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return; // context here هو الداخلي بعد MultiBlocProvider
    }

    final patientId = _deviceIdController.text.trim(); // نستخدمه كمُعرف موحد
    final patientName = _patientNameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    final phoneNumber = _phoneController.text.trim();
    final notes = _notesController.text.trim();

    final device = Device(
      deviceId: patientId,
      name: patientName.isNotEmpty ? patientName : 'جهاز $patientId',
      readings: {
        'temperature': 0.0,
        'heartRate': 0.0,
        'respiratoryRate': 0.0,
        'spo2': 0.0,
        'bloodPressure': {'systolic': 0, 'diastolic': 0},
        'ecg': 0.0,
      },
      lastUpdated: null,
    );

    final now = DateTime.now();
    final patientInfo = PatientInfo(
      deviceId: patientId,
      patientName: patientName.isEmpty ? null : patientName,
      age: age,
      gender: _selectedGender,
      bloodType: _selectedBloodType == 'غير محدد' ? null : _selectedBloodType,
      phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
      chronicDiseases: _selectedChronicDiseases.contains('لا يوجد')
          ? []
          : _selectedChronicDiseases,
      notes: notes.isEmpty ? null : notes,
      createdAt: now,
      updatedAt: now,
      device: device,
    );

    context.read<PatientInfoCubit>().savePatientInfo(
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
