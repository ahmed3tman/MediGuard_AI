import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/core/shared/widgets/state_widgets.dart';
import 'package:spider_doctor/features/devices/model/data_model.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';
import '../../cubit/patient_detail_cubit.dart';
import '../../cubit/patient_detail_state.dart';
import '../widgets/patient_detail_doctor_tab.dart';
import '../../../medical_assistant/view/screens/medical_assistant_screen.dart';
import '../../../medical_assistant/cubit/medical_assistant_cubit.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (context) => PatientDetailCubit(
        deviceId: widget.device.deviceId,
        patientName: widget.device.name,
      )..initialize(),
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: Text(widget.device.name),
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.local_hospital),
                    text: l10n.doctorTab, // Primary medical view
                  ),
                  Tab(
                    icon: const Icon(Icons.smart_toy),
                    text: l10n.aiTab, // AI assistant tab
                  ),
                ],
              ),
            ),
            body: BlocBuilder<PatientDetailCubit, PatientDetailState>(
              builder: (context, state) {
                if (state is PatientDetailLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(l10n.loadingPatientData),
                      ],
                    ),
                  );
                } else if (state is PatientDetailError) {
                  return Center(
                    child: ErrorStateWidget(
                      title: l10n.errorPrefix,
                      message: state.message,
                      buttonText: l10n.retryButton,
                      onButtonPressed: () =>
                          context.read<PatientDetailCubit>().initialize(),
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Doctor Tab - Main medical monitoring view
                    const PatientDetailDoctorTab(),

                    // AI Assistant Tab - New Smart Medical Assistant
                    BlocProvider(
                      create: (context) => MedicalAssistantCubit(),
                      child: Builder(
                        builder: (context) {
                          // جمع بيانات المريض من الحالة
                          Map<String, dynamic> patientData = {};

                          if (state is PatientDetailLoaded) {
                            patientData = {
                              'patientName': widget.device.name,
                              'deviceId': widget.device.deviceId,
                              'temperature': state.vitalSigns.temperature,
                              'heartRate': state.vitalSigns.heartRate,
                              'bloodPressure': {
                                'systolic':
                                    state.vitalSigns.bloodPressure['systolic'],
                                'diastolic':
                                    state.vitalSigns.bloodPressure['diastolic'],
                              },
                              'spo2': state.vitalSigns.spo2,
                              'age':
                                  30, // يمكن إضافة عمر المريض من قاعدة البيانات
                              'lastUpdated': state.vitalSigns.timestamp,
                            };
                          }

                          return MedicalAssistantScreen(
                            patientData: patientData,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
