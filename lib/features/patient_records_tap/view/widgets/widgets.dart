export 'vital_sign_card.dart';
export 'ecg_section.dart';
export 'patient_info_card.dart';
export 'patient_info_item.dart';
export 'chronic_diseases_section.dart';
export 'notes_section.dart';
export 'blood_pressure_card.dart';
export 'monitoring_controls_card.dart';
import 'blood_pressure_card.dart';
import 'monitoring_controls_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';
import '../../../patient_detail/cubit/patient_detail_cubit.dart';
import '../../../patient_detail/cubit/patient_detail_state.dart';
import '../../../patient_detail/model/patient_vital_signs.dart';
import 'vital_sign_card.dart';
import 'ecg_section.dart';

/// Small UI helpers for `patient_record_screen` to keep that screen UI-only.
class PatientRecordWidgets {
  static Widget vitalSignsGrid(BuildContext context, AppLocalizations l10n) {
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
                  value: temp <= 0
                      ? l10n.deviceNotConnected
                      : temp.toStringAsFixed(1),
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
                  value: hr <= 0
                      ? l10n.deviceNotConnected
                      : hr.toStringAsFixed(0),
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
                  value: rr <= 0
                      ? l10n.deviceNotConnected
                      : rr.toStringAsFixed(0),
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
                  value: spo2 <= 0
                      ? l10n.deviceNotConnected
                      : spo2.toStringAsFixed(0),
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

  static Widget bloodPressureSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return BloodPressureCard(l10n: l10n);
  }

  static Widget ecgSection(BuildContext context, AppLocalizations l10n) {
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

  static Widget controlsSection(BuildContext context, AppLocalizations l10n) {
    return MonitoringControlsCard(l10n: l10n);
  }
}

// Local lightweight view models used by the widgets helpers
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
