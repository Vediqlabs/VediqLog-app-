import 'package:flutter/material.dart';

class PolicyPage extends StatelessWidget {
  final String title;
  final String content;

  const PolicyPage({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: const TextStyle(height: 1.5),
        ),
      ),
    );
  }
}
