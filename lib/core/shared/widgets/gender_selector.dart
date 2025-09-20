import 'package:flutter/material.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';
import 'package:spider_doctor/core/shared/theme/my_colors.dart';
import 'package:spider_doctor/features/edit_patient_info/model/patient_info_model.dart';

typedef GenderChanged = void Function(Gender);

/// Reusable gender selector used in forms.
class GenderSelector extends StatelessWidget {
  final Gender value;
  final GenderChanged onChanged;

  const GenderSelector({Key? key, required this.value, required this.onChanged})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              Icon(
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
                          style: const TextStyle(fontFamily: 'NeoSansArabic'),
                        ),
                        value: Gender.male,
                        groupValue: value,
                        onChanged: (v) => onChanged(v!),
                        activeColor: AppColors.primaryColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<Gender>(
                        title: Text(
                          AppLocalizations.of(context).female,
                          style: const TextStyle(fontFamily: 'NeoSansArabic'),
                        ),
                        value: Gender.female,
                        groupValue: value,
                        onChanged: (v) => onChanged(v!),
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
    );
  }
}
