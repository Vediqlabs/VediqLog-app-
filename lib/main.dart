import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:alarm/alarm.dart';

import 'routes.dart';
import 'services/notification_service.dart';
import 'providers/active_profile_provider.dart';
import 'theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/membership_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://wwppycqpkcgfjzketidw.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3cHB5Y3Fwa2NnZmp6a2V0aWR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkzNDAwOTAsImV4cCI6MjA4NDkxNjA5MH0.oPVD2flTrogzyeDlpa_sLYBEkCrJWBxamiRZr8OQJdA",
  );

  await NotificationService.init();

  final supabase = Supabase.instance.client;

  supabase.auth.onAuthStateChange.listen((event) async {
    final user = supabase.auth.currentUser;

    if (user == null || user.id.trim().isEmpty) {
      print("⚠️ Skip restore — invalid user");
      return;
    }

    appRouter.refresh();

    // delay ensures session fully ready
    await Future.delayed(const Duration(milliseconds: 300));

    await restoreReminders();
  });

  final profileProvider = ActiveProfileProvider();
  profileProvider.initWithSelf();

  runApp(
    ChangeNotifierProvider.value(
      value: profileProvider,
      child: const VediqLogApp(),
    ),
  );
  Alarm.ringStream.stream.listen((alarm) async {
    final supabase = Supabase.instance.client;

    final reminder = await supabase
        .from('reminders')
        .select()
        .eq('alarm_id', alarm.id)
        .maybeSingle();

    if (reminder == null) return;

    final repeatType = reminder['repeat_type']?.toString() ?? "one_time";

    // ONLY everyday repeats here
    if (repeatType != "everyday") return;

    final nextTime = alarm.dateTime.add(const Duration(days: 1));

    final newId = nextTime.millisecondsSinceEpoch.remainder(2147483647);

    await NotificationService.scheduleAlarm(
      id: newId,
      reminderId: reminder['id'],
      title: alarm.notificationSettings?.title ?? "Reminder",
      body: alarm.notificationSettings?.body ?? "",
      dateTime: nextTime,
    );

    appRouter.go('/alarm', extra: {
      'id': alarm.id,
      'title': alarm.notificationSettings?.title ?? "Reminder",
      'body': alarm.notificationSettings?.body ?? "",
    });
  });
}

Future<void> restoreReminders() async {
  try {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null || user.id.trim().isEmpty) {
      print("restoreReminders skipped — invalid user");
      return;
    }

    final existingAlarms = await Alarm.getAlarms();
    for (final alarm in existingAlarms) {
      await Alarm.stop(alarm.id);
    }

    final reminders = await supabase
        .from('reminders')
        .select()
        .eq('user_id', user.id)
        .limit(30);

    final now = DateTime.now();
    final usedIds = <int>{};

    for (final r in reminders) {
      try {
        if (r['date'] == null || r['time'] == null) continue;

        final parts = r['time'].split(':');
        final reminderTime = DateTime.parse(r['date']).add(
          Duration(
            hours: int.parse(parts[0]),
            minutes: int.parse(parts[1]),
          ),
        );

        final repeatType = r['repeat_type']?.toString() ?? "one_time";
        final interval =
            int.tryParse(r['repeat_interval']?.toString() ?? '1') ?? 1;

        var nextTime = reminderTime;

        while (!nextTime.isAfter(now)) {
          if (repeatType == "everyday") {
            nextTime = nextTime.add(const Duration(days: 1));
          } else if (repeatType == "custom") {
            nextTime = nextTime.add(Duration(days: interval));
          } else {
            break;
          }
        }
        final alarmId = nextTime.millisecondsSinceEpoch.remainder(2147483647);

        await NotificationService.scheduleAlarm(
          id: alarmId,
          reminderId: r['id'],
          title: "VEDIQLOG Reminder",
          body: "${r['type']}: ${r['title']}",
          dateTime: nextTime,
          repeatType: r['repeat_type']?.toString() ?? "one_time",
        );
      } catch (_) {}
    }
  } catch (_) {}
}

class VediqLogApp extends StatefulWidget {
  const VediqLogApp({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_VediqLogAppState>();
    state?.setLocale(locale);
  }

  static void setThemeMode(BuildContext context, ThemeMode mode) {
    final state = context.findAncestorStateOfType<_VediqLogAppState>();
    state?.setThemeMode(mode);
  }

  @override
  State<VediqLogApp> createState() => _VediqLogAppState();
}

class _VediqLogAppState extends State<VediqLogApp> {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
    _loadSavedTheme();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code');

    if (code != null) {
      setState(() => _locale = Locale(code));
    }
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('dark_mode') ?? false;

    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);

    setState(() => _locale = locale);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', mode == ThemeMode.dark);

    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      locale: _locale,
      title: 'VEDIQLOG',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
