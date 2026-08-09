import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/constants/price_formatter.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/features/cart_feature/domain/entities/cart_item_entity.dart';
import 'package:supastore/features/order_feature/presentation/pages/order_success_page.dart';
import 'package:supastore/features/order_feature/presentation/providers/checkout_provider.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({
    super.key,
    required this.cartItems,
  });

  final List<CartItemEntity> cartItems;

  @override
  Widget build(BuildContext context) {
    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'لطفاً ابتدا وارد حساب کاربری شوید',
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => getIt<CheckoutProvider>()
        ..initialize(
          items: cartItems,
        ),
      child: const _CheckoutView(),
    );
  }
}

class _CheckoutView extends StatelessWidget {
  const _CheckoutView();

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<CheckoutProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تکمیل سفارش',
          ),
          centerTitle: true,
        ),

        body: provider.isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : ListView(
          padding: EdgeInsets.only(
            top: 12.h,
            bottom: 120.h,
          ),
          children: [
            const _SectionTitle(
              title: 'محصولات سفارش',
            ),

            const _CheckoutItemsSection(),

            SizedBox(height: 12.h),

            const _SectionTitle(
              title: 'آدرس ارسال',
            ),

            const _AddressSection(),

            SizedBox(height: 12.h),

            const _SectionTitle(
              title: 'روش ارسال',
            ),

            const _ShippingSection(),

            SizedBox(height: 12.h),

            const _SectionTitle(
              title: 'روش پرداخت',
            ),

            const _PaymentSection(),

            SizedBox(height: 12.h),

            const _SectionTitle(
              title: 'خلاصه سفارش',
            ),

            const _OrderSummary(),

            SizedBox(height: 20.h),

            if (provider.error != null)
              _ErrorMessage(
                message:
                provider.error!,
              ),

            SizedBox(height: 20.h),
          ],
        ),

        bottomNavigationBar:
        provider.isLoading
            ? null
            : const _CheckoutBottomBar(),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CheckoutItemsSection
    extends StatelessWidget {
  const _CheckoutItemsSection();

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<CheckoutProvider>();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: provider.cartItems.map(
              (item) {
            final product =
                item.product;

            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8.h,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(
                      10.r,
                    ),
                    child: Image.network(
                      product.thumbnail,
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return Container(
                          width: 60.w,
                          height: 60.w,
                          color: Colors
                              .grey
                              .shade100,
                          child: Icon(
                            Icons
                                .image_not_supported_outlined,
                            color: Colors
                                .grey
                                .shade400,
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(width: 12.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          product.title,
                          maxLines: 2,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: 6.h),

                        Text(
                          '${item.quantity} عدد',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors
                                .grey
                                .shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    PriceFormatter.format(
                      product.finalPrice *
                          item.quantity,
                    ),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight:
                      FontWeight.bold,
                      color:
                      AppColors.price,
                    ),
                  ),
                ],
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}

class _AddressSection
    extends StatefulWidget {
  const _AddressSection();

  @override
  State<_AddressSection> createState() =>
      _AddressSectionState();
}

class _AddressSectionState
    extends State<_AddressSection> {
  final TextEditingController
  _controller =
  TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider =
    context.read<CheckoutProvider>();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: TextField(
        controller: _controller,
        maxLines: 3,
        onChanged:
        provider.setShippingAddress,
        textDirection:
        TextDirection.rtl,
        decoration: InputDecoration(
          hintText:
          'آدرس کامل محل تحویل را وارد کنید',
          prefixIcon: const Icon(
            Icons.location_on_outlined,
          ),
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}

class _ShippingSection
    extends StatelessWidget {
  const _ShippingSection();

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<CheckoutProvider>();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: RadioListTile<int>(
        value: 0,
        groupValue:
        provider.shippingCost,
        onChanged: (value) {
          if (value != null) {
            provider.setShippingCost(
              value,
            );
          }
        },
        title: const Text(
          'ارسال معمولی',
        ),
        subtitle: const Text(
          'ارسال با هزینه رایگان',
        ),
        secondary: const Icon(
          Icons.local_shipping_outlined,
        ),
      ),
    );
  }
}

class _PaymentSection
    extends StatelessWidget {
  const _PaymentSection();

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<CheckoutProvider>();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: RadioListTile<String>(
        value: 'online',
        groupValue:
        provider.paymentMethod,
        onChanged: (value) {
          if (value != null) {
            provider.setPaymentMethod(
              value,
            );
          }
        },
        title: const Text(
          'پرداخت آنلاین',
        ),
        subtitle: const Text(
          'پرداخت امن از طریق درگاه',
        ),
        secondary: const Icon(
          Icons.payment_outlined,
        ),
      ),
    );
  }
}

class _OrderSummary
    extends StatelessWidget {
  const _OrderSummary();

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<CheckoutProvider>();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          _SummaryRow(
            title: 'جمع کالاها',
            value: provider.subtotal,
          ),

          SizedBox(height: 10.h),

          _SummaryRow(
            title: 'تخفیف',
            value:
            provider.totalDiscount,
            isDiscount: true,
          ),

          SizedBox(height: 10.h),

          _SummaryRow(
            title: 'هزینه ارسال',
            value:
            provider.shippingCost,
          ),

          Divider(
            height: 24.h,
          ),

          _SummaryRow(
            title: 'مبلغ قابل پرداخت',
            value:
            provider.totalPrice,
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow
    extends StatelessWidget {
  const _SummaryRow({
    required this.title,
    required this.value,
    this.isDiscount = false,
    this.isTotal = false,
  });

  final String title;
  final int value;
  final bool isDiscount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize:
            isTotal ? 15.sp : 13.sp,
            fontWeight:
            isTotal
                ? FontWeight.bold
                : FontWeight.normal,
            color:
            isDiscount
                ? Colors.green
                : Colors.black87,
          ),
        ),

        const Spacer(),

        Text(
          PriceFormatter.format(
            value,
          ),
          style: TextStyle(
            fontSize:
            isTotal ? 16.sp : 13.sp,
            fontWeight:
            FontWeight.bold,
            color:
            isDiscount
                ? Colors.green
                : isTotal
                ? AppColors.price
                : Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _CheckoutBottomBar extends StatelessWidget {
  const _CheckoutBottomBar();

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<CheckoutProvider>();

    final user =
        Supabase.instance.client.auth.currentUser;

    final navigator =
    Navigator.of(context);

    final scaffoldMessenger =
    ScaffoldMessenger.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        16.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.06,
            ),
            blurRadius: 12.r,
            offset: Offset(
              0,
              -3.h,
            ),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed:
            provider.canSubmit &&
                user != null
                ? () async {
              debugPrint(
                'CHECKOUT START',
              );

              final success =
              await provider.placeOrder(
                userId: user.id,
              );

              debugPrint(
                'CHECKOUT RESULT: $success',
              );

              debugPrint(
                'ORDER: ${provider.order}',
              );

              if (!success) {
                scaffoldMessenger
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      provider.error ??
                          'ثبت سفارش ناموفق بود',
                    ),
                  ),
                );

                return;
              }

              final order =
                  provider.order;

              if (order == null) {
                scaffoldMessenger
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'سفارش ثبت شد اما اطلاعات آن دریافت نشد.',
                    ),
                  ),
                );

                return;
              }

              debugPrint(
                'ORDER ID: ${order.id}',
              );

              debugPrint(
                'NAVIGATING...',
              );

              navigator.pushReplacement(
                MaterialPageRoute(
                  builder: (_) =>
                      OrderSuccessPage(
                        order: order,
                      ),
                ),
              );
            }
                : null,
            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              AppColors.primary,
              foregroundColor:
              Colors.white,
              elevation: 0,
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  14.r,
                ),
              ),
            ),
            child: Text(
              'ثبت سفارش و پرداخت',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorMessage
    extends StatelessWidget {
  const _ErrorMessage({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius:
        BorderRadius.circular(12.r),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.red.shade700,
        ),
      ),
    );
  }
}