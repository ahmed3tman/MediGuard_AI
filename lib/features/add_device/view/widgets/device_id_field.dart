import 'package:flutter/material.dart';
import '../../../../core/shared/widgets/widgets.dart';
import '../../../../core/shared/theme/my_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

typedef ScanCallback = Future<void> Function();

/// Device ID input row with QR scan button and info box.
class DeviceIdField extends StatelessWidget {
  final TextEditingController controller;
  final ScanCallback onScanPressed;
  final VoidCallback? onManualPressed;

  const DeviceIdField({
    Key? key,
    required this.controller,
    required this.onScanPressed,
    this.onManualPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: controller,
                labelText: AppLocalizations.of(context).deviceId,
                hintText: AppLocalizations.of(context).enterDeviceId,
                prefixIcon: Icons.qr_code,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context).pleaseEnterDeviceId;
                  }
                  if (value.trim().length < 3) {
                    return AppLocalizations.of(context).deviceIdMinLength;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () async {
                  try {
                    await onScanPressed();
                  } catch (_) {
                    if (onManualPressed != null) onManualPressed!();
                  }
                },
                icon: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 28,
                ),
                tooltip: AppLocalizations.of(context).qrScannerTooltip,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Device ID info alert
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).deviceIdInfo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontFamily: 'NeoSansArabic',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
