import 'package:flutter/foundation.dart';

import '../../domain/entities/admin_product_option.dart';
import '../../domain/usecases/create_admin_product.dart';
import '../../domain/usecases/delete_admin_product.dart';
import '../../domain/usecases/get_admin_product_options.dart';
import '../../domain/usecases/get_admin_products.dart';
import '../../domain/usecases/update_admin_product.dart';
import '../../domain/usecases/upload_admin_product_image.dart';

class AdminProductProvider extends ChangeNotifier {
  AdminProductProvider({
    required GetAdminProducts getProducts,
    required GetAdminProductOptions getOptions,
    required CreateAdminProduct createProduct,
    required UpdateAdminProduct updateProduct,
    required DeleteAdminProduct deleteProduct,
    required UploadAdminProductImage uploadImage,
  })  : _getProducts = getProducts,
        _getOptions = getOptions,
        _createProduct = createProduct,
        _updateProduct = updateProduct,
        _deleteProduct = deleteProduct,
        _uploadImage = uploadImage;

  final GetAdminProducts _getProducts;
  final GetAdminProductOptions _getOptions;
  final CreateAdminProduct _createProduct;
  final UpdateAdminProduct _updateProduct;
  final DeleteAdminProduct _deleteProduct;
  final UploadAdminProductImage _uploadImage;

  static const int pageSize = 10;

  final List<Map<String, dynamic>> _products = [];

  List<Map<String, dynamic>> get products =>
      List.unmodifiable(_products);

  List<AdminProductOption> _categories = [];

  List<AdminProductOption> get categories =>
      List.unmodifiable(_categories);

  List<AdminProductOption> _brands = [];

  List<AdminProductOption> get brands =>
      List.unmodifiable(_brands);

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;

  bool get isLoadingMore => _isLoadingMore;

  bool _isSaving = false;

  bool get isSaving => _isSaving;

  bool _isDeleting = false;

  bool get isDeleting => _isDeleting;

  bool _hasMore = true;

  bool get hasMore => _hasMore;

  int _page = 0;

  String _search = '';

  String? _error;

  String? get error => _error;

  Future<void> initialize() async {
    await Future.wait([
      loadProducts(refresh: true),
      loadOptions(),
    ]);
  }

  Future<void> loadOptions() async {
    try {
      final categories =
      await _getOptions.getCategories();

      final brands =
      await _getOptions.getBrands();

      _categories = categories;
      _brands = brands;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadProducts({
    bool refresh = false,
    String? search,
  }) async {
    if (_isLoading) return;

    if (refresh) {
      _page = 0;
      _hasMore = true;
      _products.clear();
    }

    if (search != null) {
      _search = search.trim();
      _page = 0;
      _hasMore = true;
      _products.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _getProducts(
        page: _page,
        limit: pageSize,
        search: _search.isEmpty ? null : _search,
      );

      _products.addAll(result);

      if (result.length < pageSize) {
        _hasMore = false;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore ||
        _isLoading ||
        !_hasMore) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _page + 1;

      final result = await _getProducts(
        page: nextPage,
        limit: pageSize,
        search: _search.isEmpty ? null : _search,
      );

      if (result.isEmpty) {
        _hasMore = false;
      } else {
        _products.addAll(result);
        _page = nextPage;

        if (result.length < pageSize) {
          _hasMore = false;
        }
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> createProduct({
    required Map<String, dynamic> data,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _createProduct(data: data);

      await loadProducts(refresh: true);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct({
    required String productId,
    required Map<String, dynamic> data,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _updateProduct(
        productId: productId,
        data: data,
      );

      await loadProducts(refresh: true);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct({
    required String productId,
  }) async {
    _isDeleting = true;
    _error = null;
    notifyListeners();

    try {
      await _deleteProduct(
        productId: productId,
      );

      _products.removeWhere(
            (product) => product['id'] == productId,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  Future<String> uploadImage({
    required String filePath,
  }) {
    return _uploadImage(
      filePath: filePath,
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}