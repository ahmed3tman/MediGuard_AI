import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/core/shared/widgets/state_widgets.dart';
import 'package:spider_doctor/features/devices/model/data_model.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';
import '../../cubit/patient_detail_cubit.dart';
import '../../cubit/patient_detail_state.dart';
import '../../../patient_record/view/screens/patient_record_screen.dart';
import '../../../medical_assistant_tap/view/screens/medical_assistant_tap.dart';
import '../../../medical_assistant_tap/cubit/medical_assistant_cubit.dart';
import '../../../patient_info/cubit/patient_info_cubit.dart';
import '../../../patient_info/cubit/patient_info_state.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PatientDetailCubit(
            deviceId: widget.device.deviceId,
            patientName: widget.device.name,
          )..initialize(),
        ),
        BlocProvider(create: (context) => PatientInfoCubit()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: Text(
                widget.device.name,
                style: const TextStyle(
                  fontFamily: 'NeoSansArabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                indicatorWeight: 1,
                // labelStyle: const TextStyle(
                //   fontFamily: 'NeoSansArabic',
                //   fontWeight: FontWeight.bold,
                //   fontSize: 14,
                // ),
                // unselectedLabelStyle: const TextStyle(
                //   fontFamily: 'NeoSansArabic',
                //   fontWeight: FontWeight.normal,
                //   fontSize: 13,
                // ),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.local_hospital),
                    child: Text(
                      l10n.doctorTab,
                      style: const TextStyle(
                        fontFamily: 'NeoSansArabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Tab(
                    icon: const Icon(Icons.smart_toy),
                    child: Text(
                      l10n.aiTab,
                      style: const TextStyle(
                        fontFamily: 'NeoSansArabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
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
                    // Patient Record Tab - Main medical monitoring view
                    const PatientRecordScreen(),

                    // AI Assistant Tab - New Smart Medical Assistant
                    BlocProvider(
                      create: (context) => MedicalAssistantCubit(),
                      child: Builder(
                        builder: (context) {
                          // جمع بيانات المريض من الحالة مع معلومات المريض المحفوظة
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
                              'lastUpdated': state.vitalSigns.timestamp,
                            };

                            // إضافة معلومات المريض المحفوظة محلياً
                            return BlocBuilder<
                              PatientInfoCubit,
                              PatientInfoState
                            >(
                              builder: (context, patientInfoState) {
                                // تحميل معلومات المريض إذا لم تكن محملة
                                if (patientInfoState is PatientInfoInitial) {
                                  context
                                      .read<PatientInfoCubit>()
                                      .loadPatientInfo(widget.device.deviceId);
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (patientInfoState is PatientInfoLoaded &&
                                    patientInfoState.patientInfo != null) {
                                  final patientInfo =
                                      patientInfoState.patientInfo!;
                                  patientData.addAll({
                                    'age': patientInfo.age,
                                    'gender': patientInfo.gender.name,
                                    'bloodType': patientInfo.bloodType,
                                    'chronicDiseases':
                                        patientInfo.chronicDiseases,
                                  });
                                }

                                return MedicalAssistantScreen(
                                  patientData: patientData,
                                );
                              },
                            );
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
