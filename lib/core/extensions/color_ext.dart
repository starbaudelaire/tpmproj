import 'package:flutter/widgets.dart';

extension ColorExt on Color {
  Color withOpacityValue(double opacity) => withValues(alpha: opacity);
}
