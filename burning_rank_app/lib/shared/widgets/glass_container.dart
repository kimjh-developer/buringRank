import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:burning_rank_app/core/theme/app_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final double? width;
  final double? height;
  final Color? color;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
