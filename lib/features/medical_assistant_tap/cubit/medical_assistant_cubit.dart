import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../model/medical_assistant_models.dart';
import 'medical_assistant_state.dart';
import '../data/hugging_face_service.dart';

class MedicalAssistantCubit extends Cubit<MedicalAssistantState> {
  MedicalAssistantCubit() : super(MedicalAssistantInitial());

  /// خريطة المحادثات المحفوظة لكل مريض
  static final Map<String, List<ChatMessage>> _savedChats = {};

  /// قائمة الرسائل في المحادثة الحالية
  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  /// الأسئلة المقترحة الحالية
  List<Map<String, String>> _suggestedQuestions = [];
  List<Map<String, String>> get suggestedQuestions => _suggestedQuestions;

  /// بيانات المريض الحالية
  Map<String, dynamic> _currentPatientData = {};

  /// معرف المريض الحالي
  String _currentPatientId = '';
  bool _initializedForCurrent = false;

  /// تهيئة المحادثة مع البيانات المحفوظة
  void initializeChat(Map<String, dynamic> patientData, BuildContext context) {
    final newId = patientData['deviceId'] ?? '';
    // Prevent reinitialization loops when switching tabs
    if (_initializedForCurrent &&
        newId == _currentPatientId &&
        _messages.isNotEmpty) {
      return;
    }
    _currentPatientData = patientData;
    _currentPatientId = newId;
    _initializedForCurrent = true;

    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    // تحميل المحادثة المحفوظة إن وجدت
    if (_savedChats.containsKey(_currentPatientId)) {
      _messages = List.from(_savedChats[_currentPatientId]!);
    } else {
      _messages.clear();

      // إضافة رسالة ترحيب بسيطة للمرة الأولى فقط
      final welcomeMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: isArabic ? 'كيف يمكنني مساعدتك؟' : 'How can I help you?',
        isUser: false,
        timestamp: DateTime.now(),
        type: MessageType.text,
      );

      _messages.add(welcomeMessage);
    }

    // تحديث الأسئلة المقترحة
    _updateSuggestedQuestions(isArabic);

    _safeEmit(
      MedicalAssistantChatUpdated(
        messages: _messages,
        suggestedQuestions: _suggestedQuestions,
      ),
    );
  }

  /// Update patient data without resetting conversation
  void updatePatientData(Map<String, dynamic> patientData) {
    if (patientData['deviceId'] == _currentPatientId) {
      _currentPatientData = patientData;
    }
  }

  /// إرسال رسالة جديدة
  Future<void> sendMessage(String messageContent, BuildContext context) async {
    _safeEmit(MedicalAssistantLoading());

    try {
      final locale = Localizations.localeOf(context);
      final isArabic = locale.languageCode == 'ar';

      // إضافة رسالة المستخدم
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: messageContent,
        isUser: true,
        timestamp: DateTime.now(),
        type: MessageType.text,
      );

      _messages.add(userMessage);

      // استخدام الخدمة الجديدة مع البيانات الفعلية
      final response = await MedicalAssistantService.sendMessage(
        messageContent,
        patientData: _currentPatientData,
      );

      // إضافة رد المساعد
      final assistantMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
        type: _determineMessageType(messageContent),
      );

      _messages.add(assistantMessage);

      // حفظ المحادثة
      _savedChats[_currentPatientId] = List.from(_messages);

      // تحديث الأسئلة المقترحة
      _updateSuggestedQuestions(isArabic);

      _safeEmit(
        MedicalAssistantChatUpdated(
          messages: _messages,
          suggestedQuestions: _suggestedQuestions,
        ),
      );
    } catch (e) {
      _safeEmit(MedicalAssistantError(message: 'حدث خطأ في إرسال الرسالة: $e'));
    }
  }

  /// تحديد نوع الرسالة
  MessageType _determineMessageType(String message) {
    final messageLower = message.toLowerCase();

    if (messageLower.contains('حالة') ||
        messageLower.contains('وصف') ||
        messageLower.contains('describe') ||
        messageLower.contains('condition')) {
      return MessageType.analysis;
    } else if (messageLower.contains('نصيحة') ||
        messageLower.contains('advice') ||
        messageLower.contains('توصية') ||
        messageLower.contains('recommend')) {
      return MessageType.medicalAdvice;
    }

    return MessageType.text;
  }

  /// تحديث الأسئلة المقترحة
  void _updateSuggestedQuestions(bool isArabic) {
    // print('📝 تحديث الأسئلة المقترحة - اللغة العربية: $isArabic');

    if (isArabic) {
      _suggestedQuestions = [
        {'question': 'اوصف لي حالة المريض', 'icon': '📊'},
        {'question': 'ما هي التوصيات الطبية؟', 'icon': '💊'},
        {'question': 'هل هناك أي مخاوف؟', 'icon': '⚠️'},
        {'question': 'ما هي حالة العلامات الحيوية؟', 'icon': '❤️'},
      ];
    } else {
      _suggestedQuestions = [
        {'question': 'Describe patient condition', 'icon': '📊'},
        {'question': 'What are the medical recommendations?', 'icon': '💊'},
        {'question': 'Are there any concerns?', 'icon': '⚠️'},
        {'question': 'How are the vital signs?', 'icon': '❤️'},
      ];
    }

    // print('📋 عدد الأسئلة المقترحة: ${_suggestedQuestions.length}');
    // _suggestedQuestions.forEach(
    //   (q) => print('   ${q['icon']} ${q['question']}'),
    // );
  }

  /// إرسال سؤال مقترح
  Future<void> sendSuggestedQuestion(
    String question,
    BuildContext context,
  ) async {
    await sendMessage(question, context);
  }

  /// إعادة تعيين المحادثة
  void resetChat() {
    _messages.clear();
    _suggestedQuestions.clear();
    _currentPatientData.clear();
    _currentPatientId = '';
    _initializedForCurrent = false;
    _safeEmit(MedicalAssistantInitial());
  }

  // Prevent emitting after cubit is closed (can happen if async finishes after pop)
  void _safeEmit(MedicalAssistantState state) {
    if (isClosed) return;
    try {
      emit(state);
    } catch (_) {
      // swallow to avoid crashing the app
    }
  }
}
