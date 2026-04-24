import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/widgets/glass_card.dart';

class MapPreviewStrip extends StatelessWidget {
  const MapPreviewStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse('https://maps.apple.com/?daddr=-7.7971,110.3708'),
      ),
      child: const GlassCard(
        child: Row(
          children: [
            Icon(CupertinoIcons.map_fill),
            SizedBox(width: 12),
            Expanded(child: Text('Buka peta destinasi sekitar')),
            Icon(CupertinoIcons.arrow_up_right_square),
          ],
        ),
      ),
    );
  }
}
