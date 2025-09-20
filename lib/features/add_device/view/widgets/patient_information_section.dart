import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/shared/widgets/widgets.dart';
import '../../../../core/shared/theme/theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../edit_patient_info/model/patient_info_model.dart';
// moved to shared widgets barrel

class PatientInformationSection extends StatelessWidget {
  const PatientInformationSection({
    super.key,
    required this.patientNameController,
    required this.ageController,
    required this.phoneController,
    required this.notesController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.selectedBloodType,
    required this.onBloodTypeChanged,
    required this.selectedChronicDiseases,
    required this.onChronicDiseasesChanged,
  });

  final TextEditingController patientNameController;
  final TextEditingController ageController;
  final TextEditingController phoneController;
  final TextEditingController notesController;

  final Gender selectedGender;
  final ValueChanged<Gender> onGenderChanged;

  final String selectedBloodType;
  final ValueChanged<String> onBloodTypeChanged;

  final List<String> selectedChronicDiseases;
  final ValueChanged<List<String>> onChronicDiseasesChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_add, color: AppColors.primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).patientInformation,
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
            controller: patientNameController,
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppLocalizations.of(context).pleaseEnterPatientName;
              }
              if (value.trim().length < 2) {
                return AppLocalizations.of(context).patientNameMinLength;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Age field
          TextFormField(
            controller: ageController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).patientAge,
              hintText: AppLocalizations.of(context).enterPatientAge,
              prefixIcon: const Icon(Icons.cake, color: AppColors.primaryColor),
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
                return AppLocalizations.of(context).pleaseEnterPatientAge;
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
          GenderSelector(value: selectedGender, onChanged: onGenderChanged),
          const SizedBox(height: 16),

          // Blood type dropdown
          BloodTypeDropdown(
            selected: selectedBloodType,
            onChanged: onBloodTypeChanged,
          ),
          const SizedBox(height: 16),

          // Phone number field
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).phoneNumberOptional,
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
            selectedDiseases: selectedChronicDiseases,
            onSelectionChanged: onChronicDiseasesChanged,
          ),
          const SizedBox(height: 16),

          // Notes field
          TextFormField(
            controller: notesController,
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
        ],
      ),
    );
  }
}
