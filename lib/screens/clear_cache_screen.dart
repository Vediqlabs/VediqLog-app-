import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClearCacheScreen extends StatefulWidget {
  const ClearCacheScreen({super.key});

  @override
  State<ClearCacheScreen> createState() => _ClearCacheScreenState();
}

class _ClearCacheScreenState extends State<ClearCacheScreen> {
  bool clearing = false;

  Future<void> clearCache() async {
    setState(() => clearing = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // clears local stored data

    setState(() => clearing = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cache cleared successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clear Cache")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Clearing cache removes temporary stored data and may free storage space.",
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: clearing ? null : clearCache,
              child: clearing
                  ? const CircularProgressIndicator()
                  : const Text("Clear Cache"),
            ),
          ],
        ),
      ),
    );
  }
}
