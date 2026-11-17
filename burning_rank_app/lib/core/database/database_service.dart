import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'burning_rank.db');

    return await openDatabase(
      path,
      version: 3, // Bump to 3 to trigger schema reset for sessions
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Profile table (Single row for current user/personal info)
    await db.execute('''
      CREATE TABLE profile(
        id TEXT PRIMARY KEY,
        userFullName TEXT,
        userEmail TEXT,
        userAge INTEGER,
        maxHeartRate REAL,
        userState TEXT,
        userNickname TEXT,
        profileImagePath TEXT,
        alarmEnabled INTEGER DEFAULT 1
      )
    ''');

    // Workout records table
    await db.execute('''
      CREATE TABLE workout_records(
        id TEXT PRIMARY KEY,
        type INTEGER NOT NULL,
        date TEXT NOT NULL,
        items TEXT NOT NULL,
        totalDurationSeconds INTEGER NOT NULL,
        totalCalories REAL NOT NULL,
        totalDistanceKm REAL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Force recreation of workout_records for the new session-based schema
      await db.execute('DROP TABLE IF EXISTS workout_records');
      
      // Also ensure profile exists or is correct if needed, but primarily we target workout_records here
      await db.execute('''
        CREATE TABLE IF NOT EXISTS workout_records(
          id TEXT PRIMARY KEY,
          type INTEGER NOT NULL,
          date TEXT NOT NULL,
          items TEXT NOT NULL,
          totalDurationSeconds INTEGER NOT NULL,
          totalCalories REAL NOT NULL,
          totalDistanceKm REAL
        )
      ''');
    }
  }
}
