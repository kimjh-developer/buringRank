import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:burning_rank_app/core/theme/app_text_styles.dart';
import 'package:burning_rank_app/shared/widgets/glass_container.dart';
import 'package:burning_rank_app/features/burning/domain/entities/workout_type.dart';

class WorkoutGridCell extends StatelessWidget {
  final WorkoutType workout;
  final bool isSelected;
  final VoidCallback onTap;

  const WorkoutGridCell({
    super.key,
    required this.workout,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    workout.accentColor,
                    workout.accentColor.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: workout.accentColor.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: GlassContainer(
          borderRadius: 24,
          color: isSelected ? Colors.transparent : null,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                workout.iconPath,
                width: 48,
                height: 48,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                workout.name,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
