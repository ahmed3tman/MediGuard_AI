import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/features/patient_record/view/widgets/ecg_section.dart';
import 'package:spider_doctor/features/patient_record/view/widgets/vital_sign_card.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';
import '../../../patient_detail/cubit/patient_detail_cubit.dart';
import '../../../patient_detail/cubit/patient_detail_state.dart';
import '../../../patient_detail/model/patient_vital_signs.dart';
import '../../../patient_info/cubit/patient_info_cubit.dart';
import '../../../patient_info/cubit/patient_info_state.dart';
import '../../../patient_info/view/screens/edit_patient_info_screen.dart';
import '../../../patient_info/view/widgets/patient_info_card.dart';

/// Doctor tab showing real-time vital signs and ECG chart
class PatientDetailDoctorTab extends StatefulWidget {
  const PatientDetailDoctorTab({super.key});

  @override
  State<PatientDetailDoctorTab> createState() => _PatientDetailDoctorTabState();
}

class _PatientDetailDoctorTabState extends State<PatientDetailDoctorTab> {
  @override
  void initState() {
    super.initState();
    // Load patient info when tab is initialized
    final patientDetailCubit = context.read<PatientDetailCubit>();
    context.read<PatientInfoCubit>().loadPatientInfo(
      patientDetailCubit.deviceId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<PatientDetailCubit, PatientDetailState>(
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

        final vitalSigns = state.vitalSigns;
        final ecgReadings = state.ecgReadings;

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
                BlocBuilder<PatientInfoCubit, PatientInfoState>(
                  builder: (context, patientState) {
                    if (patientState is PatientInfoLoaded &&
                        patientState.patientInfo != null) {
                      return Column(
                        children: [
                          PatientInfoCard(
                            patientInfo: patientState.patientInfo!,
                            onEdit: () => _editPatientInfo(
                              context,
                              patientState.patientInfo!,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                // Vital Signs Grid
                _buildVitalSignsGrid(vitalSigns, l10n),
                const SizedBox(height: 20),

                // Blood Pressure Section (moved before ECG)
                _buildBloodPressureSection(vitalSigns, l10n),
                const SizedBox(height: 20),

                // ECG Chart Section
                _buildEcgSection(ecgReadings, vitalSigns, l10n),
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

  Widget _buildVitalSignsGrid(
    PatientVitalSigns vitalSigns,
    AppLocalizations l10n,
  ) {
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
            VitalSignCard(
              title: l10n.temperature,
              value: _getTemperatureDisplay(vitalSigns.temperature, l10n),
              unit: vitalSigns.temperature > 0 ? '°C' : '',
              icon: Icons.thermostat,
              color: Colors.deepOrange.shade300,
              isConnected: vitalSigns.temperature > 0,
            ),
            VitalSignCard(
              title: l10n.heartRate,
              value: _getHeartRateDisplay(vitalSigns.heartRate, l10n),
              unit: vitalSigns.heartRate > 0 ? 'BPM' : '',
              icon: Icons.favorite,
              color: Colors.red.shade300,
              isConnected: vitalSigns.heartRate > 0,
            ),
            VitalSignCard(
              title: l10n.respiratoryRate,
              value: _getRespiratoryRateDisplay(
                vitalSigns.respiratoryRate,
                l10n,
              ),
              unit: vitalSigns.respiratoryRate > 0 ? 'BPM' : '',
              icon: Icons.air_outlined,
              color: Colors.teal.shade300,
              isConnected: vitalSigns.respiratoryRate > 0,
            ),
            VitalSignCard(
              title: l10n.spo2,
              value: _getSpo2Display(vitalSigns.spo2, l10n),
              unit: vitalSigns.spo2 > 0 ? '%' : '',
              icon: Icons.air,
              color: Colors.cyan.shade400,
              isConnected: vitalSigns.spo2 > 0,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEcgSection(
    List<EcgReading> ecgReadings,
    PatientVitalSigns vitalSigns,
    AppLocalizations l10n,
  ) {
    return EcgSection(
      ecgReadings: ecgReadings,
      vitalSigns: vitalSigns,
      l10n: l10n,
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

  Widget _buildBloodPressureSection(
    PatientVitalSigns vitalSigns,
    AppLocalizations l10n,
  ) {
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.indigo.withOpacity(0.2),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.monitor_heart,
                size: 40,
                color: Colors.indigo.shade300,
              ),
              const SizedBox(height: 10),
              Text(
                _getBloodPressureDisplay(vitalSigns.bloodPressure, l10n),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _isBloodPressureConnected(vitalSigns.bloodPressure)
                      ? (vitalSigns.isBloodPressureNormal
                            ? Colors.green[700]
                            : Colors.red[700])
                      : Colors.grey[600],
                ),
              ),
              if (_isBloodPressureConnected(vitalSigns.bloodPressure))
                Text(
                  'mmHg',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isBloodPressureConnected(vitalSigns.bloodPressure)
                      ? (vitalSigns.isBloodPressureNormal
                            ? Colors.green[100]
                            : Colors.red[100])
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isBloodPressureConnected(vitalSigns.bloodPressure)
                      ? (vitalSigns.isBloodPressureNormal
                            ? l10n.normal
                            : l10n.abnormal)
                      : l10n.deviceNotConnected,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isBloodPressureConnected(vitalSigns.bloodPressure)
                        ? (vitalSigns.isBloodPressureNormal
                              ? Colors.green[700]
                              : Colors.red[700])
                        : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editPatientInfo(BuildContext context, patientInfo) async {
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
