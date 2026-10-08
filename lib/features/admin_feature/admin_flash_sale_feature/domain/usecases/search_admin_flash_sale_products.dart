
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/entities/admin_flash_sale_product_option.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/repositories/admin_flash_sale_repository.dart';

class SearchAdminFlashSaleProducts {
  const SearchAdminFlashSaleProducts({
    required this.repository,
  });

  final AdminFlashSaleRepository repository;

  Future<List<AdminFlashSaleProductOption>> call({
    String query = '',
    int limit = 30,
  }) {
    return repository.searchProducts(
      query: query,
      limit: limit,
    );
  }
}