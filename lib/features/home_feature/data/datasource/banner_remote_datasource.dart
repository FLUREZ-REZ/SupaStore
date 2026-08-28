import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/features/home_feature/data/models/banner_model.dart';

abstract class BannerRemoteDataSource {
  Future<List<BannerModel>> getHeroBanners();

  Future<List<BannerModel>> getPromotionalBanners();

  Future<List<BannerModel>> getSingleBanners();
}

class BannerRemoteDataSourceImpl
    implements BannerRemoteDataSource {
  BannerRemoteDataSourceImpl({
    SupabaseClient? client,
  }) : _client =
      client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String get _now =>
      DateTime.now().toUtc().toIso8601String();

  Future<List<BannerModel>> _getBanners({
    required String bannerType,
  }) async {
    final response = await _client
        .from('banners')
        .select()
        .eq('banner_type', bannerType)
        .eq('is_active', true)
        .or(
      'start_date.is.null,start_date.lte.$_now',
    )
        .or(
      'end_date.is.null,end_date.gte.$_now',
    )
        .order(
      'sort_order',
      ascending: true,
    );

    return response
        .map<BannerModel>(
          (json) => BannerModel.fromMap(
        Map<String, dynamic>.from(json),
      ),
    )
        .toList();
  }

  @override
  Future<List<BannerModel>>
  getHeroBanners() {
    return _getBanners(
      bannerType: 'hero',
    );
  }

  @override
  Future<List<BannerModel>>
  getPromotionalBanners() {
    return _getBanners(
      bannerType: 'promotional',
    );
  }

  @override
  Future<List<BannerModel>>
  getSingleBanners() {
    return _getBanners(
      bannerType: 'bottom_home',
    );
  }
}