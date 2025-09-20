import 'package:flutter/material.dart';
import 'package:spider_doctor/core/shared/utils/localized_data.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';

typedef BloodTypeChanged = void Function(String);

class BloodTypeDropdown extends StatelessWidget {
  final String selected;
  final BloodTypeChanged onChanged;

  const BloodTypeDropdown({
    Key? key,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloodTypes = LocalizedData.getBloodTypes(context);
    final safeSelected = selected.isEmpty || !bloodTypes.contains(selected)
        ? bloodTypes.first
        : selected;
    final matches = bloodTypes.where((b) => b == safeSelected).length;
    final dropdownValue = matches == 1 ? safeSelected : null;

    return DropdownButtonFormField<String>(
      value: dropdownValue,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).bloodType,
        prefixIcon: const Icon(Icons.water_drop_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: bloodTypes.map((bloodType) {
        return DropdownMenuItem(
          value: bloodType,
          child: Text(
            bloodType,
            style: const TextStyle(fontFamily: 'NeoSansArabic'),
          ),
        );
      }).toList(),
      onChanged: (v) => onChanged(v!),
    );
  }
}
