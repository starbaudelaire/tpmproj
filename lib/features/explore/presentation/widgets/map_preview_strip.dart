import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/destination.dart';
import '../../../../shared/widgets/glass_card.dart';

class MapPreviewStrip extends StatelessWidget {
  const MapPreviewStrip({
    required this.destinations,
    required this.userLatitude,
    required this.userLongitude,
    super.key,
  });

  final List<DestinationModel> destinations;
  final double? userLatitude;
  final double? userLongitude;

  static const _jogjaCenter = LatLng(
    LocationService.jogjaLatitude,
    LocationService.jogjaLongitude,
  );

  LatLng get _center {
    if (userLatitude != null && userLongitude != null) {
      return LatLng(userLatitude!, userLongitude!);
    }

    if (destinations.isNotEmpty) {
      return LatLng(destinations.first.latitude, destinations.first.longitude);
    }

    return _jogjaCenter;
  }

  Future<void> _openDestination(
    BuildContext context,
    DestinationModel destination,
  ) async {
    final opened = await getIt<LocationService>().openDestinationMap(
      destination,
    );

    if (!context.mounted || opened) return;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Maps tidak bisa dibuka'),
        message: const Text(
          'Coba cek aplikasi maps atau koneksi internet kamu.',
        ),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ),
    );
  }

  Future<void> _openJogjaMap(BuildContext context) async {
    final opened = await getIt<LocationService>().openMap(
      latitude: _center.latitude,
      longitude: _center.longitude,
      label: 'Destinasi wisata Yogyakarta',
    );

    if (!context.mounted || opened) return;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Maps tidak bisa dibuka'),
        message: const Text(
          'Coba cek aplikasi maps atau koneksi internet kamu.',
        ),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleDestinations = destinations.take(12).toList();
    final hasUserLocation = userLatitude != null && userLongitude != null;

    return GlassCard(
      blur: 32,
      opacity: 0.075,
      borderRadius: 28,
      borderColor: CupertinoColors.white.withValues(alpha: 0.11),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Jelajah Sekitarmu',
                    style: AppTypography.displaySemi20.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      letterSpacing: -0.45,
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: () => _openJogjaMap(context),
                  child: GlassCard(
                    blur: 18,
                    opacity: 0.075,
                    borderRadius: 999,
                    borderColor:
                        CupertinoColors.white.withValues(alpha: 0.10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.arrow_up_right_square,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Buka Peta',
                          style: AppTypography.captionSmall11.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              height: 230,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: hasUserLocation ? 12.5 : 11.5,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.drag |
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.doubleTapZoom,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.jogjasplorasi',
                  ),
                  MarkerLayer(
                    markers: [
                      if (hasUserLocation)
                        Marker(
                          point: LatLng(userLatitude!, userLongitude!),
                          width: 42,
                          height: 42,
                          child: const _UserMarker(),
                        ),
                      ...visibleDestinations.map(
                        (destination) => Marker(
                          point: LatLng(
                            destination.latitude,
                            destination.longitude,
                          ),
                          width: 46,
                          height: 46,
                          child: GestureDetector(
                            onTap: () => _openDestination(
                              context,
                              destination,
                            ),
                            child: const _DestinationMarker(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
            child: Text(
              hasUserLocation
                  ? 'Lihat tempat menarik di dekatmu dan pilih destinasi yang ingin kamu kunjungi.'
                  : 'Aktifkan lokasi agar Kanca Jogja bisa menunjukkan tempat menarik di sekitarmu.',
              style: AppTypography.captionSmall11.copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationMarker extends StatelessWidget {
  const _DestinationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accentPrimary.withValues(alpha: 0.18),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.42),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            spreadRadius: -6,
            color: AppColors.accentPrimary.withValues(alpha: 0.45),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentPrimary,
            border: Border.all(
              color: CupertinoColors.white.withValues(alpha: 0.75),
              width: 1,
            ),
          ),
          child: const Icon(
            CupertinoIcons.location_solid,
            size: 14,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}

class _UserMarker extends StatelessWidget {
  const _UserMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accentSecondary.withValues(alpha: 0.18),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            spreadRadius: -6,
            color: AppColors.accentSecondary.withValues(alpha: 0.55),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentSecondary,
            border: Border.all(
              color: CupertinoColors.white.withValues(alpha: 0.78),
              width: 1,
            ),
          ),
          child: const Icon(
            CupertinoIcons.person_fill,
            size: 11,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}