import 'package:flutter/material.dart';

enum WorkoutActivityType { strength, cardio, hike, mind }

class WorkoutType {
  final WorkoutActivityType type;
  final String name;
  final String iconPath;
  final Color accentColor;

  const WorkoutType({
    required this.type,
    required this.name,
    required this.iconPath,
    required this.accentColor,
  });

  static List<WorkoutType> get all => [
    const WorkoutType(
      type: WorkoutActivityType.strength,
      name: '쇠질',
      iconPath: 'assets/images/workout_strength.svg',
      accentColor: Color(0xFFFF512F),
    ),
    const WorkoutType(
      type: WorkoutActivityType.cardio,
      name: '유산소',
      iconPath: 'assets/images/workout_cardio.svg',
      accentColor: Color(0xFFDD2476),
    ),
    const WorkoutType(
      type: WorkoutActivityType.hike,
      name: '등산',
      iconPath: 'assets/images/workout_hike.svg',
      accentColor: Color(0xFF8E2DE2),
    ),
    const WorkoutType(
      type: WorkoutActivityType.mind,
      name: '휴식',
      iconPath: 'assets/images/workout_mind.svg',
      accentColor: Color(0xFF4A00E0),
    ),
  ];
}
