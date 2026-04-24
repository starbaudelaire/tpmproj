import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/models/destination.dart';
import '../../../../shared/widgets/destination_card_large.dart';

class DestinationGrid extends StatelessWidget {
  const DestinationGrid({required this.items, super.key});

  final List<DestinationModel> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisExtent: 240,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final destination = items[index];
        return DestinationCardLarge(
          destination: destination,
          onTap: () =>
              context.push('${RouteNames.destination}/${destination.id}'),
          onFavoriteToggle: () {},
        );
      },
    );
  }
}
