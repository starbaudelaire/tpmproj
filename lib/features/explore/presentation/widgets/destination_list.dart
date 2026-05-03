import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/models/destination.dart';
import '../../../../shared/widgets/destination_card_compact.dart';

class DestinationList extends StatelessWidget {
  const DestinationList({
    required this.items,
    required this.distanceLabels,
    super.key,
  });

  final List<DestinationModel> items;
  final Map<String, String> distanceLabels;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (destination) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DestinationCardCompact(
                destination: destination,
                subtitle: distanceLabels[destination.id] == null
                    ? '${destination.category} • rating ${destination.rating}'
                    : '${distanceLabels[destination.id]} • ${destination.category}',
                onTap: () =>
                    context.push('${RouteNames.destination}/${destination.id}'),
              ),
            ),
          )
          .toList(),
    );
  }
}
