import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/category.dart';
import '../../../../shared/widgets/glass_card.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      CategoryModel(
        label: 'Budaya',
        icon: CupertinoIcons.building_2_fill,
        color: AppColors.accentSecondary,
      ),
      CategoryModel(
        label: 'Alam',
        icon: CupertinoIcons.leaf_arrow_circlepath,
        color: AppColors.accentTertiary,
      ),
      CategoryModel(
        label: 'Kuliner',
        icon: CupertinoIcons.flame_fill,
        color: AppColors.accentPrimary,
      ),
      CategoryModel(
        label: 'Belanja',
        icon: CupertinoIcons.bag_fill,
        color: AppColors.textSecondary,
      ),
      CategoryModel(
        label: 'Seni',
        icon: CupertinoIcons.paintbrush_fill,
        color: AppColors.textSecondary,
      ),
      CategoryModel(
        label: 'Aktivitas',
        icon: CupertinoIcons.bolt_fill,
        color: AppColors.textSecondary,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GlassCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: item.color),
              const SizedBox(height: 8),
              Text(item.label),
            ],
          ),
        );
      },
    );
  }
}
