import 'package:flutter/cupertino.dart';

import '../../core/theme/app_typography.dart';

class IosListSection extends StatelessWidget {
  const IosListSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.displaySemi20),
        const SizedBox(height: 12),
        ...children.expand((child) => [child, const SizedBox(height: 10)]),
      ],
    );
  }
}
