import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/widgets/widgets.dart';
import '../../../../core/shared/theme/theme.dart';
import '../../../../core/shared/utils/localized_data.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../cubit/patient_info_cubit.dart';
import '../../cubit/patient_info_state.dart';
import '../../model/patient_info_model.dart';
import '../../../add_device/view/widgets/chronic_diseases_selector.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  Gender _selectedGender = Gender.male;
  String _selectedBloodType = '';
  List<String> _selectedChronicDiseases = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _initializeData();
    }
  }

  void _initializeData() {
    final bloodTypes = LocalizedData.getBloodTypes(context);
    final diseases = LocalizedData.getChronicDiseases(context);

    if (widget.patientInfo != null) {
      final info = widget.patientInfo!;
      _patientNameController.text = info.patientName ?? '';
      _ageController.text = info.age.toString();
      _phoneController.text = info.phoneNumber ?? '';
      _notesController.text = info.notes ?? '';
      _selectedGender = info.gender;
      _selectedBloodType = info.bloodType ?? bloodTypes.last; // 'Unspecified'
      _selectedChronicDiseases = info.chronicDiseases.isEmpty
          ? [diseases.last] // 'No chronic diseases'
          : info.chronicDiseases;
    } else {
      _selectedBloodType = bloodTypes.last;
      _selectedChronicDiseases = [diseases.last];
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // حاول إعادة استخدام PatientInfoCubit إن وجد وإلا أنشئ واحداً محلياً
    PatientInfoCubit? existingCubit;
    try {
      existingCubit = context.read<PatientInfoCubit>();
    } catch (_) {
      existingCubit = null;
    }
    final scaffold = Scaffold(
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
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor.withOpacity(0.1),
                          AppColors.primaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 40,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).updatePatientInfo,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'NeoSansArabic',
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${AppLocalizations.of(context).deviceIdDisplay} ${widget.deviceId}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontFamily: 'NeoSansArabic',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Patient name field (optional)
                  TextFormField(
                    controller: _patientNameController,
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

                  // Age field
                  TextFormField(
                    controller: _ageController,
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

                  // Gender selection
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
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
                                        AppLocalizations.of(context).male,
                                        style: const TextStyle(
                                          fontFamily: 'NeoSansArabic',
                                        ),
                                      ),
                                      value: Gender.male,
                                      groupValue: _selectedGender,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedGender = value!;
                                        });
                                      },
                                      activeColor: AppColors.primaryColor,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<Gender>(
                                      title: Text(
                                        AppLocalizations.of(context).female,
                                        style: const TextStyle(
                                          fontFamily: 'NeoSansArabic',
                                        ),
                                      ),
                                      value: Gender.female,
                                      groupValue: _selectedGender,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedGender = value!;
                                        });
                                      },
                                      activeColor: AppColors.primaryColor,
                                      contentPadding: EdgeInsets.zero,
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
                      labelText: AppLocalizations.of(context).bloodType,
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
                          style: const TextStyle(fontFamily: 'NeoSansArabic'),
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

                  // Save button
                  BlocBuilder<PatientInfoCubit, PatientInfoState>(
                    builder: (context, state) {
                      final isLoading = state is PatientInfoSaving;
                      return CustomButton(
                        text: AppLocalizations.of(context).saveChanges,
                        onPressed: isLoading
                            ? null
                            : () => _saveChanges(context),
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
    if (existingCubit != null) {
      return scaffold;
    } else {
      return BlocProvider<PatientInfoCubit>(
        create: (_) => PatientInfoCubit(),
        child: scaffold,
      );
    }
  }

  void _saveChanges(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final age = int.tryParse(_ageController.text.trim()) ?? 0;
      final phoneNumber = _phoneController.text.trim();
      final patientName = _patientNameController.text.trim();
      final notes = _notesController.text.trim();

      context.read<PatientInfoCubit>().updatePatientInfo(
        deviceId: widget.deviceId,
        patientName: patientName.isEmpty ? null : patientName,
        age: age,
        gender: _selectedGender,
        bloodType: _selectedBloodType,
        phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
        chronicDiseases: _selectedChronicDiseases,
        notes: notes.isEmpty ? null : notes,
      );
    }
  }
}
