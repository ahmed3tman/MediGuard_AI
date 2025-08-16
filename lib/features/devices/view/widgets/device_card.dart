import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/features/critical_cases/cubit/critical_cases_cubit.dart';
import 'package:spider_doctor/features/patient_detail/view/screens/patient_detail_screen.dart';
import '../../model/data_model.dart';
import '../../cubit/device_cubit.dart';
import '../../../../l10n/generated/app_localizations.dart';

enum VitalSignType {
  temperature,
  heartRate,
  respiratoryRate,
  spo2,
  bloodPressure,
  unknown,
}

enum ButtonState { idle, loading, done }

class DeviceCard extends StatefulWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  @override
  _DeviceCardState createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  ButtonState _buttonState = ButtonState.idle;

  @override
  Widget build(BuildContext context) {
    final isAlreadyCritical = context
        .watch<CriticalCasesCubit>()
        .isDeviceCritical(widget.device.deviceId);
    if (isAlreadyCritical && _buttonState != ButtonState.done) {
      _buttonState = ButtonState.done;
    } else if (!isAlreadyCritical && _buttonState == ButtonState.done) {
      _buttonState = ButtonState.idle;
    }

    return GestureDetector(
      onTap: () => _navigateToPatientDetail(context),
      child: Container(
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.device.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                                fontFamily: 'NeoSansArabic',
                              ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: widget.device.hasValidReadings
                                  ? Colors.green.withOpacity(0.08)
                                  : Colors.grey.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              widget.device.hasValidReadings
                                  ? Icons.wifi
                                  : Icons.wifi_off,
                              color: widget.device.hasValidReadings
                                  ? Colors.green[600]
                                  : Colors.grey[500],
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showDeleteDialog(context),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red[300],
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
                    'ID: ${widget.device.deviceId}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    children: [
                      _buildVitalSignTile(
                        icon: Icons.thermostat,
                        title: AppLocalizations.of(context).temperature,
                        value:
                            '${widget.device.temperature.toStringAsFixed(1)}°C',
                        isNormal: widget.device.isTemperatureNormal,
                        color: Colors.orange[300]!,
                        context: context,
                      ),
                      _buildVitalSignTile(
                        icon: Icons.favorite,
                        title: AppLocalizations.of(context).heartRate,
                        value:
                            '${widget.device.heartRate.toStringAsFixed(0)} BPM',
                        isNormal:
                            widget.device.heartRate >= 60 &&
                            widget.device.heartRate <= 100,
                        color: Colors.red[300]!,
                        context: context,
                      ),
                      _buildVitalSignTile(
                        icon: Icons.air,
                        title: AppLocalizations.of(context).spo2,
                        value: '${widget.device.spo2.toStringAsFixed(0)}%',
                        isNormal: widget.device.isSpo2Normal,
                        color: Colors.blueGrey[300]!,
                        context: context,
                      ),
                      _buildVitalSignTile(
                        icon: Icons.air_outlined,
                        title: AppLocalizations.of(context).respiratoryRate,
                        value:
                            '${widget.device.respiratoryRate.toStringAsFixed(0)} BPM',
                        isNormal: widget.device.isRespiratoryRateNormal,
                        color: Colors.teal[300]!,
                        context: context,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildStatusWidget(context),
                      Spacer(),
                      SizedBox(
                        width: 110,
                        height: 35,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonState == ButtonState.done
                                ? Colors.green[400]
                                : const Color.fromARGB(255, 237, 99, 97),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'NeoSansArabic',
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          onPressed:
                              _buttonState == ButtonState.idle &&
                                  !isAlreadyCritical
                              ? _addToEmergency
                              : null,
                          child: _buildButtonChild(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonChild() {
    switch (_buttonState) {
      case ButtonState.loading:
        return const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case ButtonState.done:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check, size: 16),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context).added,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        );
      case ButtonState.idle:
        return Text(
          AppLocalizations.of(context).addToEmergency,
          style: const TextStyle(fontSize: 10),
        );
    }
  }

  void _addToEmergency() {
    setState(() {
      _buttonState = ButtonState.loading;
    });
    context.read<CriticalCasesCubit>().addCriticalCase(widget.device);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _buttonState = ButtonState.done;
        });
      }
    });
  }

  void _navigateToPatientDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(device: widget.device),
      ),
    );
  }

  Widget _buildStatusWidget(BuildContext context) {
    final lu = widget.device.lastUpdated;
    // 1) No signal at all
    if (lu == null || !widget.device.hasValidReadings) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Text(
          AppLocalizations.of(context).waitingForDeviceData,
          style: TextStyle(
            color: Colors.orange[700],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final diffSeconds = DateTime.now().difference(lu).inSeconds;
    // 2) Real-time (<= 5 seconds)
    if (diffSeconds <= 5) {
      return Text(
        AppLocalizations.of(context).deviceConnected,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.green[600], fontSize: 12),
      );
    }

    // 3) Stale: show last updated since ...
    return Text(
      '${AppLocalizations.of(context).lastUpdated}: ${_formatDateTime(lu, context)}',
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontSize: 11),
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
    bool hasValidReading = false;
    String displayValue = AppLocalizations.of(context).notConnected;

    VitalSignType signType = _getVitalSignType(title, context);

    switch (signType) {
      case VitalSignType.temperature:
        if (widget.device.temperature > 0) {
          hasValidReading = true;
          displayValue = value;
        }
        break;
      case VitalSignType.heartRate:
        if (widget.device.heartRate > 0) {
          hasValidReading = true;
          displayValue = value;
        }
        break;
      case VitalSignType.respiratoryRate:
        if (widget.device.respiratoryRate > 0) {
          hasValidReading = true;
          displayValue = value;
        }
        break;
      case VitalSignType.spo2:
        if (widget.device.spo2 > 0) {
          hasValidReading = true;
          displayValue = value;
        }
        break;
      case VitalSignType.bloodPressure:
        if (widget.device.bloodPressure['systolic']! > 0 ||
            widget.device.bloodPressure['diastolic']! > 0) {
          hasValidReading = true;
          displayValue = value;
        }
        break;
      case VitalSignType.unknown:
        break;
    }

    final displayColor = hasValidReading
        ? (isNormal ? Colors.green : Colors.red)
        : Colors.grey;

    final backgroundColors = hasValidReading
        ? [color.withOpacity(0.1), color.withOpacity(0.05)]
        : [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.05)];

    final borderColor = hasValidReading
        ? color.withOpacity(0.3)
        : Colors.grey.withOpacity(0.3);
    const borderWidth = 1.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: backgroundColors,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
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
                    color: hasValidReading
                        ? Colors.grey[800]
                        : Colors.grey[500],
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
        ),
        if (hasValidReading && !isNormal)
          Positioned(
            top: -6,
            right: -4,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Center(
                child: Text(
                  '!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context).justNow;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  VitalSignType _getVitalSignType(String title, BuildContext context) {
    if (title == AppLocalizations.of(context).temperature ||
        title == 'Temperature') {
      return VitalSignType.temperature;
    } else if (title == AppLocalizations.of(context).heartRate ||
        title == 'Heart Rate') {
      return VitalSignType.heartRate;
    } else if (title == AppLocalizations.of(context).respiratoryRate ||
        title == 'Respiratory Rate') {
      return VitalSignType.respiratoryRate;
    } else if (title == AppLocalizations.of(context).spo2 || title == 'SpO2') {
      return VitalSignType.spo2;
    } else if (title == AppLocalizations.of(context).bloodPressure ||
        title == 'Blood Pressure') {
      return VitalSignType.bloodPressure;
    }
    return VitalSignType.unknown;
  }

  void _showDeleteDialog(BuildContext context) {
    final deviceCubit = context.read<DeviceCubit>();
    final criticalCasesCubit = context.read<CriticalCasesCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteDevice),
        content: Text(
          AppLocalizations.of(context).deleteDeviceConfirm(widget.device.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              deviceCubit.deleteDevice(widget.device.deviceId);
              // Remove from critical cases if exists
              criticalCasesCubit.removeCriticalCase(widget.device.deviceId);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context).delete),
          ),
        ],
      ),
    );
  }
}
