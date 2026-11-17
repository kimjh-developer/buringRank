import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:burning_rank_app/core/theme/app_colors.dart';
import 'package:burning_rank_app/core/theme/app_text_styles.dart';
import 'package:burning_rank_app/features/burning/presentation/pages/active_workout_page.dart';
import 'package:burning_rank_app/features/burning/presentation/widgets/workout_grid_cell.dart';
import 'package:burning_rank_app/features/burning/domain/entities/workout_type.dart';
import 'package:burning_rank_app/features/burning/presentation/pages/weight_workout_page.dart';
import 'package:burning_rank_app/features/burning/presentation/pages/breathing_workout_page.dart';

class BurningPage extends StatefulWidget {
  const BurningPage({super.key});

  @override
  State<BurningPage> createState() => _BurningPageState();
}

class _BurningPageState extends State<BurningPage> {
  // [Antigravity] Added state to track selected workout type
  WorkoutType? _selectedWorkout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, AppColors.surface],
          ),
        ),
        child: SafeArea(
          // [Antigravity] Changed layout to Stack to fix the action button at the bottom overlaying the content
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    FadeInDown(
                      child: Text(
                        '오늘의 운동을\n선택해주세요',
                        style: AppTextStyles.h1.copyWith(height: 1.2),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: GridView.count(
                          shrinkWrap: true, // 내용만큼 높이
                          // physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.8,
                          children: WorkoutType.all.map((workout) {
                            return WorkoutGridCell(
                              workout: workout,
                              isSelected:
                                  _selectedWorkout?.type == workout.type,
                              onTap: () {
                                setState(() {
                                  _selectedWorkout = workout;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    // [Antigravity] Space footer to ensure scrolling content isn't obscured by fixed button
                    const SizedBox(height: 100),
                    // const Spacer(flex: 3),
                  ],
                ),
              ),

              // [Antigravity] Fixed action button positioned 5pt above the floating navigation bar
              Positioned(
                left: 24,
                right: 24,
                bottom: 30.0, // Calculated height above the nav bar
                child: FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: GestureDetector(
                    onTap: _selectedWorkout == null
                        ? null
                        : () {
                            // [Antigravity] Route to dedicated weightlifting page or general active workout page
                            if (_selectedWorkout!.type ==
                                WorkoutActivityType.strength) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WeightWorkoutPage(),
                                ),
                              );
                            } else if (_selectedWorkout!.type ==
                                WorkoutActivityType.mind) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BreathingWorkoutPage(
                                    workout: _selectedWorkout!,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ActiveWorkoutPage(
                                    workout: _selectedWorkout!,
                                  ),
                                ),
                              );
                            }
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: _selectedWorkout == null
                            ? LinearGradient(
                                colors: [
                                  Colors.grey.withValues(alpha: 0.3),
                                  Colors.grey.withValues(alpha: 0.2),
                                ],
                              )
                            : AppColors.burningGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _selectedWorkout == null
                            ? []
                            : [
                                BoxShadow(
                                  color: AppColors.primaryRed.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: Center(
                        child: Text(
                          '운동 시작하기!',
                          style: AppTextStyles.button.copyWith(
                            color: _selectedWorkout == null
                                ? Colors.white.withValues(alpha: 0.5)
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
