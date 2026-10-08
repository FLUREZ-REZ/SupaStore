import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FlashSaleCountdown extends StatefulWidget {
  const FlashSaleCountdown({
    super.key,
    required this.startAt,
    required this.endAt,
    required this.isActive,
  });

  final DateTime startAt;
  final DateTime endAt;
  final bool isActive;

  @override
  State<FlashSaleCountdown> createState() =>
      _FlashSaleCountdownState();
}

class _FlashSaleCountdownState
    extends State<FlashSaleCountdown> {
  Timer? _timer;

  Duration _remaining = Duration.zero;

  bool _started = false;
  bool _expired = false;

  @override
  void initState() {
    super.initState();

    _updateCountdown();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        _updateCountdown();
      },
    );
  }

  @override
  void didUpdateWidget(
      covariant FlashSaleCountdown oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.startAt != widget.startAt ||
        oldWidget.endAt != widget.endAt ||
        oldWidget.isActive != widget.isActive) {
      _updateCountdown();
    }
  }

  void _updateCountdown() {
    if (!mounted) {
      return;
    }

    final now = DateTime.now();

    if (!widget.isActive) {
      setState(() {
        _remaining = Duration.zero;
        _started = false;
        _expired = false;
      });

      return;
    }

    if (now.isBefore(widget.startAt)) {
      setState(() {
        _remaining =
            widget.startAt.difference(now);
        _started = false;
        _expired = false;
      });

      return;
    }

    if (now.isBefore(widget.endAt)) {
      setState(() {
        _remaining =
            widget.endAt.difference(now);
        _started = true;
        _expired = false;
      });

      return;
    }

    setState(() {
      _remaining = Duration.zero;
      _started = true;
      _expired = true;
    });
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;

    final hours =
    duration.inHours.remainder(24);

    final minutes =
    duration.inMinutes.remainder(60);

    final seconds =
    duration.inSeconds.remainder(60);

    if (days > 0) {
      return '${days}روز '
          '${_twoDigits(hours)}:'
          '${_twoDigits(minutes)}:'
          '${_twoDigits(seconds)}';
    }

    return '${_twoDigits(hours)}:'
        '${_twoDigits(minutes)}:'
        '${_twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return _buildLabel(
        text: 'غیرفعال',
        color: Colors.grey,
      );
    }

    if (_expired) {
      return _buildLabel(
        text: 'منقضی شده',
        color: Colors.grey,
      );
    }

    if (!_started) {
      return _buildLabel(
        text:
        'شروع در ${_formatDuration(_remaining)}',
        color: Colors.orange,
      );
    }

    return _buildLabel(
      text:
      'باقی‌مانده ${_formatDuration(_remaining)}',
      color: const Color(0xFFE21B23),
    );
  }

  Widget _buildLabel({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          8.r,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }
}