import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';

class SensorLiveBanner extends StatelessWidget {
  const SensorLiveBanner({required this.accel, required this.gyro, super.key});

  final String accel;
  final String gyro;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Accelerometer',
            style: AppTypography.captionSmall11,
          ),
          const SizedBox(height: 4),
          Text(
            accel,
            style: AppTypography.textRegular13,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            'Gyroscope',
            style: AppTypography.captionSmall11,
          ),
          const SizedBox(height: 4),
          Text(
            gyro,
            style: AppTypography.textRegular13,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
