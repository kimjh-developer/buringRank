import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:burning_rank_app/features/record/data/repositories/workout_repository.dart';
import 'package:burning_rank_app/core/theme/app_colors.dart';
import 'package:burning_rank_app/core/theme/app_text_styles.dart';
import 'package:burning_rank_app/features/burning/domain/entities/workout_type.dart';
import 'package:uuid/uuid.dart';
import 'package:burning_rank_app/features/record/domain/models/workout_record.dart';

class WeightWorkoutPage extends StatefulWidget {
  const WeightWorkoutPage({super.key});

  @override
  State<WeightWorkoutPage> createState() => _WeightWorkoutPageState();
}

class _WeightWorkoutPageState extends State<WeightWorkoutPage> {
  // [Antigravity] Exercise configuration for Weightlifting
  final List<Map<String, dynamic>> _muscleGroups = [
    {
      'name': '가슴',
      'exercises': ['벤치프레스', '푸쉬업', '딥스', '플라이 머신'],
    },
    {
      'name': '등',
      'exercises': ['풀업', '바벨 로우', '랫풀다운', '데드리프트'],
    },
    {
      'name': '어깨',
      'exercises': ['숄더프레스', '레터럴 레이즈', '페이스 풀', '프론트 레이즈'],
    },
    {
      'name': '팔',
      'exercises': ['바벨 컬', '덤벨 컬', '트라이셉스 익스텐션', '케이블 푸쉬다운'],
    },
    {
      'name': '복부',
      'exercises': ['크런치', '레그 레이즈', '플랭크', '러시안 트위스트'],
    },
    {
      'name': '하체',
      'exercises': ['스쿼트', '레그 프레스', '런지', '레그 익스텐션'],
    },
    {
      'name': '전신',
      'exercises': ['버피', '케틀벨 스윙', '스내치', '클린앤저크'],
    },
  ];

  // [Antigravity] Workout state management
  String? _selectedMuscleGroup;
  String? _selectedExercise;
  int _counter = 0;
  int _accumulatedReps = 0; // [Antigravity] Total reps from completed sets
  int _setCount = 1;
  int _secondsElapsed = 0; // Current exercise duration
  Timer? _timer;
  bool _isStarted = false;
  final DateTime _sessionDate = DateTime.now(); // Start of the entire session

  // [Antigravity] Accumulate workout items in memory
  final List<WorkoutItem> _sessionItems = [];

  // [Antigravity] Repository for saving records
  final WorkoutRepository _workoutRepository = WorkoutRepository();

  @override
  void initState() {
    super.initState();
    _initPermissions();
  }

  Future<void> _initPermissions() async {
    await _workoutRepository.requestPermissions();
  }

