import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';
import 'package:supastore/features/address_feature/domain/entities/address_entity.dart';
import 'package:supastore/features/address_feature/presentation/providers/address_provider.dart';
import 'package:supastore/features/cart_feature/domain/entities/cart_item_entity.dart';
import 'package:supastore/features/order_feature/presentation/providers/checkout_provider.dart';
import 'package:supastore/features/shipping_feature/domain/entities/shipping_method_entity.dart';
import 'package:supastore/features/shipping_feature/presentation/providers/shipping_provider.dart';
import 'package:url_launcher/url_launcher.dart';



class CheckoutPage extends StatelessWidget {
  const CheckoutPage({
    super.key,
    required this.cartItems,
  });

  final List<CartItemEntity> cartItems;

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('تسویه حساب'),
        ),
        body: Center(
          child: Text(
            'برای ادامه ابتدا وارد حساب کاربری شوید.',
            style: AppTextStyles.body,
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
          getIt<AddressProvider>()
            ..loadAddresses(
              userId: user.id,
            )
        ),
        ChangeNotifierProvider(
          create: (_) =>
          getIt<ShippingProvider>()
            ..loadShippingMethods(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
          getIt<CheckoutProvider>()
            ..initialize(
              items: cartItems,
            ),
        ),
      ],
      child: const _CheckoutView(),
    );
  }
}

class _CheckoutView extends StatelessWidget {
  const _CheckoutView();

