import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FAQs")),
      body: ListView(
        children: const [
          _FaqItem(
            question: "How do I upload reports?",
            answer: "Go to Reports tab and tap Upload.",
          ),
          _FaqItem(
            question: "How do I add family members?",
            answer: "Open Profile → Family Management → Add member.",
          ),
          _FaqItem(
            question: "Is my data secure?",
            answer: "Yes, your data is securely stored.",
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
