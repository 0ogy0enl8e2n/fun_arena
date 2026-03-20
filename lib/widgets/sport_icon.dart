import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme/app_colors.dart';

class SportIcon extends StatelessWidget {
  final String sport;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const SportIcon({
    super.key,
    required this.sport,
    this.size = 24,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 12,
      height: size + 12,
      decoration: BoxDecoration(
        color: backgroundColor ??
            AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        AppConstants.sportIcon(sport),
        size: size,
        color: color ?? AppColors.primary,
      ),
    );
  }
}
