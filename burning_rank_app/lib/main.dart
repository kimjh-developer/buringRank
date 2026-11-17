import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:burning_rank_app/core/theme/app_theme.dart';
import 'package:burning_rank_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:burning_rank_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:burning_rank_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:burning_rank_app/features/auth/presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for Desktop (macOS/Windows/Linux)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await initializeDateFormatting('ko_KR', null);
  final prefs = await SharedPreferences.getInstance();
  final authRepository = AuthRepositoryImpl(prefs);

  runApp(MyApp(authRepository: authRepository));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;

  const MyApp({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authRepository,
      child: BlocProvider(
        create: (_) =>
            AuthBloc(authRepository: authRepository)..add(AuthAppStarted()),
        child: MaterialApp(
          title: 'Burning Rank',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const SplashPage(),
        ),
      ),
    );
  }
}
