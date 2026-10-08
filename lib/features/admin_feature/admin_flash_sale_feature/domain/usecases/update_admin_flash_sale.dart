
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/entities/admin_flash_sale_entity.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/repositories/admin_flash_sale_repository.dart';

class UpdateAdminFlashSale {
  const UpdateAdminFlashSale({
    required this.repository,
  });

  final AdminFlashSaleRepository repository;

  Future<AdminFlashSaleEntity> call({
    required String id,
    required String productId,
    required int discountPrice,
    required DateTime startAt,
    required DateTime endAt,
    required bool isActive,
    required int sortOrder,
  }) {
    return repository.updateFlashSale(
      id: id,
      productId: productId,
      discountPrice: discountPrice,
      startAt: startAt,
      endAt: endAt,
      isActive: isActive,
      sortOrder: sortOrder,
    );
  }
}