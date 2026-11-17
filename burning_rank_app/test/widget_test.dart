// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:burning_rank_app/features/auth/domain/entities/user_model.dart';
import 'package:burning_rank_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:burning_rank_app/main.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<UserModel?> get currentUser => Future.value(null);
  @override
  Stream<UserModel?> get user => Stream.value(null);
  @override
  Future<UserModel?> signInWithApple() => Future.value(null);
  @override
  Future<void> signOut() => Future.value(null);
  @override
  Future<void> saveUser(UserModel user) => Future.value(null);
  @override
  Future<UserModel?> checkAuthStatus() => Future.value(null);
}

void main() {
  testWidgets('Splash page smoke test', (WidgetTester tester) async {
    final mockRepository = MockAuthRepository();
    await tester.pumpWidget(MyApp(authRepository: mockRepository));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
