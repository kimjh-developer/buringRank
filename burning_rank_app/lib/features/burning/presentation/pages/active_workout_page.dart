import 'dart:async';
import 'dart:math' as math;
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:burning_rank_app/core/theme/app_colors.dart';
import 'package:burning_rank_app/core/theme/app_text_styles.dart';
import 'package:burning_rank_app/core/utils/health_service.dart';
import 'package:burning_rank_app/shared/widgets/glass_container.dart';
import 'package:burning_rank_app/features/burning/domain/entities/workout_type.dart';
import 'package:burning_rank_app/features/record/domain/models/workout_record.dart';
import 'package:burning_rank_app/features/record/data/repositories/workout_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ActiveWorkoutPage extends StatefulWidget {
  final WorkoutType workout;
  const ActiveWorkoutPage({super.key, required this.workout});

  @override
  State<ActiveWorkoutPage> createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends State<ActiveWorkoutPage> {
  final HealthService _healthService = HealthService();
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  Timer? _timer;
  int _secondsElapsed = 0;

  double heartRate = 75;
  double calories = 0;
  double distance = 0;

  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _startWorkout();
  }

  void _startWorkout() async {
    // [Antigravity] Request location permissions and health authorization for tracking workouts
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      await Permission.locationAlways.request();
    }
    await _healthService.requestAuthorization();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _secondsElapsed++;
          // Simulated incremental logic - will be linked to real stream later
          calories += 0.15;
          distance += 0.002;
          heartRate = 120 + (timer.tick % 10);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
      type: widget.workout.type,
      date: endTime,
      items: [
        WorkoutItem(
          type: widget.workout.type,
          exerciseName: widget.workout.type.name,
          durationSeconds: _secondsElapsed,
          calories: calories,
          distanceKm: distance,
        ),
      ],
      totalDurationSeconds: _secondsElapsed,
      totalCalories: calories,
      totalDistanceKm: distance,
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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background - Google Map
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.5665, 126.9780), // Seoul
                zoom: 15,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: true,
              // style: _darkMapStyle, // 임시 비활성화 - 기본 스타일로 테스트
            ),
          ),

          // Top Overlay (Gradient)
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
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black26,
                        ),
                      ),
                      const Spacer(),
                      if (widget.workout.type != WorkoutActivityType.mind)
                        GlassContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          borderRadius: 20,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'REC',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const Spacer(),

                // Metrics Panel
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FadeInUp(
                    child: GlassContainer(
                      borderRadius: 32,
                      padding: const EdgeInsets.all(24),
                      color: widget.workout.type == WorkoutActivityType.mind
                          ? Colors.white.withValues(alpha: 0.05)
                          : null, // More transparent for breathing
                      child: Column(
                        children: [
                          // Time & Major Metric
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetricItem(
                                'Duration',
                                _formatDuration(_secondsElapsed),
                                AppColors.white,
                              ),
                              if (widget.workout.type !=
                                  WorkoutActivityType.mind)
                                _buildMetricItem(
                                  'Distance',
                                  '${distance.toStringAsFixed(2)}km',
                                  widget.workout.accentColor,
                                )
                              else
                                const SizedBox.shrink(), // Hide distance for mind mode
                            ],
                          ),
                          const Divider(height: 48, color: Colors.white10),
                          // HR & Calories
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetricItem(
                                'Heart Rate',
                                '${heartRate.toInt()}bpm',
                                Colors.redAccent,
                              ),
                              _buildMetricItem(
                                'Calories',
                                '${calories.toInt()}kcal',
                                Colors.orangeAccent,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Controls
                          Row(
                            children: [
                              Expanded(
                                child: _buildControlButton(
                                  onTap: () {
                                    setState(() {
                                      _isPaused = !_isPaused;
                                    });
                                  },
                                  icon: _isPaused
                                      ? Icons.play_arrow_rounded
                                      : Icons.pause_rounded,
                                  label: _isPaused ? 'Resume' : 'Pause',
                                  color: Colors.white24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildControlButton(
                                  onTap: () async {
                                    await _saveWorkout();
                                  },
                                  icon: Icons.stop_rounded,
                                  label: 'Finish',
                                  color: AppColors.primaryRed,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.h2.copyWith(color: valueColor, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // 지도는 항상 기본 라이트 모드로 표시됨 (다크 스타일 제거)
}

class BreathingBackground extends StatefulWidget {
  const BreathingBackground({super.key});

  @override
  State<BreathingBackground> createState() => _BreathingBackgroundState();
}

class _BreathingBackgroundState extends State<BreathingBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Much slower for relaxation
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final breathingValue = math.sin(_controller.value * 2 * math.pi);
        final pulseAlpha = 0.5 + 0.3 * breathingValue; // Subtle breathing pulse

        return CustomPaint(
          painter: WavePainter(_controller.value),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0F2027),
                  const Color(0xFF203A43).withValues(alpha: pulseAlpha),
                  const Color(0xFF2C5364).withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Multi-layered, organic waves
    _drawWave(
      canvas,
      size,
      1.2,
      0.0,
      0.8,
      const Color(0xFF4A00E0).withValues(alpha: 0.15),
    );
    _drawWave(
      canvas,
      size,
      0.9,
      1.5,
      1.2,
      const Color(0xFF8E2DE2).withValues(alpha: 0.12),
    );
    _drawWave(
      canvas,
      size,
      0.7,
      3.0,
      1.5,
      const Color(0xFFDD2476).withValues(alpha: 0.08),
    );
    _drawWave(
      canvas,
      size,
      0.5,
      4.5,
      0.5,
      const Color(0xFF00D2FF).withValues(alpha: 0.1),
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    double amplitudeScale,
    double phaseOffset,
    double velocityScale,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final yCenter = size.height * 0.65;
    final amplitude = 60.0 * amplitudeScale;
    final wavelength = size.width * 1.5;

    path.moveTo(0, size.height);
    path.lineTo(0, yCenter);

    for (double x = 0; x <= size.width; x++) {
      // Use combination of sines for more organic feel
      final wave1 = math.sin(
        (x / wavelength * 2 * math.pi) +
            (animationValue * 2 * math.pi * velocityScale) +
            phaseOffset,
      );
      final wave2 = math.cos(
        (x / (wavelength * 0.7) * 2 * math.pi) -
            (animationValue * math.pi) +
            phaseOffset * 0.5,
      );

      final y = yCenter + amplitude * (wave1 * 0.7 + wave2 * 0.3);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
