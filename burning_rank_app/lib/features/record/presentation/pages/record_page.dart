import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:burning_rank_app/core/theme/app_colors.dart';
import 'package:burning_rank_app/core/theme/app_text_styles.dart';
import 'package:burning_rank_app/shared/widgets/glass_container.dart';
import 'package:burning_rank_app/features/record/data/repositories/workout_repository.dart';
import 'package:burning_rank_app/features/record/domain/models/workout_record.dart';
import 'package:burning_rank_app/features/burning/domain/entities/workout_type.dart';
import 'package:burning_rank_app/features/record/presentation/pages/workout_detail_page.dart';
import 'package:intl/intl.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  List<WorkoutRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      await _workoutRepository.requestPermissions();
      final records = await _workoutRepository.getRecords();
      if (mounted) {
        setState(() {
          _records = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading records: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('활동 기록을 불러오는데 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadRecords,
          color: AppColors.primaryRed,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                FadeInDown(child: Text('활동 기록', style: AppTextStyles.h1)),
                const SizedBox(height: 24),

                // Weekly Summary Chart
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: GlassContainer(
                    height: 220,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '최근 7일 소모 칼로리',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryRed,
                                  ),
                                )
                              : BarChart(
                                  BarChartData(
                                    gridData: const FlGridData(show: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final date = DateTime.now()
                                                .subtract(
                                                  Duration(
                                                    days: 6 - value.toInt(),
                                                  ),
                                                );
                                            final dayLabel = DateFormat(
                                              'E',
                                              'ko_KR',
                                            ).format(date);
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: Text(
                                                dayLabel,
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(fontSize: 10),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barGroups: _generateGroupsFromRecords(),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // History Title
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('최근 운동', style: AppTextStyles.h3),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          '모두 보기',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // History List
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryRed,
                        ),
                      )
                    : _records.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            '운동 기록이 없습니다.',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _records.length > 5 ? 5 : _records.length,
                        itemBuilder: (context, index) {
                          return FadeInUp(
                            delay: Duration(milliseconds: 500 + (index * 100)),
                            child: _buildHistoryItem(_records[index]),
                          );
                        },
                      ),

                const SizedBox(height: 100), // Bottom nav space
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateGroupsFromRecords() {
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return DateTime(date.year, date.month, date.day);
    });

    final dailyCalories = <DateTime, double>{};
    for (var day in last7Days) {
      dailyCalories[day] = 0;
    }

    for (var record in _records) {
      final recordDay = DateTime(
        record.date.year,
        record.date.month,
        record.date.day,
      );
      if (dailyCalories.containsKey(recordDay)) {
        dailyCalories[recordDay] = dailyCalories[recordDay]! + record.totalCalories;
      }
    }

    // Find max calories to scale the bars if needed, but for now just use a reasonable max or let fl_chart handle it
    double maxCal = 100;
    for (var cal in dailyCalories.values) {
      if (cal > maxCal) maxCal = cal;
    }

    return List.generate(7, (index) {
      final day = last7Days[index];
      final cal = dailyCalories[day]!;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: cal == 0 ? 2 : cal, // Show a tiny bit if 0 for aesthetics
            gradient: AppColors.burningGradient,
            width: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  Widget _buildHistoryItem(WorkoutRecord record) {
    final workoutType = WorkoutType.all.firstWhere(
      (w) => w.type == record.type,
      orElse: () => WorkoutType.all.first,
    );

    final formattedDate = DateFormat('yyyy.MM.dd • HH:mm').format(record.date);
    final durationMins = record.totalDurationSeconds ~/ 60;
    
    // Summary name logic
    String sessionSummary;
    if (record.items.isEmpty) {
      sessionSummary = workoutType.name;
    } else {
      String firstItem = record.items.first.exerciseName;
      // [Antigravity] Map legacy 'Breathing' name to Korea '휴식'
      if (firstItem == 'Breathing') firstItem = '휴식';
      if (firstItem == 'hike') firstItem = '등산/하이킹';
      if (firstItem == 'card') firstItem = '유산소';

      if (record.items.length > 1) {
        sessionSummary = '$firstItem 외 ${record.items.length - 1}개';
      } else {
        sessionSummary = firstItem;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutDetailPage(record: record),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: workoutType.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIconForType(record.type), color: workoutType.accentColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sessionSummary, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('$formattedDate • ${durationMins}분', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('+${record.totalCalories.toInt()}kcal',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
                  if (record.totalDistanceKm != null && record.totalDistanceKm! > 0)
                    Text('${record.totalDistanceKm!.toStringAsFixed(1)}km', style: AppTextStyles.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(WorkoutActivityType type) {
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
}
