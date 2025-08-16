import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/features/patient_record/view/widgets/vital_sign_card.dart';
import 'package:spider_doctor/features/patient_record/view/widgets/ecg_section.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';
import '../../../patient_detail/cubit/patient_detail_cubit.dart';
import '../../../patient_detail/cubit/patient_detail_state.dart';
import '../../../patient_detail/model/patient_vital_signs.dart';
import '../../../edit_patient_info/cubit/patient_info_cubit.dart';
import '../../../edit_patient_info/services/firebase_patient_info_service.dart';
import '../../../edit_patient_info/view/screens/edit_patient_info_screen.dart';
import '../../../edit_patient_info/view/widgets/patient_info_card.dart';

/// Patient record screen showing real-time vital signs and ECG chart
class PatientRecordScreen extends StatefulWidget {
  const PatientRecordScreen({super.key});

  @override
  State<PatientRecordScreen> createState() => _PatientRecordScreenState();
}

class _PatientRecordScreenState extends State<PatientRecordScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isNavigatingToEdit = false;
  @override
  void initState() {
    super.initState();
    // Initial one-time load (kept as fallback); stream will handle realtime
    final patientDetailCubit = context.read<PatientDetailCubit>();
    context.read<PatientInfoCubit>().loadPatientInfo(
      patientDetailCubit.deviceId,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for keep alive
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<PatientDetailCubit, PatientDetailState>(
      buildWhen: (previous, current) {
        // Rebuild the whole page only when switching state types (e.g., loading -> loaded -> error).
        if (previous.runtimeType != current.runtimeType) return true;
        // If both are loaded, avoid rebuilding the entire page; inner BlocSelectors will update only numbers.
        return !(previous is PatientDetailLoaded &&
            current is PatientDetailLoaded);
      },
      builder: (context, state) {
        if (state is! PatientDetailLoaded) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.initializingPatientMonitoring),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<PatientDetailCubit>().refreshData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Information Section
                _buildRealtimePatientInfoSection(),
                // Vital Signs Grid
                _buildVitalSignsGrid(l10n),
                //  const SizedBox(height: 4),

                // Blood Pressure Section (moved before ECG)
                _buildBloodPressureSection(l10n),
                const SizedBox(height: 20),

                // ECG Chart Section
                _buildEcgSection(l10n),
                const SizedBox(height: 30),

                // Controls
                _buildControlsSection(l10n),
                const SizedBox(height: 40), // Space for FAB
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  // Lightweight view models are defined after the widget class

  Widget _buildVitalSignsGrid(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.vitalSignsTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            // Temperature
            BlocSelector<PatientDetailCubit, PatientDetailState, double>(
              selector: (state) => state is PatientDetailLoaded
                  ? state.vitalSigns.temperature
                  : 0.0,
              builder: (context, temp) {
                final isConnected = temp > 0;
                return VitalSignCard(
                  title: l10n.temperature,
                  value: _getTemperatureDisplay(temp, l10n),
                  unit: isConnected ? '°C' : '',
                  icon: Icons.thermostat,
                  color: Colors.deepOrange.shade300,
                  isConnected: isConnected,
                );
              },
            ),
            // Heart rate
            BlocSelector<PatientDetailCubit, PatientDetailState, double>(
              selector: (state) => state is PatientDetailLoaded
                  ? state.vitalSigns.heartRate
                  : 0.0,
              builder: (context, hr) {
                final isConnected = hr > 0;
                return VitalSignCard(
                  title: l10n.heartRate,
                  value: _getHeartRateDisplay(hr, l10n),
                  unit: isConnected ? 'BPM' : '',
                  icon: Icons.favorite,
                  color: Colors.red.shade300,
                  isConnected: isConnected,
                );
              },
            ),
            // Respiratory rate
            BlocSelector<PatientDetailCubit, PatientDetailState, double>(
              selector: (state) => state is PatientDetailLoaded
                  ? state.vitalSigns.respiratoryRate
                  : 0.0,
              builder: (context, rr) {
                final isConnected = rr > 0;
                return VitalSignCard(
                  title: l10n.respiratoryRate,
                  value: _getRespiratoryRateDisplay(rr, l10n),
                  unit: isConnected ? 'BPM' : '',
                  icon: Icons.air_outlined,
                  color: Colors.teal.shade300,
                  isConnected: isConnected,
                );
              },
            ),
            // SpO2
            BlocSelector<PatientDetailCubit, PatientDetailState, double>(
              selector: (state) =>
                  state is PatientDetailLoaded ? state.vitalSigns.spo2 : 0.0,
              builder: (context, spo2) {
                final isConnected = spo2 > 0;
                return VitalSignCard(
                  title: l10n.spo2,
                  value: _getSpo2Display(spo2, l10n),
                  unit: isConnected ? '%' : '',
                  icon: Icons.air,
                  color: Colors.cyan.shade400,
                  isConnected: isConnected,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRealtimePatientInfoSection() {
    final deviceId = context.read<PatientDetailCubit>().deviceId;
    return StreamBuilder(
      stream: FirebasePatientInfoService.getPatientInfoStream(deviceId),
      builder: (context, snapshot) {
        // Debug logging
        // ignore: avoid_print
        print(
          'PatientInfo stream snapshot: hasData=${snapshot.hasData} err=${snapshot.error}',
        );
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final patientInfo = snapshot.data;
        if (patientInfo == null) {
          return const SizedBox.shrink();
        }
        return Column(
          children: [
            PatientInfoCard(
              patientInfo: patientInfo,
              onEdit: () {
                if (_isNavigatingToEdit) return; // guard
                _isNavigatingToEdit = true;
                _editPatientInfo(context, patientInfo).whenComplete(() {
                  // small delay to avoid race
                  Future.delayed(const Duration(milliseconds: 150), () {
                    if (mounted) _isNavigatingToEdit = false;
                  });
                });
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildEcgSection(AppLocalizations l10n) {
    return BlocSelector<PatientDetailCubit, PatientDetailState, _EcgViewData>(
      selector: (state) {
        if (state is PatientDetailLoaded) {
          return _EcgViewData(
            readings: state.ecgReadings,
            vitalSigns: state.vitalSigns,
          );
        }
        return const _EcgViewData(readings: [], vitalSigns: null);
      },
      builder: (context, data) {
        if (data.vitalSigns == null) return const SizedBox.shrink();
        return EcgSection(
          ecgReadings: data.readings,
          vitalSigns: data.vitalSigns!,
          l10n: l10n,
        );
      },
    );
  }

  Widget _buildControlsSection(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.monitoringControlsTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'NeoSansArabic',
            ),
          ),

          const SizedBox(height: 8),
          Text(
            l10n.monitoringControlsDescription,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return l10n.timeJustNow;
    } else if (difference.inMinutes < 60) {
      return l10n.timeMinutesAgo(difference.inMinutes.toString());
    } else if (difference.inHours < 24) {
      return l10n.timeHoursAgo(difference.inHours.toString());
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  // Helper methods for accurate data display
  String _getTemperatureDisplay(double temperature, AppLocalizations l10n) {
    if (temperature <= 0) {
      return l10n.deviceNotConnected;
    }
    return temperature.toStringAsFixed(1);
  }

  String _getHeartRateDisplay(double heartRate, AppLocalizations l10n) {
    if (heartRate <= 0) {
      return l10n.deviceNotConnected;
    }
    return heartRate.toStringAsFixed(0);
  }

  String _getBloodPressureDisplay(
    Map<String, dynamic> bloodPressure,
    AppLocalizations l10n,
  ) {
    final systolic = bloodPressure['systolic'] ?? 0;
    final diastolic = bloodPressure['diastolic'] ?? 0;

    if (systolic <= 0 || diastolic <= 0) {
      return l10n.deviceNotConnected;
    }
    return '$systolic/$diastolic';
  }

  bool _isBloodPressureConnected(Map<String, dynamic> bloodPressure) {
    final systolic = bloodPressure['systolic'] ?? 0;
    final diastolic = bloodPressure['diastolic'] ?? 0;
    return systolic > 0 && diastolic > 0;
  }

  String _getSpo2Display(double spo2, AppLocalizations l10n) {
    if (spo2 <= 0) {
      return l10n.deviceNotConnected;
    }
    return spo2.toStringAsFixed(0);
  }

  String _getRespiratoryRateDisplay(
    double respiratoryRate,
    AppLocalizations l10n,
  ) {
    if (respiratoryRate <= 0) {
      return l10n.deviceNotConnected;
    }
    return respiratoryRate.toStringAsFixed(0);
  }

  Widget _buildBloodPressureSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.bloodPressure,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        BlocSelector<PatientDetailCubit, PatientDetailState, _BpViewData>(
          selector: (state) {
            if (state is! PatientDetailLoaded) {
              return const _BpViewData(0, 0, false, false);
            }
            final bp = state.vitalSigns.bloodPressure;
            final sys = bp['systolic'] ?? 0;
            final dia = bp['diastolic'] ?? 0;
            final connected = sys > 0 && dia > 0;
            final normal =
                connected && sys >= 90 && sys <= 120 && dia >= 60 && dia <= 80;
            return _BpViewData(sys, dia, connected, normal);
          },
          builder: (context, bp) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.indigo.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.monitor_heart,
                    size: 28,
                    color: Colors.indigo.shade300,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bp.connected
                              ? '${bp.sys}/${bp.dia}'
                              : l10n.deviceNotConnected,
                          style: TextStyle(
                            fontSize: bp.connected ? 20 : 14,
                            fontWeight: FontWeight.bold,
                            color: bp.connected
                                ? (bp.normal
                                      ? Colors.green[700]
                                      : Colors.red[700])
                                : Colors.grey[600],
                          ),
                        ),
                        if (bp.connected)
                          Text(
                            'mmHg',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: bp.connected
                          ? (bp.normal ? Colors.green[100] : Colors.red[100])
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      bp.connected
                          ? (bp.normal ? l10n.normal : l10n.abnormal)
                          : l10n.deviceNotConnected,
                      style: TextStyle(
                        fontSize: bp.connected ? 10 : 8,
                        fontWeight: FontWeight.w600,
                        color: bp.connected
                            ? (bp.normal ? Colors.green[700] : Colors.red[700])
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _editPatientInfo(BuildContext context, patientInfo) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPatientInfoScreen(
          deviceId: patientInfo.deviceId,
          patientInfo: patientInfo,
        ),
      ),
    );

    // Reload patient info if changes were made
    if (result == true) {
      context.read<PatientInfoCubit>().loadPatientInfo(patientInfo.deviceId);
    }
  }
}

// Lightweight view models used by BlocSelectors to limit rebuild scope
class _EcgViewData {
  final List<EcgReading> readings;
  final PatientVitalSigns? vitalSigns;
  const _EcgViewData({required this.readings, required this.vitalSigns});
}

class _BpViewData {
  final int sys;
  final int dia;
  final bool connected;
  final bool normal;
  const _BpViewData(this.sys, this.dia, this.connected, this.normal);
}
