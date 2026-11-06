
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';

import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';
import 'package:supastore/features/cart_feature/presentation/widgets/cart_item.dart';
import 'package:supastore/features/cart_feature/presentation/widgets/cart_summary.dart';
import 'package:supastore/features/order_feature/presentation/pages/checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late final CartProvider _cartProvider;

  bool _minimumLoadingFinished = false;

  @override
  void initState() {
    super.initState();

    _cartProvider = getIt<CartProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCart();
    });
  }

  Future<void> _loadCart() async {
    final stopwatch = Stopwatch()..start();

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        await _cartProvider.loadCart(user.id);
      }
    } finally {
      final elapsed = stopwatch.elapsed;
      const minimumDuration = Duration(seconds: 1);

      if (elapsed < minimumDuration) {
        await Future.delayed(minimumDuration - elapsed);
      }

      if (mounted) {
        setState(() {
          _minimumLoadingFinished = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F8F8),
        body: Center(
          child: Text('لطفاً ابتدا وارد حساب کاربری شوید'),
        ),
      );
    }

    return ChangeNotifierProvider<CartProvider>.value(
      value: _cartProvider,
      child: _CartView(
        minimumLoadingFinished: _minimumLoadingFinished,
      ),
    );
  }
}

// ============================================================
// CART VIEW
// ============================================================

class _CartView extends StatelessWidget {
  final bool minimumLoadingFinished;

  const _CartView({
    required this.minimumLoadingFinished,
  });

  static const Color _backgroundColor = Color(0xFFF7F7F7);
  static const Color _desktopBackground = Color(0xFFF7F7F8);
  static const double _desktopBreakpoint = 1000;
  static const double _maxContentWidth = 1450;

