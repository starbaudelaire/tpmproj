import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/segmented_control.dart';
import 'auth_controller.dart';
import 'login_view.dart';
import 'register_view.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.user != null) {
        context.go(RouteNames.home);
      }
    });

    final state = ref.watch(authControllerProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundPrimary,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spaceMD),
          child: Center(
            child: GlassCard(
              width: 420,
              padding: const EdgeInsets.all(AppSpacing.spaceLG),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Jogjasplorasi', style: AppTypography.displayBold34),
                  const SizedBox(height: 8),
                  Text(
                    'Liquid Glass travel companion untuk menjelajahi Yogyakarta.',
                    textAlign: TextAlign.center,
                    style: AppTypography.textRegular13,
                  ),
                  const SizedBox(height: 20),
                  AppSegmentedControl<bool>(
                    groupValue: _isLogin,
                    children: const {
                      true: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Text('Login'),
                      ),
                      false: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Text('Register'),
                      ),
                    },
                    onValueChanged: (value) => setState(() => _isLogin = value),
                  ),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _isLogin
                        ? LoginView(
                            key: const ValueKey('login'),
                            emailController: _emailController,
                            passwordController: _passwordController,
                          )
                        : RegisterView(
                            key: const ValueKey('register'),
                            nameController: _nameController,
                            emailController: _emailController,
                            passwordController: _passwordController,
                          ),
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.error!.replaceFirst('Exception: ', ''),
                      style: AppTypography.textRegular13.copyWith(
                        color: AppColors.destructive,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  GlassButton(
                    label: state.isLoading
                        ? 'Memproses...'
                        : _isLogin
                            ? 'Masuk'
                            : 'Buat Akun',
                    filled: true,
                    onPressed: state.isLoading
                        ? null
                        : () {
                            if (_isLogin) {
                              ref.read(authControllerProvider.notifier).login(
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                            } else {
                              ref
                                  .read(authControllerProvider.notifier)
                                  .register(
                                    _nameController.text,
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                            }
                          },
                  ),
                  if (!kIsWeb) ...[
                    const SizedBox(height: 12),
                    GlassButton(
                      label: 'Masuk dengan Biometrik',
                      icon: CupertinoIcons.person_crop_circle_badge_checkmark,
                      onPressed: () async {
                        final success = await ref
                            .read(authControllerProvider.notifier)
                            .biometricLogin();
                        if (success && context.mounted) {
                          context.go(RouteNames.home);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
