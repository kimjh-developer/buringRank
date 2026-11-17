import 'package:burning_rank_app/core/database/database_service.dart';
import 'package:burning_rank_app/core/utils/health_service.dart';
import 'package:burning_rank_app/features/record/domain/models/workout_record.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

class WorkoutRepository {
  final HealthService _healthService = HealthService();
  final DatabaseService _dbService = DatabaseService();

  // [Antigravity] Save a full workout session to Local SQLite and Health Store
  Future<void> saveRecord(WorkoutRecord record) async {
    try {
      // 1. Save to Local SQLite (Primary)
      final db = await _dbService.database;
      final json = record.toJson();
      debugPrint('Saving record to SQL: ${json['id']}');
      await db.insert(
        'workout_records',
        json,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Successfully saved to SQL');

      // 2. Save to Health Store (Secondary Sync - Best effort)
      try {
        final healthType = _healthService.mapActivityType(record.type);
        debugPrint('Syncing to Health: $healthType');
        await _healthService.saveWorkout(
          activityType: healthType,
          start: record.date.subtract(Duration(seconds: record.totalDurationSeconds)),
          end: record.date,
          calories: record.totalCalories,
          distance: record.totalDistanceKm ?? 0,
        );
        debugPrint('Successfully synced to Health');
      } catch (e) {
        debugPrint('Error syncing to Health: $e');
      }
    } catch (e) {
      debugPrint('Error saving record: $e');
      rethrow;
    }
  }

  // [Antigravity] Statistics aggregation (from Local SQLite)
  Future<double> getTotalCalories() async {
    final db = await _dbService.database;
    final result = await db.rawQuery('SELECT SUM(totalCalories) as total FROM workout_records');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getWorkoutDaysCount() async {
    final db = await _dbService.database;
    final result = await db.rawQuery('SELECT COUNT(DISTINCT substr(date, 1, 10)) as count FROM workout_records');
    return (result.first['count'] as int?) ?? 0;
  }

  // [Antigravity] Fetch records from local SQLite (ordered by date)
  Future<List<WorkoutRecord>> getRecords() async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'workout_records',
        orderBy: 'date DESC',
      );
      debugPrint('Fetched ${maps.length} records from SQL');
      return List.generate(maps.length, (i) {
        try {
          return WorkoutRecord.fromJson(maps[i]);
        } catch (e) {
          debugPrint('Error parsing record ${maps[i]['id']}: $e');
          rethrow;
        }
      });
    } catch (e) {
      debugPrint('Error fetching records: $e');
      rethrow;
    }
  }

  Future<bool> requestPermissions() async {
    return await _healthService.requestAuthorization();
  }
}
