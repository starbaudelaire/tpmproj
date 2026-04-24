import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/utils/timezone_util.dart';

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<void> scheduleDaily(
    int id,
    String title,
    String body,
    DateTime time,
  ) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      TimezoneUtil.nextDailyEight(),
      const NotificationDetails(
        android: AndroidNotificationDetails('jogjasplorasi_main', 'Main'),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showImmediate(String title, String body) async {
    await _plugin.show(
      1,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails('jogjasplorasi_main', 'Main'),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