  @override
  Widget build(BuildContext context) {
    final checkoutProvider =
    context.watch<CheckoutProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Text(
          'تسویه حساب',
          style: AppTextStyles.titleMedium,
        ),
      ),
      body: SafeArea(
        child: checkoutProvider.cartItems.isEmpty
            ? const _EmptyCheckout()
            : const SingleChildScrollView(
          child: Column(
            children: [
              _ProductsSection(),
              _AddressSection(),
              _ShippingSection(),
              _PaymentSection(),
              _SummarySection(),
              SizedBox(height: 110),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
      const _CheckoutBottomBar(),
    );
  }
}

class _ProductsSection extends StatelessWidget {
  const _ProductsSection();

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<CheckoutProvider>();

    return _CheckoutCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'محصولات سفارش',
            icon: Icons.shopping_bag_outlined,
          ),
          SizedBox(height: 12.h),
          ...provider.cartItems.map(
                (item) => _CartItemTile(
              item: item,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
  });

  final CartItemEntity item;

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    final price = product.finalPrice;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 12.h,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
            BorderRadius.circular(10.r),
            child: Image.network(
              product.thumbnail,
              width: 72.w,
              height: 72.w,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) {
                return Container(
                  width: 72.w,
                  height: 72.w,
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 26.sp,
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  AppTextStyles.product_prize,
                ),
                SizedBox(height: 6.h),
                Text(
                  '${_formatPrice(price)} تومان',
                  style:
                  AppTextStyles.second_title_section,
                ),
                SizedBox(height: 4.h),
                Text(
                  'تعداد: ${item.quantity}',
                  style:
                  AppTextStyles.otp_title,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressSection extends StatelessWidget {
  const _AddressSection();

  @override
  Widget build(BuildContext context) {
    final addressProvider =
    context.watch<AddressProvider>();

    final checkoutProvider =
    context.watch<CheckoutProvider>();

    if (addressProvider.isLoading) {
      return _CheckoutCard(
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              title: 'آدرس ارسال',
              icon: Icons.location_on_outlined,
            ),
            SizedBox(height: 16.h),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    final addresses =
        addressProvider.addresses;

    return _CheckoutCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'آدرس ارسال',
            icon: Icons.location_on_outlined,
          ),
          SizedBox(height: 12.h),
          if (addresses.isEmpty)
            Column(
              children: [
                Text(
                  'هنوز آدرسی ثبت نکرده‌اید.',
                  style:
                  AppTextStyles.body,
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _showAddressMessage(
                        context,
                      );
                    },
                    child: const Text(
                      'افزودن آدرس',
                    ),
                  ),
                ),
              ],
            )
          else
            ...addresses.map(
                  (address) {
                final selected =
                    checkoutProvider
                        .selectedAddress
                        ?.id ==
                        address.id;

                return _AddressTile(
                  address: address,
                  selected: selected,
                  onTap: () {
                    checkoutProvider
                        .setAddress(address);
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  void _showAddressMessage(
      BuildContext context,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'برای افزودن آدرس از بخش آدرس‌های حساب کاربری استفاده کنید.',
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final AddressEntity address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(
          bottom: 10.h,
        ),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(12.r),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected
                  ? AppColors.primary
                  : Colors.grey,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    address.title,
                    style:
                    AppTextStyles.section_title,
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    address.address,
                    style:
                    AppTextStyles.body,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShippingSection extends StatelessWidget {
  const _ShippingSection();

  @override
  Widget build(BuildContext context) {
    final shippingProvider =
    context.watch<ShippingProvider>();

    final checkoutProvider =
    context.watch<CheckoutProvider>();

    return _CheckoutCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'روش ارسال',
            icon: Icons.local_shipping_outlined,
          ),
          SizedBox(height: 12.h),
          if (shippingProvider.isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (shippingProvider.shippingMethods
              .isEmpty)
            Text(
              'روش ارسالی موجود نیست.',
              style:
              AppTextStyles.body,
            )
          else
            ...shippingProvider
                .shippingMethods
                .map(
                  (method) {
                final selected =
                    checkoutProvider
                        .selectedShippingMethod
                        ?.id ==
                        method.id;

                return _ShippingTile(
                  method: method,
                  selected: selected,
                  onTap: () {
                    shippingProvider
                        .selectShippingMethod(
                      method,
                    );

                    checkoutProvider
                        .setShippingMethod(
                      method,
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ShippingTile extends StatelessWidget {
  const _ShippingTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final ShippingMethodEntity method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(
          bottom: 10.h,
        ),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(12.r),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected
                  ? AppColors.primary
                  : Colors.grey,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    method.title,
                    style:
                    AppTextStyles.section_title,
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    '${_formatPrice(method.cost)} تومان',
                    style:
                    AppTextStyles.body,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection();

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<CheckoutProvider>();

    return _CheckoutCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'روش پرداخت',
            icon: Icons.payment_outlined,
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () {
              provider.setPaymentMethod(
                'online',
              );
            },
            child: Container(
              width: double.infinity,
              padding:
              EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(12.r),
                border: Border.all(
                  color:
                  provider.paymentMethod ==
                      'online'
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  width:
                  provider.paymentMethod ==
                      'online'
                      ? 1.5
                      : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    provider.paymentMethod ==
                        'online'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color:
                    provider.paymentMethod ==
                        'online'
                        ? AppColors.primary
                        : Colors.grey,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'پرداخت آنلاین',
                          style:
                          AppTextStyles.section_title,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'پرداخت امن از طریق درگاه زرین‌پال',
                          style:
                          AppTextStyles.body,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.credit_card_outlined,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection();

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<CheckoutProvider>();

    return _CheckoutCard(
      child: Column(
        children: [
          _SummaryRow(
            title: 'مجموع کالاها',
            value:
            '${_formatPrice(provider.subtotal)} تومان',
          ),
          SizedBox(height: 10.h),
          _SummaryRow(
            title: 'تخفیف',
            value:
            '${_formatPrice(provider.totalDiscount)} تومان',
            valueStyle: TextStyle(
              color: Colors.green,
              fontSize: 13.sp,
              fontWeight:
              FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          _SummaryRow(
            title: 'هزینه ارسال',
            value:
            '${_formatPrice(provider.shippingCost)} تومان',
          ),
          Padding(
            padding:
            EdgeInsets.symmetric(
              vertical: 12.h,
            ),
            child: Divider(
              color: Colors.grey.shade300,
              height: 1,
            ),
          ),
          _SummaryRow(
            title: 'مبلغ قابل پرداخت',
            value:
            '${_formatPrice(provider.totalPrice)} تومان',
            valueStyle:
            AppTextStyles.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.title,
    required this.value,
    this.valueStyle,
  });

  final String title;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style:
            AppTextStyles.body,
          ),
        ),
        Text(
          value,
          style: valueStyle ??
              AppTextStyles.body,
        ),
      ],
    );
  }
}

class _CheckoutBottomBar
    extends StatelessWidget {
  const _CheckoutBottomBar();

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<CheckoutProvider>();

    final user =
        Supabase.instance.client.auth.currentUser;

    final canSubmit =
        provider.canSubmit &&
            user != null;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        10.h,
        16.w,
        10.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, -3),
            color:
            Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            if (provider.error != null)
              Padding(
                padding:
                EdgeInsets.only(
                  bottom: 8.h,
                ),
                child: Text(
                  provider.error!,
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Text(
                        'مبلغ قابل پرداخت',
                        style:
                        AppTextStyles.body,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '${_formatPrice(provider.totalPrice)} تومان',
                        style:
                        AppTextStyles.titleMedium,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed:
                      !canSubmit
                          ? null
                          : () {
                        _startPayment(
                          context,
                        );
                      },
                      child:
                      provider.isLoading
                          ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child:
                        const CircularProgressIndicator(
                          strokeWidth:
                          2,
                          color:
                          Colors.white,
                        ),
                      )
                          : const Text(
                        'ادامه و پرداخت',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startPayment(
      BuildContext context,
      ) async {


    final user = Supabase.instance.client.auth.currentUser;
    debugPrint('========== CHECKOUT AUTH TEST ==========');
    debugPrint('CHECKOUT USER ID: ${user?.id}');
    debugPrint(
      'CHECKOUT SESSION: ${Supabase.instance.client.auth.currentSession != null}',
    );
    debugPrint('========================================');


    final provider =
    context.read<CheckoutProvider>();

    final result =
    await provider.createCheckout();

    if (!context.mounted) {
      return;
    }

    if (result == null) {
      return;
    }

    final uri =
    Uri.tryParse(
      result.paymentUrl,
    );

    if (uri == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'آدرس درگاه پرداخت نامعتبر است.',
          ),
        ),
      );

      return;
    }

    final launched =
    await launchUrl(
      uri,
      mode:
      LaunchMode.externalApplication,
    );

    if (!launched &&
        context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'امکان باز کردن درگاه پرداخت وجود ندارد.',
          ),
        ),
      );
    }
  }
}

class _CheckoutCard extends StatelessWidget {
  const _CheckoutCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: 8.h,
      ),
      padding: EdgeInsets.all(16.w),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22.sp,
          color: AppColors.primary,
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style:
          AppTextStyles.titleMedium,
        ),
      ],
    );
  }
}

class _EmptyCheckout
    extends StatelessWidget {
  const _EmptyCheckout();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              'سبد خرید شما خالی است.',
              style:
              AppTextStyles.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPrice(int price) {
  return price
      .toString()
      .replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
  );
}