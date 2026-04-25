import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _notifications =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void alarmCallback() async {
  const androidDetails = AndroidNotificationDetails(
    'vediqlog_alarm',
    'Health Alarm',
    importance: Importance.max,
    priority: Priority.high,
    fullScreenIntent: true,
    playSound: true,
    enableVibration: true,
  );

  _notifications.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,

    "VEDIQLOG Reminder",
    "It's time for your scheduled reminder",
    const NotificationDetails(android: androidDetails),
  );
}
