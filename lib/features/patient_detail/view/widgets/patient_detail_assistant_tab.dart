import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:spider_doctor/features/medical_assistant/data/hugging_face_service.dart';
import '../../cubit/patient_detail_cubit.dart';
import '../../cubit/patient_detail_state.dart';
import '../../model/patient_vital_signs.dart';

/// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// Patient Detail Assistant Tab with AI Chat Integration
class PatientDetailAssistantTab extends StatefulWidget {
  const PatientDetailAssistantTab({super.key});

  @override
  State<PatientDetailAssistantTab> createState() =>
      _PatientDetailAssistantTabState();
}

class _PatientDetailAssistantTabState extends State<PatientDetailAssistantTab> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeDotenv();
    _testAPIConnection();
  }

  Future<void> _initializeDotenv() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print('Error loading .env file: $e');
    }
  }

  Future<void> _testAPIConnection() async {
    try {
      final isConnected = await MedicalAssistantService.sendMessage('test');
      print(
        '🔗 Medical Assistant Connection: ${isConnected.isNotEmpty ? "✅ متصل" : "❌ فشل"}',
      );
    } catch (e) {
      print('❌ خطأ في اختبار الاتصال: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Generate vital signs summary based on current locale
  String _generateVitalsSummary(PatientVitalSigns vitals, String locale) {
    final isArabic = locale.startsWith('ar');

    if (isArabic) {
      return 'المريض لديه درجة حرارة ${vitals.temperature.toStringAsFixed(1)}°م، معدل نبض ${vitals.heartRate.toStringAsFixed(0)} ن/د، ضغط دم ${vitals.bloodPressure['systolic']}/${vitals.bloodPressure['diastolic']} مم زئبق، و نسبة أكسجين ${vitals.spo2.toStringAsFixed(1)}%. كيف يمكنني مساعدتك اليوم؟';
    } else {
      return 'Patient has temperature ${vitals.temperature.toStringAsFixed(1)}°C, heart rate ${vitals.heartRate.toStringAsFixed(0)} bpm, blood pressure ${vitals.bloodPressure['systolic']}/${vitals.bloodPressure['diastolic']} mmHg, and SpO₂ ${vitals.spo2.toStringAsFixed(1)}%. How can I assist you today?';
    }
  }

  /// Send message to Hugging Face API
  Future<void> _sendMessage(String message, PatientVitalSigns vitals) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final locale = Localizations.localeOf(context).languageCode;
      final contextualMessage = _buildContextualMessage(
        message,
        vitals,
        locale,
      );

      final aiResponse = await MedicalAssistantService.sendMessage(
        contextualMessage,
      );

      setState(() {
        _messages.add(
          ChatMessage(
            text: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      final locale = Localizations.localeOf(context).languageCode;
      String errorMessage;

      print('AI Error: $e'); // للتشخيص

      if (e.toString().contains('Unauthorized') ||
          e.toString().contains('Invalid credentials')) {
        errorMessage = locale.startsWith('ar')
            ? 'خطأ في التوثيق. يرجى التحقق من رمز API.'
            : 'Authentication error. Please check API token.';
      } else if (e.toString().contains('Model not found') ||
          e.toString().contains('404')) {
        errorMessage = locale.startsWith('ar')
            ? 'النموذج غير متوفر حالياً. جاري المحاولة مع نموذج آخر...'
            : 'AI model temporarily unavailable. Trying alternative...';
      } else if (e.toString().contains('loading') ||
          e.toString().contains('503')) {
        errorMessage = locale.startsWith('ar')
            ? 'المساعد الذكي يستعد للعمل. يرجى المحاولة مرة أخرى خلال ثوانٍ.'
            : 'AI assistant is loading. Please try again in a few seconds.';
      } else if (e.toString().contains('HF_TOKEN not found')) {
        errorMessage = locale.startsWith('ar')
            ? 'رمز API مفقود. يرجى التحقق من إعدادات التطبيق.'
            : 'API token missing. Please check app configuration.';
      } else {
        errorMessage = locale.startsWith('ar')
            ? 'حدث خطأ في الاتصال بالمساعد الذكي. يرجى المحاولة مرة أخرى.'
            : 'Error connecting to AI assistant. Please try again.';
      }

      setState(() {
        _messages.add(
          ChatMessage(
            text: errorMessage,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  /// Build contextual message with patient data
  String _buildContextualMessage(
    String userMessage,
    PatientVitalSigns vitals,
    String locale,
  ) {
    if (locale.startsWith('ar')) {
      return '''المريض الحالي:
- درجة الحرارة: ${vitals.temperature.toStringAsFixed(1)}°م
- معدل النبض: ${vitals.heartRate.toStringAsFixed(0)} ن/د
- ضغط الدم: ${vitals.bloodPressure['systolic']}/${vitals.bloodPressure['diastolic']} مم زئبق
- نسبة الأكسجين: ${vitals.spo2.toStringAsFixed(1)}%

سؤال المستخدم: $userMessage''';
    } else {
      return '''Patient Status:
- Temperature: ${vitals.temperature.toStringAsFixed(1)}°C
- Heart Rate: ${vitals.heartRate.toStringAsFixed(0)} bpm
- Blood Pressure: ${vitals.bloodPressure['systolic']}/${vitals.bloodPressure['diastolic']} mmHg
- SpO₂: ${vitals.spo2.toStringAsFixed(1)}%

User Question: $userMessage''';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientDetailCubit, PatientDetailState>(
      builder: (context, state) {
        if (state is! PatientDetailLoaded) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading patient data...'),
              ],
            ),
          );
        }

        final vitals = state.vitalSigns;
        final locale = Localizations.localeOf(context).languageCode;

        return Column(
          children: [
            // Vital Signs Summary Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.blue[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.smart_toy, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        locale.startsWith('ar')
                            ? 'المساعد الطبي الذكي'
                            : 'AI Medical Assistant',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _generateVitalsSummary(vitals, locale),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Chat Messages List
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            locale.startsWith('ar')
                                ? 'ابدأ محادثة مع المساعد الطبي'
                                : 'Start a conversation with the medical assistant',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isLoading) {
                          return _buildLoadingMessage();
                        }

                        final message = _messages[index];
                        return _buildMessageBubble(message, locale);
                      },
                    ),
            ),

            // Message Input Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: locale.startsWith('ar')
                            ? 'اكتب سؤالك هنا...'
                            : 'Type your question here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (message) => _sendMessage(message, vitals),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    onPressed: _isLoading
                        ? null
                        : () => _sendMessage(_messageController.text, vitals),
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, String locale) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.smart_toy, size: 16, color: Colors.blue[700]),
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: EdgeInsets.only(
                left: message.isUser ? 50 : 0,
                right: message.isUser ? 0 : 50,
              ),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue[600] : Colors.grey[100],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      color: message.isUser ? Colors.white70 : Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 16, color: Colors.grey[700]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.smart_toy, size: 16, color: Colors.blue[700]),
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(right: 50),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue[600]!,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Thinking...',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
