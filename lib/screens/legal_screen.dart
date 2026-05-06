import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

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
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.legalPrivacy)),
      body: ListView(
        children: [
          _tile(
            t.privacyPolicy,
            () => _openUrl(
              "https://vediq-legal.vercel.app/privacy-policy.html",
            ),
          ),
          _tile(
            t.termsConditions,
            () => _openUrl(
              "https://vediq-legal.vercel.app/terms.html",
            ),
          ),
          _tile(
            t.dataUsagePolicy,
            () => _openUrl(
              "https://vediq-legal.vercel.app/data-usage.html",
            ),
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
