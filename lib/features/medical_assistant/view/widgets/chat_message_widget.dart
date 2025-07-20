import 'package:flutter/material.dart';
import '../../model/medical_assistant_models.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final bool isArabic;

  const ChatMessageWidget({
    Key? key,
    required this.message,
    required this.isArabic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            _buildAvatar(false),
            const SizedBox(width: 8),
          ],
          Flexible(child: _buildMessageBubble(context)),
          if (message.isUser) ...[const SizedBox(width: 8), _buildAvatar(true)],
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isUser ? Colors.blue[100] : Colors.teal[100],
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: isUser ? Colors.blue[700] : Colors.teal[700],
        size: 20,
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: message.isUser ? Colors.blue[500] : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(message.isUser ? 20 : 4),
          bottomRight: Radius.circular(message.isUser ? 4 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageContent(),
          const SizedBox(height: 4),
          _buildTimestamp(),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    // إضافة أيقونات حسب نوع الرسالة
    IconData? messageIcon;
    Color? iconColor;

    switch (message.type) {
      case MessageType.patientStatus:
        messageIcon = Icons.assessment;
        iconColor = Colors.green[600];
        break;
      case MessageType.nutritionAdvice:
        messageIcon = Icons.restaurant;
        iconColor = Colors.orange[600];
        break;
      case MessageType.medicalAdvice:
        messageIcon = Icons.medical_information;
        iconColor = Colors.blue[600];
        break;
      case MessageType.emergency:
        messageIcon = Icons.emergency;
        iconColor = Colors.red[600];
        break;
      case MessageType.suggestedQuestion:
        messageIcon = Icons.help_outline;
        iconColor = Colors.purple[600];
        break;
      default:
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (messageIcon != null) ...[
          Row(
            children: [
              Icon(
                messageIcon,
                size: 16,
                color: message.isUser ? Colors.white70 : iconColor,
              ),
              const SizedBox(width: 6),
              Text(
                _getMessageTypeLabel(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: message.isUser ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Text(
          message.content,
          style: TextStyle(
            fontSize: 14,
            color: message.isUser ? Colors.white : Colors.grey[800],
            height: 1.4,
          ),
          textDirection: _getTextDirection(),
        ),
      ],
    );
  }

  String _getMessageTypeLabel() {
    switch (message.type) {
      case MessageType.patientStatus:
        return isArabic ? 'تحليل الحالة' : 'Status Analysis';
      case MessageType.nutritionAdvice:
        return isArabic ? 'نصائح غذائية' : 'Nutrition Advice';
      case MessageType.medicalAdvice:
        return isArabic ? 'نصائح طبية' : 'Medical Advice';
      case MessageType.emergency:
        return isArabic ? 'طوارئ' : 'Emergency';
      case MessageType.suggestedQuestion:
        return isArabic ? 'سؤال مقترح' : 'Suggested Question';
      default:
        return '';
    }
  }

  TextDirection _getTextDirection() {
    // تحديد اتجاه النص بناءً على المحتوى
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(message.content)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  Widget _buildTimestamp() {
    return Text(
      _formatTime(message.timestamp),
      style: TextStyle(
        fontSize: 11,
        color: message.isUser ? Colors.white70 : Colors.grey[500],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return isArabic ? 'الآن' : 'Now';
    } else if (difference.inHours < 1) {
      return isArabic
          ? 'منذ ${difference.inMinutes} دقيقة'
          : '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return isArabic
          ? 'منذ ${difference.inHours} ساعة'
          : '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
