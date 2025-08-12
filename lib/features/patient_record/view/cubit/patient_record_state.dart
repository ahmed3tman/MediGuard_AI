import 'package:spider_doctor/features/patient_detail/model/patient_vital_signs.dart';

abstract class PatientRecordState {}

class PatientRecordInitial extends PatientRecordState {}

class PatientRecordLoading extends PatientRecordState {}

class PatientRecordLoaded extends PatientRecordState {
  final PatientVitalSigns vitalSigns;
  final List<EcgReading> ecgReadings;

  PatientRecordLoaded(this.vitalSigns, this.ecgReadings);
}

class PatientRecordError extends PatientRecordState {
  final String message;

  PatientRecordError(this.message);
}
