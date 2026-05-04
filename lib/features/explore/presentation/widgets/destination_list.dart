import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/models/destination.dart';
import '../../../../shared/widgets/destination_card_compact.dart';
import '../../../favorites/data/favorites_local_datasource.dart';
import '../../../home/presentation/home_controller.dart';
import '../explore_controller.dart';

class DestinationList extends ConsumerWidget {
  const DestinationList({
    required this.items,
    required this.distanceLabels,
    super.key,
  });

  final List<DestinationModel> items;
  final Map<String, String> distanceLabels;

  Future<void> _toggleFavorite(
    WidgetRef ref,
    DestinationModel destination,
  ) async {
    await getIt<FavoritesLocalDataSource>().toggleFavorite(destination);

    ref.invalidate(exploreResultsProvider);
    ref.invalidate(featuredDestinationsProvider);
    ref.invalidate(nearbyDestinationsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: items
          .map(
            (destination) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DestinationCardCompact(
                destination: destination,
                subtitle: distanceLabels[destination.id] == null
                    ? '${_categoryLabel(destination)} • rating ${destination.rating.toStringAsFixed(1)}'
                    : '${distanceLabels[destination.id]} • ${_categoryLabel(destination)}',
                onTap: () => context.push('${RouteNames.destination}/${destination.id}'),
                onFavoriteToggle: () => _toggleFavorite(ref, destination),
              ),
            ),
          )
          .toList(),
    );
  }

  String _categoryLabel(DestinationModel destination) {
    final source = '${destination.category} ${destination.type} ${destination.tags.join(' ')}'.toLowerCase();
    if (source.contains('culture') || source.contains('heritage') || source.contains('budaya')) return 'Budaya';
    if (source.contains('history') || source.contains('sejarah') || source.contains('museum')) return 'Sejarah';
    if (source.contains('nature') || source.contains('alam') || source.contains('pantai') || source.contains('goa')) return 'Alam';
    if (source.contains('culinary') || source.contains('kuliner') || source.contains('food')) return 'Kuliner';
    if (source.contains('shopping') || source.contains('belanja') || source.contains('gift')) return 'Belanja';
    if (source.contains('art') || source.contains('seni')) return 'Seni';
    if (source.contains('activity') || source.contains('aktivitas')) return 'Aktivitas';
    if (source.contains('photo') || source.contains('foto')) return 'Foto';
    return destination.category.trim().isEmpty ? 'Wisata' : destination.category;
  }
}
