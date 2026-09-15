import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/order_feature/presentation/providers/checkout_provider.dart';

class PaymentResultPage extends StatefulWidget {
  const PaymentResultPage({
    super.key,
    required this.orderId,
    this.status,
    this.refId,
    this.gateway,
  });

  final String orderId;
  final String? status;
  final String? refId;
  final String? gateway;

  @override
  State<PaymentResultPage> createState() =>
      _PaymentResultPageState();
}

class _PaymentResultPageState
    extends State<PaymentResultPage> {
  bool _isLoading = true;
  bool _cartCleared = false;
  bool _isPaid = false;

  String? _errorMessage;
  String? _paymentRefId;
  String? _paymentGateway;

  @override
  void initState() {
    super.initState();

    _paymentRefId = widget.refId;
    _paymentGateway = widget.gateway;

    _checkPayment();
  }

  // ============================================================
  // Check Payment
  // ============================================================

  Future<void> _checkPayment() async {
    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
        'کاربر وارد حساب کاربری نشده است.';
      });

      return;
    }

    final selectedGateway =
    widget.gateway?.trim().isNotEmpty == true
        ? widget.gateway!.trim()
        : 'zarinpal';

    try {
      debugPrint(
        '========== PAYMENT RESULT =========',
      );

      debugPrint(
        'ORDER ID: ${widget.orderId}',
      );

      debugPrint(
        'GATEWAY: $selectedGateway',
      );

      debugPrint(
        'CALLBACK STATUS: ${widget.status}',
      );

      debugPrint(
        'CALLBACK REF ID: ${widget.refId}',
      );

      debugPrint(
        '====================================',
      );

      Map<String, dynamic>? payment;

      // ----------------------------------------------------------
      // Sometimes callback reaches the app slightly before
      // the Edge Function finishes updating the payment.
      // ----------------------------------------------------------

      for (int attempt = 0; attempt < 5; attempt++) {
        payment = await Supabase.instance.client
            .from('payments')
            .select(
          '''
              id,
              order_id,
              user_id,
              amount,
              gateway,
              status,
              authority,
              ref_id,
              gateway_message,
              created_at,
              updated_at,
              paid_at
              ''',
        )
            .eq(
          'order_id',
          widget.orderId,
        )
            .eq(
          'user_id',
          user.id,
        )
            .eq(
          'gateway',
          selectedGateway,
        )
            .order(
          'created_at',
          ascending: false,
        )
            .limit(1)
            .maybeSingle();

        if (payment != null) {
          final paymentStatus =
          payment['status']?.toString();

          debugPrint(
            'Payment attempt ${attempt + 1}: '
                'status=$paymentStatus',
          );

          if (paymentStatus == 'paid' ||
              paymentStatus == 'failed' ||
              paymentStatus == 'canceled') {
            break;
          }
        }

        if (attempt < 4) {
          await Future.delayed(
            const Duration(seconds: 1),
          );
        }
      }

      // ----------------------------------------------------------
      // Payment not found
      // ----------------------------------------------------------

      if (payment == null) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
          _errorMessage =
          'اطلاعات پرداخت سفارش پیدا نشد.';
        });

        return;
      }

      final paymentStatus =
      payment['status']?.toString();

      final databaseGateway =
      payment['gateway']?.toString();

      final databaseRefId =
      payment['ref_id']?.toString();

      if (databaseGateway != null &&
          databaseGateway.isNotEmpty) {
        _paymentGateway =
            databaseGateway;
      } else {
        _paymentGateway =
            selectedGateway;
      }

      if (databaseRefId != null &&
          databaseRefId.isNotEmpty) {
        _paymentRefId =
            databaseRefId;
      }

      // ----------------------------------------------------------
      // Paid
      // ----------------------------------------------------------

      if (paymentStatus == 'paid') {
        _isPaid = true;

        await _clearCart(user.id);

        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
          _isPaid = true;
        });

        return;
      }

      // ----------------------------------------------------------
      // Failed
      // ----------------------------------------------------------

      if (paymentStatus == 'failed') {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
          _isPaid = false;
          _errorMessage =
              payment?['gateway_message']?.toString() ??
                  'پرداخت ناموفق بود.';
        });

        return;
      }

      // ----------------------------------------------------------
      // Canceled
      // ----------------------------------------------------------

      if (paymentStatus == 'canceled') {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
          _isPaid = false;
          _errorMessage =
          'پرداخت توسط کاربر لغو شد.';
        });

        return;
      }

      // ----------------------------------------------------------
      // Pending / Unknown
      // ----------------------------------------------------------

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _isPaid = false;
        _errorMessage =
        'وضعیت پرداخت هنوز نهایی نشده است.';
      });
    } catch (error) {
      debugPrint(
        'Payment result error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _isPaid = false;
        _errorMessage =
        'بررسی وضعیت پرداخت انجام نشد.';
      });
    }
  }

  // ============================================================
  // Clear Cart
  // ============================================================

  Future<void> _clearCart(
      String userId,
      ) async {
    try {
      final checkoutProvider =
      getIt<CheckoutProvider>();

      final cleared =
      await checkoutProvider.confirmPayment(
        orderId: widget.orderId,
        userId: userId,
      );

      _cartCleared = cleared;

      debugPrint(
        'PaymentResultPage cart cleared: $cleared',
      );
    } catch (error) {
      _cartCleared = false;

      debugPrint(
        'PaymentResultPage cart clear error: $error',
      );
    }
  }

  // ============================================================
  // Gateway Title
  // ============================================================

  String _gatewayTitle() {
    switch (_paymentGateway) {
      case 'sep':
        return 'سامان (SEP)';

      case 'zarinpal':
        return 'زرین‌پال';

      default:
        return 'درگاه پرداخت';
    }
  }

  // ============================================================
  // Retry
  // ============================================================

  Future<void> _retry() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isPaid = false;
    });

    await _checkPayment();
  }

  // ============================================================
  // Close
  // ============================================================

  void _goHome() {
    if (!mounted) {
      return;
    }

    context.go('/home');
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'نتیجه پرداخت',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoading()
            : _isPaid
            ? _buildSuccess()
            : _buildFailure(),
      ),
    );
  }

  // ============================================================
  // Loading
  // ============================================================

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48.w,
              height: 48.w,
              child:
              const CircularProgressIndicator(),
            ),
            SizedBox(height: 24.h),
            Text(
              'در حال بررسی وضعیت پرداخت...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              _gatewayTitle(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Success
  // ============================================================

  Widget _buildSuccess() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          SizedBox(height: 30.h),

          Container(
            width: 84.w,
            height: 84.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.12),
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 58.sp,
              color: Colors.green,
            ),
          ),

          SizedBox(height: 22.h),

          Text(
            'پرداخت با موفقیت انجام شد',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 10.h),

          Text(
            'سفارش شما با موفقیت ثبت شد.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),

          SizedBox(height: 28.h),

          _InfoCard(
            children: [
              _InfoRow(
                title: 'شماره سفارش',
                value: widget.orderId,
              ),
              SizedBox(height: 12.h),
              _InfoRow(
                title: 'درگاه پرداخت',
                value: _gatewayTitle(),
              ),
              if (_paymentRefId != null &&
                  _paymentRefId!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                _InfoRow(
                  title: 'شماره پیگیری',
                  value: _paymentRefId!,
                ),
              ],
            ],
          ),

          if (!_cartCleared) ...[
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(12.r),
                color: Colors.orange
                    .withOpacity(0.08),
              ),
              child: Text(
                'پرداخت موفق بود، اما پاک‌سازی سبد خرید انجام نشد.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],

          SizedBox(height: 30.h),

          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: _goHome,
              child: const Text(
                'بازگشت به فروشگاه',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Failure
  // ============================================================

  Widget _buildFailure() {
    final isCanceled =
    (_errorMessage ?? '')
        .contains('لغو');

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          SizedBox(height: 30.h),

          Container(
            width: 84.w,
            height: 84.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.10),
            ),
            child: Icon(
              isCanceled
                  ? Icons.cancel_outlined
                  : Icons.error_outline,
              size: 58.sp,
              color: Colors.red,
            ),
          ),

          SizedBox(height: 22.h),

          Text(
            isCanceled
                ? 'پرداخت لغو شد'
                : 'پرداخت ناموفق بود',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 10.h),

          Text(
            _errorMessage ??
                'متأسفانه پرداخت سفارش انجام نشد.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),

          SizedBox(height: 28.h),

          _InfoCard(
            children: [
              _InfoRow(
                title: 'شماره سفارش',
                value: widget.orderId,
              ),
              SizedBox(height: 12.h),
              _InfoRow(
                title: 'درگاه پرداخت',
                value: _gatewayTitle(),
              ),
            ],
          ),

          SizedBox(height: 30.h),

          if (!isCanceled)
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _retry,
                child: const Text(
                  'بررسی مجدد پرداخت',
                ),
              ),
            ),

          SizedBox(height: 10.h),

          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: OutlinedButton(
              onPressed: _goHome,
              child: const Text(
                'بازگشت به فروشگاه',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Info Card
// ============================================================

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// ============================================================
// Info Row
// ============================================================

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}