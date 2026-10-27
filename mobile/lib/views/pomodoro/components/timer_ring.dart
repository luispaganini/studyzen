import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class TimerRing extends StatelessWidget {
  final double progress;
  final String label;
  final String caption;
  final bool active;

  const TimerRing({
    super.key,
    required this.progress,
    required this.label,
    required this.caption,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: active ? 0.35 : 0.12),
            blurRadius: active ? 60 : 30,
            spreadRadius: active ? 4 : 0,
          ),
        ],
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: progress),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, _) => CustomPaint(
          painter: _RingPainter(value),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  key: const Key('pomodoroTimeLabel'),
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -2,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  caption,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);

    canvas.drawCircle(
      rect.center,
      arcRect.width / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.surfaceHigh,
    );

    if (progress <= 0) return;
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          colors: [AppColors.primary, AppColors.accent, AppColors.secondary, AppColors.primary],
          transform: GradientRotation(-math.pi / 2),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.progress != progress;
}
