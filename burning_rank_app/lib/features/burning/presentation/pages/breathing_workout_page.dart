import 'dart:async';
import 'dart:math' as math;
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:burning_rank_app/core/theme/app_colors.dart';
import 'package:burning_rank_app/features/burning/domain/entities/workout_type.dart';
import 'package:burning_rank_app/features/record/data/repositories/workout_repository.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:burning_rank_app/features/record/domain/models/workout_record.dart';

class BreathingWorkoutPage extends StatefulWidget {
  final WorkoutType workout;
  const BreathingWorkoutPage({super.key, required this.workout});

  @override
  State<BreathingWorkoutPage> createState() => _BreathingWorkoutPageState();
}

class _BreathingWorkoutPageState extends State<BreathingWorkoutPage> {
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  int _secondsElapsed = 0; // Current exercise duration

  double heartRate = 60;
  double calories = 0;
  final bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _initPermissions();
    _startWorkout();
    _playBreathingMusic();
  }

  Future<void> _initPermissions() async {
    await WorkoutRepository().requestPermissions();
  }

  Future<void> _playBreathingMusic() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setSource(AssetSource('audio/breathing_music.mp3'));
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('Error playing breathing music: $e');
    }
  }

  void _startWorkout() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _secondsElapsed++;
          calories += 0.05;
          heartRate = 60 + (timer.tick % 5);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    int hrs = seconds ~/ 3600;
    int mins = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hrs.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _saveWorkout() async {
    final DateTime endTime = DateTime.now();
    final WorkoutRecord record = WorkoutRecord(
      id: Uuid().v4(),
      type: WorkoutActivityType.mind,
      date: endTime,
      items: [
        WorkoutItem(
          type: WorkoutActivityType.mind,
          exerciseName: '휴식',
          durationSeconds: _secondsElapsed,
          calories: calories,
        ),
      ],
      totalDurationSeconds: _secondsElapsed,
      totalCalories: calories,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A10),
      body: Stack(
        children: [
          // Background - Raining Forest
          const Positioned.fill(child: RainingForestBackground()),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header with close button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black26,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Simple Metrics Display (Duration, HeartRate, Finish only)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: FadeInUp(
                    child: Column(
                      children: [
                        // Duration
                        Text(
                          _formatDuration(_secondsElapsed),
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w200,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Duration',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.6),
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Heart Rate
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              color: Colors.redAccent.withValues(alpha: 0.8),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${heartRate.toInt()}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'bpm',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Finish Button
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: GestureDetector(
                      onTap: () async {
                        await _saveWorkout();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryRed.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.stop_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Finish',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Raining Forest Background with rain animation
class RainingForestBackground extends StatefulWidget {
  const RainingForestBackground({super.key});

  @override
  State<RainingForestBackground> createState() =>
      _RainingForestBackgroundState();
}

class _RainingForestBackgroundState extends State<RainingForestBackground>
    with TickerProviderStateMixin {
  late AnimationController _rainController;
  late AnimationController _mistController;
  final List<RainDrop> _rainDrops = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _mistController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Generate rain drops
    for (int i = 0; i < 150; i++) {
      _rainDrops.add(
        RainDrop(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          length: 10 + _random.nextDouble() * 20,
          speed: 0.5 + _random.nextDouble() * 0.5,
          opacity: 0.1 + _random.nextDouble() * 0.3,
        ),
      );
    }
  }

  @override
  void dispose() {
    _rainController.dispose();
    _mistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark forest gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A1A10), // Dark forest green
                Color(0xFF0D2818), // Deep green
                Color(0xFF1A3A2A), // Forest green
                Color(0xFF0A1510), // Very dark
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),

        // Subtle tree silhouettes (top)
        AnimatedBuilder(
          animation: _mistController,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: ForestSilhouettePainter(_mistController.value),
            );
          },
        ),

        // Rain drops animation
        AnimatedBuilder(
          animation: _rainController,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: RainPainter(_rainDrops, _rainController.value),
            );
          },
        ),

        // Mist/fog overlay
        AnimatedBuilder(
          animation: _mistController,
          builder: (context, child) {
            final mistValue = math.sin(_mistController.value * 2 * math.pi);
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xFF1A3A2A).withValues(alpha: 0.2 + 0.1 * mistValue),
                    Color(0xFF0A1A10).withValues(alpha: 0.4 + 0.1 * mistValue),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            );
          },
        ),

        // Top gradient overlay for header visibility
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 120,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RainDrop {
  double x;
  double y;
  final double length;
  final double speed;
  final double opacity;

  RainDrop({
    required this.x,
    required this.y,
    required this.length,
    required this.speed,
    required this.opacity,
  });
}

class RainPainter extends CustomPainter {
  final List<RainDrop> rainDrops;
  final double animationValue;

  RainPainter(this.rainDrops, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final drop in rainDrops) {
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: drop.opacity)
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round;

      // Calculate position with animation
      final y = ((drop.y + animationValue * drop.speed) % 1.2) * size.height;
      final x = drop.x * size.width;

      // Draw rain drop as a line
      canvas.drawLine(Offset(x, y), Offset(x - 2, y + drop.length), paint);
    }
  }

  @override
  bool shouldRepaint(RainPainter oldDelegate) => true;
}

class ForestSilhouettePainter extends CustomPainter {
  final double animationValue;
  ForestSilhouettePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF051008).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Draw layered tree silhouettes
    _drawTreeLayer(canvas, size, 0.15, paint, 0);

    paint.color = const Color(0xFF071510).withValues(alpha: 0.5);
    _drawTreeLayer(canvas, size, 0.25, paint, 20);

    paint.color = const Color(0xFF0A1A12).withValues(alpha: 0.4);
    _drawTreeLayer(canvas, size, 0.35, paint, 40);
  }

  void _drawTreeLayer(
    Canvas canvas,
    Size size,
    double heightRatio,
    Paint paint,
    double offsetX,
  ) {
    final path = Path();
    path.moveTo(0, size.height * heightRatio);

    // Create jagged tree-top silhouette
    double x = 0;
    while (x < size.width) {
      final treeWidth = 20 + math.sin(x * 0.05 + offsetX) * 15;
      final treeHeight = 30 + math.cos(x * 0.03 + offsetX) * 20;

      path.lineTo(x, size.height * heightRatio);
      path.lineTo(x + treeWidth / 2, size.height * heightRatio - treeHeight);
      path.lineTo(x + treeWidth, size.height * heightRatio);

      x += treeWidth;
    }

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ForestSilhouettePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
