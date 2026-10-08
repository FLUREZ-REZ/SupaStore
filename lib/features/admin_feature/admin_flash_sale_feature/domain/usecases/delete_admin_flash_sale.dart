
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/repositories/admin_flash_sale_repository.dart';

class DeleteAdminFlashSale {
  const DeleteAdminFlashSale({
    required this.repository,
  });

  final AdminFlashSaleRepository repository;

  Future<void> call({
    required String id,
  }) {
    return repository.deleteFlashSale(
      id: id,
    );
  }
}