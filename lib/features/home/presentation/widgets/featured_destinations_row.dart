import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/models/destination.dart';
import '../../../../shared/widgets/destination_card_large.dart';

class FeaturedDestinationsRow extends StatelessWidget {
  const FeaturedDestinationsRow({required this.destinations, super.key});

  final List<DestinationModel> destinations;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.88),
        itemCount: destinations.length,
        itemBuilder: (context, index) {
          final destination = destinations[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: DestinationCardLarge(
              destination: destination,
              distanceLabel: '${destination.rating} ★',
              onTap: () =>
                  context.push('${RouteNames.destination}/${destination.id}'),
              onFavoriteToggle: () {},
            ),
          );
        },
      ),
    );
  }
}
