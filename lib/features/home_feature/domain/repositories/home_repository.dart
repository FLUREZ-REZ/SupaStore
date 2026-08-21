import 'package:supastore/features/home_feature/domain/entities/banner_entity.dart';

abstract class BannerRepository {
  Future<List<BannerEntity>> getHeroBanners();

  Future<List<BannerEntity>> getPromotionalBanners();
}