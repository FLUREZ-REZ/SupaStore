import 'package:supastore/features/shipping_feature/data/datasources/shipping_remote_data_source.dart';
import 'package:supastore/features/shipping_feature/domain/entities/shipping_method_entity.dart';
import 'package:supastore/features/shipping_feature/domain/repositories/shipping_repository.dart';

class ShippingRepositoryImpl
    implements ShippingRepository {
  ShippingRepositoryImpl({
    required ShippingRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ShippingRemoteDataSource _remoteDataSource;

  @override
  Future<List<ShippingMethodEntity>>
  getShippingMethods() async {
    final result =
    await _remoteDataSource
        .getShippingMethods();

    return result.map(
          (map) {
        return ShippingMethodEntity(
          id: map['id'] as String,

          title: map['title'] as String,

          description:
          map['description'] as String?,

          cost: map['cost'] as int,

          estimatedDays:
          map['estimated_days'] as String?,

          isActive:
          map['is_active'] as bool,

          sortOrder:
          map['sort_order'] as int,

          createdAt:
          DateTime.parse(
            map['created_at'] as String,
          ),
        );
      },
    ).toList();
  }
}