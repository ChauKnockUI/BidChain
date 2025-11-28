import 'dart:async';
import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime endTime;
  final TextStyle? textStyle;

  const CountdownTimer({super.key, required this.endTime, this.textStyle});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
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
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return Text(
        'Đã kết thúc',
        style:
            widget.textStyle ??
            AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey,
              fontWeight: FontWeight.w600,
            ),
      );
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    final isUrgent = _remaining.inHours < 24;

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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer_outlined,
          size: 18,
          color: isUrgent ? AppColors.error : AppColors.accent,
        ),
        const SizedBox(width: 6),
        Text(
          timeString,
          style:
              widget.textStyle ??
              AppTextStyles.bodyMedium.copyWith(
                color: isUrgent ? AppColors.error : AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
