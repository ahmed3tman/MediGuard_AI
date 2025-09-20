import 'package:flutter/material.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';

class VitalSignCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final Color color;
  final bool isConnected;

  const VitalSignCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    this.isConnected = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isConnected ? color.withOpacity(0.3) : Colors.grey[300]!,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 32,
                width: 32,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isConnected
                      ? color.withOpacity(0.10)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: isConnected ? color : Colors.grey[400],
                  size: 18,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 9,
                      color: isConnected ? Colors.green[700] : Colors.grey[500],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      isConnected
                          ? l10n.connectedStatus
                          : l10n.offlineStatusSmall,
                      style: TextStyle(
                        fontSize: 8,
                        color: isConnected
                            ? Colors.green[700]
                            : Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          if (isConnected) ...[
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    if (unit.isNotEmpty)
                      TextSpan(
                        text: ' $unit',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Text(
              value,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
