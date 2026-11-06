
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/features/favorite_feature/presentation/providers/favorite_provider.dart';
import 'package:supastore/features/product_feature/presentation/widgets/product_card.dart';

// =============================================================
// FAVORITES PAGE
// =============================================================

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'لطفاً ابتدا وارد حساب کاربری شوید',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => getIt<FavoriteProvider>()
        ..loadFavorites(userId: user.id),
      child: const _FavoritesView(),
    );
  }
}

// =============================================================
// FAVORITES VIEW
// =============================================================

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavoriteProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: AppColors.favorite_page_redi,
          foregroundColor: Colors.white,
          title: const Text('علاقه‌مندی‌های من' , style: TextStyle(color: Colors.white),),
          centerTitle: true,
        ),
        body: _buildBody(context, provider),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      FavoriteProvider provider,
      ) {
    if (provider.isLoading) {
      return const _FavoritesShimmer();
    }

    if (provider.error != null) {
      return _FavoritesError(
        error: provider.error!,
        onRetry: () {
          final user = Supabase.instance.client.auth.currentUser;

          if (user == null) return;

          provider.loadFavorites(userId: user.id);
        },
      );
    }

    if (provider.favoriteProducts.isEmpty) {
      return const _EmptyFavorites();
    }

    return RefreshIndicator(
      onRefresh: () async {
        final user = Supabase.instance.client.auth.currentUser;

        if (user == null) return;

        await provider.loadFavorites(userId: user.id);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final columns = _getColumnCount(width);
          final aspectRatio = _getCardAspectRatio(width);
          final maxWidth = _getMaxContentWidth(width);

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
              ),
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  30,
                ),
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: provider.favoriteProducts.length,
                itemBuilder: (context, index) {
                  final product = provider.favoriteProducts[index];

                  return ProductCard(
                    product: product,
                    onTap: () {
                      context.pushNamed(
                        'product-details',
                        extra: product,
                      );
                    },
                    onFavorite: () async {
                      final user =
                          Supabase.instance.client.auth.currentUser;

                      if (user == null) return;

                      await provider.toggleFavorite(
                        userId: user.id,
                        productId: product.id,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================
// RESPONSIVE GRID HELPERS
// =============================================================

int _getColumnCount(double width) {
  if (width < 600) {
    return 2;
  } else if (width < 900) {
    return 3;
  } else if (width < 1200) {
    return 4;
  } else if (width < 1550) {
    return 5;
  } else {
    return 6;
  }
}

double _getCardAspectRatio(double width) {
  if (width < 600) {
    return 0.38;
  } else if (width < 900) {
    return 0.48;
  } else if (width < 1200) {
    return 0.46;
  } else {
    return 0.58;
  }
}

double _getMaxContentWidth(double width) {
  if (width >= 1550) {
    return 1450;
  }

  if (width >= 900) {
    return 1250;
  }

  return double.infinity;
}

// =============================================================
// FAVORITES ERROR
// =============================================================

class _FavoritesError extends StatelessWidget {
  const _FavoritesError({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 55,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: onRetry,
                      child: const Text('تلاش مجدد'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================
// FAVORITES SHIMMER
// =============================================================

class _FavoritesShimmer extends StatefulWidget {
  const _FavoritesShimmer();

  @override
  State<_FavoritesShimmer> createState() =>
      _FavoritesShimmerState();
}

class _FavoritesShimmerState extends State<_FavoritesShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();

    _animation = Tween<double>(
      begin: -1.5,
      end: 2.5,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final columns = _getColumnCount(width);
            final aspectRatio = _getCardAspectRatio(width);
            final maxWidth = _getMaxContentWidth(width);

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                ),
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    30,
                  ),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return LayoutBuilder(
                      builder: (context, cardConstraints) {
                        return _FavoriteProductShimmer(
                          animationValue: _animation.value,
                          cardWidth: cardConstraints.maxWidth,
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// =============================================================
// FAVORITE PRODUCT SHIMMER
// =============================================================

class _FavoriteProductShimmer extends StatelessWidget {
  const _FavoriteProductShimmer({
    required this.animationValue,
    required this.cardWidth,
  });

  final double animationValue;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PRODUCT IMAGE
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: double.infinity,
                  child: _ShimmerBox(
                    animationValue: animationValue,
                    height: double.infinity,
                    radius: 10,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // PRODUCT TITLE
            _ShimmerBox(
              animationValue: animationValue,
              width: double.infinity,
              height: 12,
              radius: 5,
            ),

            const SizedBox(height: 7),

            _ShimmerBox(
              animationValue: animationValue,
              width: cardWidth * 0.72,
              height: 10,
              radius: 5,
            ),

            const Spacer(),

            // RATING OR SHORT DESCRIPTION
            _ShimmerBox(
              animationValue: animationValue,
              width: cardWidth * 0.35,
              height: 10,
              radius: 5,
            ),

            const SizedBox(height: 10),

            // PRODUCT PRICE
            Row(
              children: [
                Expanded(
                  child: _ShimmerBox(
                    animationValue: animationValue,
                    height: 15,
                    radius: 5,
                  ),
                ),
                const SizedBox(width: 8),
                _ShimmerBox(
                  animationValue: animationValue,
                  width: 30,
                  height: 20,
                  radius: 6,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // BOTTOM AREA
            _ShimmerBox(
              animationValue: animationValue,
              width: cardWidth * 0.45,
              height: 9,
              radius: 5,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// SHIMMER BOX
// =============================================================

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.animationValue,
    this.width,
    required this.height,
    this.radius = 6,
  });

  final double animationValue;
  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment(animationValue - 1, 0),
          end: Alignment(animationValue, 0),
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
            Colors.grey.shade300,
          ],
        ),
      ),
    );
  }
}

// =============================================================
// EMPTY FAVORITES
// =============================================================

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 420,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.heart_copy,
                          size: 60,
                          color: Colors.red.shade300,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'هنوز محصولی را به علاقه‌مندی‌ها اضافه نکرده‌اید',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'محصولات مورد علاقه خود را با زدن قلب ذخیره کنید.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 180,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            context.pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('بازگشت به فروشگاه'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
