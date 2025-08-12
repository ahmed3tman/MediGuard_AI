import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';

class LocalizedData {
  static List<String> getBloodTypes(BuildContext context) {
    return [
      AppLocalizations.of(context).unspecifiedBloodType,
      'A+',
      'A-',
      'B+',
      'B-',
      'AB+',
      'AB-',
      'O+',
      'O-',
    ];
  }

  static List<String> getChronicDiseases(BuildContext context) {
    return [
      AppLocalizations.of(context).diabetes,
      AppLocalizations.of(context).hypertension,
      AppLocalizations.of(context).heartDisease,
      AppLocalizations.of(context).asthma,
      AppLocalizations.of(context).arthritis,
      AppLocalizations.of(context).kidneyDisease,
      AppLocalizations.of(context).liverDisease,
      AppLocalizations.of(context).cancer,
      AppLocalizations.of(context).epilepsy,
      AppLocalizations.of(context).depression,
      AppLocalizations.of(context).anxietyDisorders,
      AppLocalizations.of(context).osteoporosis,
      AppLocalizations.of(context).thyroidDisease,
      AppLocalizations.of(context).cholesterol,
      AppLocalizations.of(context).noChronicDiseases,
    ];
  }

  // Helper method to get the localized "unspecified" value for blood type
  static String getUnspecifiedBloodType(BuildContext context) {
    return AppLocalizations.of(context).unspecifiedBloodType;
  }

  // Helper method to get the localized "none" value for chronic diseases
  static String getNoDiseases(BuildContext context) {
    return AppLocalizations.of(context).noChronicDiseases;
  }

  // Helper method to check if a blood type is unspecified
  static bool isBloodTypeUnspecified(String? bloodType, BuildContext context) {
    return bloodType == null ||
        bloodType == AppLocalizations.of(context).unspecifiedBloodType ||
        bloodType == 'غير محدد';
  }

  // Helper method to check if chronic diseases list indicates "none"
  static bool hasNoChronicDiseases(
    List<String> diseases,
    BuildContext context,
  ) {
    return diseases.isEmpty ||
        diseases.contains(AppLocalizations.of(context).noChronicDiseases) ||
        diseases.contains('لا يوجد');
  }
}
