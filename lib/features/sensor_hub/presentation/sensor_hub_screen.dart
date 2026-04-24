import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../shared/widgets/glass_card.dart';
import 'widgets/accel_graph.dart';
import 'widgets/gyro_cube_visualizer.dart';
import 'widgets/sensor_feature_card.dart';
import 'widgets/sensor_live_banner.dart';

final accelerometerProvider = StreamProvider<AccelerometerEvent>(
  (ref) => accelerometerEventStream(),
);
final gyroscopeProvider = StreamProvider<GyroscopeEvent>(
  (ref) => gyroscopeEventStream(),
);

class SensorHubScreen extends ConsumerStatefulWidget {
  const SensorHubScreen({super.key});

  @override
  ConsumerState<SensorHubScreen> createState() => _SensorHubScreenState();
}

class _SensorHubScreenState extends ConsumerState<SensorHubScreen> {
  final List<double> _values = [];
  StreamSubscription<AccelerometerEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;
    _subscription = accelerometerEventStream().listen((event) {
      setState(() {
        _values.add(event.x);
        if (_values.length > 20) _values.removeAt(0);
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          children: const [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Sensor Hub'),
                  SizedBox(height: 8),
                  Text(
                    'Browser tidak menyediakan stream accelerometer dan gyroscope yang konsisten untuk app ini. Coba jalankan di Android untuk sensor live.',
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            SensorFeatureCard(
              icon: CupertinoIcons.device_phone_portrait,
              label: 'Platform',
              value: 'Web Preview',
            ),
            SizedBox(height: 12),
            SensorFeatureCard(
              icon: CupertinoIcons.waveform_path_ecg,
              label: 'Motion',
              value: 'Unavailable',
            ),
          ],
        ),
      );
    }

    final accel = ref.watch(accelerometerProvider).value;
    final gyro = ref.watch(gyroscopeProvider).value;
    final width = MediaQuery.sizeOf(context).width;
    final aspectRatio = width > 900
        ? 2.2
        : width > 600
            ? 1.7
            : 1.3;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        children: [
          SensorLiveBanner(
            accel: accel == null
                ? '-'
                : '${accel.x.toStringAsFixed(2)}, ${accel.y.toStringAsFixed(2)}, ${accel.z.toStringAsFixed(2)}',
            gyro: gyro == null
                ? '-'
                : '${gyro.x.toStringAsFixed(2)}, ${gyro.y.toStringAsFixed(2)}, ${gyro.z.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 16),
          GyroCubeVisualizer(x: gyro?.x ?? 0, y: gyro?.y ?? 0),
          const SizedBox(height: 16),
          AccelGraph(values: _values.isEmpty ? [0, 1, 0.2, 1.4] : _values),
          const SizedBox(height: 16),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: aspectRatio,
            ),
            children: [
              SensorFeatureCard(
                icon: CupertinoIcons.waveform_path_ecg,
                label: 'Motion',
                value: 'Live',
              ),
              SensorFeatureCard(
                icon: CupertinoIcons.scope,
                label: 'Gyro',
                value: '3-axis',
              ),
              SensorFeatureCard(
                icon: CupertinoIcons.speedometer,
                label: 'Shake',
                value: 'Ready',
              ),
              SensorFeatureCard(
                icon: CupertinoIcons.cube_box,
                label: 'Visualizer',
                value: '3D',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
