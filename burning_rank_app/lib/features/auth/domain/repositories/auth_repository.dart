import 'package:burning_rank_app/features/auth/domain/entities/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> get currentUser;
  Stream<UserModel?> get user;
  Future<UserModel?> signInWithApple();
  Future<void> signOut();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> checkAuthStatus();
}
