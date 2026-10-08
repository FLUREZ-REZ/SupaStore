
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/entities/admin_flash_sale_entity.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/repositories/admin_flash_sale_repository.dart';

class UpdateAdminFlashSaleStatus {
  const UpdateAdminFlashSaleStatus({
    required this.repository,
  });

  final AdminFlashSaleRepository repository;

  Future<AdminFlashSaleEntity> call({
    required String id,
    required bool isActive,
  }) {
    return repository.updateFlashSaleStatus(
      id: id,
      isActive: isActive,
    );
  }
}