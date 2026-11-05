import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/admin_feature/dashboard/domain/entities/admin_dashboard_entity.dart';
import 'package:supastore/features/admin_feature/dashboard/presentaion/providers/admin_dashboard_provider.dart';
import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';

// ============================================================
// RESPONSIVE HELPERS
// ============================================================

extension _DashboardResponsiveUnits on num {
  double get w => toDouble();
  double get h => toDouble();
  double get sp => toDouble();
  double get r => toDouble();
}

class _DashboardBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1100;
}

bool _isTablet(double width) {
  return width >= _DashboardBreakpoints.mobile &&
      width < _DashboardBreakpoints.desktop;
}

bool _isDesktop(double width) {
  return width >= _DashboardBreakpoints.desktop;
}

int _statsColumns(double width) {
  if (width >= _DashboardBreakpoints.desktop) return 4;
  if (width >= _DashboardBreakpoints.mobile) return 2;
  return 2;
}

// ============================================================
// DASHBOARD SHIMMER
// ============================================================

class _DashboardShimmer extends StatefulWidget {
  const _DashboardShimmer();

  @override
  State<_DashboardShimmer> createState() => _DashboardShimmerState();
}

class _DashboardShimmerState extends State<_DashboardShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = _statsColumns(width);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(width < 600 ? 12 : 20),
                children: [
                  const SizedBox(height: 6),
                  _DashboardSkeletonBox(
                    animation: _controller,
                    width: 175,
                    height: 22,
                  ),
                  const SizedBox(height: 10),
                  _DashboardSkeletonBox(
                    animation: _controller,
                    width: 220,
                    height: 14,
                  ),
                  const SizedBox(height: 20),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: width >= 1100 ? 1.8 : 1.5,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF023e8a),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _DashboardSkeletonBox(
                              animation: _controller,
                              width: 27,
                              height: 27,
                            ),
                            _DashboardSkeletonBox(
                              animation: _controller,
                              width: 75,
                              height: 12,
                            ),
                            _DashboardSkeletonBox(
                              animation: _controller,
                              width: 100,
                              height: 17,
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  _DashboardSkeletonSection(
                    animation: _controller,
                    height: 320,
                    titleWidth: 135,
                    subtitleWidth: 160,
                    child: SizedBox(
                      height: 195,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          70.0,
                          110.0,
                          90.0,
                          150.0,
                          120.0,
                          175.0,
                          135.0,
                        ].map((barHeight) {
                          return _DashboardSkeletonBox(
                            animation: _controller,
                            width: 18,
                            height: barHeight,
                            radius: 5,
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _DashboardSkeletonSection(
                    animation: _controller,
                    height: 250,
                    titleWidth: 175,
                    rowCount: 3,
                  ),

                  const SizedBox(height: 20),

                  _DashboardSkeletonSection(
                    animation: _controller,
                    height: 250,
                    titleWidth: 105,
                    rowCount: 3,
                    showThumbnail: true,
                  ),

                  const SizedBox(height: 20),

                  _DashboardSkeletonSection(
                    animation: _controller,
                    height: 255,
                    titleWidth: 140,
                    rowCount: 5,
                    compactRows: true,
                  ),

                  const SizedBox(height: 20),

                  _DashboardSkeletonSection(
                    animation: _controller,
                    height: 245,
                    titleWidth: 130,
                    rowCount: 3,
                    showThumbnail: true,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DashboardSkeletonSection extends StatelessWidget {
  const _DashboardSkeletonSection({
    required this.animation,
    required this.height,
    required this.titleWidth,
    this.subtitleWidth,
    this.rowCount = 0,
    this.showThumbnail = false,
    this.compactRows = false,
    this.child,
  });

  final Animation<double> animation;
  final double height;
  final double titleWidth;
  final double? subtitleWidth;
  final int rowCount;
  final bool showThumbnail;
  final bool compactRows;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFCAF0F8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardSkeletonBox(
            animation: animation,
            width: titleWidth,
            height: 19,
          ),
          if (subtitleWidth != null) ...[
            const SizedBox(height: 8),
            _DashboardSkeletonBox(
              animation: animation,
              width: subtitleWidth!,
              height: 12,
            ),
          ],
          if (child != null) ...[
            const Spacer(),
            child!,
          ],
          if (rowCount > 0) ...[
            const SizedBox(height: 20),
            ...List.generate(rowCount, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: compactRows ? 15 : 12,
                ),
                child: Row(
                  children: [
                    if (showThumbnail) ...[
                      _DashboardSkeletonBox(
                        animation: animation,
                        width: 43,
                        height: 43,
                        radius: 10,
                      ),
                      const SizedBox(width: 10),
                    ] else if (!compactRows) ...[
                      _DashboardSkeletonBox(
                        animation: animation,
                        width: 32,
                        height: 32,
                        radius: 8,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: _DashboardSkeletonBox(
                        animation: animation,
                        width: double.infinity,
                        height: compactRows ? 12 : 14,
                        radius: 4,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _DashboardSkeletonBox(
                      animation: animation,
                      width: compactRows ? 28 : 48,
                      height: compactRows ? 13 : 25,
                      radius: 6,
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _DashboardSkeletonBox extends StatelessWidget {
  const _DashboardSkeletonBox({
    required this.animation,
    required this.width,
    required this.height,
    this.radius = 6,
  });

  final Animation<double> animation;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final start = -1.5 + animation.value * 3;

          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(start, 0),
                end: Alignment(start + 1, 0),
                colors: const [
                  Color(0xFFDCEAF0),
                  Color(0xFFF8FCFD),
                  Color(0xFFDCEAF0),
                ],
                stops: const [0, 0.5, 1],
              ).createShader(bounds);
            },
            child: Container(
              width: width,
              height: height,
              color: const Color(0xFFDCEAF0),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// DASHBOARD PAGE
// ============================================================

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminDashboardProvider>(
      create: (_) => getIt<AdminDashboardProvider>()..loadDashboard(),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && !provider.hasData) {
          return const _DashboardShimmer();
        }

        if (provider.error != null && !provider.hasData) {
          return _ErrorView(
            message: provider.error!,
            onRetry: provider.loadDashboard,
          );
        }

        final dashboard = provider.dashboard;

        if (dashboard == null) {
          return _ErrorView(
            message: 'اطلاعات داشبورد موجود نیست.',
            onRetry: provider.loadDashboard,
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final desktop = _isDesktop(width);

            final horizontalPadding = width < 600
                ? 12.0
                : width < 1100
                ? 20.0
                : 28.0;

            return RefreshIndicator(
              onRefresh: provider.refreshDashboard,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 16,
                  ),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 1440,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 6),

                            const Text(
                              'خلاصه وضعیت فروشگاه',
                              style: TextStyle(
                                color: Color(0xFF03045E),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              'نمای کلی عملکرد فروشگاه',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 20),

                            _StatsGrid(
                              dashboard: dashboard,
                            ),

                            const SizedBox(height: 22),

                            if (desktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: _SalesChartCard(
                                      salesByDay: dashboard.salesByDay,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    flex: 2,
                                    child: _ActionOrdersCard(
                                      orders: dashboard.actionOrders,
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              _SalesChartCard(
                                salesByDay: dashboard.salesByDay,
                              ),
                              const SizedBox(height: 18),
                              _ActionOrdersCard(
                                orders: dashboard.actionOrders,
                              ),
                            ],

                            const SizedBox(height: 20),

                            if (desktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _LowStockProductsCard(
                                      products: dashboard.lowStockProducts,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: _OrderStatusCard(
                                      dashboard: dashboard,
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              _LowStockProductsCard(
                                products: dashboard.lowStockProducts,
                              ),
                              const SizedBox(height: 18),
                              _OrderStatusCard(
                                dashboard: dashboard,
                              ),
                            ],

                            const SizedBox(height: 20),

                            _RecentOrdersCard(
                              orders: dashboard.recentOrders,
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
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
// STATS
// ============================================================

class _StatsGrid extends StatefulWidget {
  const _StatsGrid({
    required this.dashboard,
  });

  final AdminDashboardEntity dashboard;

  @override
  State<_StatsGrid> createState() => _StatsGridState();
}

class _StatsGridState extends State<_StatsGrid> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final dashboard = widget.dashboard;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _statsColumns(constraints.maxWidth);
        final aspectRatio = constraints.maxWidth >= 1100 ? 1.9 : 1.55;

        Widget buildGrid(List<Widget> cards) {
          return GridView.count(
            crossAxisCount: columns,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: aspectRatio,
            children: cards,
          );
        }

        return Column(
          children: [
            buildGrid([
              _StatCard(
                title: 'فروش امروز',
                value: '${_formatPrice(dashboard.todaySales)} تومان',
                icon: Iconsax.card_copy,
              ),
              _StatCard(
                title: 'سفارش‌ها',
                value: _formatNumber(dashboard.periodOrders),
                icon: Iconsax.box_copy,
              ),
              _StatCard(
                title: 'محصولات',
                value: _formatNumber(dashboard.totalProducts),
                icon: Iconsax.shop_copy,
              ),
              _StatCard(
                title: 'کاربران',
                value: _formatNumber(dashboard.totalUsers),
                icon: Iconsax.people_copy,
              ),
            ]),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Padding(
                padding: const EdgeInsets.only(top: 12),
                child: buildGrid([
                  _StatCard(
                    title: 'سفارش امروز',
                    value: _formatNumber(dashboard.todayOrders),
                    icon: Iconsax.receipt_copy,
                  ),
                  _StatCard(
                    title: 'فروش ۷ روز اخیر',
                    value: '${_formatPrice(dashboard.periodSales)} تومان',
                    icon: Iconsax.trend_up_copy,
                  ),
                ]),
              )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 8),

            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isExpanded ? 'نمایش کمتر' : 'نمایش بیشتر',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 3),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 23,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFCAF0F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            size: 27,
            color: const Color(0xFF03045E),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SALES CHART
// ============================================================

class _SalesChartCard extends StatelessWidget {
  const _SalesChartCard({
    required this.salesByDay,
  });

  final List<AdminSalesDayEntity> salesByDay;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartHeight = constraints.maxWidth < 400 ? 220.0 : 250.0;
        final barWidth = constraints.maxWidth < 400 ? 15.0 : 22.0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF03045E),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'فروش ۷ روز اخیر',
                style: TextStyle(
                  color: Color(0xFFCAF0F8),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'میزان فروش روزانه',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFCAF0F8),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: chartHeight,
                child: salesByDay.isEmpty
                    ? const Center(
                  child: Text(
                    'داده‌ای برای نمایش وجود ندارد.',
                    style: TextStyle(
                      color: Color(0xFFCAF0F8),
                      fontSize: 12,
                    ),
                  ),
                )
                    : BarChart(
                  BarChartData(
                    minY: 0,
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxY(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _getInterval(),
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.white.withOpacity(0.12),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          interval: _getInterval(),
                          getTitlesWidget: (value, meta) {
                            return Text(
                              _compactPricePersian(value),
                              style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFFCAF0F8),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();

                            if (index < 0 ||
                                index >= salesByDay.length) {
                              return const SizedBox.shrink();
                            }

                            final date = salesByDay[index].date;

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${_toPersianDigits(date.day.toString())}/${_toPersianDigits(date.month.toString())}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFFCAF0F8),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (
                            group,
                            groupIndex,
                            rod,
                            rodIndex,
                            ) {
                          return BarTooltipItem(
                            '${_formatPrice(rod.toY.toInt())} تومان',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                    ),
                    barGroups: List.generate(
                      salesByDay.length,
                          (index) {
                        final sales = salesByDay[index].sales;

                        return BarChartGroupData(
                          x: index,
                          barsSpace: 0,
                          barRods: [
                            BarChartRodData(
                              toY: sales.toDouble(),
                              width: barWidth,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5),
                              ),
                              color: const Color(0xFF00B4D8),
                              backDrawRodData:
                              BackgroundBarChartRodData(
                                show: true,
                                toY: _getMaxY(),
                                color: Colors.white.withOpacity(0.06),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _getMaxY() {
    if (salesByDay.isEmpty) return 100;

    final maxSales = salesByDay
        .map((item) => item.sales)
        .reduce((a, b) => a > b ? a : b);

    if (maxSales == 0) return 100;

    return maxSales * 1.2;
  }

  double _getInterval() {
    final maxY = _getMaxY();

    if (maxY <= 1000) return 200;
    if (maxY <= 10000) return 2000;
    if (maxY <= 100000) return 20000;
    if (maxY <= 1000000) return 200000;
    if (maxY <= 10000000) return 2000000;

    return maxY / 5;
  }
}

String _compactPricePersian(double value) {
  if (value >= 1000000000) {
    return '${_toPersianDigits((value / 1000000000).toStringAsFixed(1))}B';
  }

  if (value >= 1000000) {
    return '${_toPersianDigits((value / 1000000).toStringAsFixed(1))}M';
  }

  if (value >= 1000) {
    return '${_toPersianDigits((value / 1000).toStringAsFixed(0))}K';
  }

  return _toPersianDigits(value.toInt().toString());
}

// ============================================================
// ACTION ORDERS
// ============================================================

class _ActionOrdersCard extends StatelessWidget {
  const _ActionOrdersCard({
    required this.orders,
  });

  final List<OrderEntity> orders;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0096C7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFCAF0F8),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Iconsax.warning_2_copy,
                  size: 21,
                  color: Color(0xFF03045E),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سفارش‌های نیازمند اقدام',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'سفارش‌هایی که نیاز به پیگیری دارند',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF03045E),
                      ),
                    ),
                  ],
                ),
              ),
              if (orders.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFADE8F4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatNumber(orders.length),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03045E),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (orders.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Column(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 34,
                    color: Colors.green,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'سفارشی برای پیگیری وجود ندارد.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            )
          else
            ...orders.map(
                  (order) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCAF0F8),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Iconsax.box_copy,
                        size: 21,
                        color: Color(0xFF03045E),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سفارش #${_shortOrderId(order.id)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatPrice(order.totalPrice)} تومان',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF03045E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ActionOrderStatus(status: order.status),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionOrderStatus extends StatelessWidget {
  const _ActionOrderStatus({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;
    Color background;

    switch (status) {
      case 'pending':
        text = 'بررسی';
        color = const Color(0xFF03045E);
        background = const Color(0xFFF2F7A0);
        break;
      case 'processing':
        text = 'پردازش';
        color = const Color(0xFF1565C0);
        background = const Color(0xFFE3F2FD);
        break;
      case 'shipped':
        text = 'پیگیری ارسال';
        color = const Color(0xFF6A1B9A);
        background = const Color(0xFFF3E5F5);
        break;
      default:
        text = status;
        color = Colors.black54;
        background = const Color(0xFFF3F3F3);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ============================================================
// LOW STOCK PRODUCTS
// ============================================================

class _LowStockProductsCard extends StatelessWidget {
  const _LowStockProductsCard({
    required this.products,
  });

  final List<AdminLowStockProductEntity> products;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF023E8A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFCAF0F8),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Iconsax.warning_2_copy,
                  size: 21,
                  color: Color(0xFF03045E),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'موجودی کم',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'محصولاتی که نیاز به تأمین موجودی دارند',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFADE8F4),
                      ),
                    ),
                  ],
                ),
              ),
              if (products.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCAF0F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatNumber(products.length),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03045E),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (products.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Column(
                children: [
                  Icon(
                    Iconsax.box_copy,
                    size: 34,
                    color: Colors.green,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'محصولی با موجودی کم وجود ندارد.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            )
          else
            ...products.map(
                  (product) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCAF0F8),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: product.thumbnail != null &&
                          product.thumbnail!.isNotEmpty
                          ? Image.network(
                        product.thumbnail!,
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Iconsax.image_copy,
                            size: 21,
                            color: Color(0xFF03045E),
                          );
                        },
                      )
                          : const Icon(
                        Iconsax.box_copy,
                        size: 21,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StockBadge(stock: product.stock),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({
    required this.stock,
  });

  final int stock;

  @override
  Widget build(BuildContext context) {
    final critical = stock <= 2;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: critical
            ? const Color(0xFFFFE9EA)
            : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            _formatNumber(stock),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: critical
                  ? const Color(0xFFE21B23)
                  : const Color(0xFFF57C00),
            ),
          ),
          Text(
            'موجودی',
            style: TextStyle(
              fontSize: 9,
              color: critical
                  ? const Color(0xFFE21B23)
                  : const Color(0xFFF57C00),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ORDER STATUS
// ============================================================

class _OrderStatusCard extends StatelessWidget {
  const _OrderStatusCard({
    required this.dashboard,
  });

  final AdminDashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatusItem(
        title: 'در انتظار بررسی',
        value: dashboard.pendingOrders,
        icon: Iconsax.clock_copy,
      ),
      _StatusItem(
        title: 'در حال پردازش',
        value: dashboard.processingOrders,
        icon: Iconsax.refresh_copy,
      ),
      _StatusItem(
        title: 'ارسال شده',
        value: dashboard.shippedOrders,
        icon: Iconsax.truck_copy,
      ),
      _StatusItem(
        title: 'تحویل داده شده',
        value: dashboard.deliveredOrders,
        icon: Icons.check_circle_rounded,
      ),
      _StatusItem(
        title: 'لغو شده',
        value: dashboard.canceledOrders,
        icon: Icons.cancel_rounded,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF90E0EF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'وضعیت سفارش‌ها',
            style: TextStyle(
              color: Color(0xFF03045E),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ...items.map(
                (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 21,
                    color: const Color(0xFF03045E),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        color: Color(0xFF03045E),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    _formatNumber(item.value),
                    style: const TextStyle(
                      color: Color(0xFF03045E),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
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

class _StatusItem {
  const _StatusItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final int value;
  final IconData icon;
}

// ============================================================
// RECENT ORDERS
// ============================================================

class _RecentOrdersCard extends StatelessWidget {
  const _RecentOrdersCard({
    required this.orders,
  });

  final List<OrderEntity> orders;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFCAF0F8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'آخرین سفارش‌ها',
            style: TextStyle(
              color: Color(0xFF03045E),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('هنوز سفارشی ثبت نشده است.'),
              ),
            )
          else
            ...orders.map(
                  (order) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF03045E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Iconsax.shopping_bag_copy,
                          color: Color(0xFFCAF0F8),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'سفارش #${_shortOrderId(order.id)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF03045E),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_formatPrice(order.totalPrice)} تومان',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF023E8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _OrderStatusBadge(status: order.status),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  const _OrderStatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    String text;

    switch (status) {
      case 'pending':
        text = 'در انتظار';
        break;
      case 'processing':
        text = 'پردازش';
        break;
      case 'shipped':
        text = 'ارسال شده';
        break;
      case 'delivered':
        text = 'تحویل شده';
        break;
      case 'canceled':
      case 'cancelled':
        text = 'لغو شده';
        break;
      default:
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF03045E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFCAF0F8),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ============================================================
// ERROR VIEW
// ============================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Iconsax.warning_2_copy,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('تلاش مجدد'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

String _formatNumber(int value) {
  final text = value.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) {
      buffer.write(',');
    }

    buffer.write(text[i]);
  }

  return _toPersianDigits(buffer.toString());
}

String _formatPrice(int value) {
  return _formatNumber(value);
}

String _compactPrice(double value) {
  if (value >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(1)}B';
  }

  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }

  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(0)}K';
  }

  return value.toInt().toString();
}

String _shortOrderId(String id) {
  if (id.length <= 8) {
    return id;
  }

  return id.substring(0, 8);
}

String _toPersianDigits(String value) {
  const english = '0123456789';
  const persian = '۰۱۲۳۴۵۶۷۸۹';

  return value.split('').map((char) {
    final index = english.indexOf(char);

    if (index == -1) {
      return char;
    }

    return persian[index];
  }).join();
}