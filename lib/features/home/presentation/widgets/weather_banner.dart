import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/weather_remote_datasource.dart';

class WeatherBanner extends StatelessWidget {
  const WeatherBanner({required this.weather, super.key});

  final WeatherModel weather;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      color: AppColors.accentTertiary,
      opacity: 0.08,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yogyakarta',
                  style: AppTypography.captionSmall11.copyWith(
                    color: AppColors.accentTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${weather.temp.toStringAsFixed(0)}°C',
                  style: AppTypography.displayBold34.copyWith(
                    color: AppColors.accentTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  weather.isStale
                      ? '${weather.condition} • data cache'
                      : weather.condition,
                  style: AppTypography.textRegular13,
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.cloud_sun_fill,
            color: AppColors.accentTertiary,
            size: 42,
          ),
        ],
      ),
    );
  }
}
