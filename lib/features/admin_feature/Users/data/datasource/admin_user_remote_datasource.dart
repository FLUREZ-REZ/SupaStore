import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_user_model.dart';

class AdminUserRemoteDataSource {
  AdminUserRemoteDataSource({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<AdminUserModel>> getUsers({
    required int page,
    required int limit,
    String? search,
  }) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;

      var query = _client
          .from('profiles')
          .select(
        'id, phone, full_name, avatar_url, '
            'is_admin, created_at, updated_at',
      );

      if (search != null && search.trim().isNotEmpty) {
        final value = search.trim();

        query = query.or(
          'full_name.ilike.%$value%,'
              'phone.ilike.%$value%',
        );
      }

      final response = await query
          .order(
        'created_at',
        ascending: false,
      )
          .range(
        from,
        to,
      );

      return response
          .map(
            (item) => AdminUserModel.fromMap(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(
      Object error,
      ) {
    if (error is SocketException) {
      return Exception(
        'اتصال به اینترنت برقرار نیست.\n'
            'لطفاً اتصال خود را بررسی کنید و دوباره تلاش کنید.',
      );
    }

    if (error is TimeoutException) {
      return Exception(
        'پاسخی از سرور دریافت نشد.\n'
            'لطفاً دوباره تلاش کنید.',
      );
    }

    if (error is PostgrestException) {
      if (error.code == '42501') {
        return Exception(
          'شما اجازه مشاهده کاربران را ندارید.',
        );
      }

      if (error.code == '42P01') {
        return Exception(
          'جدول کاربران پیدا نشد.\n'
              'لطفاً تنظیمات دیتابیس را بررسی کنید.',
        );
      }

      return Exception(
        'دریافت اطلاعات کاربران با مشکل مواجه شد.\n'
            'لطفاً دوباره تلاش کنید.',
      );
    }

    return Exception(
      'دریافت اطلاعات کاربران با مشکل مواجه شد.\n'
          'لطفاً دوباره تلاش کنید.',
    );
  }
}