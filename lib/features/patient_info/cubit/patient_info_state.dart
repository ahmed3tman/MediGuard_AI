import 'package:equatable/equatable.dart';
import '../model/patient_info_model.dart';

abstract class PatientInfoState extends Equatable {
  const PatientInfoState();

  @override
  List<Object?> get props => [];
}

class PatientInfoInitial extends PatientInfoState {}

class PatientInfoLoading extends PatientInfoState {}

class PatientInfoLoaded extends PatientInfoState {
  final PatientInfo? patientInfo;

  const PatientInfoLoaded(this.patientInfo);

  @override
  List<Object?> get props => [patientInfo];
}

class PatientInfoSaving extends PatientInfoState {}

class PatientInfoSaved extends PatientInfoState {}

class PatientInfoError extends PatientInfoState {
  final String message;

  const PatientInfoError(this.message);

  @override
  List<Object?> get props => [message];
}
