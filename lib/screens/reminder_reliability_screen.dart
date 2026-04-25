import 'package:flutter/material.dart';
import '../utils/battery_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

class ReminderReliabilityScreen extends StatelessWidget {
  const ReminderReliabilityScreen({super.key});

  Future<void> _handleContinue(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await openBatteryOptimizationSettings();
    await prefs.setBool('battery_setup_done', true);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text(t.reliableReminders),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Text(
              t.neverMissMedicines,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Text(
              t.batteryOptimizationInfo,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),

            const SizedBox(height: 24),

            Text(t.thisEnsures),
            const SizedBox(height: 10),

            Text(t.remindersOnTime),
            Text(t.medicinesNotMissed),
            Text(t.healthSchedulesReliable),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleContinue(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.all(14),
                ),
                child: Text(t.continueSetup),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t.doLater),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
