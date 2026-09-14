import 'package:supastore/features/admin_feature/shipping/data/datasources/admin_shipping_remote_data_source.dart';
import 'package:supastore/features/admin_feature/shipping/data/models/admin_shipping_method_model.dart';
import 'package:supastore/features/admin_feature/shipping/domain/entities/admin_shipping_method_entity.dart';
import 'package:supastore/features/admin_feature/shipping/domain/repositories/admin_shipping_repository.dart';

class AdminShippingRepositoryImpl
    implements AdminShippingRepository {
  AdminShippingRepositoryImpl({
    required AdminShippingRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AdminShippingRemoteDataSource _remoteDataSource;

  @override
  Future<List<AdminShippingMethodEntity>> getShippingMethods() async {
    final result =
    await _remoteDataSource.getShippingMethods();

    return result
        .map(
          (map) => AdminShippingMethodModel.fromMap(map),
    )
        .toList();
  }

  @override
  Future<AdminShippingMethodEntity> createShippingMethod({
    required String title,
    String? description,
    required int cost,
    String? estimatedDays,
    required bool isActive,
    required int sortOrder,
  }) async {
    final result =
    await _remoteDataSource.createShippingMethod(
      title: title,
      description: description,
      cost: cost,
      estimatedDays: estimatedDays,
      isActive: isActive,
      sortOrder: sortOrder,
    );

    return AdminShippingMethodModel.fromMap(result);
  }

  @override
  Future<AdminShippingMethodEntity> updateShippingMethod({
    required String id,
    required String title,
    String? description,
    required int cost,
    String? estimatedDays,
    required bool isActive,
    required int sortOrder,
  }) async {
    final result =
    await _remoteDataSource.updateShippingMethod(
      id: id,
      title: title,
      description: description,
      cost: cost,
      estimatedDays: estimatedDays,
      isActive: isActive,
      sortOrder: sortOrder,
    );

    return AdminShippingMethodModel.fromMap(result);
  }

  @override
  Future<void> deleteShippingMethod({
    required String id,
  }) async {
    await _remoteDataSource.deleteShippingMethod(
      id: id,
    );
  }
}