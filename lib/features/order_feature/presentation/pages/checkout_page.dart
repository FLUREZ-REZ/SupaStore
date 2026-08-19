import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/constants/price_formatter.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';

import 'package:supastore/features/address_feature/presentation/pages/addresses_page.dart';
import 'package:supastore/features/address_feature/presentation/providers/address_provider.dart';

import 'package:supastore/features/cart_feature/domain/entities/cart_item_entity.dart';

import 'package:supastore/features/order_feature/presentation/pages/order_success_page.dart';
import 'package:supastore/features/order_feature/presentation/providers/checkout_provider.dart';

import 'package:supastore/features/shipping_feature/domain/entities/shipping_method_entity.dart';
import 'package:supastore/features/shipping_feature/presentation/providers/shipping_provider.dart';

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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AddressProvider>(
          create: (_) =>
          getIt<AddressProvider>()
            ..loadAddresses(
              userId: user.id,
            ),
        ),

        ChangeNotifierProvider<ShippingProvider>(
          create: (_) =>
          getIt<ShippingProvider>()
            ..loadShippingMethods(),
        ),

        ChangeNotifierProvider<CheckoutProvider>(
          create: (_) =>
          getIt<CheckoutProvider>()
            ..initialize(
              items: cartItems,
            ),
        ),
      ],
      child: _CheckoutView(
        userId: user.id,
      ),
    );
  }
}

// ============================================================
// CHECKOUT VIEW
// ============================================================

