import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/encryption_util.dart';
import '../../../shared/models/user.dart';

class AuthLocalDataSource {
  AuthLocalDataSource({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs;

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  Future<UserModel> register(String name, String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final existingHash = await _secureStorage.read(
      key: 'password_$normalizedEmail',
    );
    if (existingHash != null) {
      throw Exception('Akun sudah terdaftar.');
    }

    final hashedPassword = EncryptionUtil.hashPassword(password);
    await _secureStorage.write(
      key: 'password_$normalizedEmail',
      value: hashedPassword,
    );

    final user = UserModel(
      id: const Uuid().v4(),
      name: name,
      email: normalizedEmail,
      joinedAt: DateTime.now(),
    );
    await Hive.box<UserModel>(AppConstants.usersBox).put(normalizedEmail, user);
    await _persistSession(normalizedEmail);
    return user;
  }

  Future<UserModel> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final storedHash = await _secureStorage.read(
      key: 'password_$normalizedEmail',
    );
    if (storedHash == null ||
        storedHash != EncryptionUtil.hashPassword(password)) {
      throw Exception('Email atau password tidak sesuai.');
    }

    final user = Hive.box<UserModel>(
      AppConstants.usersBox,
    ).get(normalizedEmail);
    if (user == null) throw Exception('Profil pengguna tidak ditemukan.');

    await _persistSession(normalizedEmail);
    return user;
  }

  Future<bool> checkSession() async {
    final token = await _secureStorage.read(key: AppConstants.sessionKey);
    final expiryRaw = await _secureStorage.read(
      key: AppConstants.sessionExpiryKey,
    );
    if (token == null || expiryRaw == null) return false;

    final expiry = DateTime.tryParse(expiryRaw);
    if (expiry == null || expiry.isBefore(DateTime.now())) {
      await logout();
      return false;
    }
    return true;
  }

  Future<UserModel?> currentUser() async {
    final email = _prefs.getString(AppConstants.currentUserKey);
    if (email == null) return null;
    return Hive.box<UserModel>(AppConstants.usersBox).get(email);
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.sessionKey);
    await _secureStorage.delete(key: AppConstants.sessionExpiryKey);
    await _prefs.remove(AppConstants.currentUserKey);
  }

  Future<void> _persistSession(String email) async {
    final expiry = DateTime.now().add(const Duration(days: 7));
    final token = const Uuid().v4();
    await _secureStorage.write(
      key: AppConstants.sessionKey,
      value: EncryptionUtil.encryptText(token),
    );
    await _secureStorage.write(
      key: AppConstants.sessionExpiryKey,
      value: expiry.toIso8601String(),
    );
    await _prefs.setString(AppConstants.currentUserKey, email);
  }
}
