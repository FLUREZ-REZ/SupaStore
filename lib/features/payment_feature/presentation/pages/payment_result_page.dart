import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentResultPage extends StatefulWidget {
  const PaymentResultPage({
    super.key,
    required this.orderId,
    this.status,
    this.refId,
  });

  final String orderId;
  final String? status;
  final String? refId;

  @override
  State<PaymentResultPage> createState() =>
      _PaymentResultPageState();
}

class _PaymentResultPageState
    extends State<PaymentResultPage> {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  bool _isLoading = true;

  bool _isPaid = false;

  String? _errorMessage;

  Map<String, dynamic>? _payment;

  @override
  void initState() {
    super.initState();

    _checkPayment();
  }

  Future<void> _checkPayment() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user =
          _supabase.auth.currentUser;

      if (user == null) {
        throw Exception(
          'کاربر وارد حساب کاربری نشده است.',
        );
      }

      Map<String, dynamic>? payment;

      for (int attempt = 0;
      attempt < 5;
      attempt++) {
        final response =
        await _supabase
            .from('payments')
            .select(
          'id, order_id, amount, gateway, status, authority, ref_id, paid_at',
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
          'zarinpal',
        )
            .maybeSingle();

        payment = response;

        if (payment != null &&
            payment['status'] == 'paid') {
          break;
        }

        if (attempt < 4) {
          await Future.delayed(
            const Duration(
              seconds: 1,
            ),
          );
        }
      }

      if (!mounted) {
        return;
      }

      if (payment == null) {
        setState(() {
          _isLoading = false;

          _isPaid = false;

          _errorMessage =
          'اطلاعات پرداخت پیدا نشد.';
        });

        return;
      }

      final paymentStatus =
      payment['status']
          ?.toString()
          .toLowerCase();

      if (paymentStatus == 'paid') {
        setState(() {
          _isLoading = false;

          _isPaid = true;

          _payment = payment;
        });

        /*
         * -------------------------------------------------------
         * IMPORTANT
         * -------------------------------------------------------
         *
         * پرداخت در دیتابیس تأیید شده است.
         *
         * اینجا باید منطق فعلی CheckoutProvider خودت
         * برای پاک کردن Cart را صدا بزنی.
         *
         * فعلاً عمداً اینجا چیزی اختراع نکرده‌ایم چون
         * متد دقیق Cart/CheckoutProvider پروژه تو را
         * نباید حدس بزنیم.
         */
      } else {
        setState(() {
          _isLoading = false;

          _isPaid = false;

          _payment = payment;

          _errorMessage =
          'پرداخت تأیید نشده است.';
        });
      }
    } catch (error) {
      debugPrint(
        'PaymentResultPage error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;

        _isPaid = false;

        _errorMessage =
        'بررسی وضعیت پرداخت با خطا مواجه شد.';
      });
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'نتیجه پرداخت',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(
              24.w,
            ),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'در حال بررسی وضعیت پرداخت...',
          ),
        ],
      );
    }

    if (_isPaid) {
      return _buildSuccess();
    }

    return _buildFailed();
  }

  Widget _buildSuccess() {
    final refId =
        _payment?['ref_id']?.toString() ??
            widget.refId ??
            'ثبت شده';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 90.sp,
          color: Colors.green,
        ),
        SizedBox(height: 24.h),
        Text(
          'پرداخت موفق بود',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'پرداخت سفارش شما با موفقیت تأیید شد.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 24.h),
        _infoRow(
          title: 'شماره سفارش',
          value: widget.orderId,
        ),
        SizedBox(height: 8.h),
        _infoRow(
          title: 'شماره پیگیری',
          value: refId,
        ),
        SizedBox(height: 32.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.go('/home');
            },
            child: const Text(
              'بازگشت به فروشگاه',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFailed() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.cancel_rounded,
          size: 90.sp,
          color: Colors.red,
        ),
        SizedBox(height: 24.h),
        Text(
          'پرداخت ناموفق بود',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          _errorMessage ??
              'پرداخت تأیید نشد.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 32.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _checkPayment,
            child: const Text(
              'بررسی مجدد',
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow({
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        14.w,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(
          12.r,
        ),
      ),
      child: Row(
        children: [
          Text(
            '$title:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              overflow:
              TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}