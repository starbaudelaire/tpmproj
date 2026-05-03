import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme_controller.dart';

class JogjaSplorasiApp extends ConsumerWidget {
  const JogjaSplorasiApp({required this.initialLoggedIn, super.key});

  final bool initialLoggedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = AppRouter.createRouter(
      ref,
      initialLoggedIn: initialLoggedIn,
    );
    final themeMode = ref.watch(themeControllerProvider);
    final platformBrightness = MediaQuery.of(context).platformBrightness;

    return CupertinoApp.router(
      debugShowCheckedModeBanner: false,
      title: 'JogjaSplorasi',
      theme: themeForMode(themeMode, platformBrightness),
      routerConfig: router,
    );
  }
}
