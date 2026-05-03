import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_local_datasource.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/converter/presentation/converter_screen.dart';
import '../../features/destination_detail/presentation/destination_detail_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/feedback/presentation/feedback_screen.dart';
import '../../features/guide/presentation/guide_screen.dart';
import '../../features/global_search/presentation/global_search_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/mini_game/presentation/mini_game_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/sensor_hub/presentation/sensor_hub_screen.dart';
import '../../features/tpm_about/presentation/tpm_about_screen.dart';
import '../../shared/widgets/floating_tab_bar.dart';
import '../di/injection.dart';
import 'route_names.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter createRouter(WidgetRef ref, {required bool initialLoggedIn}) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initialLoggedIn ? RouteNames.home : RouteNames.auth,
      redirect: (context, state) async {
        final isLoggedIn = await getIt<AuthLocalDataSource>().checkSession();
        final onAuth = state.uri.path == RouteNames.auth;

        if (!isLoggedIn && !onAuth) return RouteNames.auth;
        if (isLoggedIn && onAuth) return RouteNames.home;
        return null;
      },
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
          path: RouteNames.globalSearch,
          pageBuilder: (context, state) =>
              const CupertinoPage(child: GlobalSearchScreen()),
        ),
        GoRoute(
          path: RouteNames.feedback,
          pageBuilder: (context, state) =>
              const CupertinoPage(child: FeedbackScreen()),
        ),
        GoRoute(
          path: RouteNames.tpmAbout,
          pageBuilder: (context, state) =>
              const CupertinoPage(child: TpmAboutScreen()),
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
            currentIndex: _shellIndexToNavIndex(navigationShell.currentIndex),
            onTap: (index) {
              final branchIndex = _navIndexToShellIndex(index);
              if (branchIndex == null) return;

              navigationShell.goBranch(
                branchIndex,
                initialLocation: branchIndex == navigationShell.currentIndex,
              );
            },
          ),
        ],
      ),
    );
  }

  int _shellIndexToNavIndex(int shellIndex) {
    switch (shellIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 2;
      case 3:
        return 3;
      default:
        return 0;
    }
  }

  int? _navIndexToShellIndex(int navIndex) {
    switch (navIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 2;
      case 3:
        return 3;
      default:
        return null;
    }
  }
}