import 'package:flutter/foundation.dart';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shake/shake.dart';

import '../../../shared/widgets/bottom_sheet_wrapper.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import 'home_controller.dart';
import 'widgets/category_grid.dart';
import 'widgets/featured_destinations_row.dart';
import 'widgets/nearby_destinations_row.dart';
import 'widgets/quick_guide_row.dart';
import 'widgets/weather_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ShakeDetector? _detector;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;
    _detector = ShakeDetector.autoStart(
      shakeThresholdGravity: 15,
      onPhoneShake: (_) async {
        final featured = await ref.read(featuredDestinationsProvider.future);
        if (!mounted || featured.isEmpty) return;
        HapticFeedback.mediumImpact();
        final random = featured[Random().nextInt(featured.length)];
        if (!mounted) return;
        showCupertinoModalPopup<void>(
          context: context,
          builder: (context) => BottomSheetWrapper(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rekomendasi spontan'),
                const SizedBox(height: 8),
                Text(
                  random.name,
                  style: CupertinoTheme.of(
                    context,
                  ).textTheme.navLargeTitleTextStyle,
                ),
                const SizedBox(height: 6),
                Text(random.description),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _detector?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weather = ref.watch(weatherProvider);
    final featured = ref.watch(featuredDestinationsProvider);
    final nearby = ref.watch(nearbyDestinationsProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Selamat Datang'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: const Icon(CupertinoIcons.bell),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            sliver: SliverList.list(
              children: [
                weather.when(
                  data: (value) => WeatherBanner(weather: value),
                  loading: () => const LoadingSkeleton(height: 120),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),
                const Text('Kategori'),
                const SizedBox(height: 12),
                const CategoryGrid(),
                const SizedBox(height: 24),
                const Text('Pilihan Untukmu'),
                const SizedBox(height: 12),
                featured.when(
                  data: (value) => FeaturedDestinationsRow(destinations: value),
                  loading: () => const LoadingSkeleton(height: 220),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),
                const Text('Terdekat Darimu'),
                const SizedBox(height: 12),
                nearby.when(
                  data: (value) => NearbyDestinationsRow(destinations: value),
                  loading: () => const LoadingSkeleton(height: 180),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),
                const Text('Panduan Cepat'),
                const SizedBox(height: 12),
                const QuickGuideRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
