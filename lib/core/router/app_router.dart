import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_screen.dart';
import '../../features/converter/presentation/converter_screen.dart';
import '../../features/destination_detail/presentation/destination_detail_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/feedback/presentation/feedback_screen.dart';
import '../../features/guide/presentation/guide_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/mini_game/presentation/mini_game_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/sensor_hub/presentation/sensor_hub_screen.dart';
import '../../shared/widgets/floating_tab_bar.dart';
import 'route_names.dart';

class AppRouter {
  static GoRouter createRouter(WidgetRef ref, {required bool initialLoggedIn}) {
    return GoRouter(
      initialLocation: initialLoggedIn ? RouteNames.home : RouteNames.auth,
      routes: [
        GoRoute(
          path: RouteNames.auth,
          builder: (context, state) => const AuthScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return _MainShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.home,
                  pageBuilder: (context, state) =>
                      const CupertinoPage(child: HomeScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.explore,
                  pageBuilder: (context, state) =>
                      const CupertinoPage(child: ExploreScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.guide,
                  pageBuilder: (context, state) => CupertinoPage(
                    child: GuideScreen(
                      initialPrompt: state.uri.queryParameters['prompt'],
                    ),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.profile,
                  pageBuilder: (context, state) =>
                      const CupertinoPage(child: ProfileScreen()),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.sensor,
          pageBuilder: (context, state) =>
              const CupertinoPage(child: SensorHubScreen()),
        ),
        GoRoute(
          path: '${RouteNames.destination}/:id',
          pageBuilder: (context, state) => CupertinoPage(
            child: DestinationDetailScreen(
              destinationId: state.pathParameters['id']!,
            ),
          ),
        ),
        GoRoute(
          path: RouteNames.converter,
          pageBuilder: (context, state) =>
              const CupertinoPage(child: ConverterScreen()),
        ),
        GoRoute(
          path: RouteNames.game,
          pageBuilder: (context, state) =>
              const CupertinoPage(child: MiniGameScreen()),
        ),
        GoRoute(
          path: RouteNames.feedback,
          pageBuilder: (context, state) =>
              const CupertinoPage(child: FeedbackScreen()),
        ),
        GoRoute(
          path: RouteNames.favorites,
          pageBuilder: (context, state) =>
              const CupertinoPage(child: FavoritesScreen()),
        ),
      ],
    );
  }
}

class _MainShell extends StatelessWidget {
  const _MainShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Positioned.fill(child: navigationShell),
          FloatingTabBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) {
              if (index == 4) {
                context.push(RouteNames.sensor);
                return;
              }
              navigationShell.goBranch(index);
            },
          ),
        ],
      ),
    );
  }
}
