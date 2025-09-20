import 'package:flutter/material.dart';
import '../../../../core/shared/theme/theme.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ChronicDiseasesSection extends StatelessWidget {
  final List<String> diseases;

  const ChronicDiseasesSection({super.key, required this.diseases});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety,
                size: 14,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context).chronicDiseases,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontFamily: 'NeoSansArabic',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 3,
            children: diseases.map((disease) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  disease,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryColor,
                    fontFamily: 'NeoSansArabic',
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
