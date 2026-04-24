import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/di/injection.dart';
import '../../../shared/models/user.dart';
import '../data/auth_local_datasource.dart';
import '../domain/usecases/biometric_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/register_usecase.dart';

class AuthState {
  const AuthState({this.isLoading = false, this.user, this.error});

  final bool isLoading;
  final UserModel? user;
  final String? error;

  AuthState copyWith({bool? isLoading, UserModel? user, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController()
      : _loginUseCase = LoginUseCase(getIt()),
        _registerUseCase = RegisterUseCase(getIt()),
        _logoutUseCase = LogoutUseCase(getIt()),
        _biometricUseCase = BiometricUseCase(getIt<LocalAuthentication>()),
        _localDataSource = getIt<AuthLocalDataSource>(),
        super(const AuthState());

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final BiometricUseCase _biometricUseCase;
  final AuthLocalDataSource _localDataSource;

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _loginUseCase(email, password);
      state = state.copyWith(isLoading: false, user: user);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _registerUseCase(name, email, password);
      state = state.copyWith(isLoading: false, user: user);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<bool> biometricLogin() async {
    final authorized = await _biometricUseCase();
    if (!authorized) return false;
    final user = await _localDataSource.currentUser();
    if (user == null) return false;
    state = state.copyWith(user: user, error: null);
    return true;
  }

  Future<void> logout() => _logoutUseCase();
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);

final sessionProvider = FutureProvider<bool>(
  (ref) => getIt<AuthLocalDataSource>().checkSession(),
);
