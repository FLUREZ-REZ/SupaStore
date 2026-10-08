
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/data/models/admin_flash_sale_product_option.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/entities/admin_flash_sale_entity.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/entities/admin_flash_sale_product_option.dart';

abstract class AdminFlashSaleRepository {
  Future<List<AdminFlashSaleEntity>> getFlashSales();

  Future<AdminFlashSaleEntity> createFlashSale({
    required String productId,
    required int discountPrice,
    required DateTime startAt,
    required DateTime endAt,
    required bool isActive,
    required int sortOrder,
  });

  Future<AdminFlashSaleEntity> updateFlashSale({
    required String id,
    required String productId,
    required int discountPrice,
    required DateTime startAt,
    required DateTime endAt,
    required bool isActive,
    required int sortOrder,
  });

  Future<void> deleteFlashSale({
    required String id,
  });

  Future<AdminFlashSaleEntity> updateFlashSaleStatus({
    required String id,
    required bool isActive,
  });

  Future<List<AdminFlashSaleProductOption>> searchProducts({
    String query = '',
    int limit = 30,
  });
}