import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class JogjasplorasiApp extends ConsumerWidget {
  const JogjasplorasiApp({required this.initialLoggedIn, super.key});

  final bool initialLoggedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = AppRouter.createRouter(
      ref,
      initialLoggedIn: initialLoggedIn,
    );
    return CupertinoApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Jogjasplorasi',
      theme: AppTheme.cupertinoTheme,
      routerConfig: router,
    );
  }
}
