import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Legal & Privacy")),
      body: ListView(
        children: [
          _tile(
            "Privacy Policy",
            () =>
                _openUrl("https://vediq-legal.vercel.app/privacy-policy.html"),
          ),
          _tile(
            "Terms & Conditions",
            () => _openUrl("https://vediq-legal.vercel.app/terms.html"),
          ),
          _tile(
            "Data Usage Policy",
            () => _openUrl("https://vediq-legal.vercel.app/data-usage.html"),
          ),
        ],
      ),
    );
  }

  Widget _tile(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
