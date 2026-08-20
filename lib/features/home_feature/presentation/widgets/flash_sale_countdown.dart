import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FlashSaleCountdown extends StatefulWidget {
  const FlashSaleCountdown({
    super.key,
    required this.endAt,
  });

  final DateTime endAt;

  @override
  State<FlashSaleCountdown> createState() =>
      _FlashSaleCountdownState();
}

class _FlashSaleCountdownState
    extends State<FlashSaleCountdown> {
  Timer? _timer;

  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();

    _calculateRemaining();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _calculateRemaining(),
    );
  }

  void _calculateRemaining() {
    final remaining =
    widget.endAt.toLocal().difference(
      DateTime.now(),
    );

    if (remaining.isNegative) {
      _timer?.cancel();

      if (!mounted) return;

      setState(() {
        _remaining = Duration.zero;
      });

      return;
    }

    if (!mounted) return;

    setState(() {
      _remaining = remaining;
    });
  }

  String _format(int value) {
    return value.toString().padLeft(2, '0');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _remaining.inHours;

    final minutes =
    _remaining.inMinutes.remainder(60);

    final seconds =
    _remaining.inSeconds.remainder(60);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TimeBox(
          value: _format(hours),
        ),

        SizedBox(width: 4.w),

        Text(
          ':',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        SizedBox(width: 4.w),

        _TimeBox(
          value: _format(minutes),
        ),

        SizedBox(width: 4.w),

        Text(
          ':',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        SizedBox(width: 4.w),

        _TimeBox(
          value: _format(seconds),
        ),
      ],
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({
    required this.value,
  });

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 29.w,
      height: 29.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }
}