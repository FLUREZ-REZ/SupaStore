import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supastore/features/home_feature/data/models/banner_model.dart';

class BannerRemoteDataSource {
  BannerRemoteDataSource({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<BannerModel>> getBanners() async {
    final response = await _client
        .from('banners')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    return response
        .map<BannerModel>(
          (json) => BannerModel.fromMap(json),
    )
        .toList();
  }
}