import 'package:spider_doctor/features/patient_detail/model/patient_vital_signs.dart';

abstract class DoctorTabState {}

class DoctorTabInitial extends DoctorTabState {}

class DoctorTabLoading extends DoctorTabState {}

class DoctorTabLoaded extends DoctorTabState {
  final PatientVitalSigns vitalSigns;
  final List<EcgReading> ecgReadings;
  DoctorTabLoaded(this.vitalSigns, this.ecgReadings);
}

class DoctorTabError extends DoctorTabState {
  final String message;
  DoctorTabError(this.message);
}
