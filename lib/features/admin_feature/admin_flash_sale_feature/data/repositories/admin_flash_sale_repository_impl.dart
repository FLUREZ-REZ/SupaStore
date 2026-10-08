
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/data/datasources/admin_flash_sale_remote_data_source.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/data/models/admin_flash_sale_model.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/data/models/admin_flash_sale_product_option.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/entities/admin_flash_sale_entity.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/entities/admin_flash_sale_product_option.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/repositories/admin_flash_sale_repository.dart';

class AdminFlashSaleRepositoryImpl
    implements AdminFlashSaleRepository {
  AdminFlashSaleRepositoryImpl({
    required AdminFlashSaleRemoteDataSource
    remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AdminFlashSaleRemoteDataSource
  _remoteDataSource;

  @override
  Future<List<AdminFlashSaleEntity>>
  getFlashSales() async {
    final response =
    await _remoteDataSource.getFlashSales();

    return response
        .map(
          (item) =>
          AdminFlashSaleModel.fromMap(
            item,
          ).toEntity(),
    )
        .toList();
  }

  @override
  Future<AdminFlashSaleEntity>
  createFlashSale({
    required String productId,
    required int discountPrice,
    required DateTime startAt,
    required DateTime endAt,
    required bool isActive,
    required int sortOrder,
  }) async {
    final response =
    await _remoteDataSource.createFlashSale(
      productId: productId,
      discountPrice: discountPrice,
      startAt: startAt,
      endAt: endAt,
      isActive: isActive,
      sortOrder: sortOrder,
    );

    return AdminFlashSaleModel.fromMap(
      response,
    ).toEntity();
  }

  @override
  Future<AdminFlashSaleEntity>
  updateFlashSale({
    required String id,
    required String productId,
    required int discountPrice,
    required DateTime startAt,
    required DateTime endAt,
    required bool isActive,
    required int sortOrder,
  }) async {
    final response =
    await _remoteDataSource.updateFlashSale(
      id: id,
      productId: productId,
      discountPrice: discountPrice,
      startAt: startAt,
      endAt: endAt,
      isActive: isActive,
      sortOrder: sortOrder,
    );

    return AdminFlashSaleModel.fromMap(
      response,
    ).toEntity();
  }

  @override
  Future<void> deleteFlashSale({
    required String id,
  }) {
    return _remoteDataSource.deleteFlashSale(
      id: id,
    );
  }

  @override
  Future<AdminFlashSaleEntity>
  updateFlashSaleStatus({
    required String id,
    required bool isActive,
  }) async {
    final response =
    await _remoteDataSource
        .updateFlashSaleStatus(
      id: id,
      isActive: isActive,
    );

    return AdminFlashSaleModel.fromMap(
      response,
    ).toEntity();
  }

  @override
  Future<List<AdminFlashSaleProductOption>>
  searchProducts({
    String query = '',
    int limit = 30,
  }) async {
    final response =
    await _remoteDataSource.searchProducts(
      query: query,
      limit: limit,
    );

    return response
        .map(
          (item) =>
          AdminFlashSaleProductOptionModel
              .fromMap(item),
    )
        .toList();
  }
}