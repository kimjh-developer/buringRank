import 'package:health/health.dart';
import 'package:burning_rank_app/features/burning/domain/entities/workout_type.dart';

class HealthService {
  final Health health = Health();

  static const types = [
    HealthDataType.HEART_RATE,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.WORKOUT,
  ];

  Future<bool> requestAuthorization() async {
    final permissions = types.map((e) => HealthDataAccess.READ_WRITE).toList();
    // Directly request authorization to ensure the system dialog is triggered if needed
    return await health.requestAuthorization(types, permissions: permissions);
  }

  Future<List<HealthDataPoint>> fetchData(DateTime start, DateTime end) async {
    return await health.getHealthDataFromTypes(
      types: types,
      startTime: start,
      endTime: end,
    );
  }

  Future<bool> saveWorkout({
    required HealthWorkoutActivityType activityType,
    required DateTime start,
    required DateTime end,
    required double calories,
    double distance = 0,
  }) async {
    try {
      // 1. Write the workout summary
      final success = await health.writeWorkoutData(
        activityType: activityType,
        start: start,
        end: end,
        totalEnergyBurned: calories.toInt(),
        totalDistance: distance.toInt(),
      );

      // 2. Also write specific data points for Active Energy Burned
      // This helps many health apps aggregate calories correctly
      if (success && calories > 0) {
        await health.writeHealthData(
          value: calories,
          type: HealthDataType.ACTIVE_ENERGY_BURNED,
          startTime: start,
          endTime: end,
        );
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // Fetch aggregated statistics
  Future<Map<String, dynamic>> summarizeStats() async {
    try {
      final now = DateTime.now();
      // Fetch data for a reasonably long period (e.g., last year) to get totals
      // In a real app, you might want a more sophisticated approach for "Total"
      final start = now.subtract(const Duration(days: 365));
      final data = await fetchData(start, now);

      double totalCalories = 0;
      Set<String> uniqueDays = {};

      for (var point in data) {
        if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
          totalCalories += (point.value as NumericHealthValue).numericValue
              .toDouble();
        }
        if (point.type == HealthDataType.WORKOUT) {
          final workoutValue = point.value as WorkoutHealthValue;
          totalCalories += (workoutValue.totalEnergyBurned ?? 0).toDouble();
          uniqueDays.add(point.dateFrom.toIso8601String().substring(0, 10));
        }
      }

      return {'totalCalories': totalCalories, 'workoutDays': uniqueDays.length};
    } catch (e) {
      return {'totalCalories': 0.0, 'workoutDays': 0};
    }
  }

  // Fetch detailed workout history
  Future<List<Map<String, dynamic>>> getWorkoutHistory() async {
    try {
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 30)); // Last 30 days
      final data = await fetchData(start, now);

      // We need to correlate workout data points
      // Health pkg simplifies this with HealthDataType.WORKOUT
      final workouts = data
          .where((p) => p.type == HealthDataType.WORKOUT)
          .toList();

      return workouts.map((w) {
        final workoutValue = w.value as WorkoutHealthValue;
        // Map health workout to a map compatible with WorkoutRecord
        return {
          'id': w.uuid,
          'type': _reverseMapActivityType(workoutValue.workoutActivityType),
          'exerciseName': workoutValue.workoutActivityType.name,
          'date': w.dateFrom.toIso8601String(),
          'durationSeconds': w.dateTo.difference(w.dateFrom).inSeconds,
          'calories': (workoutValue.totalEnergyBurned ?? 0).toDouble(),
          'distanceKm': workoutValue.totalDistance != null
              ? (workoutValue.totalDistance! /
                    1000.0) // Convert to km if stored as meters
              : null,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  int _reverseMapActivityType(HealthWorkoutActivityType? type) {
    if (type == HealthWorkoutActivityType.RUNNING) {
      return WorkoutActivityType.cardio.index;
    }
    if (type == HealthWorkoutActivityType.HIKING) {
      return WorkoutActivityType.hike.index;
    }
    // Note: Use standard available types from health package
    return WorkoutActivityType.strength.index;
  }

  HealthWorkoutActivityType mapActivityType(WorkoutActivityType type) {
    switch (type) {
      case WorkoutActivityType.strength:
        return HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING;
      case WorkoutActivityType.cardio:
        return HealthWorkoutActivityType.RUNNING;
      case WorkoutActivityType.hike:
        return HealthWorkoutActivityType.HIKING;
      case WorkoutActivityType.mind:
        // Attempt to find best match for mind/breathing
        return HealthWorkoutActivityType.YOGA;
    }
  }
}
