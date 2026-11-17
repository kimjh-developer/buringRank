import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:burning_rank_app/core/database/database_service.dart';
import 'package:burning_rank_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:burning_rank_app/features/auth/domain/entities/user_model.dart';
import 'package:sqflite/sqflite.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SharedPreferences _prefs;
  final DatabaseService _databaseService = DatabaseService();
  final _userController = StreamController<UserModel?>.broadcast();
  static const String _userKey = 'appleUserIdentifier';

  AuthRepositoryImpl(this._prefs);

  @override
  Stream<UserModel?> get user => _userController.stream;

  @override
  Future<UserModel?> get currentUser async {
    return await checkAuthStatus();
  }

  @override
  Future<UserModel?> checkAuthStatus() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('profile', limit: 1);

    if (maps.isNotEmpty) {
      final user = UserModel.fromJson(maps.first);
      if (user.userState == UserState.terminate) return null;
      _userController.add(user);
      return user;
    }

    // Fallback to legacy prefs and migrate to SQL
    final userJson = _prefs.getString(_userKey);
    if (userJson != null) {
      try {
        final user = UserModel.fromJson(jsonDecode(userJson));
        await saveUser(user);
        return user;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<UserModel?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final userIdentifier = credential.userIdentifier;
      final existingUser = await checkAuthStatus();

      if (existingUser != null &&
          existingUser.userIdentifier == userIdentifier) {
        return existingUser;
      }

      final givenName = credential.givenName;
      final familyName = credential.familyName;
      final fullName = (givenName != null && familyName != null)
          ? "$givenName$familyName"
          : (givenName ?? familyName);

      final newUser = UserModel(
        userIdentifier: userIdentifier,
        userFullName: fullName,
        userEmail: credential.email,
        userNickname: _generateRandomID(),
        userState: UserState.normal,
      );

      await saveUser(newUser);
      return newUser;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    _userController.add(null);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final db = await _databaseService.database;
    final userData = user.toJson();
    userData['id'] = user.userIdentifier;

    await db.insert(
      'profile',
      userData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _userController.add(user);
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  String _generateRandomID() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(10, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }
}
