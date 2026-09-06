import 'package:flutter/foundation.dart';
import 'package:supastore/features/admin_feature/category/domain/entities/admin_category.dart';
import 'package:supastore/features/admin_feature/category/domain/usecases/create_admin_category.dart';
import 'package:supastore/features/admin_feature/category/domain/usecases/delete_admin_category.dart';
import 'package:supastore/features/admin_feature/category/domain/usecases/get_admin_categories.dart';
import 'package:supastore/features/admin_feature/category/domain/usecases/update_admin_category.dart';
import 'package:supastore/features/admin_feature/category/domain/usecases/upload_admin_category_image.dart';



class AdminCategoryProvider extends ChangeNotifier {
  AdminCategoryProvider({
    required GetAdminCategories getCategories,
    required CreateAdminCategory createCategory,
    required UpdateAdminCategory updateCategory,
    required DeleteAdminCategory deleteCategory,
    required UploadAdminCategoryImage uploadImage,
  })  : _getCategories = getCategories,
        _createCategory = createCategory,
        _updateCategory = updateCategory,
        _deleteCategory = deleteCategory,
        _uploadImage = uploadImage;

  static const int pageSize = 10;

  final GetAdminCategories _getCategories;
  final CreateAdminCategory _createCategory;
  final UpdateAdminCategory _updateCategory;
  final DeleteAdminCategory _deleteCategory;
  final UploadAdminCategoryImage _uploadImage;

  final List<AdminCategory> _categories = [];

  List<AdminCategory> get categories =>
      List.unmodifiable(_categories);

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

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    await loadCategories(
      refresh: true,
    );
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> loadCategories({
    bool refresh = false,
    String? search,
  }) async {
    if (_isLoading ||
        _isLoadingMore) {
      return;
    }

    if (refresh) {
      _page = 0;
      _hasMore = true;
      _categories.clear();
    }

    if (search != null) {
      _search = search.trim();
      _page = 0;
      _hasMore = true;
      _categories.clear();
    }

    final isFirstPage = _page == 0;

    if (isFirstPage) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }

    _error = null;

    notifyListeners();

    try {
      final result =
      await _getCategories(
        page: _page,
        limit: pageSize,
        search: _search.isEmpty
            ? null
            : _search,
      );

      _categories.addAll(result);

      if (result.length <
          pageSize) {
        _hasMore = false;
      } else {
        _page++;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    _isLoadingMore = false;

    notifyListeners();
  }

  // ============================================================
  // CREATE
  // ============================================================

  Future<void> createCategory({
    required Map<String, dynamic> data,
  }) async {
    _isSaving = true;
    _error = null;

    notifyListeners();

    try {
      await _createCategory(
        data: data,
      );

      await loadCategories(
        refresh: true,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<void> updateCategory({
    required String categoryId,
    required Map<String, dynamic> data,
  }) async {
    _isSaving = true;
    _error = null;

    notifyListeners();

    try {
      await _updateCategory(
        categoryId: categoryId,
        data: data,
      );

      await loadCategories(
        refresh: true,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteCategory({
    required String categoryId,
  }) async {
    _isDeleting = true;
    _error = null;

    notifyListeners();

    try {
      await _deleteCategory(
        categoryId: categoryId,
      );

      _categories.removeWhere(
            (category) =>
        category.id == categoryId,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  // ============================================================
  // UPLOAD
  // ============================================================

  Future<String> uploadImage({
    required String filePath,
    String? slug,
  }) {
    return _uploadImage(
      filePath: filePath,
      slug: slug,
    );
  }
}