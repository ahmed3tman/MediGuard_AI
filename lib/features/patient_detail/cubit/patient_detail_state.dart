import 'package:equatable/equatable.dart';
import '../model/patient_vital_signs.dart';

/// States for patient detail screen
abstract class PatientDetailState extends Equatable {
  const PatientDetailState();

  @override
  List<Object?> get props => [];
}

class PatientDetailInitial extends PatientDetailState {}

class PatientDetailLoading extends PatientDetailState {}

class PatientDetailLoaded extends PatientDetailState {
  final PatientVitalSigns vitalSigns;
  final List<EcgReading> ecgReadings;

  const PatientDetailLoaded({
    required this.vitalSigns,
    required this.ecgReadings,
  });

  @override
  List<Object?> get props => [vitalSigns, ecgReadings];
}

class PatientDetailError extends PatientDetailState {
  final String message;

  const PatientDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
