import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/models/destination.dart';
import '../../../../shared/widgets/destination_card_compact.dart';
import '../home_controller.dart';

class NearbyDestinationsRow extends ConsumerWidget {
  const NearbyDestinationsRow({required this.destinations, super.key});

  final List<DestinationModel> destinations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: destinations
          .map(
            (destination) {
              final distance = ref.watch(destinationDistanceLabelProvider(destination));
              final label = _categoryLabel(destination);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DestinationCardCompact(
                  destination: destination,
                  subtitle: distance.when(
                    data: (value) => '$value • $label',
                    loading: () => 'Menghitung jarak • $label',
                    error: (_, __) => '$label • rating ${destination.rating.toStringAsFixed(1)}',
                  ),
                  onTap: () => context.push('${RouteNames.destination}/${destination.id}'),
                ),
              );
            },
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
