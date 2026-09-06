import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_category_model.dart';

class AdminCategoryRemoteDataSource {
  AdminCategoryRemoteDataSource({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _bucket = 'assets';
  static const String _categoryFolder = 'categories';

  // ---------------------------------------------------------------------------
  // GET CATEGORIES
  // ---------------------------------------------------------------------------

  Future<List<AdminCategoryModel>> getCategories({
    required int page,
    required int limit,
    String? search,
  }) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;

      var query = _client
          .from('categories')
          .select();

      if (search != null && search.trim().isNotEmpty) {
        query = query.ilike(
          'name',
          '%${search.trim()}%',
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
      )
          .range(
        from,
        to,
      );

      return response
          .map(
            (item) => AdminCategoryModel.fromMap(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } catch (e) {
      throw _mapSupabaseError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // CREATE CATEGORY
  // ---------------------------------------------------------------------------

  Future<void> createCategory({
    required Map<String, dynamic> data,
  }) async {
    final imagePath = _extractStoragePath(
      data['image_url'],
    );

    try {
      await _client
          .from('categories')
          .insert(data);
    } catch (e) {
      // اگر ثبت در دیتابیس شکست خورد،
      // تصویری که قبل از آن آپلود شده را پاک می‌کنیم.
      if (imagePath != null) {
        try {
          await _deleteStorageFile(
            imagePath,
          );
        } catch (_) {
          // خطای حذف تصویر نباید خطای اصلی را مخفی کند.
        }
      }

      throw _mapSupabaseError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE CATEGORY
  // ---------------------------------------------------------------------------

  Future<void> updateCategory({
    required String categoryId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final oldCategory = await _client
          .from('categories')
          .select('image_url')
          .eq(
        'id',
        categoryId,
      )
          .maybeSingle();

      if (oldCategory == null) {
        throw Exception(
          'دسته‌بندی مورد نظر پیدا نشد.',
        );
      }

      final oldImage = _extractStoragePath(
        oldCategory['image_url'],
      );

      final newImage = _extractStoragePath(
        data['image_url'],
      );

      final imageChanged =
          newImage != null &&
              newImage != oldImage;

      try {
        await _client
            .from('categories')
            .update(data)
            .eq(
          'id',
          categoryId,
        );
      } catch (e) {
        // اگر تصویر جدید آپلود شده ولی آپدیت DB شکست خورد،
        // تصویر جدید را پاک می‌کنیم.
        if (imageChanged) {
          try {
            await _deleteStorageFile(
              newImage,
            );
          } catch (_) {
            // خطای Storage نباید خطای اصلی را مخفی کند.
          }
        }

        throw _mapSupabaseError(e);
      }

      // بعد از موفقیت DB، تصویر قدیمی را حذف می‌کنیم.
      if (imageChanged && oldImage != null) {
        try {
          await _deleteStorageFile(
            oldImage,
          );
        } catch (_) {
          // آپدیت موفق بوده؛ این فقط یک مشکل Cleanup است.
        }
      }
    } catch (e) {
      throw _mapSupabaseError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE CATEGORY
  // ---------------------------------------------------------------------------

  Future<void> deleteCategory({
    required String categoryId,
  }) async {
    try {
      // -----------------------------------------------------------------------
      // 1. پیدا کردن دسته‌بندی
      // -----------------------------------------------------------------------

      final category = await _client
          .from('categories')
          .select('id, name, image_url')
          .eq(
        'id',
        categoryId,
      )
          .maybeSingle();

      if (category == null) {
        throw Exception(
          'دسته‌بندی مورد نظر پیدا نشد.',
        );
      }

      final categoryName =
          category['name'] as String? ?? 'این دسته‌بندی';

      final imagePath = _extractStoragePath(
        category['image_url'],
      );

      // -----------------------------------------------------------------------
      // 2. بررسی وجود محصول
      // -----------------------------------------------------------------------

      final products = await _client
          .from('products')
          .select('id')
          .eq(
        'category_id',
        categoryId,
      )
          .limit(1);

      // -----------------------------------------------------------------------
      // 3. اگر محصولی وجود دارد، حذف ممنوع است.
      // -----------------------------------------------------------------------

      if (products.isNotEmpty) {
        final productCount =
        await _getCategoryProductCount(
          categoryId,
        );

        throw CategoryHasProductsException(
          categoryName: categoryName,
          productCount: productCount,
        );
      }

      // -----------------------------------------------------------------------
      // 4. حذف دسته‌بندی از DB
      // -----------------------------------------------------------------------

      try {
        await _client
            .from('categories')
            .delete()
            .eq(
          'id',
          categoryId,
        );
      } catch (e) {
        throw _mapSupabaseError(e);
      }

      // -----------------------------------------------------------------------
      // 5. حذف تصویر از Storage
      // -----------------------------------------------------------------------

      if (imagePath != null) {
        try {
          await _deleteStorageFile(
            imagePath,
          );
        } catch (_) {
          // دسته‌بندی از DB حذف شده است.
          // خطای Cleanup را به کاربر نشان نمی‌دهیم.
        }
      }
    } catch (e) {
      if (e is CategoryHasProductsException) {
        rethrow;
      }

      throw _mapSupabaseError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // GET PRODUCT COUNT
  // ---------------------------------------------------------------------------

  Future<int> _getCategoryProductCount(
      String categoryId,
      ) async {
    try {
      final response = await _client
          .from('products')
          .select('id')
          .eq(
        'category_id',
        categoryId,
      );

      return response.length;
    } catch (e) {
      throw _mapSupabaseError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // UPLOAD CATEGORY IMAGE
  // ---------------------------------------------------------------------------

  Future<String> uploadCategoryImage({
    required String filePath,
    String? slug,
  }) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        throw Exception(
          'فایل تصویر پیدا نشد.',
        );
      }

      final fileName = _createFileName(
        slug: slug,
      );

      final storagePath =
          '$_categoryFolder/$fileName.webp';

      try {
        await _client.storage
            .from(_bucket)
            .upload(
          storagePath,
          file,
          fileOptions: FileOptions(
            contentType: 'image/webp',
            upsert: false,
          ),
        );
      } catch (e) {
        throw _mapSupabaseError(e);
      }

      return storagePath;
    } catch (e) {
      throw _mapSupabaseError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE STORAGE FILE
  // ---------------------------------------------------------------------------

  Future<void> _deleteStorageFile(
      String? storagePath,
      ) async {
    if (storagePath == null ||
        storagePath.trim().isEmpty) {
      return;
    }

    final path = _extractStoragePath(
      storagePath,
    );

    if (path == null || path.isEmpty) {
      return;
    }

    await _client.storage
        .from(_bucket)
        .remove([
      path,
    ]);
  }

  // ---------------------------------------------------------------------------
  // EXTRACT STORAGE PATH
  // ---------------------------------------------------------------------------

  String? _extractStoragePath(
      dynamic value,
      ) {
    if (value == null || value is! String) {
      return null;
    }

    var path = value.trim();

    if (path.isEmpty) {
      return null;
    }

    // -------------------------------------------------------------------------
    // Raw Storage Path
    // مثال:
    // categories/mobile.webp
    // -------------------------------------------------------------------------

    if (!path.startsWith('http://') &&
        !path.startsWith('https://')) {
      path = path.split('?').first;

      if (path.startsWith('$_bucket/')) {
        path = path.substring(
          _bucket.length + 1,
        );
      }

      return path;
    }

    // -------------------------------------------------------------------------
    // URL
    // -------------------------------------------------------------------------

    final uri = Uri.tryParse(path);

    if (uri == null) {
      return null;
    }

    const marker = '/storage/v1/object/';

    final markerIndex = uri.path.indexOf(
      marker,
    );

    if (markerIndex == -1) {
      return null;
    }

    var storagePart = uri.path.substring(
      markerIndex + marker.length,
    );

    final parts = storagePart.split('/');

    if (parts.length < 2) {
      return null;
    }

    // public / sign / authenticated
    parts.removeAt(0);

    if (parts.isEmpty) {
      return null;
    }

    if (parts.first == _bucket) {
      parts.removeAt(0);
    }

    if (parts.isEmpty) {
      return null;
    }

    return parts.join('/');
  }

  // ---------------------------------------------------------------------------
  // CREATE FILE NAME
  // ---------------------------------------------------------------------------

  String _createFileName({
    String? slug,
  }) {
    if (slug != null &&
        slug.trim().isNotEmpty) {
      final sanitized = _sanitizeFileName(
        slug,
      );

      if (sanitized.isNotEmpty) {
        return sanitized;
      }
    }

    return 'category_${DateTime.now().millisecondsSinceEpoch}';
  }

  // ---------------------------------------------------------------------------
  // SANITIZE FILE NAME
  // ---------------------------------------------------------------------------

  String _sanitizeFileName(
      String value,
      ) {
    var result =
    value.trim().toLowerCase();

    result = result.replaceAll(
      RegExp(r'\s+'),
      '-',
    );

    result = result.replaceAll(
      RegExp(r'[^a-z0-9\-]'),
      '',
    );

    result = result.replaceAll(
      RegExp(r'-+'),
      '-',
    );

    result = result.replaceAll(
      RegExp(r'^-+|-+$'),
      '',
    );

    return result;
  }

  // ---------------------------------------------------------------------------
  // MAP SUPABASE ERROR
  // ---------------------------------------------------------------------------

  Exception _mapSupabaseError(
      Object error,
      ) {
    // =========================================================================
    // خطای اختصاصی دسته‌بندی دارای محصول
    // =========================================================================

    if (error is CategoryHasProductsException) {
      return error;
    }

    // =========================================================================
    // خطای اینترنت
    // =========================================================================

    if (error is SocketException) {
      return Exception(
        'اتصال به اینترنت برقرار نیست.\n'
            'لطفاً اتصال خود را بررسی کنید و دوباره تلاش کنید.',
      );
    }

    // =========================================================================
    // Timeout
    // =========================================================================

    if (error is TimeoutException) {
      return Exception(
        'پاسخی از سرور دریافت نشد.\n'
            'لطفاً دوباره تلاش کنید.',
      );
    }

    // =========================================================================
    // Auth
    // =========================================================================

    if (error is AuthException) {
      return _mapAuthError(
        error,
      );
    }

    // =========================================================================
    // PostgreSQL / PostgREST
    // =========================================================================

    if (error is PostgrestException) {
      return _mapPostgrestError(
        error,
      );
    }

    // =========================================================================
    // Storage
    // =========================================================================

    if (error is StorageException) {
      return _mapStorageError(
        error,
      );
    }

    // =========================================================================
    // Supabase Exception
    // =========================================================================



    // =========================================================================
    // Exception معمولی
    // =========================================================================

    if (error is Exception) {
      final message = error
          .toString()
          .replaceFirst(
        'Exception: ',
        '',
      )
          .trim();

      if (message.isNotEmpty &&
          !_isTechnicalError(message)) {
        return Exception(
          message,
        );
      }

      return Exception(
        'خطایی رخ داد.\n'
            'لطفاً دوباره تلاش کنید.',
      );
    }

    // =========================================================================
    // Unknown Error
    // =========================================================================

    return Exception(
      'خطایی رخ داد.\n'
          'لطفاً دوباره تلاش کنید.',
    );
  }

  // ---------------------------------------------------------------------------
  // AUTH ERROR
  // ---------------------------------------------------------------------------

  Exception _mapAuthError(
      AuthException error,
      ) {
    final message =
    error.message.toLowerCase();

    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout')) {
      return Exception(
        'اتصال به اینترنت برقرار نیست.\n'
            'لطفاً اتصال خود را بررسی کنید.',
      );
    }

    if (message.contains('jwt') ||
        message.contains('token') ||
        message.contains('session') ||
        message.contains('expired')) {
      return Exception(
        'نشست شما منقضی شده است.\n'
            'لطفاً دوباره وارد حساب کاربری شوید.',
      );
    }

    if (message.contains('unauthorized') ||
        message.contains('forbidden')) {
      return Exception(
        'شما اجازه انجام این عملیات را ندارید.',
      );
    }

    return Exception(
      'ارتباط با حساب کاربری برقرار نشد.\n'
          'لطفاً دوباره تلاش کنید.',
    );
  }

  // ---------------------------------------------------------------------------
  // POSTGRES / POSTGREST ERROR
  // ---------------------------------------------------------------------------

  Exception _mapPostgrestError(
      PostgrestException error,
      ) {
    switch (error.code) {
    // -----------------------------------------------------------------------
    // Foreign Key
    // -----------------------------------------------------------------------

      case '23503':
        return Exception(
          'این دسته‌بندی قابل حذف نیست.\n'
              'ابتدا اطلاعات وابسته به آن را منتقل کنید.',
        );

    // -----------------------------------------------------------------------
    // Unique
    // -----------------------------------------------------------------------

      case '23505':
        return Exception(
          'این اطلاعات قبلاً ثبت شده است.\n'
              'لطفاً مقدار دیگری وارد کنید.',
        );

    // -----------------------------------------------------------------------
    // Not Null
    // -----------------------------------------------------------------------

      case '23502':
        return Exception(
          'برخی اطلاعات ضروری وارد نشده است.\n'
              'لطفاً فرم را بررسی کنید.',
        );

    // -----------------------------------------------------------------------
    // Check Constraint
    // -----------------------------------------------------------------------

      case '23514':
        return Exception(
          'اطلاعات واردشده معتبر نیست.\n'
              'لطفاً مقادیر فرم را بررسی کنید.',
        );

    // -----------------------------------------------------------------------
    // Invalid Text
    // -----------------------------------------------------------------------

      case '22P02':
        return Exception(
          'یکی از اطلاعات واردشده معتبر نیست.',
        );

    // -----------------------------------------------------------------------
    // Permission
    // -----------------------------------------------------------------------

      case '42501':
        return Exception(
          'شما اجازه انجام این عملیات را ندارید.',
        );

    // -----------------------------------------------------------------------
    // Undefined Table
    // -----------------------------------------------------------------------

      case '42P01':
        return Exception(
          'ارتباط با سرور با مشکل مواجه شد.\n'
              'لطفاً دوباره تلاش کنید.',
        );

    // -----------------------------------------------------------------------
    // Undefined Column
    // -----------------------------------------------------------------------

      case '42703':
        return Exception(
          'اطلاعات مورد نیاز پیدا نشد.\n'
              'لطفاً دوباره تلاش کنید.',
        );

    // -----------------------------------------------------------------------
    // Connection
    // -----------------------------------------------------------------------

      case '08000':
      case '08001':
      case '08003':
      case '08004':
      case '08006':
        return Exception(
          'ارتباط با سرور برقرار نشد.\n'
              'لطفاً اتصال اینترنت را بررسی کنید.',
        );

    // -----------------------------------------------------------------------
    // سایر خطاهای PostgreSQL
    // -----------------------------------------------------------------------

      default:
        return Exception(
          'ارتباط با سرور برقرار نشد.\n'
              'لطفاً دوباره تلاش کنید.',
        );
    }
  }

  // ---------------------------------------------------------------------------
  // STORAGE ERROR
  // ---------------------------------------------------------------------------

  Exception _mapStorageError(
      StorageException error,
      ) {
    final message =
    error.message.toLowerCase();

    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout') ||
        message.contains('socket')) {
      return Exception(
        'اتصال به اینترنت برقرار نیست.\n'
            'لطفاً اتصال خود را بررسی کنید.',
      );
    }

    if (message.contains('duplicate') ||
        message.contains('already exists') ||
        message.contains('already exist')) {
      return Exception(
        'فایلی با این نام از قبل وجود دارد.\n'
            'لطفاً تصویر دیگری انتخاب کنید.',
      );
    }

    if (message.contains('not found')) {
      return Exception(
        'فایل تصویر پیدا نشد.',
      );
    }

    if (message.contains('permission') ||
        message.contains('unauthorized') ||
        message.contains('forbidden')) {
      return Exception(
        'اجازه دسترسی به فایل تصویر وجود ندارد.',
      );
    }

    return Exception(
      'مدیریت تصویر با مشکل مواجه شد.\n'
          'لطفاً دوباره تلاش کنید.',
    );
  }

  // ---------------------------------------------------------------------------
  // TECHNICAL ERROR CHECK
  // ---------------------------------------------------------------------------

  bool _isTechnicalError(
      String message,
      ) {
    final lower =
    message.toLowerCase();

    final technicalPatterns = [
      'socketexception',
      'postgrexception',
      'postgrestexception',
      'storageexception',
      'authexception',
      'supabaseexception',
      'failed host lookup',
      'connection refused',
      'connection reset',
      'connection closed',
      'network is unreachable',
      'clientexception',
      'http exception',
      'handshakeexception',
      'xmlhttprequest',
      'statuscode',
      'internal server error',
      'gateway timeout',
      'service unavailable',
    ];

    for (final pattern in technicalPatterns) {
      if (lower.contains(pattern)) {
        return true;
      }
    }

    return false;
  }
}

// =============================================================================
// CATEGORY HAS PRODUCTS EXCEPTION
// =============================================================================

class CategoryHasProductsException
    implements Exception {
  CategoryHasProductsException({
    required this.categoryName,
    required this.productCount,
  });

  final String categoryName;
  final int productCount;

  String get message {
    if (productCount == 1) {
      return 'دسته‌بندی «$categoryName» قابل حذف نیست.\n'
          'یک محصول به این دسته‌بندی متصل است.\n\n'
          'ابتدا محصول را به دسته‌بندی دیگری منتقل کنید.';
    }

    return 'دسته‌بندی «$categoryName» قابل حذف نیست.\n'
        '$productCount محصول به این دسته‌بندی متصل هستند.\n\n'
        'ابتدا محصولات را به دسته‌بندی دیگری منتقل کنید.';
  }

  @override
  String toString() => message;
}