import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:burning_rank_app/core/theme/app_colors.dart';
import 'package:burning_rank_app/core/theme/app_text_styles.dart';
import 'package:burning_rank_app/shared/widgets/glass_container.dart';
import 'package:burning_rank_app/features/record/domain/models/workout_record.dart';
import 'package:burning_rank_app/features/burning/domain/entities/workout_type.dart';
import 'package:intl/intl.dart';

class WorkoutDetailPage extends StatefulWidget {
  final WorkoutRecord record;
  const WorkoutDetailPage({super.key, required this.record});

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    final workoutType = WorkoutType.all.firstWhere(
      (w) => w.type == widget.record.type,
      orElse: () => WorkoutType.all.first,
    );
    final formattedDate = DateFormat(
      'yyyy년 MM월 dd일 • HH:mm',
    ).format(widget.record.date);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background - Static Map (since we don't have polyline data yet)
          if (widget.record.type != WorkoutActivityType.mind)
            Positioned.fill(
              child: SizedBox.expand(
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    if (!_mapController.isCompleted) {
                      _mapController.complete(controller);
                    }
                    debugPrint('[WorkoutDetailPage] Map created successfully');
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(37.5665, 126.9780), // default to Seoul
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                  compassEnabled: true,
                  // 지도는 항상 기본 라이트 모드로 표시
                ),
              ),
            )
          else
            Positioned.fill(child: Container(color: AppColors.background)),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
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
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('운동 상세', style: AppTextStyles.h2),
                    ],
                  ),
                ),

                const Spacer(),

                // Info Panel
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FadeInUp(
                    child: GlassContainer(
                      borderRadius: 32,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getIcon(widget.record.type),
                                color: workoutType.accentColor,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (widget.record.items.isEmpty 
                                          ? workoutType.name 
                                          : (widget.record.items.first.exerciseName == 'Breathing' 
                                              ? '휴식' 
                                              : widget.record.items.first.exerciseName)),
                                      style: AppTextStyles.h3,
                                    ),
                                    Text(
                                      formattedDate,
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 48, color: Colors.white10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatItem(
                                '총 운동 시간',
                                '${widget.record.totalDurationSeconds ~/ 60}분 ${widget.record.totalDurationSeconds % 60}초',
                              ),
                              _buildStatItem(
                                '총 소모 칼로리',
                                '${widget.record.totalCalories.toInt()}kcal',
                              ),
                            ],
                          ),
                          
                          if (widget.record.items.isNotEmpty) ...[
                            const SizedBox(height: 32),
                            const Text('운동 구성', style: AppTextStyles.bodyMedium),
                            const SizedBox(height: 12),
                            ...widget.record.items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.exerciseName == 'Breathing' ? '휴식' : item.exerciseName, 
                                        style: AppTextStyles.bodyLarge
                                      ),
                                      if (item.sets != null)
                                        Text('${item.sets}세트 / ${item.reps}회', style: AppTextStyles.bodySmall),
                                    ],
                                  ),
                                  Text('${item.calories.toInt()}kcal', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryRed)),
                                ],
                              ),
                            )),
                          ],

                          if (widget.record.totalDistanceKm != null && widget.record.totalDistanceKm! > 0) ...[
                             const SizedBox(height: 24),
                             _buildStatItem(
                                '총 이동 거리',
                                '${widget.record.totalDistanceKm!.toStringAsFixed(2)}km',
                              ),
                          ],
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.h2.copyWith(fontSize: 24)),
      ],
    );
  }

  IconData _getIcon(WorkoutActivityType type) {
    switch (type) {
      case WorkoutActivityType.strength:
        return Icons.fitness_center_rounded;
      case WorkoutActivityType.cardio:
        return Icons.directions_run_rounded;
      case WorkoutActivityType.hike:
        return Icons.terrain_rounded;
      case WorkoutActivityType.mind:
        return Icons.self_improvement_rounded;
    }
  }

  // 지도는 항상 기본 라이트 모드로 표시됨 (다크 스타일 제거)
}
