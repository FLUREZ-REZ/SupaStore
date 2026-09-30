import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminBannerRemoteDataSource {
  AdminBannerRemoteDataSource({
    SupabaseClient? client,
  }) : _client =
      client ?? Supabase.instance.client;

  final SupabaseClient _client;

  // ============================================================
  // GET BANNERS
  // ============================================================

  Future<List<Map<String, dynamic>>> getBanners({
    String? bannerType,
    String? search,
  }) async {
    var query = _client
        .from('banners')
        .select('''
          id,
          title,
          description,
          image_url,
          banner_type,
          action_type,
          action_value,
          sort_order,
          is_active,
          start_date,
          end_date,
          created_at,
          updated_at
        ''');

    if (bannerType != null &&
        bannerType.isNotEmpty &&
        bannerType != 'all') {
      query = query.eq(
        'banner_type',
        bannerType,
      );
    }

    if (search != null &&
        search.trim().isNotEmpty) {
      final value = search.trim();

      query = query.or(
        'title.ilike.%$value%,'
            'description.ilike.%$value%',
      );
    }

    final response = await query
        .order(
      'sort_order',
      ascending: true,
    )
        .order(
      'created_at',
      ascending: false,
    );

    return List<Map<String, dynamic>>.from(
      response,
    );
  }

  // ============================================================
  // CREATE
  // ============================================================

  Future<Map<String, dynamic>> createBanner({
    required String title,
    String? description,
    required String imagePath,
    required String bannerType,
    String? actionType,
    String? actionValue,
    required int sortOrder,
    required bool isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _client
        .from('banners')
        .insert({
      'title': title,
      'description': description,
      'image_url': imagePath,
      'banner_type': bannerType,
      'action_type': actionType,
      'action_value': actionValue,
      'sort_order': sortOrder,
      'is_active': isActive,
      'start_date':
      startDate?.toUtc().toIso8601String(),
      'end_date':
      endDate?.toUtc().toIso8601String(),
    })
        .select('''
          id,
          title,
          description,
          image_url,
          banner_type,
          action_type,
          action_value,
          sort_order,
          is_active,
          start_date,
          end_date,
          created_at,
          updated_at
        ''')
        .single();

    return Map<String, dynamic>.from(
      response,
    );
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<Map<String, dynamic>> updateBanner({
    required String bannerId,
    required String title,
    String? description,
    required String imagePath,
    required String bannerType,
    String? actionType,
    String? actionValue,
    required int sortOrder,
    required bool isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _client
        .from('banners')
        .update({
      'title': title,
      'description': description,
      'image_url': imagePath,
      'banner_type': bannerType,
      'action_type': actionType,
      'action_value': actionValue,
      'sort_order': sortOrder,
      'is_active': isActive,
      'start_date':
      startDate?.toUtc().toIso8601String(),
      'end_date':
      endDate?.toUtc().toIso8601String(),
      'updated_at':
      DateTime.now().toUtc().toIso8601String(),
    })
        .eq(
      'id',
      bannerId,
    )
        .select('''
          id,
          title,
          description,
          image_url,
          banner_type,
          action_type,
          action_value,
          sort_order,
          is_active,
          start_date,
          end_date,
          created_at,
          updated_at
        ''')
        .single();

    return Map<String, dynamic>.from(
      response,
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteBanner({
    required String bannerId,
  }) async {
    await _client
        .from('banners')
        .delete()
        .eq(
      'id',
      bannerId,
    );
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  Future<Map<String, dynamic>> updateBannerStatus({
    required String bannerId,
    required bool isActive,
  }) async {
    // تست Session کاربر
    final user = _client.auth.currentUser;

    print('========== ADMIN BANNER DEBUG ==========');
    print('CURRENT USER ID: ${user?.id}');
    print('CURRENT USER PHONE: ${user?.phone}');

    try {
      final roleResponse = await _client.rpc(
        'current_admin_role',
      );

      print('CURRENT ADMIN ROLE: $roleResponse');
    } catch (e) {
      print('ROLE RPC ERROR: $e');
    }

    try {
      final superAdminResponse = await _client.rpc(
        'is_super_admin',
      );

      print('IS SUPER ADMIN: $superAdminResponse');
    } catch (e) {
      print('SUPER ADMIN RPC ERROR: $e');
    }

    print('========================================');

    final response = await _client
        .from('banners')
        .update({
      'is_active': isActive,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    })
        .eq('id', bannerId)
        .select('''
        id,
        title,
        description,
        image_url,
        banner_type,
        action_type,
        action_value,
        sort_order,
        is_active,
        start_date,
        end_date,
        created_at,
        updated_at
      ''')
        .single();

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // UPLOAD IMAGE
  // ============================================================

  Future<String> uploadBannerImage({
    required XFile file,
  }) async {
    final bytes = await file.readAsBytes();

    final extension =
    file.name.contains('.')
        ? file.name
        .split('.')
        .last
        .toLowerCase()
        : 'webp';

    final timestamp =
        DateTime.now().millisecondsSinceEpoch;

    final path =
        'banners/banner_$timestamp.$extension';

    String contentType;

    switch (extension) {
      case 'png':
        contentType = 'image/png';
        break;

      case 'jpg':
      case 'jpeg':
        contentType = 'image/jpeg';
        break;

      case 'webp':
      default:
        contentType = 'image/webp';
        break;
    }

    await _client.storage
        .from('assets')
        .uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        upsert: false,
        contentType: contentType,
      ),
    );

    return path;
  }

  // ============================================================
  // DELETE IMAGE
  // ============================================================

  Future<void> deleteBannerImage({
    required String imagePath,
  }) async {
    if (imagePath.trim().isEmpty) {
      return;
    }

    try {
      await _client.storage
          .from('assets')
          .remove([
        imagePath,
      ]);
    } catch (e) {
      // Storage cleanup should not block
      // the main database operation.
      //
      // The database record may already be
      // deleted/updated.
      //
      // So only log the error here.
      //
      // You can later add a cleanup mechanism.
      // if needed.

      // ignore: avoid_print
      print(
        'Banner image delete error: $e',
      );
    }
  }
}