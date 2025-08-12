import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/shared/theme/theme.dart';

class ManualDeviceIdDialog extends StatefulWidget {
  final Function(String) onDeviceIdEntered;

  const ManualDeviceIdDialog({super.key, required this.onDeviceIdEntered});

  @override
  State<ManualDeviceIdDialog> createState() => _ManualDeviceIdDialogState();
}

class _ManualDeviceIdDialogState extends State<ManualDeviceIdDialog> {
  final _deviceIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _deviceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.edit, color: AppColors.primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).enterDeviceIdManually,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NeoSansArabic',
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Instructions
              Text(
                AppLocalizations.of(context).manualEntryInstructions,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: 'NeoSansArabic',
                ),
              ),
              const SizedBox(height: 20),

              // Device ID input field
              TextFormField(
                controller: _deviceIdController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).deviceId,
                  hintText: AppLocalizations.of(context).enterDeviceId,
                  prefixIcon: const Icon(
                    Icons.medical_services,
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
                    return AppLocalizations.of(context).pleaseEnterDeviceId;
                  }
                  if (value.trim().length < 3) {
                    return AppLocalizations.of(context).deviceIdTooShort;
                  }
                  return null;
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-_]')),
                ],
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).cancel,
                        style: const TextStyle(
                          fontFamily: 'NeoSansArabic',
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitDeviceId,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).add,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'NeoSansArabic',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitDeviceId() {
    if (_formKey.currentState!.validate()) {
      final deviceId = _deviceIdController.text.trim();
      widget.onDeviceIdEntered(deviceId);
      Navigator.of(context).pop();
    }
  }
}
