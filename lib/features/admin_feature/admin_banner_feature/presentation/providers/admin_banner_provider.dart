import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/admin_banner_entity.dart';
import '../../domain/usecases/create_admin_banner.dart';
import '../../domain/usecases/delete_admin_banner.dart';
import '../../domain/usecases/get_admin_banners.dart';
import '../../domain/usecases/remove_admin_banner_image.dart';
import '../../domain/usecases/update_admin_banner.dart';
import '../../domain/usecases/update_admin_banner_status.dart';
import '../../domain/usecases/upload_admin_banner_image.dart';

class AdminBannerProvider
    extends ChangeNotifier {
  AdminBannerProvider({
    required GetAdminBanners getBanners,
    required CreateAdminBanner createBanner,
    required UpdateAdminBanner updateBanner,
    required DeleteAdminBanner deleteBanner,
    required UpdateAdminBannerStatus
    updateBannerStatus,
    required UploadAdminBannerImage uploadImage,
    required RemoveAdminBannerImage
    removeImage,
  })  : _getBanners = getBanners,
        _createBanner = createBanner,
        _updateBanner = updateBanner,
        _deleteBanner = deleteBanner,
        _updateBannerStatus =
            updateBannerStatus,
        _uploadImage = uploadImage,
        _removeImage = removeImage;

  final GetAdminBanners _getBanners;
  final CreateAdminBanner _createBanner;
  final UpdateAdminBanner _updateBanner;
  final DeleteAdminBanner _deleteBanner;
  final UpdateAdminBannerStatus
  _updateBannerStatus;
  final UploadAdminBannerImage _uploadImage;
  final RemoveAdminBannerImage _removeImage;

  // ============================================================
  // STATE
  // ============================================================

  List<AdminBannerEntity> _banners = [];

  List<AdminBannerEntity> get banners =>
      List.unmodifiable(_banners);

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isSaving = false;

  bool get isSaving => _isSaving;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  String _search = '';

  String get search => _search;

  String _selectedType = 'all';

  String get selectedType =>
      _selectedType;

  // ============================================================
  // FILTER
  // ============================================================

  void setSearch(String value) {
    _search = value;
  }

  void setBannerType(String value) {
    _selectedType = value;
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> loadBanners() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _banners = await _getBanners(
        bannerType:
        _selectedType == 'all'
            ? null
            : _selectedType,
        search: _search.trim(),
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // CREATE
  // ============================================================

  Future<bool> createBanner({
    required String title,
    String? description,
    required XFile image,
    required String bannerType,
    String? actionType,
    String? actionValue,
    required int sortOrder,
    required bool isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isSaving = true;
    _errorMessage = null;

    notifyListeners();

    String? uploadedImagePath;

    try {
      uploadedImagePath =
      await _uploadImage(
        file: image,
      );

      final banner =
      await _createBanner(
        title: title,
        description: description,
        imagePath:
        uploadedImagePath,
        bannerType: bannerType,
        actionType: actionType,
        actionValue: actionValue,
        sortOrder: sortOrder,
        isActive: isActive,
        startDate: startDate,
        endDate: endDate,
      );

      _banners.insert(
        0,
        banner,
      );

      _sortBanners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      if (uploadedImagePath != null) {
        await _removeImage(
          imagePath: uploadedImagePath,
        );
      }

      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<bool> updateBanner({
    required String bannerId,
    required String title,
    String? description,
    XFile? newImage,
    required String currentImagePath,
    required String bannerType,
    String? actionType,
    String? actionValue,
    required int sortOrder,
    required bool isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isSaving = true;
    _errorMessage = null;

    notifyListeners();

    String imagePath =
        currentImagePath;

    String? uploadedNewImagePath;

    try {
      if (newImage != null) {
        uploadedNewImagePath =
        await _uploadImage(
          file: newImage,
        );

        imagePath =
            uploadedNewImagePath;
      }

      final updatedBanner =
      await _updateBanner(
        bannerId: bannerId,
        title: title,
        description: description,
        imagePath: imagePath,
        bannerType: bannerType,
        actionType: actionType,
        actionValue: actionValue,
        sortOrder: sortOrder,
        isActive: isActive,
        startDate: startDate,
        endDate: endDate,
      );

      final index =
      _banners.indexWhere(
            (banner) =>
        banner.id == bannerId,
      );

      if (index != -1) {
        _banners[index] =
            updatedBanner;
      } else {
        _banners.add(
          updatedBanner,
        );
      }

      _sortBanners();

      if (uploadedNewImagePath != null &&
          currentImagePath !=
              uploadedNewImagePath) {
        await _removeImage(
          imagePath: currentImagePath,
        );
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      if (uploadedNewImagePath != null) {
        await _removeImage(
          imagePath:
          uploadedNewImagePath,
        );
      }

      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<bool> deleteBanner({
    required AdminBannerEntity banner,
  }) async {
    _isSaving = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _deleteBanner(
        bannerId: banner.id,
      );

      _banners.removeWhere(
            (item) =>
        item.id == banner.id,
      );

      await _removeImage(
        imagePath:
        banner.imagePath,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ============================================================
  // STATUS
  // ============================================================

  Future<bool> updateBannerStatus({
    required String bannerId,
    required bool isActive,
  }) async {
    _isSaving = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final updatedBanner =
      await _updateBannerStatus(
        bannerId: bannerId,
        isActive: isActive,
      );

      final index =
      _banners.indexWhere(
            (banner) =>
        banner.id == bannerId,
      );

      if (index != -1) {
        _banners[index] =
            updatedBanner;
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ============================================================
  // SORT
  // ============================================================

  void _sortBanners() {
    _banners.sort(
          (a, b) {
        final orderResult =
        a.sortOrder.compareTo(
          b.sortOrder,
        );

        if (orderResult != 0) {
          return orderResult;
        }

        return b.createdAt.compareTo(
          a.createdAt,
        );
      },
    );
  }
}