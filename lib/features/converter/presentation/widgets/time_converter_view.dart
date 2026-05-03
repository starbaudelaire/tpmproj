import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_util.dart';
import '../../../../shared/widgets/glass_card.dart';

class TimeConverterView extends StatefulWidget {
  const TimeConverterView({super.key});

  @override
  State<TimeConverterView> createState() => _TimeConverterViewState();
}

class _TimeConverterViewState extends State<TimeConverterView> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final utcNow = DateTime.now().toUtc();

    final zones = [
      _TimeZoneItem(
        code: 'WIB',
        city: 'Yogyakarta',
        offsetLabel: 'UTC+7',
        time: utcNow.add(const Duration(hours: 7)),
        color: AppColors.accentPrimary,
      ),
      _TimeZoneItem(
        code: 'WITA',
        city: 'Makassar',
        offsetLabel: 'UTC+8',
        time: utcNow.add(const Duration(hours: 8)),
        color: AppColors.accentTertiary,
      ),
      _TimeZoneItem(
        code: 'WIT',
        city: 'Jayapura',
        offsetLabel: 'UTC+9',
        time: utcNow.add(const Duration(hours: 9)),
        color: AppColors.accentSecondary,
      ),
      _TimeZoneItem(
        code: 'London',
        city: 'United Kingdom',
        offsetLabel: _londonOffsetLabel(utcNow),
        time: _londonTime(utcNow),
        color: AppColors.textSecondary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          blur: 34,
          opacity: 0.078,
          borderRadius: 30,
          borderColor: CupertinoColors.white.withOpacity(0.12),
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.fromLTRB(17, 17, 17, 17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.2,
                colors: [
                  AppColors.accentTertiary.withOpacity(0.13),
                  CupertinoColors.white.withOpacity(0.038),
                  CupertinoColors.black.withOpacity(0.02),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'World Time',
                  style: AppTypography.displaySemi22.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: -0.55,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'WIB, WITA, WIT, and London with DST handling.',
                  style: AppTypography.textRegular13.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                _MainTimeCard(zone: zones.first),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: zones.length - 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisExtent: 78,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final zone = zones[index + 1];
            return _TimeRow(zone: zone);
          },
        ),
      ],
    );
  }

  DateTime _londonTime(DateTime utcNow) {
    final isBst = _isLikelyBritishSummerTime(utcNow);
    return utcNow.add(Duration(hours: isBst ? 1 : 0));
  }

  String _londonOffsetLabel(DateTime utcNow) {
    return _isLikelyBritishSummerTime(utcNow) ? 'UTC+1' : 'UTC+0';
  }

  bool _isLikelyBritishSummerTime(DateTime utcNow) {
    final year = utcNow.year;
    final bstStart = _lastSundayOfMonth(year, 3);
    final bstEnd = _lastSundayOfMonth(year, 10);

    return utcNow.isAfter(bstStart) && utcNow.isBefore(bstEnd);
  }

  DateTime _lastSundayOfMonth(int year, int month) {
    final lastDay = DateTime.utc(year, month + 1, 0, 1);
    final daysBack = lastDay.weekday % 7;
    return lastDay.subtract(Duration(days: daysBack));
  }
}

class _MainTimeCard extends StatelessWidget {
  const _MainTimeCard({required this.zone});

  final _TimeZoneItem zone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: CupertinoColors.white.withOpacity(0.060),
        border: Border.all(
          color: CupertinoColors.white.withOpacity(0.085),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: zone.color.withOpacity(0.14),
            ),
            child: Icon(
              CupertinoIcons.location_solid,
              size: 19,
              color: zone.color,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.city,
                  style: AppTypography.textRegular13.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  zone.code,
                  style: AppTypography.displaySemi22.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateUtil.hourMinute(zone.time),
            style: AppTypography.displayBold34.copyWith(
              color: AppColors.textPrimary,
              fontSize: 36,
              letterSpacing: -1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.zone});

  final _TimeZoneItem zone;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 28,
      opacity: 0.070,
      borderRadius: 24,
      borderColor: CupertinoColors.white.withOpacity(0.10),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: zone.color.withOpacity(0.14),
            ),
            child: Text(
              zone.code.characters.first,
              style: AppTypography.textMedium15.copyWith(
                color: zone.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.code,
                  style: AppTypography.textMedium15.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${zone.city} • ${zone.offsetLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionSmall11.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateUtil.hourMinute(zone.time),
            style: AppTypography.displaySemi20.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: -0.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeZoneItem {
  const _TimeZoneItem({
    required this.code,
    required this.city,
    required this.offsetLabel,
    required this.time,
    required this.color,
  });

  final String code;
  final String city;
  final String offsetLabel;
  final DateTime time;
  final Color color;
}
