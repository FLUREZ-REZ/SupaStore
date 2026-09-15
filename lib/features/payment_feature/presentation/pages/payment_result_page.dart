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

    _paymentRefId =
        widget.refId;

    _paymentGateway =
        widget.gateway;

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
        _isPaid = false;
        _errorMessage =
        'کاربر وارد حساب کاربری نشده است.';
      });

      return;
    }

    final callbackGateway =
    widget.gateway
        ?.trim()
        .toLowerCase();

    final selectedGateway =
    callbackGateway != null &&
        callbackGateway.isNotEmpty
        ? callbackGateway
        : 'zarinpal';

    try {
      debugPrint(
        '========== PAYMENT RESULT =========',
      );

      debugPrint(
        'ORDER ID: ${widget.orderId}',
      );

      debugPrint(
        'USER ID: ${user.id}',
      );

      debugPrint(
        'GATEWAY FROM CALLBACK: ${widget.gateway}',
      );

      debugPrint(
        'NORMALIZED GATEWAY: $selectedGateway',
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

      // ========================================================
      // Retry payment lookup
      // ========================================================

      for (
      int attempt = 0;
      attempt < 5;
      attempt++
      ) {
        try {
          payment =
          await Supabase
              .instance
              .client
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
              .order(
            'created_at',
            ascending: false,
          )
              .limit(1)
              .maybeSingle();

          debugPrint(
            'PAYMENT QUERY ATTEMPT: ${attempt + 1}',
          );

          debugPrint(
            'PAYMENT RECORD: $payment',
          );

          if (payment != null) {
            final paymentStatus =
            payment['status']
                ?.toString()
                .trim()
                .toLowerCase();

            final paymentGateway =
            payment['gateway']
                ?.toString()
                .trim()
                .toLowerCase();

            debugPrint(
              'PAYMENT STATUS: $paymentStatus',
            );

            debugPrint(
              'PAYMENT GATEWAY: $paymentGateway',
            );

            debugPrint(
              'EXPECTED GATEWAY: $selectedGateway',
            );

            if (
            paymentStatus == 'paid' ||
                paymentStatus == 'failed' ||
                paymentStatus == 'canceled'
            ) {
              break;
            }
          }
        } catch (error) {
          debugPrint(
            'PAYMENT QUERY ERROR: $error',
          );
        }

        if (attempt < 4) {
          await Future.delayed(
            const Duration(
              seconds: 1,
            ),
          );
        }
      }

      // ========================================================
      // Payment not found
      // ========================================================

      if (payment == null) {
        debugPrint(
          'PAYMENT RESULT: PAYMENT NOT FOUND',
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
          _isPaid = false;
          _errorMessage =
          'اطلاعات پرداخت سفارش پیدا نشد.';
        });

        return;
      }

      // ========================================================
      // Extract payment data
      // ========================================================

      final paymentStatus =
      payment['status']
          ?.toString()
          .trim()
          .toLowerCase();

      final databaseGateway =
      payment['gateway']
          ?.toString()
          .trim()
          .toLowerCase();

      final databaseRefId =
      payment['ref_id']
          ?.toString();

      final gatewayMessage =
      payment['gateway_message']
          ?.toString();

      debugPrint(
        '========== DATABASE PAYMENT =========',
      );

      debugPrint(
        'PAYMENT ID: ${payment['id']}',
      );

      debugPrint(
        'ORDER ID: ${payment['order_id']}',
      );

      debugPrint(
        'STATUS: $paymentStatus',
      );

      debugPrint(
        'GATEWAY: $databaseGateway',
      );

      debugPrint(
        'AUTHORITY: ${payment['authority']}',
      );

      debugPrint(
        'REF ID: $databaseRefId',
      );

      debugPrint(
        'GATEWAY MESSAGE: $gatewayMessage',
      );

      debugPrint(
        'PAID AT: ${payment['paid_at']}',
      );

      debugPrint(
        '======================================',
      );

      // ========================================================
      // Gateway
      // ========================================================

      if (
      databaseGateway != null &&
          databaseGateway.isNotEmpty
      ) {
        _paymentGateway =
            databaseGateway;
      } else {
        _paymentGateway =
            selectedGateway;
      }

      // ========================================================
      // Reference ID
      // ========================================================

      if (
      databaseRefId != null &&
          databaseRefId.isNotEmpty
      ) {
        _paymentRefId =
            databaseRefId;
      } else if (
      widget.refId != null &&
          widget.refId!.isNotEmpty
      ) {
        _paymentRefId =
            widget.refId;
      }

      // ========================================================
      // PAID
      // ========================================================

      if (
      paymentStatus == 'paid'
      ) {
        debugPrint(
          'PAYMENT RESULT: SUCCESS',
        );

        final cartCleared =
        await _clearCart(
          user.id,
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
          _isPaid = true;
          _cartCleared =
              cartCleared;
        });

        return;
      }

      // ========================================================
      // FAILED
      // ========================================================

      if (
      paymentStatus == 'failed'
      ) {
        debugPrint(
          'PAYMENT RESULT: FAILED',
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
          _isPaid = false;
          _errorMessage =
          gatewayMessage != null &&
              gatewayMessage
                  .trim()
                  .isNotEmpty
              ? gatewayMessage
              : 'پرداخت ناموفق بود.';
        });

        return;
      }

      // ========================================================
      // CANCELED
      // ========================================================

      if (
      paymentStatus == 'canceled'
      ) {
        debugPrint(
          'PAYMENT RESULT: CANCELED',
        );

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

      // ========================================================
      // Pending / Unknown
      // ========================================================

      debugPrint(
        'PAYMENT RESULT: PENDING / UNKNOWN',
      );

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

  Future<bool> _clearCart(
      String userId,
      ) async {
    try {
      final checkoutProvider =
      getIt<CheckoutProvider>();

      final cleared =
      await checkoutProvider.confirmPayment(
        orderId:
        widget.orderId,
        userId:
        userId,
      );

      debugPrint(
        'PaymentResultPage cart cleared: $cleared',
      );

      return cleared;
    } catch (error) {
      debugPrint(
        'PaymentResultPage cart clear error: $error',
      );

      return false;
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
  // Go Home
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
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
        Colors.white,
        foregroundColor:
        Colors.black,
        centerTitle: true,
        automaticallyImplyLeading:
        false,
        title: Text(
          'نتیجه پرداخت',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight:
            FontWeight.w700,
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
        padding:
        EdgeInsets.all(24.w),
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
            SizedBox(
              height: 24.h,
            ),
            Text(
              'در حال بررسی وضعیت پرداخت...',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight:
                FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Text(
              _gatewayTitle(),
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color:
                Colors.grey.shade600,
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
      padding:
      EdgeInsets.all(20.w),
      child: Column(
        children: [
          SizedBox(
            height: 30.h,
          ),

          Container(
            width: 84.w,
            height: 84.w,
            decoration:
            BoxDecoration(
              shape:
              BoxShape.circle,
              color: Colors.green
                  .withOpacity(0.12),
            ),
            child: Icon(
              Icons
                  .check_circle_outline,
              size: 58.sp,
              color:
              Colors.green,
            ),
          ),

          SizedBox(
            height: 22.h,
          ),

          Text(
            'پرداخت با موفقیت انجام شد',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight:
              FontWeight.w800,
              color:
              Colors.black,
            ),
          ),

          SizedBox(
            height: 10.h,
          ),

          Text(
            'سفارش شما با موفقیت ثبت شد.',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color:
              Colors.grey.shade600,
            ),
          ),

          SizedBox(
            height: 28.h,
          ),

          _InfoCard(
            children: [
              _InfoRow(
                title:
                'شماره سفارش',
                value:
                widget.orderId,
              ),
              SizedBox(
                height: 12.h,
              ),
              _InfoRow(
                title:
                'درگاه پرداخت',
                value:
                _gatewayTitle(),
              ),
              if (
              _paymentRefId != null &&
                  _paymentRefId!
                      .isNotEmpty
              ) ...[
                SizedBox(
                  height: 12.h,
                ),
                _InfoRow(
                  title:
                  'شماره پیگیری',
                  value:
                  _paymentRefId!,
                ),
              ],
            ],
          ),

          if (!_cartCleared) ...[
            SizedBox(
              height: 14.h,
            ),
            Container(
              width:
              double.infinity,
              padding:
              EdgeInsets.all(
                12.w,
              ),
              decoration:
              BoxDecoration(
                borderRadius:
                BorderRadius
                    .circular(
                  12.r,
                ),
                color: Colors.orange
                    .withOpacity(
                  0.08,
                ),
              ),
              child: Text(
                'پرداخت موفق بود، اما پاک‌سازی سبد خرید انجام نشد.',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color: Colors
                      .orange
                      .shade800,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],

          SizedBox(
            height: 30.h,
          ),

          SizedBox(
            width:
            double.infinity,
            height: 50.h,
            child:
            ElevatedButton(
              onPressed:
              _goHome,
              child:
              const Text(
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
      padding:
      EdgeInsets.all(20.w),
      child: Column(
        children: [
          SizedBox(
            height: 30.h,
          ),

          Container(
            width: 84.w,
            height: 84.w,
            decoration:
            BoxDecoration(
              shape:
              BoxShape.circle,
              color: Colors.red
                  .withOpacity(0.10),
            ),
            child: Icon(
              isCanceled
                  ? Icons
                  .cancel_outlined
                  : Icons
                  .error_outline,
              size: 58.sp,
              color:
              Colors.red,
            ),
          ),

          SizedBox(
            height: 22.h,
          ),

          Text(
            isCanceled
                ? 'پرداخت لغو شد'
                : 'پرداخت ناموفق بود',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight:
              FontWeight.w800,
              color:
              Colors.black,
            ),
          ),

          SizedBox(
            height: 10.h,
          ),

          Text(
            _errorMessage ??
                'متأسفانه پرداخت سفارش انجام نشد.',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color:
              Colors.grey.shade600,
            ),
          ),

          SizedBox(
            height: 28.h,
          ),

          _InfoCard(
            children: [
              _InfoRow(
                title:
                'شماره سفارش',
                value:
                widget.orderId,
              ),
              SizedBox(
                height: 12.h,
              ),
              _InfoRow(
                title:
                'درگاه پرداخت',
                value:
                _gatewayTitle(),
              ),
            ],
          ),

          SizedBox(
            height: 30.h,
          ),

          if (!isCanceled)
            SizedBox(
              width:
              double.infinity,
              height: 50.h,
              child:
              ElevatedButton(
                onPressed:
                _retry,
                child:
                const Text(
                  'بررسی مجدد پرداخت',
                ),
              ),
            ),

          SizedBox(
            height: 10.h,
          ),

          SizedBox(
            width:
            double.infinity,
            height: 50.h,
            child:
            OutlinedButton(
              onPressed:
              _goHome,
              child:
              const Text(
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

class _InfoCard
    extends StatelessWidget {
  const _InfoCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width:
      double.infinity,
      padding:
      EdgeInsets.all(16.w),
      decoration:
      BoxDecoration(
        color:
        Colors.grey.shade50,
        borderRadius:
        BorderRadius.circular(
          14.r,
        ),
        border:
        Border.all(
          color:
          Colors.grey.shade200,
        ),
      ),
      child: Column(
        children:
        children,
      ),
    );
  }
}

// ============================================================
// Info Row
// ============================================================

class _InfoRow
    extends StatelessWidget {
  const _InfoRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              color:
              Colors.grey.shade600,
            ),
          ),
        ),
        SizedBox(
          width: 16.w,
        ),
        Flexible(
          child: Text(
            value,
            textAlign:
            TextAlign.end,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight:
              FontWeight.w600,
              color:
              Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}