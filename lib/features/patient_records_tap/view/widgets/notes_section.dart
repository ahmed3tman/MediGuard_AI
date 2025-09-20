import 'package:flutter/material.dart';
import '../../../../core/shared/theme/theme.dart';
import '../../../../l10n/generated/app_localizations.dart';

class NotesSection extends StatelessWidget {
  final String notes;

  const NotesSection({super.key, required this.notes});

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
              Icon(Icons.note, size: 14, color: AppColors.primaryColor),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context).notes,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontFamily: 'NeoSansArabic',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            notes,
            style: const TextStyle(fontSize: 12, fontFamily: 'NeoSansArabic'),
          ),
        ],
      ),
    );
  }
}
