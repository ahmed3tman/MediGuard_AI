// Copied from features/add_device to make chronic selector shared
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
        InkWell(
          onTap: () {
            // Unfocus any focused text field so the keyboard hides before opening the dialog
            FocusScope.of(context).unfocus();
            // slight delay gives the keyboard a moment to dismiss on some platforms
            Future.delayed(const Duration(milliseconds: 50), () {
              _showSelectionDialog(context);
            });
          },
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.primaryColor.withOpacity(0.1),
          highlightColor: AppColors.primaryColor.withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    selectedDiseases.isEmpty ||
                        selectedDiseases.contains(
                          LocalizedData.getChronicDiseases(context).last,
                        )
                    ? Colors.grey.shade300
                    : AppColors.primaryColor.withOpacity(0.5),
                width:
                    selectedDiseases.isEmpty ||
                        selectedDiseases.contains(
                          LocalizedData.getChronicDiseases(context).last,
                        )
                    ? 1
                    : 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
              color:
                  selectedDiseases.isEmpty ||
                      selectedDiseases.contains(
                        LocalizedData.getChronicDiseases(context).last,
                      )
                  ? Colors.grey.shade50
                  : AppColors.primaryColor.withOpacity(0.05),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getDisplayText(context),
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'NeoSansArabic',
                      color:
                          _getDisplayText(context) ==
                              LocalizedData.getChronicDiseases(context).last
                          ? Colors.grey.shade600
                          : Colors.black87,
                      fontWeight:
                          _getDisplayText(context) ==
                              LocalizedData.getChronicDiseases(context).last
                          ? FontWeight.normal
                          : FontWeight.w500,
                    ),
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 150),
                  turns: 0,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color:
                        selectedDiseases.isEmpty ||
                            selectedDiseases.contains(
                              LocalizedData.getChronicDiseases(context).last,
                            )
                        ? Colors.grey.shade600
                        : AppColors.primaryColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getDisplayText(BuildContext context) {
    final diseases = LocalizedData.getChronicDiseases(context);
    final noDiseases = diseases.last; // localized 'No chronic diseases'

    if (selectedDiseases.isEmpty || selectedDiseases.contains(noDiseases)) {
      return noDiseases;
    }

    if (selectedDiseases.length == 1) {
      return selectedDiseases.first;
    }

    if (selectedDiseases.length <= 2) {
      return selectedDiseases.join(' و ');
    }

    return '${selectedDiseases.take(2).join(' و ')} +${selectedDiseases.length - 2}';
  }

  void _showSelectionDialog(BuildContext context) {
    final diseases = LocalizedData.getChronicDiseases(context);
    final noDiseases = diseases.last; // 'No chronic diseases' or 'لا يوجد'
    final availableDiseases = diseases.sublist(0, diseases.length - 1);

    List<String> tempSelected = List.from(selectedDiseases);
    if (tempSelected.contains(noDiseases)) tempSelected.clear();

    // Use a modal bottom sheet with a draggable scrollable sheet to avoid freezes
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(sheetContext).unfocus(),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.35,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).dialogBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).selectChronicDiseasesTitle,
                          style: const TextStyle(
                            fontFamily: 'NeoSansArabic',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (tempSelected.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              ).numberOfSelectedDiseases(tempSelected.length),
                              style: TextStyle(
                                fontFamily: 'NeoSansArabic',
                                fontSize: 12,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: availableDiseases.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                // None option
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tempSelected.isEmpty
                                        ? AppColors.primaryColor.withOpacity(
                                            0.1,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: CheckboxListTile(
                                    title: Text(
                                      noDiseases,
                                      style: TextStyle(
                                        fontFamily: 'NeoSansArabic',
                                        fontWeight: tempSelected.isEmpty
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: tempSelected.isEmpty
                                            ? AppColors.primaryColor
                                            : null,
                                      ),
                                    ),
                                    value: tempSelected.isEmpty,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) tempSelected.clear();
                                      });
                                    },
                                    activeColor: AppColors.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }

                              final disease = availableDiseases[index - 1];
                              final isSelected = tempSelected.contains(disease);
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryColor.withOpacity(0.1)
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CheckboxListTile(
                                  title: Text(
                                    disease,
                                    style: TextStyle(
                                      fontFamily: 'NeoSansArabic',
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : null,
                                    ),
                                  ),
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        if (!tempSelected.contains(disease))
                                          tempSelected.add(disease);
                                      } else {
                                        tempSelected.remove(disease);
                                      }
                                    });
                                  },
                                  activeColor: AppColors.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context).cancel,
                                  style: const TextStyle(
                                    fontFamily: 'NeoSansArabic',
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  List<String> finalSelection =
                                      tempSelected.isEmpty
                                      ? [noDiseases]
                                      : tempSelected;
                                  onSelectionChanged(finalSelection);
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  AppLocalizations.of(context).confirm,
                                  style: const TextStyle(
                                    fontFamily: 'NeoSansArabic',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      // ensure keyboard is unfocused after sheet closed
      FocusScope.of(context).unfocus();
    });
  }
}
