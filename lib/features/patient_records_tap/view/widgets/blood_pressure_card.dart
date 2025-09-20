import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';
import '../../../patient_detail/cubit/patient_detail_cubit.dart';
import '../../../patient_detail/cubit/patient_detail_state.dart';

class BloodPressureCard extends StatelessWidget {
  final AppLocalizations l10n;
  const BloodPressureCard({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
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
}

// keep the same local model used elsewhere
class _BpViewData {
  final int sys;
  final int dia;
  final bool connected;
  final bool normal;
  const _BpViewData(this.sys, this.dia, this.connected, this.normal);
}
