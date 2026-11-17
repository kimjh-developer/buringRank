import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:burning_rank_app/core/theme/app_colors.dart';
import 'package:burning_rank_app/shared/widgets/glass_container.dart';
import 'package:burning_rank_app/features/burning/presentation/pages/burning_page.dart';
import 'package:burning_rank_app/features/record/presentation/pages/record_page.dart';
import 'package:burning_rank_app/features/profile/presentation/pages/profile_page.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const BurningPage(),
    const RecordPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Important for floating bar
      body: _pages[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 24.0, left: 16.0, right: 16.0),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          borderRadius: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.local_fire_department_rounded, "Burning"),
              _buildNavItem(1, Icons.bar_chart_rounded, "Record"),
              _buildNavItem(2, Icons.person_rounded, "My"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryRed.withValues(alpha: 0.8)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
