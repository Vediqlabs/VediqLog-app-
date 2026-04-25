import 'package:android_intent_plus/android_intent.dart';

Future<void> openBatteryOptimizationSettings() async {
  final intent = AndroidIntent(
    action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
  );

  await intent.launch();
}
