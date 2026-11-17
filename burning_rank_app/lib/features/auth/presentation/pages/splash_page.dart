import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:burning_rank_app/core/theme/app_colors.dart';
import 'package:burning_rank_app/core/theme/app_text_styles.dart';
import 'package:burning_rank_app/shared/widgets/glass_container.dart';
import 'package:burning_rank_app/features/navigation/presentation/pages/main_navigation_screen.dart';
import 'package:burning_rank_app/features/auth/presentation/bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late String _bgImage;

  @override
  void initState() {
    super.initState();
    // Pick random background
    final randomId = Random().nextInt(4); // 0 to 3
    _bgImage = 'assets/images/sp$randomId.png';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is AuthGuest) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image
            Positioned.fill(child: Image.asset(_bgImage, fit: BoxFit.cover)),

            // Overlay
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),

            // Content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(flex: 2),
                    // Logo
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Image.asset(
                        'assets/images/logoWithTitle.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Spacer(flex: 3),

                    // Buttons
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: GlassContainer(
                        borderRadius: 24,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: SignInWithAppleButton(
                                onPressed: () {
                                  context.read<AuthBloc>().add(
                                    AuthSignInRequested(),
                                  );
                                },
                                style: SignInWithAppleButtonStyle.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                  AuthGuestLoginRequested(),
                                );
                              },
                              child: Text(
                                "로그인없이 버닝랭크이용하기",
                                style: AppTextStyles.bodySmall.copyWith(
                                  decoration: TextDecoration.underline,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Loading Overlay
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthLoading) {
                  return Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryRed,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
