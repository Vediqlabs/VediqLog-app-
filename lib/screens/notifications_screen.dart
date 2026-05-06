import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final supabase = Supabase.instance.client;

  bool loading = true;

  bool medication = true;
  bool appointments = true;
  bool reports = true;
  bool emergency = true;
  bool marketing = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('notification_settings')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (data != null) {
      setState(() {
        medication = data['medication'] ?? true;
        appointments = data['appointments'] ?? true;
        reports = data['reports'] ?? true;
        emergency = data['emergency'] ?? true;
        marketing = data['marketing'] ?? false;
        loading = false;
      });
    } else {
      await supabase.from('notification_settings').insert({
        'user_id': user.id,
      });

      setState(() => loading = false);
    }
  }

  Future<void> updateSetting(
    String key,
    bool value,
  ) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('notification_settings').upsert({
      'user_id': user.id,
      key: value,
    });
  }

  Widget toggleTile(
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.notifications),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                toggleTile(
                  t.medicationReminders,
                  medication,
                  (v) {
                    setState(() => medication = v);
                    updateSetting("medication", v);
                  },
                ),
                toggleTile(
                  t.appointments,
                  appointments,
                  (v) {
                    setState(() => appointments = v);
                    updateSetting("appointments", v);
                  },
                ),
                toggleTile(
                  t.reportUpdates,
                  reports,
                  (v) {
                    setState(() => reports = v);
                    updateSetting("reports", v);
                  },
                ),
                toggleTile(
                  t.emergencyAlerts,
                  emergency,
                  (v) {
                    setState(() => emergency = v);
                    updateSetting("emergency", v);
                  },
                ),
                toggleTile(
                  t.offersMarketing,
                  marketing,
                  (v) {
                    setState(() => marketing = v);
                    updateSetting("marketing", v);
                  },
                ),
              ],
            ),
    );
  }
}
