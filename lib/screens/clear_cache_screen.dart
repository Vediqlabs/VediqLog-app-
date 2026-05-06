import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

class ClearCacheScreen extends StatefulWidget {
  const ClearCacheScreen({super.key});

  @override
  State<ClearCacheScreen> createState() => _ClearCacheScreenState();
}

class _ClearCacheScreenState extends State<ClearCacheScreen> {
  bool clearing = false;

  Future<void> clearCache() async {
    final t = AppLocalizations.of(context)!;

    setState(() => clearing = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    setState(() => clearing = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.cacheCleared)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.clearCache)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(t.cacheDescription),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: clearing ? null : clearCache,
              child: clearing
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(t.clearCache),
            ),
          ],
        ),
      ),
    );
  }
}
