import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../shared/widgets/ios_list_row.dart';
import '../../../shared/widgets/ios_list_section.dart';
import '../presentation/widgets/profile_hero.dart';
import '../presentation/widgets/profile_stats_row.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        children: [
          const ProfileHero(name: 'Jogja Explorer'),
          const SizedBox(height: 16),
          const ProfileStatsRow(),
          const SizedBox(height: 24),
          IosListSection(
            title: 'Tools',
            children: [
              IosListRow(
                title: 'Favorites',
                onTap: () => context.push(RouteNames.favorites),
              ),
              IosListRow(
                title: 'Converter',
                onTap: () => context.push(RouteNames.converter),
              ),
              IosListRow(
                title: 'Mini Game',
                onTap: () => context.push(RouteNames.game),
              ),
              IosListRow(
                title: 'Feedback',
                onTap: () => context.push(RouteNames.feedback),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
