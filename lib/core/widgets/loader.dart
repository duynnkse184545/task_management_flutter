import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Full-screen centered loader with optional message
class Loader extends StatelessWidget {
  final String? message;
  final Color? color;

  const Loader({super.key, this.message, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: color ?? AppColors.primary,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small inline loader for buttons and inline use
class SmallLoader extends StatelessWidget {
  final Color? color;
  final double size;
  final double strokeWidth;

  const SmallLoader({
    super.key,
    this.color,
    this.size = 20,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.white,
        ),
      ),
    );
  }
}