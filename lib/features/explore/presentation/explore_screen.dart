import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import 'explore_controller.dart';
import 'widgets/destination_grid.dart';
import 'widgets/destination_list.dart';
import 'widgets/filter_sheet.dart';
import 'widgets/map_preview_strip.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGrid = ref.watch(gridModeProvider);
    final sortByNearest = ref.watch(sortByNearestProvider);
    final activeCategory = ref.watch(activeCategoryProvider);
    final location = ref.watch(exploreLocationProvider);
    final results = ref.watch(exploreResultsProvider);

    final locationReady = location.valueOrNull != null;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 126),
        physics: const BouncingScrollPhysics(),
        children: [
          _ExploreHeader(
            locationText: location.when(
              data: (value) => value == null
                  ? 'Lokasi belum aktif'
                  : sortByNearest
                      ? 'Terdekat aktif'
                      : 'Semua tempat',
              loading: () => 'Cek lokasi...',
              error: (_, __) => 'Lokasi bermasalah',
            ),
            locationActive: sortByNearest && locationReady,
          ),
          const SizedBox(height: 18),
          _SearchField(
            onChanged: (value) =>
                ref.read(searchQueryProvider.notifier).state = value,
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              _CircleToolButton(
                label: 'Terdekat',
                icon: sortByNearest
                    ? CupertinoIcons.location_solid
                    : CupertinoIcons.location,
                active: sortByNearest && locationReady,
                onTap: () {
                  ref.read(sortByNearestProvider.notifier).state =
                      !sortByNearest;
                },
              ),
              const SizedBox(width: 10),
              _CircleToolButton(
                label: isGrid ? 'List' : 'Grid',
                icon: isGrid
                    ? CupertinoIcons.list_bullet
                    : CupertinoIcons.square_grid_2x2,
                onTap: () {
                  ref.read(gridModeProvider.notifier).state = !isGrid;
                },
              ),
              const SizedBox(width: 10),
              _CircleToolButton(
                label: 'Filter',
                icon: CupertinoIcons.slider_horizontal_3,
                active: activeCategory != null,
                onTap: () => showCupertinoModalPopup<void>(
                  context: context,
                  builder: (_) => FilterSheet(
                    onSelected: (value) =>
                        ref.read(activeCategoryProvider.notifier).state = value,
                  ),
                ),
              ),
              const Spacer(),
              _MiniStatusPill(
                text: activeCategory ?? (sortByNearest ? 'Terdekat' : 'Semua'),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _CategoryChips(
            activeCategory: activeCategory,
            onSelected: (value) {
              ref.read(activeCategoryProvider.notifier).state = value;
            },
          ),
          const SizedBox(height: 22),
          results.when(
            data: (items) {
              final position = location.valueOrNull;
              final distanceLabels = <String, String>{};

              if (position != null) {
                for (final item in items) {
                  final meters = getIt<LocationService>().distanceInMeters(
                    fromLat: position.latitude,
                    fromLon: position.longitude,
                    toLat: item.latitude,
                    toLon: item.longitude,
                  );

                  distanceLabels[item.id] =
                      getIt<LocationService>().formatDistance(meters);
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MapPreviewStrip(
                    destinations: items,
                    userLatitude: position?.latitude,
                    userLongitude: position?.longitude,
                  ),
                  const SizedBox(height: 22),
                  _SectionHeader(
                    title: sortByNearest && position != null
                        ? 'Terdekat dari Lokasimu'
                        : 'Semua Destinasi',
                    subtitle: '${items.length} destinasi ditemukan',
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: isGrid
                        ? DestinationGrid(
                            key: const ValueKey('grid'),
                            items: items,
                            distanceLabels: distanceLabels,
                          )
                        : DestinationList(
                            key: const ValueKey('list'),
                            items: items,
                            distanceLabels: distanceLabels,
                          ),
                  ),
                ],
              );
            },
            loading: () => const LoadingSkeleton(height: 220),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader({
    required this.locationText,
    required this.locationActive,
  });

  final String locationText;
  final bool locationActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jelajahi Jogja',
                style: AppTypography.displayBold34.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  letterSpacing: -1.05,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Temukan destinasi terbaik di sekitarmu.',
                style: AppTypography.textRegular13.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _LocationMiniBadge(
          text: locationText,
          active: locationActive,
        ),
      ],
    );
  }
}

class _LocationMiniBadge extends StatelessWidget {
  const _LocationMiniBadge({
    required this.text,
    required this.active,
  });

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 24,
      opacity: active ? 0.09 : 0.065,
      borderRadius: 999,
      borderColor: CupertinoColors.white.withOpacity(0.10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? CupertinoIcons.location_solid : CupertinoIcons.location,
            size: 13,
            color: active ? AppColors.accentPrimary : AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTypography.captionSmall11.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 30,
      opacity: 0.073,
      borderRadius: 20,
      borderColor: CupertinoColors.white.withOpacity(0.10),
      padding: EdgeInsets.zero,
      child: CupertinoTextField.borderless(
        placeholder: 'Cari candi, kuliner, pantai, atau fitur...',
        onChanged: onChanged,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 14, right: 8),
          child: Icon(
            CupertinoIcons.search,
            size: 17,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
        ),
        placeholderStyle: AppTypography.textRegular13.copyWith(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        style: AppTypography.textRegular13.copyWith(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        cursorColor: AppColors.textPrimary,
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.activeCategory,
    required this.onSelected,
  });

  final String? activeCategory;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    const items = <String?>[
      null,
      'Budaya',
      'Alam',
      'Kuliner',
      'Belanja',
      'Seni',
      'Aktivitas',
      'Sejarah',
      'Photo',
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final value = items[index];
          final label = value ?? 'Semua';
          final selected = activeCategory == value;

          return _CategoryChip(
            label: label,
            selected: selected,
            onTap: () => onSelected(value),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      pressedOpacity: 0.75,
      onPressed: onTap,
      child: GlassCard(
        blur: 24,
        opacity: selected ? 0.11 : 0.065,
        borderRadius: 999,
        borderColor: CupertinoColors.white.withOpacity(selected ? 0.16 : 0.09),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(
          label,
          style: AppTypography.captionSmall11.copyWith(
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.05,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.displaySemi20.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.45,
            ),
          ),
        ),
        Text(
          subtitle,
          style: AppTypography.captionSmall11.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _MiniStatusPill extends StatelessWidget {
  const _MiniStatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 24,
      opacity: 0.06,
      borderRadius: 999,
      borderColor: CupertinoColors.white.withOpacity(0.08),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.captionSmall11.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _CircleToolButton extends StatefulWidget {
  const _CircleToolButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  State<_CircleToolButton> createState() => _CircleToolButtonState();
}

class _CircleToolButtonState extends State<_CircleToolButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: GlassCard(
          height: 44,
          blur: 28,
          opacity: widget.active ? 0.105 : 0.073,
          borderRadius: 999,
          borderColor: CupertinoColors.white.withOpacity(0.11),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 17,
                color: widget.active
                    ? AppColors.accentPrimary
                    : AppColors.textPrimary,
              ),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: AppTypography.captionSmall11.copyWith(
                  color: widget.active
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}