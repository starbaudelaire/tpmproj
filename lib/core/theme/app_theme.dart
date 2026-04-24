import 'package:flutter/cupertino.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static const cupertinoTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.accentPrimary,
    scaffoldBackgroundColor: AppColors.backgroundPrimary,
    barBackgroundColor: AppColors.backgroundPrimary,
    textTheme: CupertinoTextThemeData(
      textStyle: AppTypography.textRegular17,
      navLargeTitleTextStyle: AppTypography.displayBold34,
      navTitleTextStyle: AppTypography.textMedium15,
      actionTextStyle: AppTypography.textMedium15,
      tabLabelTextStyle: AppTypography.captionSmall11,
    ),
  );
}
