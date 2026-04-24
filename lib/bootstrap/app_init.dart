import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import '../core/constants/app_constants.dart';
import '../core/di/injection.dart';
import '../features/auth/data/auth_local_datasource.dart';
import '../features/notifications/notification_service.dart';
import '../shared/models/destination.dart';
import 'hive_init.dart';

abstract final class AppInit {
  static Future<bool> initialize() async {
    await HiveInit.initialize();
    await configureDependencies();
    await _seedDestinations();
    await getIt<NotificationService>().init();
    return getIt<AuthLocalDataSource>().checkSession();
  }

  static Future<void> _seedDestinations() async {
    final box = Hive.box<DestinationModel>(AppConstants.destinationsBox);
    if (box.isNotEmpty) return;

    final raw = await rootBundle.loadString('assets/data/destinations.json');
    final data = (jsonDecode(raw) as List<dynamic>)
        .map((item) => DestinationModel.fromJson(item as Map<String, dynamic>))
        .toList();

    for (final destination in data) {
      await box.put(destination.id, destination);
    }
  }
}
