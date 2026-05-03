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
                  ? Container(
                      width: 74,
                      height: 74,
                      color: CupertinoColors.white.withOpacity(0.05),
                      child: const Icon(
                        CupertinoIcons.photo,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: safeImageUrl,
                      width: 74,
                      height: 74,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        width: 74,
                        height: 74,
                        color: CupertinoColors.white.withOpacity(0.05),
                        child: const Icon(
                          CupertinoIcons.photo,
                          color: AppColors.textSecondary,
                        ),
                      ),
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
