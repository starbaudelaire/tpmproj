import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/glass_card.dart';

class AIGuideTeaser extends StatelessWidget {
  const AIGuideTeaser({required this.destinationName, super.key});

  final String destinationName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '${RouteNames.guide}?prompt=Berikan tips perjalanan untuk $destinationName',
      ),
      child: const GlassCard(
        child: Row(
          children: [
            Icon(CupertinoIcons.sparkles),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tanya Guide AI untuk itinerary, sejarah, dan hidden gems',
              ),
            ),
            Icon(CupertinoIcons.chevron_right),
          ],
        ),
      ),
    );
  }
}
