import 'package:flutter/foundation.dart';

import 'package:supastore/features/flash_sale_feature/domain/entities/flash_sale_product_entity.dart';
import 'package:supastore/features/flash_sale_feature/domain/usecases/get_active_flash_sales_use_case.dart';

class FlashSaleProvider extends ChangeNotifier {
  FlashSaleProvider({
    required this.getActiveFlashSaleProductsUseCase,
  });

  final GetActiveFlashSaleProductsUseCase
  getActiveFlashSaleProductsUseCase;

  // ============================================================
  // CONSTANTS
  // ============================================================

  static const int _pageSize = 20;

  int get pageSize => _pageSize;

  // ============================================================
  // PRODUCTS
  // ============================================================

  List<FlashSaleProductEntity> _items = [];

  List<FlashSaleProductEntity> get items =>
      List.unmodifiable(_items);

  // ============================================================
  // LOADING
  // ============================================================

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // ============================================================
  // ERROR
  // ============================================================

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  // ============================================================
  // PAGE
  // ============================================================

  int _page = 0;

  int get currentPage => _page;

  // ============================================================
  // NEXT PAGE
  // ============================================================

  bool _hasNextPage = true;

  bool get hasNextPage => _hasNextPage;

  // ============================================================
  // PREVIOUS PAGE
  // ============================================================

  bool get hasPreviousPage => _page > 0;

  // ============================================================
  // HAS DATA
  // ============================================================

  bool get hasData => _items.isNotEmpty;

  // ============================================================
  // FETCH FIRST PAGE
  // ============================================================

  Future<void> fetchFlashSales() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;

    _errorMessage = null;

    _page = 0;

    _hasNextPage = true;

    _items.clear();

    notifyListeners();

    try {
      final result =
      await getActiveFlashSaleProductsUseCase(
        page: 0,
        limit: _pageSize,
      );

      _items = result;

      // اگر کمتر از 20 محصول برگشت،
      // یعنی صفحه بعدی وجود ندارد.
      if (result.length < _pageSize) {
        _hasNextPage = false;
      }
    } catch (e) {
      _errorMessage =
      'خطا در دریافت محصولات شگفت‌انگیز';

      debugPrint(
        '❌ Flash Sale loading error: $e',
      );
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // NEXT PAGE
  // ============================================================

  Future<void> nextPage() async {
    if (_isLoading) {
      return;
    }

    if (!_hasNextPage) {
      return;
    }

    final nextPage = _page + 1;

    await _loadPage(
      page: nextPage,
    );
  }

  // ============================================================
  // PREVIOUS PAGE
  // ============================================================

  Future<void> previousPage() async {
    if (_isLoading) {
      return;
    }

    if (!hasPreviousPage) {
      return;
    }

    final previousPage = _page - 1;

    await _loadPage(
      page: previousPage,
    );
  }

  // ============================================================
  // LOAD SPECIFIC PAGE
  // ============================================================

  Future<void> _loadPage({
    required int page,
  }) async {
    if (_isLoading) {
      return;
    }

    if (page < 0) {
      return;
    }

    _isLoading = true;

    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await getActiveFlashSaleProductsUseCase(
        page: page,
        limit: _pageSize,
      );

      _items = result;

      _page = page;

      // اگر دقیقاً 20 محصول برگشت،
      // احتمال دارد صفحه بعدی وجود داشته باشد.
      //
      // اگر کمتر از 20 برگشت،
      // این آخرین صفحه است.
      _hasNextPage =
          result.length == _pageSize;
    } catch (e) {
      _errorMessage =
      'خطا در دریافت محصولات شگفت‌انگیز';

      debugPrint(
        '❌ Flash Sale page loading error: $e',
      );
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    await fetchFlashSales();
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clear() {
    _items = [];

    _page = 0;

    _hasNextPage = true;

    _errorMessage = null;

    _isLoading = false;

    notifyListeners();
  }
}