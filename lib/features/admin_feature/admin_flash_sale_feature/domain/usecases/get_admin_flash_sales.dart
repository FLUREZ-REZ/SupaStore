
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/entities/admin_flash_sale_entity.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/repositories/admin_flash_sale_repository.dart';

class GetAdminFlashSales {
  const GetAdminFlashSales({
    required this.repository,
  });

  final AdminFlashSaleRepository repository;

  Future<List<AdminFlashSaleEntity>> call() {
    return repository.getFlashSales();
  }
}