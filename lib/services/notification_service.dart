import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:alarm/alarm.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// ---------------- INIT ----------------
  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidInit);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onActionTapped,
    );

    final androidImpl = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImpl?.requestNotificationsPermission();

    await Alarm.init();
  }

  static Future<bool> isNotificationEnabled(String type) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return true;

    final data = await Supabase.instance.client
        .from('notification_settings')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (data == null) return true;

    if (type == "Medicine") return data['medication'] ?? true;
    if (type == "Appointment") return data['appointments'] ?? true;
    if (type == "Lab Test") return data['reports'] ?? true;

    return true;
  }

  /// Notification action handler
  static void _onActionTapped(NotificationResponse response) async {
    final payload = response.payload;

    if (payload == null) return;

    final alarmId = int.tryParse(payload);

    if (alarmId == null) return;

    if (response.actionId == "DONE") {
      await cancelAlarm(alarmId);
    }

    if (response.actionId == "SNOOZE") {
      final newTime = DateTime.now().add(const Duration(minutes: 10));

      await Alarm.set(
        alarmSettings: _settings(
          alarmId + 100000,
          newTime,
          "Reminder",
          "Snoozed Reminder",
        ),
      );
    }
  }

  /// ---------------- SCHEDULE ----------------

  static Future<void> scheduleAlarm({
    required int id,
    required String reminderId,
    required String title,
    required String body,
    required DateTime dateTime,
    String repeatType = "one_time",
  }) async {
    // Prevent scheduling past alarms
    if (dateTime.isBefore(DateTime.now())) {
      return;
    }

    await Alarm.set(
      alarmSettings: _settings(
        id,
        dateTime,
        title,
        body,
      ),
    );
  }

  /// ---------------- SETTINGS ----------------
  static AlarmSettings _settings(
    int id,
    DateTime dateTime,
    String title,
    String body,
  ) {
    return AlarmSettings(
      id: id,
      dateTime: dateTime,
      assetAudioPath: 'assets/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: const Duration(seconds: 3),
      ),
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
        stopButton: 'STOP',
      ),
    );
  }

  /// ---------------- CANCEL ----------------
  static Future<void> cancelAlarm(int id) async {
    await Alarm.stop(id);
    await _notifications.cancel(id);
  }

  static Future<void> cancelAll() async {
    final alarms = await Alarm.getAlarms();

    for (final a in alarms) {
      await Alarm.stop(a.id);
    }

    await _notifications.cancelAll();
  }

  /// ---------------- REBUILD SUPPORT ----------------
  /// Call this at app start to reschedule alarms
  static Future<void> rebuildAlarms(
    List<Map<String, dynamic>> reminders,
  ) async {
    for (final r in reminders) {
      final dt = DateTime.parse("${r['date']} ${r['time']}");

      await scheduleAlarm(
        id: r['id'] % 2147483647,
        reminderId: r['id'],
        title: "Reminder",
        body: r['title'],
        dateTime: dt,
        repeatType: r['repeat_type'] ?? "one_time",
      );
    }
  }
}
