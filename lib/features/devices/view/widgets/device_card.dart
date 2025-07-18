import 'dart:ui';
import 'package:flutter/material.dart';
import '../../model/data_model.dart';
import '../../cubit/device_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/generated/app_localizations.dart';

class DeviceCard extends StatelessWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with device name and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        device.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                      ),
                    ),
                    Row(
                      children: [
                        // WiFi status icon only
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: device.hasValidReadings
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            device.hasValidReadings
                                ? Icons.wifi
                                : Icons.wifi_off,
                            color: device.hasValidReadings
                                ? Colors.green[600]
                                : Colors.grey[500],
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Delete button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showDeleteDialog(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.red[400],
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: ${device.deviceId}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),

                // Vital signs grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 4.0,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  children: [
                    _buildVitalSignTile(
                      icon: Icons.thermostat,
                      title: AppLocalizations.of(context).temperature,
                      value: '${device.temperature.toStringAsFixed(1)}°C',
                      isNormal: device.isTemperatureNormal,
                      color: Colors.grey,
                      context: context,
                    ),
                    _buildVitalSignTile(
                      icon: Icons.favorite,
                      title: AppLocalizations.of(context).ecg,
                      value: '${device.ecg.toStringAsFixed(0)} BPM',
                      isNormal: device.ecg >= 60 && device.ecg <= 100,
                      color: Colors.grey,
                      context: context,
                    ),
                    _buildVitalSignTile(
                      icon: Icons.air,
                      title: AppLocalizations.of(context).spo2,
                      value: '${device.spo2.toStringAsFixed(0)}%',
                      isNormal: device.isSpo2Normal,
                      color: Colors.grey,
                      context: context,
                    ),
                    _buildVitalSignTile(
                      icon: Icons.monitor_heart,
                      title: AppLocalizations.of(context).bloodPressure,
                      value:
                          '${device.bloodPressure['systolic']}/${device.bloodPressure['diastolic']}',
                      isNormal: device.isBloodPressureNormal,
                      color: Colors.grey,
                      context: context,
                    ),
                  ],
                ),
                SizedBox(height: 14),
                // Status and last updated information
                if (device.hasValidReadings && device.lastUpdated != null)
                  Text(
                    '${AppLocalizations.of(context).lastUpdated}: ${_formatDateTime(device.lastUpdated!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  )
                else if (device.hasValidReadings)
                  Text(
                    AppLocalizations.of(context).deviceConnected,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green[600],
                      fontSize: 12,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Text(
                      'Waiting for device data...',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVitalSignTile({
    required IconData icon,
    required String title,
    required String value,
    required bool isNormal,
    required Color color,
    required BuildContext context,
  }) {
    // Check if this specific reading has valid data
    bool hasValidReading = false;
    String displayValue = 'Not Connected';

    if (title == 'Temperature' && device.temperature > 0) {
      hasValidReading = true;
      displayValue = value;
    } else if (title == 'ECG' && device.ecg > 0) {
      hasValidReading = true;
      displayValue = value;
    } else if (title == 'SpO2' && device.spo2 > 0) {
      hasValidReading = true;
      displayValue = value;
    } else if (title == 'Blood Pressure' &&
        (device.bloodPressure['systolic']! > 0 ||
            device.bloodPressure['diastolic']! > 0)) {
      hasValidReading = true;
      displayValue = value;
    }

    final displayColor = hasValidReading
        ? (isNormal ? Colors.green : Colors.red)
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: displayColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: displayColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: hasValidReading
                  ? color.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              hasValidReading ? icon : Icons.signal_wifi_off,
              color: hasValidReading ? color : Colors.grey[500],
              size: 12,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: hasValidReading ? Colors.grey[800] : Colors.grey[500],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            displayValue,
            style: TextStyle(
              fontSize: hasValidReading ? 10 : 9,
              fontWeight: FontWeight.w700,
              color: displayColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showDeleteDialog(BuildContext context) {
    final deviceCubit = context.read<DeviceCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Device'),
        content: Text('Are you sure you want to delete "${device.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deviceCubit.deleteDevice(device.deviceId);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
