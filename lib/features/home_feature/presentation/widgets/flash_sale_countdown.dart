
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

class _FlashSaleCountdownState extends State<FlashSaleCountdown>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  Timer? _shimmerTimer;

  late final AnimationController _shimmerController;

  Duration _remaining = Duration.zero;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // نمایش شیمر برای حداقل ۲ ثانیه
    _shimmerTimer = Timer(
      const Duration(seconds: 2),
          () {
        if (!mounted) return;

        setState(() {
          _isInitialLoading = false;
        });

        _calculateRemaining();

        _timer = Timer.periodic(
          const Duration(seconds: 1),
              (_) => _calculateRemaining(),
        );
      },
    );
  }

  void _calculateRemaining() {
    final remaining = widget.endAt
        .toLocal()
        .difference(DateTime.now());

    if (!mounted) return;

    setState(() {
      _remaining = remaining.isNegative
          ? Duration.zero
          : remaining;
    });

    if (remaining.isNegative) {
      _timer?.cancel();
    }
  }

  String _format(int value) {
    final formatted = value.toString().padLeft(2, '0');
    return _toPersianDigits(formatted);
  }

  String _toPersianDigits(String value) {
    const englishDigits = '0123456789';
    const persianDigits = '۰۱۲۳۴۵۶۷۸۹';

    return value.split('').map((char) {
      final index = englishDigits.indexOf(char);

      if (index == -1) return char;

      return persianDigits[index];
    }).join();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shimmerTimer?.cancel();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return _CountdownShimmer(
        controller: _shimmerController,
      );
    }

    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.rtl,
      children: [
        _TimeBox(value: _format(seconds)),
        SizedBox(width: 4.w),
        _separator(),
        SizedBox(width: 4.w),
        _TimeBox(value: _format(minutes)),
        SizedBox(width: 4.w),
        _separator(),
        SizedBox(width: 4.w),
        _TimeBox(value: _format(hours)),
      ],
    );
  }

  Widget _separator() {
    return Text(
      ':',
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

// --------------------------------------------------
// Countdown Shimmer
// --------------------------------------------------

class _CountdownShimmer extends StatelessWidget {
  const _CountdownShimmer({
    required this.controller,
  });

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.rtl,
      children: [
        _ShimmerTimeBox(controller: controller),
        SizedBox(width: 4.w),
        _shimmerSeparator(),
        SizedBox(width: 4.w),
        _ShimmerTimeBox(controller: controller),
        SizedBox(width: 4.w),
        _shimmerSeparator(),
        SizedBox(width: 4.w),
        _ShimmerTimeBox(controller: controller),
      ],
    );
  }

  Widget _shimmerSeparator() {
    return Text(
      ':',
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white.withValues(alpha: 0.65),
      ),
    );
  }
}

// --------------------------------------------------
// Shimmer Time Box
// --------------------------------------------------

class _ShimmerTimeBox extends StatelessWidget {
  const _ShimmerTimeBox({
    required this.controller,
  });

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final slide = controller.value * 2 - 1;

        return ClipRRect(
          borderRadius: BorderRadius.circular(7.r),
          child: ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(slide - 1, 0),
                end: Alignment(slide + 1, 0),
                colors: const [
                  Color(0xFFE2E2E2),
                  Color(0xFFFFFFFF),
                  Color(0xFFE2E2E2),
                ],
                stops: const [0.1, 0.5, 0.9],
              ).createShader(bounds);
            },
            child: Container(
              width: 29.w,
              height: 29.w,
              color: const Color(0xFFE2E2E2),
            ),
          ),
        );
      },
    );
  }
}

// --------------------------------------------------
// Real Time Box
// --------------------------------------------------

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
          fontSize: 9.sp,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }
}
