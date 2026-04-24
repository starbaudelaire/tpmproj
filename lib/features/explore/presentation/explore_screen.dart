import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/loading_skeleton.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../domain/usecases/filter_destinations_usecase.dart';
import 'explore_controller.dart';
import 'widgets/destination_grid.dart';
import 'widgets/destination_list.dart';
import 'widgets/filter_sheet.dart';
import 'widgets/map_preview_strip.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final activeCategory = ref.watch(activeCategoryProvider);
    final isGrid = ref.watch(gridModeProvider);
    final filter = FilterModel(query: query, category: activeCategory);
    final results = ref.watch(searchResultsProvider(filter));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        children: [
          CupertinoSearchTextField(
            onChanged: (value) =>
                ref.read(searchQueryProvider.notifier).state = value,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppSegmentedControl<bool>(
                  groupValue: isGrid,
                  children: const {
                    true: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Grid'),
                    ),
                    false: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('List'),
                    ),
                  },
                  onValueChanged: (value) =>
                      ref.read(gridModeProvider.notifier).state = value,
                ),
              ),
              const SizedBox(width: 12),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => showCupertinoModalPopup<void>(
                  context: context,
                  builder: (_) => FilterSheet(
                    onSelected: (value) =>
                        ref.read(activeCategoryProvider.notifier).state = value,
                  ),
                ),
                child: const Icon(CupertinoIcons.slider_horizontal_3),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const MapPreviewStrip(),
          const SizedBox(height: 12),
          results.when(
            data: (items) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isGrid
                  ? DestinationGrid(items: items)
                  : DestinationList(items: items),
            ),
            loading: () => const LoadingSkeleton(height: 220),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
