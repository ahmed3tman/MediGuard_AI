import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// widgets are imported via the feature widgets barrel
import 'package:spider_doctor/l10n/generated/app_localizations.dart';
import '../../../patient_detail/cubit/patient_detail_cubit.dart';
import '../../../patient_detail/cubit/patient_detail_state.dart';
import '../../../edit_patient_info/cubit/patient_info_cubit.dart';
import '../../../edit_patient_info/services/firebase_patient_info_service.dart';
import '../../../edit_patient_info/view/screens/edit_patient_info_screen.dart';
import '../widgets/widgets.dart';
import '../../controllers/patient_record_page_controller.dart';

/// Patient record screen showing real-time vital signs and ECG chart
class PatientRecordScreen extends StatefulWidget {
  const PatientRecordScreen({super.key});

  @override
  State<PatientRecordScreen> createState() => _PatientRecordScreenState();
}

class _PatientRecordScreenState extends State<PatientRecordScreen>
    with AutomaticKeepAliveClientMixin {
  final controller =
      // ...existing code...
      // controller handles scroll and simple page actions
      PatientRecordPageController();
  bool _isNavigatingToEdit = false;

  @override
  void initState() {
    super.initState();
    final patientDetailCubit = context.read<PatientDetailCubit>();
    // delegate load to PatientInfoCubit as before
    context.read<PatientInfoCubit>().loadPatientInfo(
      patientDetailCubit.deviceId,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<PatientDetailCubit, PatientDetailState>(
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        return !(previous is PatientDetailLoaded &&
            current is PatientDetailLoaded);
      },
      builder: (context, state) {
        if (state is! PatientDetailLoaded) {
          return const _PatientRecordLoading();
        }

        return _PatientRecordContent(
          l10n: l10n,
          onRefresh: () => context.read<PatientDetailCubit>().refreshData(),
          onEditPatient: (patientInfo) async {
            if (_isNavigatingToEdit) return;
            _isNavigatingToEdit = true;
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPatientInfoScreen(
                  deviceId: patientInfo.deviceId,
                  patientInfo: patientInfo,
                ),
              ),
            );
            if (result == true) {
              context.read<PatientInfoCubit>().loadPatientInfo(
                patientInfo.deviceId,
              );
            }
            // small delay before allowing navigation again
            Future.delayed(const Duration(milliseconds: 150), () {
              if (mounted) _isNavigatingToEdit = false;
            });
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// --- UI-only helper widgets -------------------------------------------------

class _PatientRecordLoading extends StatelessWidget {
  const _PatientRecordLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
}

class _PatientRecordContent extends StatelessWidget {
  final AppLocalizations l10n;
  final Future<void> Function() onRefresh;
  final Future<void> Function(dynamic patientInfo) onEditPatient;

  const _PatientRecordContent({
    required this.l10n,
    required this.onRefresh,
    required this.onEditPatient,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Information Section
            _RealtimePatientInfo(onEditPatient: onEditPatient),
            // Vital Signs Grid
            PatientRecordWidgets.vitalSignsGrid(context, l10n),
            // Blood Pressure
            const SizedBox(height: 12),
            PatientRecordWidgets.bloodPressureSection(context, l10n),
            const SizedBox(height: 20),
            // ECG
            PatientRecordWidgets.ecgSection(context, l10n),
            const SizedBox(height: 30),
            // Controls
            PatientRecordWidgets.controlsSection(context, l10n),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _RealtimePatientInfo extends StatelessWidget {
  final Future<void> Function(dynamic patientInfo) onEditPatient;
  const _RealtimePatientInfo({required this.onEditPatient, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceId = context.read<PatientDetailCubit>().deviceId;
    return StreamBuilder(
      stream: FirebasePatientInfoService.getPatientInfoStream(deviceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const SizedBox.shrink();
        final patientInfo = snapshot.data;
        if (patientInfo == null) return const SizedBox.shrink();
        return Column(
          children: [
            PatientInfoCard(
              patientInfo: patientInfo,
              onEdit: () => onEditPatient(patientInfo),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

