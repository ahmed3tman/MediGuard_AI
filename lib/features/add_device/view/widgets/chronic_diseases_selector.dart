import 'package:flutter/material.dart';
import '../../../../core/shared/theme/theme.dart';
import '../../../../core/shared/utils/localized_data.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ChronicDiseasesSelector extends StatelessWidget {
  final List<String> selectedDiseases;
  final Function(List<String>) onSelectionChanged;

  const ChronicDiseasesSelector({
    super.key,
    required this.selectedDiseases,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).chronicDiseases,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'NeoSansArabic',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getDisplayText(context),
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'NeoSansArabic',
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _showSelectionDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  AppLocalizations.of(context).selectChronicDiseases,
                  style: const TextStyle(fontFamily: 'NeoSansArabic'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDisplayText(BuildContext context) {
    final diseases = LocalizedData.getChronicDiseases(context);
    final noDiseases = diseases.last; // 'No chronic diseases' or 'لا يوجد'

    if (selectedDiseases.isEmpty || selectedDiseases.contains(noDiseases)) {
      return noDiseases;
    }

    return selectedDiseases.join(', ');
  }

  void _showSelectionDialog(BuildContext context) {
    final diseases = LocalizedData.getChronicDiseases(context);
    final noDiseases = diseases.last; // 'No chronic diseases' or 'لا يوجد'
    final availableDiseases = diseases.sublist(
      0,
      diseases.length - 1,
    ); // All except 'No chronic diseases'

    List<String> tempSelected = List.from(selectedDiseases);
    if (tempSelected.contains(noDiseases)) {
      tempSelected.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context).selectChronicDiseases,
                style: const TextStyle(fontFamily: 'NeoSansArabic'),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // None option
                    CheckboxListTile(
                      title: Text(
                        noDiseases,
                        style: const TextStyle(fontFamily: 'NeoSansArabic'),
                      ),
                      value: tempSelected.isEmpty,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelected.clear();
                          }
                        });
                      },
                      activeColor: AppColors.primaryColor,
                    ),
                    const Divider(),
                    // Disease options
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableDiseases.length,
                        itemBuilder: (context, index) {
                          final disease = availableDiseases[index];
                          return CheckboxListTile(
                            title: Text(
                              disease,
                              style: const TextStyle(
                                fontFamily: 'NeoSansArabic',
                              ),
                            ),
                            value: tempSelected.contains(disease),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  if (!tempSelected.contains(disease)) {
                                    tempSelected.add(disease);
                                  }
                                } else {
                                  tempSelected.remove(disease);
                                }
                              });
                            },
                            activeColor: AppColors.primaryColor,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    AppLocalizations.of(context).cancel,
                    style: const TextStyle(fontFamily: 'NeoSansArabic'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    List<String> finalSelection = tempSelected.isEmpty
                        ? [noDiseases]
                        : tempSelected;
                    onSelectionChanged(finalSelection);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    AppLocalizations.of(context).confirm,
                    style: const TextStyle(fontFamily: 'NeoSansArabic'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
