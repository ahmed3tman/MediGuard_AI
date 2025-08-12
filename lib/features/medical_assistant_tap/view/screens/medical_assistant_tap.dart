import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/medical_assistant_cubit.dart';
import '../../cubit/medical_assistant_state.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/suggested_questions_widget.dart';
import '../widgets/message_input_widget.dart';

class MedicalAssistantScreen extends StatefulWidget {
  final Map<String, dynamic> patientData;

  const MedicalAssistantScreen({Key? key, required this.patientData})
    : super(key: key);

  @override
  State<MedicalAssistantScreen> createState() => _MedicalAssistantScreenState();
}

class _MedicalAssistantScreenState extends State<MedicalAssistantScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  late MedicalAssistantCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MedicalAssistantCubit>();

    // تهيئة المحادثة مع السؤال الأول
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.initializeChat(widget.patientData, context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    super.build(context); // keep alive
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<MedicalAssistantCubit, MedicalAssistantState>(
        listener: (context, state) {
          if (state is MedicalAssistantChatUpdated ||
              state is MedicalAssistantAnalysisSuccess ||
              state is MedicalAssistantResponseSuccess) {
            _scrollToBottom();
          }

          if (state is MedicalAssistantError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // منطقة المحادثة
              Expanded(child: _buildChatArea(state, isArabic)),

              // الأسئلة المقترحة
              if (_cubit.suggestedQuestions.isNotEmpty)
                SuggestedQuestionsWidget(
                  questions: _cubit.suggestedQuestions,
                  onQuestionTap: (question) {
                    _cubit.sendSuggestedQuestion(question, context);
                  },
                  isArabic: isArabic,
                ),

              // مربع إدخال الرسالة
              MessageInputWidget(
                onSendMessage: (message) async {
                  await _cubit.sendMessage(message, context);
                },
                isLoading:
                    state is MedicalAssistantLoading ||
                    state is MedicalAssistantAnalyzing,
                isArabic: isArabic,
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildChatArea(MedicalAssistantState state, bool isArabic) {
    if (state is MedicalAssistantInitial) {
      return _buildWelcomeScreen(isArabic);
    }

    if (_cubit.messages.isEmpty &&
        (state is MedicalAssistantLoading ||
            state is MedicalAssistantAnalyzing)) {
      return _buildLoadingScreen(isArabic);
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F5F5), Color(0xFFEFEFEF)],
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount:
            _cubit.messages.length +
            (state is MedicalAssistantLoading ||
                    state is MedicalAssistantAnalyzing
                ? 1
                : 0),
        itemBuilder: (context, index) {
          // إظهار مؤشر التحميل في النهاية
          if (index == _cubit.messages.length) {
            return _buildTypingIndicator(isArabic);
          }

          final message = _cubit.messages[index];
          return ChatMessageWidget(message: message, isArabic: isArabic);
        },
      ),
    );
  }

  Widget _buildWelcomeScreen(bool isArabic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medical_services,
                size: 64,
                color: Colors.teal[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isArabic
                  ? 'مرحباً بك في المساعد الطبي الذكي'
                  : 'Welcome to Smart Medical Assistant',
              style: isArabic
                  ? const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontFamily: 'NeoSansArabic',
                    )
                  : TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              isArabic
                  ? 'سأقوم بتحليل حالة المريض وتقديم النصائح الطبية المناسبة'
                  : 'I will analyze the patient\'s condition and provide appropriate medical advice',
              style: isArabic
                  ? const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'NeoSansArabic',
                    )
                  : TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<MedicalAssistantCubit>().initializeChat(
                  widget.patientData,
                  context,
                );
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: Text(
                isArabic ? 'بدء المحادثة' : 'Start Conversation',
                style: isArabic
                    ? const TextStyle(
                        fontFamily: 'NeoSansArabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )
                    : null,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                ),
                const SizedBox(height: 16),
                Text(
                  isArabic
                      ? 'جاري تحليل حالة المريض...'
                      : 'Analyzing patient condition...',
                  style: isArabic
                      ? const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'NeoSansArabic',
                        )
                      : TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isArabic) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isArabic ? 'يكتب...' : 'Typing...',
                  style: isArabic
                      ? const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontFamily: 'NeoSansArabic',
                        )
                      : TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey[600]!,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
