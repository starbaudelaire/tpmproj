import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../bootstrap/hive_init.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/injection.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../shared/models/destination.dart';
import '../../../shared/models/user.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../auth/data/auth_local_datasource.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<_ProfileData> _profileFuture;
  Uint8List? _profileImage;

  static const _bgTop = Color(0xFF181821);
  static const _bgMid = Color(0xFF0F0F16);
  static const _bgBottom = Color(0xFF06070B);

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imageBase64 = prefs.getString('profile_image');
    if (imageBase64 == null || imageBase64.isEmpty) return;

    final imageBytes = base64Decode(imageBase64);
    if (!mounted) return;

    setState(() {
      _profileImage = imageBytes;
    });
  }

  Future<void> _pickImage() async {
    HapticFeedback.selectionClick();

    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage == null) return;

    final imageBytes = await pickedImage.readAsBytes();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', base64Encode(imageBytes));

    if (!mounted) return;
    setState(() {
      _profileImage = imageBytes;
    });
  }

  Future<_ProfileData> _loadProfile() async {
    final user = await getIt<AuthLocalDataSource>().currentUser();

    final destinations =
        Hive.box<DestinationModel>(AppConstants.destinationsBox)
            .values
            .toList();

    final favoriteCount = destinations.where((item) => item.isFavorite).length;

    final quizScores =
        Hive.box<QuizScoreModel>(AppConstants.quizScoresBox).values.toList();

    final bestQuizScore = quizScores.isEmpty
        ? (user?.quizBestScore ?? 0)
        : quizScores.map((item) => item.score).reduce((a, b) => a > b ? a : b);

    return _ProfileData(
      user: user,
      favoriteCount: favoriteCount,
      destinationCount: destinations.length,
      bestQuizScore: bestQuizScore,
      biometricEnabled: await getIt<AuthLocalDataSource>().isBiometricEnabled(),
    );
  }

  Future<void> _toggleBiometric(bool enabled) async {
    HapticFeedback.selectionClick();

    await getIt<AuthLocalDataSource>().setBiometricEnabled(!enabled);
    if (!mounted) return;

    setState(() {
      _profileFuture = _loadProfile();
    });

    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(!enabled ? 'Biometrik aktif' : 'Biometrik nonaktif'),
        message: Text(
          !enabled
              ? 'Login biometrik sudah diizinkan untuk akun terakhir.'
              : 'Login biometrik dimatikan untuk perangkat ini.',
        ),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    HapticFeedback.selectionClick();

    final shouldLogout = await showCupertinoModalPopup<bool>(
          context: context,
          builder: (context) => CupertinoActionSheet(
            title: const Text('Keluar dari JogjaSplorasi?'),
            message: const Text(
              'Session lokal akan dihapus dari perangkat ini. Kamu bisa login lagi kapan saja.',
            ),
            actions: [
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Logout'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
          ),
        ) ??
        false;

    if (!shouldLogout) return;

    await getIt<AuthLocalDataSource>().logout();

    if (!context.mounted) return;
    context.go(RouteNames.auth);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bgBottom,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.18,
            colors: [
              Color(0xFF282836),
              _bgTop,
              _bgMid,
              _bgBottom,
            ],
            stops: [0, 0.32, 0.68, 1],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<_ProfileData>(
            future: _profileFuture,
            builder: (context, snapshot) {
              final baseData = snapshot.data ?? _ProfileData.empty();

              return ValueListenableBuilder<Box<DestinationModel>>(
                valueListenable:
                    Hive.box<DestinationModel>(AppConstants.destinationsBox)
                        .listenable(),
                builder: (context, destinationsBox, _) {
                  final destinations = destinationsBox.values.toList();
                  final favoriteCount =
                      destinations.where((item) => item.isFavorite).length;

                  final data = _ProfileData(
                    user: baseData.user,
                    favoriteCount: favoriteCount,
                    destinationCount: destinations.length,
                    bestQuizScore: baseData.bestQuizScore,
                    biometricEnabled: baseData.biometricEnabled,
                  );

                  final user = data.user;
                  final name = user?.name ?? 'Penjelajah Jogja';
                  final email = user?.email ?? 'Local session active';

                  return ListView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 126),
                    children: [
                      _ProfileHeader(
                        onRefresh: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _profileFuture = _loadProfile();
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      _ProfileHero(
                        name: name,
                        email: email,
                        imageBytes: _profileImage,
                        onChangePhoto: _pickImage,
                      ),
                      const SizedBox(height: 14),
                      _ProfileStatsRow(
                        bestQuizScore: data.bestQuizScore,
                        favoriteCount: data.favoriteCount,
                        destinationCount: data.destinationCount,
                      ),
                      const SizedBox(height: 18),
                      _ProfileSection(
                        title: 'Identitas',
                        children: [
                          _ProfileMenuRow(
                            title: 'Edit Profil',
                            subtitle: 'Ubah nama tampilan dan foto profil',
                            icon: CupertinoIcons.pencil_circle_fill,
                            iconColor: AppColors.accentPrimary,
                            onTap: () async {
                              await context.push(RouteNames.editProfile);
                              if (!mounted) return;
                              await _loadProfileImage();
                              setState(() {
                                _profileFuture = _loadProfile();
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _ProfileSection(
                        title: 'Ruang Jelajah',
                        children: [
                          _ProfileMenuRow(
                            title: 'Favorit',
                            subtitle:
                                '${data.favoriteCount} destinasi tersimpan',
                            icon: CupertinoIcons.heart_fill,
                            iconColor: AppColors.accentPrimary,
                            onTap: () => context.push(RouteNames.favorites),
                          ),
                          _ProfileMenuRow(
                            title: 'Jelajahi Jogja',
                            subtitle: 'Cari dan filter destinasi wisata',
                            icon: CupertinoIcons.map_fill,
                            iconColor: AppColors.accentTertiary,
                            onTap: () => context.go(RouteNames.explore),
                          ),
                          _ProfileMenuRow(
                            title: 'Cari Semua',
                            subtitle: 'Cari destinasi, fitur, tema, dan setting',
                            icon: CupertinoIcons.search,
                            iconColor: AppColors.accentPrimary,
                            onTap: () => context.push(RouteNames.globalSearch),
                          ),
                          _ProfileMenuRow(
                            title: 'Guide AI',
                            subtitle: 'Rekomendasi wisata berbasis LLM',
                            icon: CupertinoIcons.sparkles,
                            iconColor: AppColors.accentSecondary,
                            onTap: () => context.go(RouteNames.guide),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _ProfileSection(
                        title: 'Tools TPM',
                        children: [
                          _ProfileMenuRow(
                            title: 'Sensor Hub',
                            subtitle: 'Accelerometer dan gyroscope',
                            icon: CupertinoIcons.waveform_path_ecg,
                            iconColor: AppColors.accentPrimary,
                            onTap: () => context.push(RouteNames.sensor),
                          ),
                          _ProfileMenuRow(
                            title: 'Converter',
                            subtitle: 'Konversi mata uang dan waktu',
                            icon: CupertinoIcons.arrow_2_circlepath,
                            iconColor: AppColors.accentTertiary,
                            onTap: () => context.push(RouteNames.converter),
                          ),
                          _ProfileMenuRow(
                            title: 'Mini Game',
                            subtitle: 'Kuis budaya Jogja',
                            icon: CupertinoIcons.gamecontroller_fill,
                            iconColor: AppColors.accentSecondary,
                            onTap: () => context.push(RouteNames.game),
                          ),
                          _ProfileMenuRow(
                            title: 'Saran & Kesan TPM',
                            subtitle: 'Kesan dan saran mata kuliah TPM',
                            icon: CupertinoIcons.doc_text_fill,
                            iconColor: AppColors.accentTertiary,
                            onTap: () => context.push(RouteNames.feedback),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _ProfileSection(
                        title: 'Keamanan',
                        children: [
                          const _ProfileMenuRow(
                            title: 'Session Lokal Aman',
                            subtitle: 'SecureStorage + Hive terenkripsi',
                            icon: CupertinoIcons.lock_shield_fill,
                            iconColor: AppColors.accentTertiary,
                            trailing: _StatusPill(label: 'Aktif'),
                          ),

                          _ProfileMenuRow(
                            title: 'Tema Light/Dark',
                            subtitle: 'Tap untuk mengganti tema aplikasi',
                            icon: CupertinoIcons.paintbrush_fill,
                            iconColor: AppColors.accentPrimary,
                            trailing: const _StatusPill(label: 'Toggle'),
                            onTap: () async {
                              final container = ProviderScope.containerOf(context);
                              await container.read(themeControllerProvider.notifier).toggleLightDark();
                            },
                          ),
                          _ProfileMenuRow(
                            title: 'Login Biometrik',
                            subtitle: data.biometricEnabled
                                ? 'Aktif untuk akun terakhir'
                                : 'Tap untuk mengaktifkan opt-in',
                            icon: CupertinoIcons
                                .person_crop_circle_badge_checkmark,
                            iconColor: AppColors.accentTertiary,
                            trailing: _StatusPill(
                              label: data.biometricEnabled ? 'Enabled' : 'Off',
                            ),
                            onTap: () =>
                                _toggleBiometric(data.biometricEnabled),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _ProfileSection(
                        title: 'Akun',
                        children: [
                          _ProfileMenuRow(
                            title: 'Keluar Akun',
                            subtitle: 'Hapus session lokal dari perangkat',
                            icon: CupertinoIcons.square_arrow_right,
                            iconColor: CupertinoColors.systemRed,
                            destructive: true,
                            onTap: () => _confirmLogout(context),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Profil',
            style: AppTypography.displayBold34.copyWith(
              color: AppColors.textPrimary,
              fontSize: 32,
              letterSpacing: -1.05,
            ),
          ),
        ),
        _CircleButton(
          icon: CupertinoIcons.arrow_clockwise,
          onTap: onRefresh,
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.name,
    required this.email,
    required this.imageBytes,
    required this.onChangePhoto,
  });

  final String name;
  final String email;
  final Uint8List? imageBytes;
  final VoidCallback onChangePhoto;

  static const _avatarUrl =
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=240&q=80';

  @override
  Widget build(BuildContext context) {
    final cleanName = name.trim().isEmpty ? 'Penjelajah Jogja' : name.trim();
    final initial = cleanName[0].toUpperCase();

    return GlassCard(
      blur: 34,
      opacity: 0.075,
      borderRadius: 30,
      borderColor: CupertinoColors.white.withOpacity(0.12),
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.15,
                  colors: [
                    AppColors.accentSecondary.withOpacity(0.14),
                    CupertinoColors.white.withOpacity(0.038),
                    CupertinoColors.black.withOpacity(0.02),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onChangePhoto,
                  child: Container(
                    width: 68,
                    height: 68,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment.topLeft,
                        radius: 1,
                        colors: [
                          AppColors.accentPrimary.withOpacity(0.34),
                          AppColors.accentSecondary.withOpacity(0.22),
                          CupertinoColors.white.withOpacity(0.055),
                        ],
                      ),
                      border: Border.all(
                        color: CupertinoColors.white.withOpacity(0.14),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 28,
                          spreadRadius: -12,
                          color: AppColors.accentPrimary.withOpacity(0.28),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageBytes != null
                        ? Image.memory(
                            imageBytes!,
                            fit: BoxFit.cover,
                            width: 68,
                            height: 68,
                          )
                        : CachedNetworkImage(
                            imageUrl: _avatarUrl,
                            fit: BoxFit.cover,
                            width: 68,
                            height: 68,
                            errorWidget: (context, url, error) => Center(
                              child: Text(
                                initial,
                                style: AppTypography.displayBold34.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 29,
                                  letterSpacing: -0.8,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cleanName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.displaySemi22.copyWith(
                          color: AppColors.textPrimary,
                          letterSpacing: -0.55,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        email.trim().isEmpty ? 'Local session active' : email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textRegular13.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 9),
                      const _InlineBadge(label: 'Hive + SecureStorage'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatsRow extends StatelessWidget {
  const _ProfileStatsRow({
    required this.bestQuizScore,
    required this.favoriteCount,
    required this.destinationCount,
  });

  final int bestQuizScore;
  final int favoriteCount;
  final int destinationCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: CupertinoIcons.star_fill,
            label: 'Quiz',
            value: '$bestQuizScore',
            color: AppColors.accentTertiary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: CupertinoIcons.heart_fill,
            label: 'Tersimpan',
            value: '$favoriteCount',
            color: AppColors.accentPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: CupertinoIcons.map_pin_ellipse,
            label: 'Places',
            value: '$destinationCount',
            color: AppColors.accentSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 30,
      opacity: 0.072,
      borderRadius: 22,
      borderColor: CupertinoColors.white.withOpacity(0.11),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.displaySemi22.copyWith(
              color: AppColors.textPrimary,
              fontSize: 22,
              letterSpacing: -0.55,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.captionSmall11.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.displaySemi20.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.45,
          ),
        ),
        const SizedBox(height: 11),
        ...children.expand((child) => [child, const SizedBox(height: 9)]),
      ],
    );
  }
}

class _ProfileMenuRow extends StatefulWidget {
  const _ProfileMenuRow({
    required this.title,
    required this.icon,
    required this.iconColor,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  State<_ProfileMenuRow> createState() => _ProfileMenuRowState();
}

class _ProfileMenuRowState extends State<_ProfileMenuRow> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final titleColor =
        widget.destructive ? CupertinoColors.systemRed : AppColors.textPrimary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: GlassCard(
          blur: 28,
          opacity: 0.068,
          borderRadius: 22,
          borderColor: CupertinoColors.white.withOpacity(0.10),
          padding: const EdgeInsets.fromLTRB(13, 12, 12, 12),
          child: Row(
            children: [
              _MenuIcon(
                icon: widget.icon,
                color: widget.iconColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textMedium15.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.15,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.captionSmall11.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              widget.trailing ??
                  Icon(
                    widget.destructive
                        ? CupertinoIcons.square_arrow_right
                        : CupertinoIcons.chevron_right,
                    size: 17,
                    color: widget.destructive
                        ? CupertinoColors.systemRed
                        : AppColors.textSecondary,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  const _MenuIcon({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.14),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 17,
          color: color,
        ),
      ),
    );
  }
}

class _CircleButton extends StatefulWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<_CircleButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: GlassCard(
          width: 42,
          height: 42,
          blur: 28,
          opacity: 0.075,
          borderRadius: 999,
          borderColor: CupertinoColors.white.withOpacity(0.11),
          padding: EdgeInsets.zero,
          child: Center(
            child: Icon(
              widget.icon,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineBadge extends StatelessWidget {
  const _InlineBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 20,
      opacity: 0.07,
      borderRadius: 999,
      borderColor: CupertinoColors.white.withOpacity(0.09),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      child: Text(
        label,
        style: AppTypography.captionSmall11.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 20,
      opacity: 0.07,
      borderRadius: 999,
      borderColor: CupertinoColors.white.withOpacity(0.09),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      child: Text(
        label,
        style: AppTypography.captionSmall11.copyWith(
          color: AppColors.accentTertiary,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _ProfileData {
  const _ProfileData({
    required this.user,
    required this.favoriteCount,
    required this.destinationCount,
    required this.bestQuizScore,
    required this.biometricEnabled,
  });

  final UserModel? user;
  final int favoriteCount;
  final int destinationCount;
  final int bestQuizScore;
  final bool biometricEnabled;

  factory _ProfileData.empty() {
    return const _ProfileData(
      user: null,
      favoriteCount: 0,
      destinationCount: 0,
      bestQuizScore: 0,
      biometricEnabled: false,
    );
  }
}
