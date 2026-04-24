import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../models/destination.dart';
import 'category_pill.dart';
import 'glass_card.dart';

class DestinationCardLarge extends StatefulWidget {
  const DestinationCardLarge({
    required this.destination,
    required this.onTap,
    required this.onFavoriteToggle,
    super.key,
    this.distanceLabel,
  });

  final DestinationModel destination;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final String? distanceLabel;

  @override
  State<DestinationCardLarge> createState() => _DestinationCardLargeState();
}

class _DestinationCardLargeState extends State<DestinationCardLarge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapCancel: _controller.reverse,
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1 - (_controller.value * 0.03);
          return Transform.scale(scale: scale, child: child);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Stack(
            children: [
              SizedBox(
                height: 220,
                width: double.infinity,
                child: Hero(
                  tag: 'destination-${widget.destination.id}',
                  child: CachedNetworkImage(
                    imageUrl: widget.destination.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        CupertinoColors.black.withValues(alpha: 0),
                        CupertinoColors.black.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.distanceLabel != null)
                Positioned(
                  left: 16,
                  top: 16,
                  child: CategoryPill(
                    widget.distanceLabel!,
                    color: AppColors.accentTertiary,
                  ),
                ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: GlassCard(
                  height: 76,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.destination.name,
                              style: AppTypography.displaySemi20,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: CategoryPill(widget.destination.category),
                            ),
                          ],
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: widget.onFavoriteToggle,
                        child: Icon(
                          widget.destination.isFavorite
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          color: AppColors.accentPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