class _CheckoutView extends StatelessWidget {
  const _CheckoutView({
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context) {
    final checkoutProvider =
    context.watch<CheckoutProvider>();

    debugPrint(
      '========== CHECKOUT VIEW BUILD ==========',
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تکمیل سفارش',
          ),
          centerTitle: true,
        ),

        body: Stack(
          children: [
            ListView(
              padding: EdgeInsets.only(
                top: 12.h,
                bottom: 120.h,
              ),
              children: [
                // ==================================================
                // PRODUCTS
                // ==================================================

                const _SectionTitle(
                  title: 'محصولات سفارش',
                ),

                const _CheckoutItemsSection(),

                SizedBox(
                  height: 12.h,
                ),

                // ==================================================
                // ADDRESS
                // ==================================================

                const _SectionTitle(
                  title: 'آدرس ارسال',
                ),

                _AddressSection(
                  userId: userId,
                ),

                SizedBox(
                  height: 12.h,
                ),

                // ==================================================
                // SHIPPING
                // ==================================================

                const _SectionTitle(
                  title: 'روش ارسال',
                ),

                const _ShippingSection(),

                SizedBox(
                  height: 12.h,
                ),

                // ==================================================
                // PAYMENT
                // ==================================================

                const _SectionTitle(
                  title: 'روش پرداخت',
                ),

                const _PaymentSection(),

                SizedBox(
                  height: 12.h,
                ),

                // ==================================================
                // SUMMARY
                // ==================================================

                const _SectionTitle(
                  title: 'خلاصه سفارش',
                ),

                const _OrderSummary(),

                SizedBox(
                  height: 20.h,
                ),

                if (checkoutProvider.error != null)
                  _ErrorMessage(
                    message:
                    checkoutProvider.error!,
                  ),

                SizedBox(
                  height: 20.h,
                ),
              ],
            ),

            if (checkoutProvider.isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(
                    alpha: 0.15,
                  ),
                  child: const Center(
                    child:
                    CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),

        bottomNavigationBar:
        const _CheckoutBottomBar(),
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

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

// ============================================================
// CHECKOUT ITEMS
// ============================================================

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
              padding:
              EdgeInsets.symmetric(
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

                  SizedBox(
                    width: 12.w,
                  ),

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

                        SizedBox(
                          height: 6.h,
                        ),

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

                  SizedBox(
                    width: 8.w,
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

// ============================================================
// ADDRESS SECTION
// ============================================================

class _AddressSection
    extends StatelessWidget {
  const _AddressSection({
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context) {
    final addressProvider =
    context.watch<AddressProvider>();

    final checkoutProvider =
    context.watch<CheckoutProvider>();

    // ==========================================================
    // LOADING
    // ==========================================================

    if (addressProvider.isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16.w,
        ),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: const Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    // ==========================================================
    // EMPTY
    // ==========================================================

    if (addressProvider.isEmpty) {
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
            Icon(
              Icons.location_off_outlined,
              size: 42.sp,
              color: Colors.grey.shade500,
            ),

            SizedBox(
              height: 10.h,
            ),

            Text(
              'هنوز آدرسی ثبت نکرده‌اید',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight:
                FontWeight.w600,
              ),
            ),

            SizedBox(
              height: 6.h,
            ),

            Text(
              'برای ادامه سفارش ابتدا یک آدرس اضافه کنید.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color:
                Colors.grey.shade600,
              ),
            ),

            SizedBox(
              height: 14.h,
            ),

            SizedBox(
              width: double.infinity,
              height: 46.h,
              child:
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const AddressesPage(),
                    ),
                  );

                  if (!context.mounted) {
                    return;
                  }

                  await context
                      .read<
                      AddressProvider>()
                      .loadAddresses(
                    userId: userId,
                  );
                },
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  'افزودن آدرس',
                ),
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
                      12.r,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ==========================================================
    // ADDRESS LIST
    // ==========================================================

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
        children: [
          ...addressProvider.addresses.map(
                (address) {
              final isSelected =
                  checkoutProvider
                      .selectedAddress
                      ?.id ==
                      address.id;

              return Padding(
                padding:
                EdgeInsets.only(
                  bottom: 8.h,
                ),
                child: InkWell(
                  borderRadius:
                  BorderRadius.circular(
                    12.r,
                  ),
                  onTap: () {
                    context
                        .read<
                        CheckoutProvider>()
                        .setAddress(
                      address,
                    );
                  },
                  child: Container(
                    padding:
                    EdgeInsets.all(12.w),
                    decoration:
                    BoxDecoration(
                      color: isSelected
                          ? AppColors
                          .primary
                          .withValues(
                        alpha: 0.06,
                      )
                          : Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                        12.r,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? AppColors
                            .primary
                            : Colors
                            .grey
                            .shade200,
                        width: isSelected
                            ? 1.5
                            : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Radio<String>(
                          value:
                          address.id,
                          groupValue:
                          checkoutProvider
                              .selectedAddress
                              ?.id,
                          activeColor:
                          AppColors
                              .primary,
                          onChanged:
                              (_) {
                            context
                                .read<
                                CheckoutProvider>()
                                .setAddress(
                              address,
                            );
                          },
                        ),

                        SizedBox(
                          width: 4.w,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child:
                                    Text(
                                      address
                                          .title,
                                      style:
                                      TextStyle(
                                        fontSize:
                                        14.sp,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  if (address
                                      .isDefault)
                                    Container(
                                      padding:
                                      EdgeInsets
                                          .symmetric(
                                        horizontal:
                                        8.w,
                                        vertical:
                                        4.h,
                                      ),
                                      decoration:
                                      BoxDecoration(
                                        color: Colors
                                            .green
                                            .withValues(
                                          alpha:
                                          0.1,
                                        ),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                          8.r,
                                        ),
                                      ),
                                      child:
                                      Text(
                                        'پیش‌فرض',
                                        style:
                                        TextStyle(
                                          fontSize:
                                          10.sp,
                                          color:
                                          Colors.green,
                                          fontWeight:
                                          FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              SizedBox(
                                height: 6.h,
                              ),

                              Text(
                                address
                                    .receiverName,
                                style:
                                TextStyle(
                                  fontSize:
                                  12.sp,
                                  fontWeight:
                                  FontWeight
                                      .w600,
                                ),
                              ),

                              SizedBox(
                                height: 4.h,
                              ),

                              Text(
                                address.phone,
                                style:
                                TextStyle(
                                  fontSize:
                                  11.sp,
                                  color: Colors
                                      .grey
                                      .shade600,
                                ),
                              ),

                              SizedBox(
                                height: 6.h,
                              ),

                              Text(
                                '${address.province}، ${address.city}',
                                style:
                                TextStyle(
                                  fontSize:
                                  11.sp,
                                  color: Colors
                                      .grey
                                      .shade700,
                                ),
                              ),

                              SizedBox(
                                height: 4.h,
                              ),

                              Text(
                                address.address,
                                maxLines: 3,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                                style:
                                TextStyle(
                                  fontSize:
                                  12.sp,
                                  color: Colors
                                      .grey
                                      .shade700,
                                  height: 1.5,
                                ),
                              ),

                              SizedBox(
                                height: 4.h,
                              ),

                              Text(
                                'کد پستی: ${address.postalCode}',
                                style:
                                TextStyle(
                                  fontSize:
                                  11.sp,
                                  color: Colors
                                      .grey
                                      .shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(
            height: 4.h,
          ),

          SizedBox(
            width: double.infinity,
            child:
            OutlinedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const AddressesPage(),
                  ),
                );

                if (!context.mounted) {
                  return;
                }

                await context
                    .read<AddressProvider>()
                    .loadAddresses(
                  userId: userId,
                );

                if (!context.mounted) {
                  return;
                }

                final updatedProvider =
                context.read<
                    AddressProvider>();

                final selected =
                    updatedProvider
                        .selectedAddress;

                if (selected != null) {
                  context
                      .read<
                      CheckoutProvider>()
                      .setAddress(
                    selected,
                  );
                }
              },
              icon: const Icon(
                Icons
                    .edit_location_alt_outlined,
              ),
              label: const Text(
                'مدیریت آدرس‌ها',
              ),
              style:
              OutlinedButton.styleFrom(
                foregroundColor:
                AppColors.primary,
                side: BorderSide(
                  color:
                  AppColors.primary,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    12.r,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SHIPPING SECTION
// ============================================================

class _ShippingSection
    extends StatelessWidget {
  const _ShippingSection();

  @override
  Widget build(BuildContext context) {
    final shippingProvider =
    context.watch<ShippingProvider>();

    final checkoutProvider =
    context.watch<CheckoutProvider>();

    // ==========================================================
    // LOADING
    // ==========================================================

    if (shippingProvider.isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16.w,
        ),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: const Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    // ==========================================================
    // ERROR
    // ==========================================================

    if (shippingProvider.error != null) {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16.w,
        ),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius:
          BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.red.shade100,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons
                  .error_outline,
              color:
              Colors.red.shade600,
              size: 40.sp,
            ),

            SizedBox(
              height: 8.h,
            ),

            Text(
              shippingProvider.error!,
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color:
                Colors.red.shade700,
              ),
            ),

            SizedBox(
              height: 12.h,
            ),

            OutlinedButton(
              onPressed:
              shippingProvider
                  .refresh,
              child: const Text(
                'تلاش مجدد',
              ),
            ),
          ],
        ),
      );
    }

    // ==========================================================
    // EMPTY
    // ==========================================================

    if (!shippingProvider.hasShippingMethods) {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16.w,
        ),
        padding: EdgeInsets.all(20.w),
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
            Icon(
              Icons
                  .local_shipping_outlined,
              size: 42.sp,
              color:
              Colors.grey.shade500,
            ),

            SizedBox(
              height: 10.h,
            ),

            const Text(
              'روش ارسالی موجود نیست',
            ),

            SizedBox(
              height: 12.h,
            ),

            OutlinedButton(
              onPressed:
              shippingProvider
                  .refresh,
              child: const Text(
                'تلاش مجدد',
              ),
            ),
          ],
        ),
      );
    }

    // ==========================================================
    // SHIPPING METHODS
    // ==========================================================

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      padding: EdgeInsets.symmetric(
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: shippingProvider
            .shippingMethods
            .map(
              (method) {
            final isSelected =
                shippingProvider
                    .selectedShippingMethod
                    ?.id ==
                    method.id;

            return _ShippingMethodTile(
              method: method,
              isSelected:
              isSelected,
              onTap: () {
                shippingProvider
                    .selectShippingMethod(
                  method,
                );

                checkoutProvider
                    .setShippingCost(
                  method.cost,
                );
              },
            );
          },
        )
            .toList(),
      ),
    );
  }
}

// ============================================================
// SHIPPING METHOD TILE
// ============================================================

class _ShippingMethodTile
    extends StatelessWidget {
  const _ShippingMethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  final ShippingMethodEntity method;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: 4.h,
        ),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              .withValues(
            alpha: 0.06,
          )
              : Colors.white,
          borderRadius:
          BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.grey.shade200,
            width:
            isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: method.id,
              groupValue: isSelected
                  ? method.id
                  : null,
              activeColor:
              AppColors.primary,
              onChanged: (_) {
                onTap();
              },
            ),

            SizedBox(
              width: 4.w,
            ),

            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                BorderRadius.circular(
                  10.r,
                ),
              ),
              child: Icon(
                Icons
                    .local_shipping_outlined,
                color:
                AppColors.primary,
              ),
            ),

            SizedBox(
              width: 12.w,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    method.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  if (method.description !=
                      null &&
                      method.description!
                          .isNotEmpty) ...[
                    SizedBox(
                      height: 4.h,
                    ),
                    Text(
                      method.description!,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors
                            .grey
                            .shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(
              width: 8.w,
            ),

            Text(
              method.cost == 0
                  ? 'رایگان'
                  : PriceFormatter.format(
                method.cost,
              ),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight:
                FontWeight.bold,
                color: method.cost == 0
                    ? Colors.green
                    : AppColors.price,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PAYMENT SECTION
// ============================================================

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

// ============================================================
// ORDER SUMMARY
// ============================================================

class _OrderSummary
    extends StatelessWidget {
  const _OrderSummary();

  @override
  Widget build(BuildContext context) {
    final checkoutProvider =
    context.watch<CheckoutProvider>();

    final shippingProvider =
    context.watch<ShippingProvider>();

    final shippingCost =
        shippingProvider
            .selectedShippingMethod
            ?.cost ??
            0;

    final totalPrice =
        checkoutProvider.subtotal -
            checkoutProvider.totalDiscount +
            shippingCost;

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
            value:
            checkoutProvider
                .subtotal,
          ),

          SizedBox(
            height: 10.h,
          ),

          _SummaryRow(
            title: 'تخفیف',
            value:
            checkoutProvider
                .totalDiscount,
            isDiscount: true,
          ),

          SizedBox(
            height: 10.h,
          ),

          _SummaryRow(
            title: 'هزینه ارسال',
            value: shippingCost,
          ),

          Divider(
            height: 24.h,
          ),

          _SummaryRow(
            title: 'مبلغ قابل پرداخت',
            value: totalPrice,
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUMMARY ROW
// ============================================================

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
            fontWeight: isTotal
                ? FontWeight.bold
                : FontWeight.normal,
            color: isDiscount
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
            color: isDiscount
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

// ============================================================
// CHECKOUT BOTTOM BAR
// ============================================================

class _CheckoutBottomBar
    extends StatelessWidget {
  const _CheckoutBottomBar();

  @override
  Widget build(BuildContext context) {
    final checkoutProvider =
    context.watch<CheckoutProvider>();

    final shippingProvider =
    context.watch<ShippingProvider>();

    debugPrint(
      '========== BOTTOM BAR BUILD ==========',
    );

    final user =
        Supabase.instance.client.auth.currentUser;

    final selectedShipping =
        shippingProvider
            .selectedShippingMethod;

    final canSubmit =
        checkoutProvider.canSubmit &&
            selectedShipping != null &&
            !shippingProvider.isLoading;

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
            color:
            Colors.black.withValues(
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
            canSubmit &&
                user != null
                ? () async {
              // ==========================================
              // SYNC SHIPPING COST
              // ==========================================

              checkoutProvider
                  .setShippingCost(
                selectedShipping
                    .cost,
              );

              debugPrint(
                '========== CHECKOUT TEST START ==========',
              );

              debugPrint(
                'Selected shipping: ${selectedShipping.title}',
              );

              debugPrint(
                'Shipping cost: ${selectedShipping.cost}',
              );

              debugPrint(
                'Provider runtime type: ${checkoutProvider.runtimeType}',
              );

              debugPrint(
                'Provider hash: ${checkoutProvider.hashCode}',
              );

              debugPrint(
                'Provider canSubmit: ${checkoutProvider.canSubmit}',
              );

              // ==========================================
              // PLACE ORDER
              // ==========================================

              final success =
              await checkoutProvider
                  .placeOrder(
                userId:
                user.id,
              );

              debugPrint(
                'TEST: placeOrder returned',
              );

              debugPrint(
                'success: $success',
              );

              debugPrint(
                'provider.isLoading: ${checkoutProvider.isLoading}',
              );

              debugPrint(
                'provider.error: ${checkoutProvider.error}',
              );

              debugPrint(
                'provider.order: ${checkoutProvider.order}',
              );

              debugPrint(
                'BOTTOM BAR AFTER AWAIT - mounted: ${context.mounted}',
              );

              if (!context.mounted) {
                debugPrint(
                  'Context is NOT mounted',
                );
                return;
              }

              if (!success) {
                debugPrint(
                  'ORDER FAILED',
                );

                ScaffoldMessenger
                    .of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      checkoutProvider
                          .error ??
                          'ثبت سفارش ناموفق بود',
                    ),
                  ),
                );

                debugPrint(
                  '========== CHECKOUT TEST END ==========',
                );

                return;
              }

              final order =
                  checkoutProvider
                      .order;

              debugPrint(
                'ORDER SUCCESS',
              );

              debugPrint(
                'order == null: ${order == null}',
              );

              if (order == null) {
                ScaffoldMessenger
                    .of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'سفارش ثبت شد اما اطلاعات آن دریافت نشد.',
                    ),
                  ),
                );

                debugPrint(
                  '========== CHECKOUT TEST END ==========',
                );

                return;
              }

              debugPrint(
                'Navigating to OrderSuccessPage',
              );

              debugPrint(
                'order.id: ${order.id}',
              );

              Navigator.of(context)
                  .pushReplacement(
                MaterialPageRoute(
                  builder: (_) =>
                      OrderSuccessPage(
                        order: order,
                      ),
                ),
              );

              debugPrint(
                'pushReplacement CALLED',
              );

              debugPrint(
                '========== CHECKOUT TEST END ==========',
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

// ============================================================
// ERROR MESSAGE
// ============================================================

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
        textAlign:
        TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          color:
          Colors.red.shade700,
        ),
      ),
    );
  }
}