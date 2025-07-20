import 'package:equatable/equatable.dart';

/// حالة المساعد الطبي
abstract class MedicalAssistantState extends Equatable {
  const MedicalAssistantState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class MedicalAssistantInitial extends MedicalAssistantState {}

/// حالة التحميل
class MedicalAssistantLoading extends MedicalAssistantState {}

/// حالة تحليل البيانات
class MedicalAssistantAnalyzing extends MedicalAssistantState {}

/// حالة نجاح التحليل
class MedicalAssistantAnalysisSuccess extends MedicalAssistantState {
  final Map<String, dynamic> analysis;
  final List<Map<String, String>> suggestedQuestions;

  const MedicalAssistantAnalysisSuccess({
    required this.analysis,
    required this.suggestedQuestions,
  });

  @override
  List<Object?> get props => [analysis, suggestedQuestions];
}

/// حالة نجاح الرد على السؤال
class MedicalAssistantResponseSuccess extends MedicalAssistantState {
  final String response;
  final List<Map<String, String>> suggestedQuestions;

  const MedicalAssistantResponseSuccess({
    required this.response,
    required this.suggestedQuestions,
  });

  @override
  List<Object?> get props => [response, suggestedQuestions];
}

/// حالة تحديث المحادثة
class MedicalAssistantChatUpdated extends MedicalAssistantState {
  final List<dynamic> messages;
  final List<Map<String, String>> suggestedQuestions;

  const MedicalAssistantChatUpdated({
    required this.messages,
    required this.suggestedQuestions,
  });

  @override
  List<Object?> get props => [messages, suggestedQuestions];
}

/// حالة الخطأ
class MedicalAssistantError extends MedicalAssistantState {
  final String message;

  const MedicalAssistantError({required this.message});

  @override
  List<Object?> get props => [message];
}
