import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.faqs)),
      body: ListView(
        children: [
          _FaqItem(
            question: t.faqUploadQuestion,
            answer: t.faqUploadAnswer,
          ),
          _FaqItem(
            question: t.faqFamilyQuestion,
            answer: t.faqFamilyAnswer,
          ),
          _FaqItem(
            question: t.faqSecurityQuestion,
            answer: t.faqSecurityAnswer,
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(answer),
        ),
      ],
    );
  }
}
