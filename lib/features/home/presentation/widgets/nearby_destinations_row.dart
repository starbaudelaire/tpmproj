import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/models/destination.dart';
import '../../../../shared/widgets/destination_card_compact.dart';

class NearbyDestinationsRow extends StatelessWidget {
  const NearbyDestinationsRow({required this.destinations, super.key});

  final List<DestinationModel> destinations;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: destinations
          .map(
            (destination) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DestinationCardCompact(
                destination: destination,
                subtitle:
                    '${destination.category} • rating ${destination.rating}',
                onTap: () =>
                    context.push('${RouteNames.destination}/${destination.id}'),
              ),
            ),
          )
          .toList(),
    );
  }
}
