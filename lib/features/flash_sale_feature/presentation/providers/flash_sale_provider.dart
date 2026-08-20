import 'package:flutter/foundation.dart';
import 'package:supastore/features/flash_sale_feature/domain/entities/flash_sale_product_entity.dart';
import 'package:supastore/features/flash_sale_feature/domain/usecases/get_active_flash_sales_use_case.dart';



class FlashSaleProvider extends ChangeNotifier {
  final GetActiveFlashSaleProductsUseCase
  getActiveFlashSaleProductsUseCase;

  FlashSaleProvider({
    required this.getActiveFlashSaleProductsUseCase,
  });

  List<FlashSaleProductEntity> _items = [];

  bool _isLoading = false;

  String? _errorMessage;

  List<FlashSaleProductEntity> get items =>
      _items;

  bool get isLoading =>
      _isLoading;

  String? get errorMessage =>
      _errorMessage;

  bool get hasData =>
      _items.isNotEmpty;

  Future<void> fetchFlashSales() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await getActiveFlashSaleProductsUseCase();

      _items = result;
    } catch (e) {
      _errorMessage =
      'خطا در دریافت شگفت‌انگیزها';
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  void clear() {
    _items = [];
    _errorMessage = null;

    notifyListeners();
  }
}