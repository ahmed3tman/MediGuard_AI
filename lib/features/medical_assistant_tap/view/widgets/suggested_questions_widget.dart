import 'package:flutter/material.dart';

class SuggestedQuestionsWidget extends StatelessWidget {
  final List<Map<String, String>> questions;
  final Function(String) onQuestionTap;
  final bool isArabic;

  const SuggestedQuestionsWidget({
    Key? key,
    required this.questions,
    required this.onQuestionTap,
    required this.isArabic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
  //  print('🔍 SuggestedQuestionsWidget - عدد الأسئلة: ${questions.length}');
   // questions.forEach((q) => print('   ${q['icon']} ${q['question']}'));

    if (questions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            final questionText = question['question'] ?? '';
            final icon = question['icon'] ?? '💬';

            return _buildQuestionChip(questionText, icon, context);
          },
        ),
      ),
    );
  }

  Widget _buildQuestionChip(
    String questionText,
    String icon,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => onQuestionTap(questionText),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.teal[300]!, width: 1),
            color: Colors.grey[100],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.5,
                ),
                child: Text(
                  questionText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.teal[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
