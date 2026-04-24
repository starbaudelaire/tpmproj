import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../../../core/utils/date_util.dart';

class TimeConverterView extends StatefulWidget {
  const TimeConverterView({super.key});

  @override
  State<TimeConverterView> createState() => _TimeConverterViewState();
}

class _TimeConverterViewState extends State<TimeConverterView> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zones = {
      'WIB': _now,
      'WITA': _now.add(const Duration(hours: 1)),
      'WIT': _now.add(const Duration(hours: 2)),
      'UTC': _now.toUtc(),
    };
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: zones.entries
          .map(
            (entry) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x14111118),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(entry.key),
                  const SizedBox(height: 8),
                  Text(DateUtil.hourMinute(entry.value)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
