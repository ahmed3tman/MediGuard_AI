import 'package:equatable/equatable.dart';

abstract class CriticalCasesState extends Equatable {
  const CriticalCasesState();

  @override
  List<Object?> get props => [];
}

class CriticalCasesInitial extends CriticalCasesState {}

class CriticalCasesLoading extends CriticalCasesState {}

class CriticalCasesLoaded extends CriticalCasesState {
  final List<Map<String, dynamic>> criticalCases;

  const CriticalCasesLoaded(this.criticalCases);

  @override
  List<Object?> get props => [criticalCases];
}

class CriticalCasesError extends CriticalCasesState {
  final String message;

  const CriticalCasesError(this.message);

  @override
  List<Object?> get props => [message];
}
