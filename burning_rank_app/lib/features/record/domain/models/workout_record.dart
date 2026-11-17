import 'dart:convert';
import 'package:burning_rank_app/features/burning/domain/entities/workout_type.dart';

class WorkoutItem {
  final WorkoutActivityType type;
  final String exerciseName;
  final int durationSeconds;
  final double calories;
  final double? distanceKm;
  final int? reps;
  final int? sets;

  WorkoutItem({
    required this.type,
    required this.exerciseName,
    required this.durationSeconds,
    required this.calories,
    this.distanceKm,
    this.reps,
    this.sets,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'exerciseName': exerciseName,
      'durationSeconds': durationSeconds,
      'calories': calories,
      'distanceKm': distanceKm,
      'reps': reps,
      'sets': sets,
    };
  }

  factory WorkoutItem.fromJson(Map<String, dynamic> json) {
    return WorkoutItem(
      type: WorkoutActivityType.values[json['type']],
      exerciseName: json['exerciseName'],
      durationSeconds: json['durationSeconds'],
      calories: (json['calories'] as num).toDouble(),
      distanceKm: json['distanceKm'] != null ? (json['distanceKm'] as num).toDouble() : null,
      reps: json['reps'],
      sets: json['sets'],
    );
  }
}

class WorkoutRecord {
  final String id;
  final WorkoutActivityType type; // Generally derived or main type
  final DateTime date;
  final List<WorkoutItem> items;
  final int totalDurationSeconds;
  final double totalCalories;
  final double? totalDistanceKm;

  WorkoutRecord({
    required this.id,
    required this.type,
    required this.date,
    required this.items,
    required this.totalDurationSeconds,
    required this.totalCalories,
    this.totalDistanceKm,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'date': date.toIso8601String(),
      'items': jsonEncode(items.map((e) => e.toJson()).toList()),
      'totalDurationSeconds': totalDurationSeconds,
      'totalCalories': totalCalories,
      'totalDistanceKm': totalDistanceKm,
    };
  }

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = jsonDecode(json['items'] as String);
    return WorkoutRecord(
      id: json['id'],
      type: WorkoutActivityType.values[json['type']],
      date: DateTime.parse(json['date']),
      items: itemsJson.map((e) => WorkoutItem.fromJson(e as Map<String, dynamic>)).toList(),
      totalDurationSeconds: json['totalDurationSeconds'],
      totalCalories: (json['totalCalories'] as num).toDouble(),
      totalDistanceKm: json['totalDistanceKm'] != null ? (json['totalDistanceKm'] as num).toDouble() : null,
    );
  }
}