  // [Antigravity] Timer logic to track workout duration
  void _startTimer() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // [Antigravity] Format seconds into HH:mm:ss
  String _formatDuration(int seconds) {
    int hrs = seconds ~/ 3600;
    int mins = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hrs.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // [Antigravity] Add current exercise to session list
  void _addCurrentExerciseToSession() {
    if (_selectedExercise == null || (_counter == 0 && _secondsElapsed == 0)) return;

    final int totalReps = _accumulatedReps + _counter;
    _sessionItems.add(WorkoutItem(
      type: WorkoutActivityType.strength,
      exerciseName: _selectedExercise!,
      durationSeconds: _secondsElapsed,
      calories: _calculateCalories(totalReps, _selectedExercise),
      reps: totalReps,
      sets: _setCount,
    ));

    _accumulatedReps = 0;
  }

  // [Antigravity] Persist the entire workout session
  Future<void> _saveSession() async {
    // Add the final exercise if active
    _addCurrentExerciseToSession();

    if (_sessionItems.isEmpty) return;

    final double totalCalories = _sessionItems.fold(0.0, (sum, item) => sum + item.calories);
    // Note: totalDuration is already tracked incrementally in _totalSessionSeconds when switching exercises 
    // but let's be safe and sum items too.
    final int totalDuration = _sessionItems.fold(0, (sum, item) => sum + item.durationSeconds);

    final record = WorkoutRecord(
      id: Uuid().v4(),
      type: WorkoutActivityType.strength,
      date: _sessionDate,
      items: _sessionItems,
      totalDurationSeconds: totalDuration,
      totalCalories: totalCalories,
    );

    await _workoutRepository.saveRecord(record);

    if (mounted) {
      Fluttertoast.showToast(
        msg: "저장되었습니다",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.primaryRed,
        textColor: Colors.white,
      );
      Navigator.of(context).pop();
    }
  }

  double _calculateCalories(int reps, String? exercise) {
    // Simple estimation: 0.5 kcal per rep
    return reps * 0.5;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _selectedExercise == null
                  ? _buildSelection()
                  : _buildCounter(),
            ),
            if (_selectedExercise != null) _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text('세트 카운터', style: AppTextStyles.h2),
          const Spacer(),
          if (_isStarted)
            Text(
              _formatDuration(_secondsElapsed),
              style: AppTextStyles.bodyLarge.copyWith(fontFamily: 'monospace'),
            ),
        ],
      ),
    );
  }

  // [Antigravity] Building selection screen for muscle group and exercise
  Widget _buildSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedMuscleGroup == null ? '부위 선택' : '운동 선택',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: _selectedMuscleGroup == null
                  ? _muscleGroups.length
                  : _muscleGroups
                        .firstWhere(
                          (g) => g['name'] == _selectedMuscleGroup,
                        )['exercises']
                        .length,
              itemBuilder: (context, index) {
                final itemName = _selectedMuscleGroup == null
                    ? _muscleGroups[index]['name']
                    : _muscleGroups.firstWhere(
                        (g) => g['name'] == _selectedMuscleGroup,
                      )['exercises'][index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_selectedMuscleGroup == null) {
                        _selectedMuscleGroup = itemName;
                      } else {
                        _selectedExercise = itemName;
                        _isStarted = true;
                        _startTimer();
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Center(
                      child: Text(itemName, style: AppTextStyles.bodyLarge),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // [Antigravity] Building counter screen with tap-to-count functionality
  Widget _buildCounter() {
    return GestureDetector(
      onTap: () {
        // [Antigravity] Increment counter on screen tap
        setState(() {
          _counter++;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              child: Text(
                'SET $_setCount',
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.primaryOrange,
                  fontSize: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              child: Text(
                '$_counter',
                style: const TextStyle(
                  fontSize: 180,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              _selectedExercise ?? '',
              style: AppTextStyles.h3.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 40),
            Text(
              '화면을 클릭하면 카운트가 올라갑니다',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }

  // [Antigravity] Building bottom action buttons (Set Complete, Other Workout, Finish)
  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  onTap: () {
                    if (_counter == 0) return;
                    setState(() {
                      _accumulatedReps += _counter;
                      _counter = 0;
                      _setCount++;
                    });
                  },
                  label: '셋트완료',
                  color: AppColors.surface,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildButton(
                  onTap: () {
                    setState(() {
                      _addCurrentExerciseToSession();
                      _stopTimer();
                      _selectedExercise = null;
                      _selectedMuscleGroup = null;
                      _counter = 0;
                      _setCount = 1;
                      _secondsElapsed = 0;
                    });
                  },
                  label: '다른운동',
                  color: AppColors.surface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildButton(
            onTap: () async {
              _stopTimer();
              await _saveSession();
            },
            label: '운동 종료',
            color: AppColors.primaryRed,
            isWide: true,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onTap,
    required String label,
    required Color color,
    bool isWide = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: isWide ? double.infinity : null,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (color != AppColors.surface)
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Center(child: Text(label, style: AppTextStyles.button)),
      ),
    );
  }
}
