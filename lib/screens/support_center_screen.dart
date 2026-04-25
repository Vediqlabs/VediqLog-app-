import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help & Support")),
      body: ListView(
        children: [
          _tile(context, "FAQs", "/faqs"),
          _tile(context, "Contact Support", "/contact-support"),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => context.push(route),
    );
  }
}
