import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/admin_flash_sale_product_option.dart';

class AdminFlashSaleProductOptionModel
    extends AdminFlashSaleProductOption {
  const AdminFlashSaleProductOptionModel({
    required super.id,
    required super.title,
    required super.thumbnail,
    required super.price,
  });

  factory AdminFlashSaleProductOptionModel.fromMap(
      Map<String, dynamic> map,
      ) {
    final thumbnailPath = map['thumbnail'] as String;

    final thumbnailUrl = Supabase.instance.client.storage
        .from('assets')
        .getPublicUrl(thumbnailPath);

    return AdminFlashSaleProductOptionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      thumbnail: thumbnailUrl,
      price: (map['price'] as num).toInt(),
    );
  }
}