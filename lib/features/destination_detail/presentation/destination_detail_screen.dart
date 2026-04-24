import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/injection.dart';
import '../../../shared/models/destination.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../home/data/weather_remote_datasource.dart';
import 'widgets/ai_guide_teaser.dart';
import 'widgets/info_strip.dart';
import 'widgets/parallax_hero.dart';
import 'widgets/similar_destinations.dart';

class DestinationDetailScreen extends ConsumerWidget {
  const DestinationDetailScreen({required this.destinationId, super.key});

  final String destinationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = Hive.box<DestinationModel>(AppConstants.destinationsBox);
    final destination = box.get(destinationId);
    if (destination == null) {
      return const CupertinoPageScaffold(
        child: Center(child: Text('Destination not found')),
      );
    }

    final similar = box.values
        .where((item) =>
            item.id != destination.id && item.category == destination.category)
        .take(3)
        .toList();

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    SizedBox(
                      height: 420,
                      width: double.infinity,
                      child: ParallaxHero(
                        tag: 'destination-${destination.id}',
                        imageUrl: destination.imageUrl,
                      ),
                    ),
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x000A0A0F), Color(0xCC0A0A0F)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                sliver: SliverList.list(
                  children: [
                    Text(
                      destination.name,
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .navLargeTitleTextStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                        '${destination.category} • rating ${destination.rating}'),
                    const SizedBox(height: 20),
                    InfoStrip(destination: destination),
                    const SizedBox(height: 20),
                    AIGuideTeaser(destinationName: destination.name),
                    const SizedBox(height: 20),
                    const Text('About'),
                    const SizedBox(height: 12),
                    GlassCard(child: Text(destination.description)),
                    const SizedBox(height: 20),
                    const Text('Local Weather'),
                    const SizedBox(height: 12),
                    FutureBuilder<WeatherModel>(
                      future: WeatherRemoteDataSource(
                        dio: Dio(),
                        prefs: getIt(),
                      ).fetchWeather(
                        lat: destination.latitude,
                        lon: destination.longitude,
                      ),
                      builder: (context, snapshot) {
                        final weather = snapshot.data;
                        return GlassCard(
                          child: Text(
                            weather == null
                                ? 'Loading weather...'
                                : '${weather.temp.toStringAsFixed(0)}°C • ${weather.condition}',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Similar Destinations'),
                    const SizedBox(height: 12),
                    SimilarDestinations(items: similar),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 48,
            left: 20,
            child: GlassCard(
              borderRadius: 999,
              padding: const EdgeInsets.all(8),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => context.pop(),
                child: const Icon(CupertinoIcons.back),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Row(
              children: [
                Expanded(
                  child: GlassButton(
                    label: 'Favorit',
                    icon: CupertinoIcons.heart,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GlassButton(
                    label: 'Start Navigation',
                    icon: CupertinoIcons.location_solid,
                    filled: true,
                    onPressed: () {
                      launchUrl(
                        Uri.parse(
                          'https://maps.apple.com/?daddr=${destination.latitude},${destination.longitude}',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
