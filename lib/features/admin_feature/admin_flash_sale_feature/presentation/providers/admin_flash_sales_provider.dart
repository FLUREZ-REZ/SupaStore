import 'package:flutter/foundation.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/entities/admin_flash_sale_entity.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/entities/admin_flash_sale_product_option.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/usecases/create_admin_flash_sale.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/usecases/delete_admin_flash_sale.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/usecases/get_admin_flash_sales.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/usecases/search_admin_flash_sale_products.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/usecases/update_admin_flash_sale.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/usecases/update_admin_flash_sale_status.dart';

class AdminFlashSalesProvider extends ChangeNotifier {
  AdminFlashSalesProvider({
    required GetAdminFlashSales getAdminFlashSales,
    required CreateAdminFlashSale createAdminFlashSale,
    required UpdateAdminFlashSale updateAdminFlashSale,
    required DeleteAdminFlashSale deleteAdminFlashSale,
    required UpdateAdminFlashSaleStatus
    updateAdminFlashSaleStatus,
    required SearchAdminFlashSaleProducts
    searchAdminFlashSaleProducts,
  })  : _getAdminFlashSales = getAdminFlashSales,
        _createAdminFlashSale =
            createAdminFlashSale,
        _updateAdminFlashSale =
            updateAdminFlashSale,
        _deleteAdminFlashSale =
            deleteAdminFlashSale,
        _updateAdminFlashSaleStatus =
            updateAdminFlashSaleStatus,
        _searchAdminFlashSaleProducts =
            searchAdminFlashSaleProducts;

  final GetAdminFlashSales _getAdminFlashSales;
  final CreateAdminFlashSale
  _createAdminFlashSale;
  final UpdateAdminFlashSale
  _updateAdminFlashSale;
  final DeleteAdminFlashSale
  _deleteAdminFlashSale;
  final UpdateAdminFlashSaleStatus
  _updateAdminFlashSaleStatus;
  final SearchAdminFlashSaleProducts
  _searchAdminFlashSaleProducts;

  List<AdminFlashSaleEntity> _items = [];

  List<AdminFlashSaleEntity> get items =>
      List.unmodifiable(_items);

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;

  bool _isDeleting = false;

  bool get isDeleting => _isDeleting;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  bool get hasData => _items.isNotEmpty;

  int get count => _items.length;

  List<AdminFlashSaleProductOption>
  _productOptions = [];

  List<AdminFlashSaleProductOption>
  get productOptions =>
      List.unmodifiable(_productOptions);

  bool _isSearchingProducts = false;

  bool get isSearchingProducts =>
      _isSearchingProducts;

  Future<void> loadFlashSales() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _items = await _getAdminFlashSales();
    } catch (e, stackTrace) {
      _errorMessage = e.toString();

      debugPrint(
        'Admin Flash Sale load error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<bool> createFlashSale({
    required String productId,
    required int discountPrice,
    required DateTime startAt,
    required DateTime endAt,
    required bool isActive,
    required int sortOrder,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final item =
      await _createAdminFlashSale(
        productId: productId,
        discountPrice: discountPrice,
        startAt: startAt,
        endAt: endAt,
        isActive: isActive,
        sortOrder: sortOrder,
      );

      _items = [
        ..._items,
        item,
      ];

      _items.sort(
            (a, b) {
          final orderCompare =
          a.sortOrder.compareTo(
            b.sortOrder,
          );

          if (orderCompare != 0) {
            return orderCompare;
          }

          return b.createdAt.compareTo(
            a.createdAt,
          );
        },
      );

      return true;
    } catch (e, stackTrace) {
      _errorMessage = e.toString();

      debugPrint(
        'Admin Flash Sale create error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    } finally {
      _isSubmitting = false;

      notifyListeners();
    }
  }

  Future<bool> updateFlashSale({
    required String id,
    required String productId,
    required int discountPrice,
    required DateTime startAt,
    required DateTime endAt,
    required bool isActive,
    required int sortOrder,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final updated =
      await _updateAdminFlashSale(
        id: id,
        productId: productId,
        discountPrice: discountPrice,
        startAt: startAt,
        endAt: endAt,
        isActive: isActive,
        sortOrder: sortOrder,
      );

      final index = _items.indexWhere(
            (item) => item.id == id,
      );

      if (index != -1) {
        final newItems =
        List<AdminFlashSaleEntity>.from(
          _items,
        );

        newItems[index] = updated;

        newItems.sort(
              (a, b) {
            final orderCompare =
            a.sortOrder.compareTo(
              b.sortOrder,
            );

            if (orderCompare != 0) {
              return orderCompare;
            }

            return b.createdAt.compareTo(
              a.createdAt,
            );
          },
        );

        _items = newItems;
      }

      return true;
    } catch (e, stackTrace) {
      _errorMessage = e.toString();

      debugPrint(
        'Admin Flash Sale update error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    } finally {
      _isSubmitting = false;

      notifyListeners();
    }
  }

  Future<bool> deleteFlashSale(
      String id,
      ) async {
    _isDeleting = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _deleteAdminFlashSale(
        id: id,
      );

      _items = _items
          .where(
            (item) => item.id != id,
      )
          .toList();

      return true;
    } catch (e, stackTrace) {
      _errorMessage = e.toString();

      debugPrint(
        'Admin Flash Sale delete error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    } finally {
      _isDeleting = false;

      notifyListeners();
    }
  }

  Future<bool> updateStatus({
    required String id,
    required bool isActive,
  }) async {
    _errorMessage = null;

    try {
      final updated =
      await _updateAdminFlashSaleStatus(
        id: id,
        isActive: isActive,
      );

      final index = _items.indexWhere(
            (item) => item.id == id,
      );

      if (index != -1) {
        final newItems =
        List<AdminFlashSaleEntity>.from(
          _items,
        );

        newItems[index] = updated;

        _items = newItems;
      }

      notifyListeners();

      return true;
    } catch (e, stackTrace) {
      _errorMessage = e.toString();

      debugPrint(
        'Admin Flash Sale status error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      notifyListeners();

      return false;
    }
  }

  Future<void> refresh() async {
    await loadFlashSales();
  }

  Future<void> searchProducts({
    String query = '',
  }) async {
    _isSearchingProducts = true;

    notifyListeners();

    try {
      _productOptions =
      await _searchAdminFlashSaleProducts(
        query: query,
        limit: 30,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Admin Flash Sale product search error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _productOptions = [];
    } finally {
      _isSearchingProducts = false;

      notifyListeners();
    }
  }

  void clearProductOptions() {
    _productOptions = [];

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }

  void clear() {
    _items = [];
    _productOptions = [];
    _errorMessage = null;
    _isLoading = false;
    _isSubmitting = false;
    _isDeleting = false;
    _isSearchingProducts = false;

    notifyListeners();
  }
}