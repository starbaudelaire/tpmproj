import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/destination.dart';
import '../../../shared/widgets/destination_card_compact.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = Hive.box<DestinationModel>(
      AppConstants.destinationsBox,
    ).values.where((item) => item.isFavorite).toList();
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Favorites')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DestinationCardCompact(
                    destination: item,
                    subtitle: item.category,
                    onTap: () {},
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
