import 'package:flutter/cupertino.dart';

import '../../../../shared/widgets/bottom_sheet_wrapper.dart';

class FilterSheet extends StatelessWidget {
  const FilterSheet({required this.onSelected, super.key});

  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    const categories = ['Budaya', 'Alam', 'Kuliner', 'Belanja', 'Seni'];
    return BottomSheetWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter kategori'),
          const SizedBox(height: 16),
          ...categories.map(
            (category) => CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                onSelected(category);
                Navigator.of(context).pop();
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(category),
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              onSelected(null);
              Navigator.of(context).pop();
            },
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text('Reset'),
            ),
          ),
        ],
      ),
    );
  }
}
