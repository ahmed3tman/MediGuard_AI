import 'package:equatable/equatable.dart';
import 'package:spider_doctor/features/critical_cases/model/critical_case_model.dart';

abstract class CriticalCasesState extends Equatable {
  const CriticalCasesState();

  @override
  List<Object> get props => [];
}

class CriticalCasesInitial extends CriticalCasesState {}

class CriticalCasesLoading extends CriticalCasesState {}

class CriticalCasesLoaded extends CriticalCasesState {
  final List<CriticalCase> criticalCases;

  const CriticalCasesLoaded(this.criticalCases);

  @override
  List<Object> get props => [criticalCases];
}

class CriticalCasesError extends CriticalCasesState {
  final String message;

  const CriticalCasesError(this.message);

  @override
  List<Object> get props => [message];
}

class CriticalCaseDeleting extends CriticalCasesState {
  final List<CriticalCase> criticalCases;
  final String deletingDeviceId;

  const CriticalCaseDeleting(this.criticalCases, this.deletingDeviceId);

  @override
  List<Object> get props => [criticalCases, deletingDeviceId];
}
