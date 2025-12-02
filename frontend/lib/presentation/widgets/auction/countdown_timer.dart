import 'dart:async';
import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime endTime;
  final TextStyle? textStyle;
  final bool showLarge;

  const CountdownTimer({
    super.key,
    required this.endTime,
    this.textStyle,
    this.showLarge = false,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  late AnimationController _pulseController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _updateRemaining();
    if (_remaining > Duration.zero) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          _updateRemaining();
        }
      });
    }
  }

  void _updateRemaining() {
    setState(() {
      final now = DateTime.now();
      _remaining = widget.endTime.difference(now);
      if (_remaining.isNegative) {
        _remaining = Duration.zero;
        _timer?.cancel();
        _timer = null;
        _pulseController.stop();
      } else if (_remaining.inMinutes < 3) {
        // Start color pulsing for critical state
        if (!_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        }
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Color _getTimerColor() {
    if (_remaining == Duration.zero) return AppColors.grey;
    if (_remaining.inMinutes < 3) return AppColors.timerCritical;
    if (_remaining.inMinutes < 10) return AppColors.timerWarning;
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return Text(
        'Đã kết thúc',
        style: widget.textStyle ??
            (widget.showLarge
                ? AppTextStyles.h3.copyWith(
                    color: AppColors.grey,
                    fontWeight: FontWeight.w600,
                  )
                : AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey,
                    fontWeight: FontWeight.w600,
                  )),
      );
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    String timeString;
    if (days > 0) {
      timeString = '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      timeString = '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      timeString = '${minutes}m ${seconds}s';
    } else {
      timeString = '${seconds}s';
    }

    final timerColor = _getTimerColor();
    final isCritical = _remaining.inMinutes < 3;

    if (widget.showLarge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: timerColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: timerColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 32,
              color: timerColor,
            ),
            const SizedBox(width: 12),
            // Only the time text pulses when critical
            AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                final textOpacity = isCritical ? _opacityAnimation.value : 1.0;
                return Text(
                  timeString,
                  style: AppTextStyles.h3.copyWith(
                    color: timerColor.withOpacity(textOpacity),
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    // Regular small display
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer_outlined,
          size: 18,
          color: timerColor,
        ),
        const SizedBox(width: 6),
        // Only the time text pulses when critical
        AnimatedBuilder(
          animation: _opacityAnimation,
          builder: (context, child) {
            final textOpacity = isCritical ? _opacityAnimation.value : 1.0;
            return Text(
              timeString,
              style: widget.textStyle ??
                  AppTextStyles.bodyMedium.copyWith(
                    color: timerColor.withOpacity(textOpacity),
                    fontWeight: FontWeight.w600,
                  ),
            );
          },
        ),
      ],
    );
  }
}

