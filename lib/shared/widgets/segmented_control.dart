import 'package:flutter/cupertino.dart';

class AppSegmentedControl<T extends Object> extends StatelessWidget {
  const AppSegmentedControl({
    required this.groupValue,
    required this.children,
    required this.onValueChanged,
    super.key,
  });

  final T groupValue;
  final Map<T, Widget> children;
  final ValueChanged<T> onValueChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoSlidingSegmentedControl<T>(
      groupValue: groupValue,
      children: children,
      onValueChanged: (value) {
        if (value != null) onValueChanged(value);
      },
    );
  }
}
