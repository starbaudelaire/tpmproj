import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../models/destination.dart';
import 'glass_card.dart';

class DestinationCardCompact extends StatelessWidget {
  const DestinationCardCompact({
    required this.destination,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final DestinationModel destination;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final safeImageUrl = destination.imageUrl.trim();

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      pressedOpacity: 0.78,
      onPressed: onTap,
      child: GlassCard(
        blur: 28,
        opacity: 0.075,
        borderRadius: 22,
        borderColor: CupertinoColors.white.withOpacity(0.12),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: safeImageUrl.isEmpty
                  ? _CompactImageFallback(destination: destination)
                  : CachedNetworkImage(
                      imageUrl: safeImageUrl,
                      width: 74,
                      height: 74,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => _CompactImageFallback(destination: destination),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textMedium15.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textRegular13.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.25,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}


class _CompactImageFallback extends StatelessWidget {
  const _CompactImageFallback({required this.destination});

  final DestinationModel destination;

  @override
  Widget build(BuildContext context) {
    final source = '${destination.category} ${destination.type} ${destination.tags.join(' ')}'.toLowerCase();
    final icon = source.contains('kuliner') || source.contains('culinary')
        ? CupertinoIcons.flame_fill
        : source.contains('alam') || source.contains('nature') || source.contains('pantai')
            ? CupertinoIcons.leaf_arrow_circlepath
            : source.contains('sejarah') || source.contains('history')
                ? CupertinoIcons.book_fill
                : source.contains('foto') || source.contains('photo')
                    ? CupertinoIcons.camera_fill
                    : CupertinoIcons.map_fill;

    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentSecondary.withOpacity(0.26),
            AppColors.accentPrimary.withOpacity(0.20),
            AppColors.accentTertiary.withOpacity(0.14),
          ],
        ),
      ),
      child: Icon(icon, color: AppColors.textPrimary.withOpacity(0.72), size: 25),
    );
  }
}

