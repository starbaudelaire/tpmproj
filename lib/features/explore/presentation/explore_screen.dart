import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/models/destination.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import 'explore_controller.dart';
import 'widgets/destination_grid.dart';
import 'widgets/destination_list.dart';
import 'widgets/map_preview_strip.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  static const int _pageSize = 20;

  void _resetPage(WidgetRef ref) {
    ref.read(explorePageProvider.notifier).state = 1;
  }

  void _showCategoryPicker(BuildContext context, WidgetRef ref, String? activeCategory) {
    const categories = <String?>[
      null,
      'Budaya',
      'Alam',
      'Kuliner',
      'Belanja',
      'Seni',
      'Aktivitas',
      'Sejarah',
      'Foto',
    ];

    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Pilih kategori'),
        message: const Text('Filter destinasi tanpa memenuhi halaman dengan chip.'),
        actions: [
          for (final category in categories)
            CupertinoActionSheetAction(
              onPressed: () {
                ref.read(activeCategoryProvider.notifier).state = category;
                _resetPage(ref);
                Navigator.of(context).pop();
              },
              child: Text(
                category ?? 'Semua destinasi',
                style: TextStyle(
                  fontWeight: activeCategory == category ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGrid = ref.watch(gridModeProvider);
    final sortByNearest = ref.watch(sortByNearestProvider);
    final activeCategory = ref.watch(activeCategoryProvider);
    final currentPage = ref.watch(explorePageProvider);
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
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
              _resetPage(ref);
            },
          ),
          const SizedBox(height: 12),
          _ExploreControlPanel(
            categoryLabel: activeCategory ?? 'Semua',
            sortLabel: sortByNearest ? 'Terdekat' : 'Kurasi',
            layoutLabel: isGrid ? 'Kartu' : 'List',
            isNearestActive: sortByNearest && locationReady,
            onCategoryTap: () => _showCategoryPicker(context, ref, activeCategory),
            onSortTap: () {
              ref.read(sortByNearestProvider.notifier).state = !sortByNearest;
              _resetPage(ref);
            },
            onLayoutTap: () => ref.read(gridModeProvider.notifier).state = !isGrid,
            onResetTap: () {
              ref.read(searchQueryProvider.notifier).state = '';
              ref.read(activeCategoryProvider.notifier).state = null;
              ref.read(sortByNearestProvider.notifier).state = true;
              _resetPage(ref);
            },
          ),
          const SizedBox(height: 20),
          results.when(
            data: (items) {
              final totalPages = math.max(1, (items.length / _pageSize).ceil());
              final safePage = currentPage.clamp(1, totalPages).toInt();
              final start = items.isEmpty ? 0 : (safePage - 1) * _pageSize;
              final end = math.min(start + _pageSize, items.length);
              final pageItems = items.isEmpty ? <DestinationModel>[] : items.sublist(start, end);
              final position = location.valueOrNull;
              final distanceLabels = <String, String>{};

              if (position != null) {
                for (final item in pageItems) {
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
                    destinations: pageItems,
                    userLatitude: position?.latitude,
                    userLongitude: position?.longitude,
                  ),
                  const SizedBox(height: 20),
                  _SectionHeader(
                    title: sortByNearest && position != null
                        ? 'Terdekat dari Lokasimu'
                        : activeCategory ?? 'Semua Destinasi',
                    subtitle: items.isEmpty
                        ? 'Tidak ada hasil'
                        : '${start + 1}-$end dari ${items.length}',
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: isGrid
                        ? DestinationGrid(
                            key: ValueKey('grid-$safePage-${activeCategory ?? 'all'}'),
                            items: pageItems,
                            distanceLabels: distanceLabels,
                          )
                        : DestinationList(
                            key: ValueKey('list-$safePage-${activeCategory ?? 'all'}'),
                            items: pageItems,
                            distanceLabels: distanceLabels,
                          ),
                  ),
                  const SizedBox(height: 16),
                  _PaginationControls(
                    page: safePage,
                    totalPages: totalPages,
                    canPrevious: safePage > 1,
                    canNext: safePage < totalPages,
                    onPrevious: () => ref.read(explorePageProvider.notifier).state = safePage - 1,
                    onNext: () => ref.read(explorePageProvider.notifier).state = safePage + 1,
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

class _ExploreControlPanel extends StatelessWidget {
  const _ExploreControlPanel({
    required this.categoryLabel,
    required this.sortLabel,
    required this.layoutLabel,
    required this.isNearestActive,
    required this.onCategoryTap,
    required this.onSortTap,
    required this.onLayoutTap,
    required this.onResetTap,
  });

  final String categoryLabel;
  final String sortLabel;
  final String layoutLabel;
  final bool isNearestActive;
  final VoidCallback onCategoryTap;
  final VoidCallback onSortTap;
  final VoidCallback onLayoutTap;
  final VoidCallback onResetTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 30,
      opacity: 0.07,
      borderRadius: 22,
      borderColor: CupertinoColors.white.withOpacity(0.10),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _SelectPill(
            icon: CupertinoIcons.square_grid_2x2,
            label: 'Kategori',
            value: categoryLabel,
            onTap: onCategoryTap,
          ),
          _SelectPill(
            icon: isNearestActive ? CupertinoIcons.location_solid : CupertinoIcons.sort_down,
            label: 'Urut',
            value: sortLabel,
            active: isNearestActive,
            onTap: onSortTap,
          ),
          _SelectPill(
            icon: CupertinoIcons.rectangle_grid_1x2,
            label: 'Tampilan',
            value: layoutLabel,
            onTap: onLayoutTap,
          ),
          _SelectPill(
            icon: CupertinoIcons.arrow_counterclockwise,
            label: 'Reset',
            value: 'Bersihkan',
            onTap: onResetTap,
          ),
        ],
      ),
    );
  }
}

class _SelectPill extends StatelessWidget {
  const _SelectPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      pressedOpacity: 0.75,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: CupertinoColors.white.withOpacity(active ? 0.10 : 0.055),
          border: Border.all(color: CupertinoColors.white.withOpacity(0.085)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: active ? AppColors.accentPrimary : AppColors.textSecondary),
            const SizedBox(width: 7),
            Text(
              '$label: $value',
              style: AppTypography.captionSmall11.copyWith(
                color: active ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationControls extends StatelessWidget {
  const _PaginationControls({
    required this.page,
    required this.totalPages,
    required this.canPrevious,
    required this.canNext,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int totalPages;
  final bool canPrevious;
  final bool canNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: canPrevious ? onPrevious : null,
            child: GlassCard(
              blur: 24,
              opacity: canPrevious ? 0.075 : 0.035,
              borderRadius: 18,
              borderColor: CupertinoColors.white.withOpacity(0.08),
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Text(
                '← Sebelumnya',
                textAlign: TextAlign.center,
                style: AppTypography.captionSmall11.copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GlassCard(
          blur: 20,
          opacity: 0.055,
          borderRadius: 18,
          borderColor: CupertinoColors.white.withOpacity(0.08),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Text(
            '$page / $totalPages',
            style: AppTypography.captionSmall11.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: canNext ? onNext : null,
            child: GlassCard(
              blur: 24,
              opacity: canNext ? 0.075 : 0.035,
              borderRadius: 18,
              borderColor: CupertinoColors.white.withOpacity(0.08),
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Text(
                'Berikutnya →',
                textAlign: TextAlign.center,
                style: AppTypography.captionSmall11.copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
        ),
      ],
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
      'Foto',
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