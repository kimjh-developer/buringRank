import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:burning_rank_app/core/theme/app_colors.dart';
import 'package:burning_rank_app/core/theme/app_text_styles.dart';
import 'package:burning_rank_app/shared/widgets/glass_container.dart';
import 'package:burning_rank_app/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:burning_rank_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:burning_rank_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:burning_rank_app/features/record/data/repositories/workout_repository.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(
        authRepository: context.read<AuthRepository>(),
        workoutRepository: WorkoutRepository(),
      )..loadProfile(),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryRed),
              );
            }

            if (state is ProfileLoaded) {
              final user = state.user;
              final totalCalories = state.totalCalories;
              final workoutDays = state.workoutDays;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Profile Header
                    FadeInDown(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: AppColors.burningGradient,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white24,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.accentPurple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            user?.userNickname ??
                                user?.userFullName ??
                                '버닝 히어로',
                            style: AppTextStyles.h2,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'lv.12 버닝 마스터',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Stats Row
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Row(
                        children: [
                          _buildStatCard(
                            '총 운동 일수',
                            '$workoutDays일',
                            Icons.local_fire_department_rounded,
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            '총 소모 칼로리',
                            '${(totalCalories / 1000).toStringAsFixed(1)}k',
                            Icons.flash_on_rounded,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Settings Sections
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('설정', style: AppTextStyles.h3),
                          const SizedBox(height: 16),
                          _buildSettingItem(
                            '내 정보 수정',
                            Icons.person_outline_rounded,
                          ),
                          _buildSettingItem(
                            '건강 데이터 권한',
                            Icons.favorite_outline_rounded,
                          ),
                          _buildSettingItem(
                            '위치 서비스 설정',
                            Icons.location_on_outlined,
                          ),
                          _buildSettingItem(
                            '알림 설정',
                            Icons.notifications_none_rounded,
                          ),
                          const Divider(height: 32, color: Colors.white10),
                          _buildSettingItem(
                            '로그아웃',
                            Icons.logout_rounded,
                            isDestructive: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              );
            }

            if (state is ProfileError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryOrange),
            const SizedBox(height: 12),
            Text(value, style: AppTextStyles.h2),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    IconData icon, {
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.redAccent : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDestructive ? Colors.redAccent : Colors.white,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
