import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/models/destination.dart';
import '../../../../shared/widgets/destination_card_compact.dart';

class DestinationList extends StatelessWidget {
  const DestinationList({required this.items, super.key});

  final List<DestinationModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (destination) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DestinationCardCompact(
                destination: destination,
                subtitle: destination.description,
                onTap: () =>
                    context.push('${RouteNames.destination}/${destination.id}'),
              ),
            ),
          )
          .toList(),
    );
  }
}
