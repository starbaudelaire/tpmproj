import '../core/di/injection.dart';
import '../features/auth/data/auth_local_datasource.dart';
import '../features/notifications/notification_service.dart';
import 'hive_init.dart';

abstract final class AppInit {
  static Future<bool> initialize() async {
    await HiveInit.initialize();
    await configureDependencies();

    final notificationService = getIt<NotificationService>();
    await notificationService.init();
    await notificationService.scheduleDefaultReminders();

    return getIt<AuthLocalDataSource>().checkSession();
  }
}
