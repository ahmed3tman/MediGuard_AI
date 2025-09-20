import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/core/shared/widgets/state_widgets.dart';
import 'package:spider_doctor/features/devices/model/data_model.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';
import '../../cubit/patient_detail_cubit.dart';
import '../../cubit/patient_detail_state.dart';
import '../../../patient_records_tap/view/screens/patient_records_screen.dart';
import '../../../medical_assistant_tap/view/screens/medical_assistant_tap.dart';
import '../../../medical_assistant_tap/cubit/medical_assistant_cubit.dart';
import '../../../edit_patient_info/cubit/patient_info_cubit.dart';
import '../../../edit_patient_info/cubit/patient_info_state.dart';
import '../../../edit_patient_info/services/patient_info_service.dart';
import '../../../../core/localization/locale_cubit.dart';

/// Main patient detail screen with tabbed interface
class PatientDetailScreen extends StatefulWidget {
  final Device device;

  const PatientDetailScreen({super.key, required this.device});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late final PatientDetailCubit _patientDetailCubit;
  late final PatientInfoCubit _patientInfoCubit;
  late final MedicalAssistantCubit _medicalAssistantCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Instantiate cubits once
    _patientDetailCubit = PatientDetailCubit(
      deviceId: widget.device.deviceId,
      patientName: widget.device.name,
    );
    _patientInfoCubit = PatientInfoCubit();
    _medicalAssistantCubit = MedicalAssistantCubit();
    // Initialize streams
    _patientDetailCubit.initialize();
    // Load patient profile for this device so all tabs (including AI) have accurate data
    _patientInfoCubit.loadPatientInfo(widget.device.deviceId);
    // مزامنة الاسم عند فتح الشاشة
    _syncPatientName();
  }

  /// مزامنة اسم الجهاز مع اسم المريض
  Future<void> _syncPatientName() async {
    try {
      final patientInfo = await PatientInfoService.getPatientInfo(
        widget.device.deviceId,
      );
      if (patientInfo?.patientName != null &&
          patientInfo!.patientName!.isNotEmpty &&
          widget.device.name != patientInfo.patientName) {
        // تحديث اسم الجهاز إذا كان مختلفاً عن اسم المريض
        widget.device.copyWith(name: patientInfo.patientName);
      }
    } catch (e) {
      print('Failed to sync patient name: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _patientDetailCubit.close();
    _patientInfoCubit.close();
    _medicalAssistantCubit.resetChat();
    _medicalAssistantCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider<PatientDetailCubit>.value(value: _patientDetailCubit),
        BlocProvider<PatientInfoCubit>.value(value: _patientInfoCubit),
        BlocProvider<MedicalAssistantCubit>.value(
          value: _medicalAssistantCubit,
        ),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return WillPopScope(
            onWillPop: () async {
              // Reset chat to prevent late emissions after disposal
              if (mounted) {
                context.read<MedicalAssistantCubit>().resetChat();
              }
              return true;
            },
            child: Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: AppBar(
                title: Text(
                  widget.device.name,
                  style: const TextStyle(fontFamily: 'NeoSansArabic'),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.monitor_heart,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.doctorTab, // existing key for medical record tab
                            style: const TextStyle(
                              fontFamily: 'NeoSansArabic',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.smart_toy,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.aiTab, // already "المساعد الذكي" in ar, can update en value if needed
                            style: const TextStyle(
                              fontFamily: 'NeoSansArabic',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              body: BlocBuilder<PatientDetailCubit, PatientDetailState>(
                builder: (context, state) {
                  if (state is PatientDetailInitial ||
                      state is PatientDetailLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is PatientDetailError) {
                    return ErrorStateWidget(
                      title: 'خطأ',
                      message: state.message,
                      buttonText: l10n.retryButton,
                      onButtonPressed: () =>
                          context.read<PatientDetailCubit>().initialize(),
                    );
                  }

                  final loadedState = state as PatientDetailLoaded;

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // Patient Record Tab - contains its own patient info card
                      const PatientRecordScreen(),
                      // AI Assistant Tab (single cubit instance)
                      Builder(
                        builder: (context) {
                          final assistantCubit = context
                              .read<MedicalAssistantCubit>();
                          Map<String, dynamic> patientData = {
                            'patientName': widget.device.name,
                            'deviceId': widget.device.deviceId,
                            'temperature': loadedState.vitalSigns.temperature,
                            'heartRate': loadedState.vitalSigns.heartRate,
                            'respiratoryRate':
                                loadedState.vitalSigns.respiratoryRate,
                            'bloodPressure': {
                              'systolic': loadedState
                                  .vitalSigns
                                  .bloodPressure['systolic'],
                              'diastolic': loadedState
                                  .vitalSigns
                                  .bloodPressure['diastolic'],
                            },
                            'spo2': loadedState.vitalSigns.spo2,
                            'lastUpdated': loadedState.vitalSigns.timestamp,
                          };

                          final patientInfoState = context
                              .watch<PatientInfoCubit>()
                              .state;
                          if (patientInfoState is PatientInfoLoaded &&
                              patientInfoState.patientInfo != null) {
                            final p = patientInfoState.patientInfo!;
                            patientData.addAll({
                              // Prefer saved profile name if available
                              if ((p.patientName ?? '').isNotEmpty)
                                'patientName': p.patientName,
                              'age': p.age,
                              // Only include gender if explicitly set (prevents default male leakage)
                              if (p.genderExplicit) 'gender': p.gender.name,
                              'bloodType': p.bloodType,
                              'chronicDiseases': p.chronicDiseases,
                              'notes': p.notes,
                            });
                          }

                          // Update data without reinitializing if same patient
                          assistantCubit.updatePatientData(patientData);
                          assistantCubit.initializeChat(patientData, context);

                          return MedicalAssistantScreen(
                            patientData: patientData,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