  void _goToCheckout(
      BuildContext context,
      CartProvider provider,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(
          cartItems: provider.items,
        ),
      ),
    );
  }

  Widget _buildCartItems(
      BuildContext context,
      CartProvider provider,
      bool isDesktop,
      ) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: 8,
        bottom: isDesktop ? 20 : 20,
        left: isDesktop ? 12 : 0,
        right: isDesktop ? 12 : 0,
      ),
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        final item = provider.items[index];

        return CartItem(
          item: item,
          onIncrease: () {
            provider.increaseQuantity(item);
          },
          onDecrease: () {
            provider.decreaseQuantity(item);
          },
          onRemove: () {
            provider.removeFromCart(item.id);
          },
        );
      },
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context,
      CartProvider provider,
      BoxConstraints constraints,
      ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: _maxContentWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // محصولات سبد خرید - سمت راست
              Expanded(
                flex: 7,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEFEFEF),
                    ),
                  ),
                  child: _buildCartItems(
                    context,
                    provider,
                    true,
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // خلاصه سفارش - سمت چپ
              SizedBox(
                width: constraints.maxWidth >= 1250 ? 340 : 300,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEFEFEF),
                    ),
                  ),
                  child: CartSummary(
                    onCheckout: () {
                      _goToCheckout(context, provider);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context,
      CartProvider provider,
      ) {
    return Column(
      children: [
        Expanded(
          child: _buildCartItems(
            context,
            provider,
            false,
          ),
        ),
        CartSummary(
          onCheckout: () {
            _goToCheckout(context, provider);
          },
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
      BuildContext context,
      CartProvider provider,
      ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 850,
        ),
        child: Column(
          children: [
            Expanded(
              child: _buildCartItems(
                context,
                provider,
                false,
              ),
            ),
            CartSummary(
              onCheckout: () {
                _goToCheckout(context, provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      CartProvider provider,
      BoxConstraints constraints,
      ) {
    final width = constraints.maxWidth;

    final bool isDesktop = width >= _desktopBreakpoint;
    final bool isTablet = width >= 600 && width < _desktopBreakpoint;

    final showShimmer =
        provider.isLoading || !minimumLoadingFinished;

    if (showShimmer) {
      return Column(
        children: [
          const Expanded(
            child: _CartShimmerList(),
          ),
          const _CartSummaryShimmer(),
        ],
      );
    }

    if (provider.error != null && provider.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
      );
    }

    if (provider.items.isEmpty) {
      return const _EmptyCart();
    }

    if (isDesktop) {
      return _buildDesktopLayout(
        context,
        provider,
        constraints,
      );
    }

    if (isTablet) {
      return _buildTabletLayout(
        context,
        provider,
      );
    }

    return _buildMobileLayout(
      context,
      provider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.cart_page_redi,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,

        ),
        body: Consumer<CartProvider>(
          builder: (context, provider, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return _buildBody(
                  context,
                  provider,
                  constraints,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// CART LIST SHIMMER
// ============================================================

class _CartShimmerList extends StatefulWidget {
  const _CartShimmerList();

  @override
  State<_CartShimmerList> createState() =>
      _CartShimmerListState();
}

class _CartShimmerListState extends State<_CartShimmerList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1000;
            final horizontalPadding = isDesktop ? 24.0 : 12.0;

            return ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: 8,
                bottom: 20,
                left: horizontalPadding,
                right: horizontalPadding,
              ),
              children: List.generate(
                isDesktop ? 5 : 4,
                    (index) => _CartShimmerCard(
                  progress: _controller.value,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================================
// CART SHIMMER CARD
// ============================================================

class _CartShimmerCard extends StatelessWidget {
  final double progress;

  const _CartShimmerCard({
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 380;

        final imageSize = isNarrow ? 82.0 : 100.0;

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 6,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFF0F0F0),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBlock(
                progress: progress,
                width: imageSize,
                height: imageSize + 12,
                radius: 10,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 3),
                    _ShimmerBlock(
                      progress: progress,
                      width: double.infinity,
                      height: 13,
                      radius: 5,
                    ),
                    const SizedBox(height: 9),
                    _ShimmerBlock(
                      progress: progress,
                      width: 125,
                      height: 11,
                      radius: 5,
                    ),
                    const SizedBox(height: 17),
                    _ShimmerBlock(
                      progress: progress,
                      width: 90,
                      height: 14,
                      radius: 5,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        _ShimmerBlock(
                          progress: progress,
                          width: 27,
                          height: 27,
                          radius: 7,
                        ),
                        const SizedBox(width: 8),
                        _ShimmerBlock(
                          progress: progress,
                          width: 20,
                          height: 13,
                          radius: 4,
                        ),
                        const SizedBox(width: 8),
                        _ShimmerBlock(
                          progress: progress,
                          width: 27,
                          height: 27,
                          radius: 7,
                        ),
                        const Spacer(),
                        _ShimmerBlock(
                          progress: progress,
                          width: 25,
                          height: 25,
                          radius: 7,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// CART SUMMARY SHIMMER
// ============================================================

class _CartSummaryShimmer extends StatefulWidget {
  const _CartSummaryShimmer();

  @override
  State<_CartSummaryShimmer> createState() =>
      _CartSummaryShimmerState();
}

class _CartSummaryShimmerState
    extends State<_CartSummaryShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            20,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _ShimmerBlock(
                    progress: _controller.value,
                    width: 95,
                    height: 13,
                    radius: 5,
                  ),
                  const Spacer(),
                  _ShimmerBlock(
                    progress: _controller.value,
                    width: 105,
                    height: 13,
                    radius: 5,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ShimmerBlock(
                    progress: _controller.value,
                    width: 75,
                    height: 12,
                    radius: 5,
                  ),
                  const Spacer(),
                  _ShimmerBlock(
                    progress: _controller.value,
                    width: 85,
                    height: 12,
                    radius: 5,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ShimmerBlock(
                progress: _controller.value,
                width: double.infinity,
                height: 48,
                radius: 12,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// REUSABLE SHIMMER BLOCK
// ============================================================

class _ShimmerBlock extends StatelessWidget {
  final double progress;
  final double width;
  final double height;
  final double radius;

  const _ShimmerBlock({
    required this.progress,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment(-1.5 + (3 * progress), 0),
            end: Alignment(-0.5 + (3 * progress), 0),
            colors: const [
              Color(0xFFEAEAEA),
              Color(0xFFF8F8F8),
              Color(0xFFEAEAEA),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFEAEAEA),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY CART
// ============================================================

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 420,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.cart_page_redi,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Icon(
                  Iconsax.shopping_cart_copy,
                  size: 42,
                  color: AppColors.cart_page_white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'سبد خرید شما خالی است',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'محصولات موردنظر خود را به سبد خرید اضافه کنید.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
