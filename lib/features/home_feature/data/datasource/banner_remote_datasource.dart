import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/features/home_feature/data/models/banner_model.dart';

class BannerRemoteDataSource {
  BannerRemoteDataSource({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Hero banners
  ///
  /// Used by the main banner slider on Home.
  Future<List<BannerModel>> getHeroBanners() async {
    final response = await _client
        .from('banners')
        .select()
        .eq('banner_type', 'hero')
        .eq('is_active', true)
        .or(
      'start_date.is.null,start_date.lte.${DateTime.now().toIso8601String()}',
    )
        .or(
      'end_date.is.null,end_date.gte.${DateTime.now().toIso8601String()}',
    )
        .order(
      'sort_order',
      ascending: true,
    );

    return response
        .map<BannerModel>(
          (json) => BannerModel.fromMap(json),
    )
        .toList();
  }

  /// Promotional banners
  ///
  /// Used by the 2x2 promotional banner grid on Home.
  Future<List<BannerModel>> getPromotionalBanners() async {
    final response = await _client
        .from('banners')
        .select()
        .eq('banner_type', 'promotional')
        .eq('is_active', true)
        .or(
      'start_date.is.null,start_date.lte.${DateTime.now().toIso8601String()}',
    )
        .or(
      'end_date.is.null,end_date.gte.${DateTime.now().toIso8601String()}',
    )
        .order(
      'sort_order',
      ascending: true,
    );

    return response
        .map<BannerModel>(
          (json) => BannerModel.fromMap(json),
    )
        .toList();
  }
}