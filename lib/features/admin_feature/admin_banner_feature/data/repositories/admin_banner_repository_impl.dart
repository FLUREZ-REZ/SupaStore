import 'package:image_picker/image_picker.dart';

import '../../domain/entities/admin_banner_entity.dart';
import '../../domain/repositories/admin_banner_repository.dart';
import '../datasources/admin_banner_remote_data_source.dart';
import '../models/admin_banner_model.dart';

class AdminBannerRepositoryImpl
    implements AdminBannerRepository {
  AdminBannerRepositoryImpl({
    required AdminBannerRemoteDataSource
    remoteDataSource,
  }) : _remoteDataSource =
      remoteDataSource;

  final AdminBannerRemoteDataSource
  _remoteDataSource;

  @override
  Future<List<AdminBannerEntity>> getBanners({
    String? bannerType,
    String? search,
  }) async {
    final response =
    await _remoteDataSource.getBanners(
      bannerType: bannerType,
      search: search,
    );

    return response
        .map(AdminBannerModel.fromMap)
        .toList();
  }

  @override
  Future<AdminBannerEntity> createBanner({
    required String title,
    String? description,
    required String imagePath,
    required String bannerType,
    String? actionType,
    String? actionValue,
    required int sortOrder,
    required bool isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response =
    await _remoteDataSource.createBanner(
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

    return AdminBannerModel.fromMap(
      response,
    );
  }

  @override
  Future<AdminBannerEntity> updateBanner({
    required String bannerId,
    required String title,
    String? description,
    required String imagePath,
    required String bannerType,
    String? actionType,
    String? actionValue,
    required int sortOrder,
    required bool isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response =
    await _remoteDataSource.updateBanner(
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

    return AdminBannerModel.fromMap(
      response,
    );
  }

  @override
  Future<void> deleteBanner({
    required String bannerId,
  }) {
    return _remoteDataSource.deleteBanner(
      bannerId: bannerId,
    );
  }

  @override
  Future<AdminBannerEntity> updateBannerStatus({
    required String bannerId,
    required bool isActive,
  }) async {
    final response =
    await _remoteDataSource
        .updateBannerStatus(
      bannerId: bannerId,
      isActive: isActive,
    );

    return AdminBannerModel.fromMap(
      response,
    );
  }

  @override
  Future<String> uploadBannerImage({
    required dynamic file,
  }) {
    return _remoteDataSource
        .uploadBannerImage(
      file: file as XFile,
    );
  }

  @override
  Future<void> deleteBannerImage({
    required String imagePath,
  }) {
    return _remoteDataSource
        .deleteBannerImage(
      imagePath: imagePath,
    );
  }
}