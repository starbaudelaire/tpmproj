import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';

class ParallaxHero extends StatelessWidget {
  const ParallaxHero({
    required this.tag,
    required this.imageUrl,
    super.key,
  });

  final String tag;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final safeImageUrl = imageUrl.trim();
    if (safeImageUrl.isEmpty) {
      return Hero(
        tag: tag,
        child: Container(
          color: CupertinoColors.white.withOpacity(0.05),
          child: const Center(
            child: Icon(
              CupertinoIcons.photo,
              color: AppColors.textSecondary,
              size: 28,
            ),
          ),
        ),
      );
    }

    return Hero(
      tag: tag,
      flightShuttleBuilder: (
        flightContext,
        animation,
        flightDirection,
        fromHeroContext,
        toHeroContext,
      ) {
        return FadeTransition(
          opacity: animation.drive(
            Tween<double>(begin: 0.96, end: 1).chain(
              CurveTween(curve: Curves.easeOutCubic),
            ),
          ),
          child: toHeroContext.widget,
        );
      },
      child: CachedNetworkImage(
        imageUrl: safeImageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: CupertinoColors.white.withOpacity(0.05),
        ),
        errorWidget: (context, url, error) => Container(
          color: CupertinoColors.white.withOpacity(0.05),
          child: const Center(
            child: Icon(
              CupertinoIcons.photo,
              color: AppColors.textSecondary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
