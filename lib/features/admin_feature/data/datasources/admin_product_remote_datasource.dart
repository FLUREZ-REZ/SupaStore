import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_product_option_model.dart';

class AdminProductRemoteDataSource {
  AdminProductRemoteDataSource({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _bucket = 'assets';
  static const String _productFolder = 'products';

  // ===========================================================================
  // GET PRODUCTS
  // ===========================================================================

  Future<List<Map<String, dynamic>>> getProducts({
    required int page,
    required int limit,
    String? search,
  }) async {
    final from = page * limit;
    final to = from + limit - 1;

    var query = _client.from('products').select('''
      *,
      brands(
        id,
        name,
        logo_url
      )
    ''');

    if (search != null && search.trim().isNotEmpty) {
      query = query.ilike(
        'title',
        '%${search.trim()}%',
      );
    }

    final response = await query
        .order(
      'created_at',
      ascending: false,
    )
        .range(from, to);

    return List<Map<String, dynamic>>.from(response);
  }

  // ===========================================================================
  // GET CATEGORIES
  // ===========================================================================

  Future<List<AdminProductOptionModel>> getCategories() async {
    final response = await _client
        .from('categories')
        .select('id, name')
        .order(
      'name',
      ascending: true,
    );

    return response
        .map(
          (item) => AdminProductOptionModel.fromMap(item),
    )
        .toList();
  }

  // ===========================================================================
  // GET BRANDS
  // ===========================================================================

  Future<List<AdminProductOptionModel>> getBrands() async {
    final response = await _client
        .from('brands')
        .select('id, name')
        .order(
      'name',
      ascending: true,
    );

    return response
        .map(
          (item) => AdminProductOptionModel.fromMap(item),
    )
        .toList();
  }

  // ===========================================================================
  // CREATE PRODUCT
  // ===========================================================================

  Future<void> createProduct({
    required Map<String, dynamic> data,
  }) async {
    final thumbnail = _extractStoragePath(
      data['thumbnail'],
    );

    try {
      await _client
          .from('products')
          .insert(data);
    } catch (e) {
      // اگر ثبت محصول در دیتابیس شکست خورد،
      // تصویر تازه آپلودشده را حذف می‌کنیم.
      if (thumbnail != null) {
        await _deleteStorageFile(
          thumbnail,
        );
      }

      rethrow;
    }
  }

  // ===========================================================================
  // UPDATE PRODUCT
  // ===========================================================================

  Future<void> updateProduct({
    required String productId,
    required Map<String, dynamic> data,
  }) async {
    // گرفتن اطلاعات فعلی محصول
    final oldProduct = await _client
        .from('products')
        .select('thumbnail')
        .eq('id', productId)
        .maybeSingle();

    if (oldProduct == null) {
      throw Exception(
        'محصول مورد نظر پیدا نشد.',
      );
    }

    final oldThumbnail = _extractStoragePath(
      oldProduct['thumbnail'],
    );

    final newThumbnail = _extractStoragePath(
      data['thumbnail'],
    );

    final imageChanged =
        oldThumbnail != null &&
            newThumbnail != null &&
            oldThumbnail != newThumbnail;

    try {
      await _client
          .from('products')
          .update(data)
          .eq('id', productId);
    } catch (e) {
      // اگر عکس جدید آپلود شده بود،
      // ولی update دیتابیس شکست خورد،
      // عکس جدید را حذف می‌کنیم.
      if (imageChanged) {
        await _deleteStorageFile(
          newThumbnail,
        );
      }

      rethrow;
    }

    // بعد از موفقیت آپدیت دیتابیس،
    // عکس قبلی را حذف می‌کنیم.
    if (imageChanged) {
      await _deleteStorageFile(
        oldThumbnail,
      );
    }
  }

  // ===========================================================================
  // DELETE PRODUCT
  // ===========================================================================

  Future<void> deleteProduct({
    required String productId,
  }) async {
    // ابتدا thumbnail محصول را می‌گیریم.
    final product = await _client
        .from('products')
        .select('thumbnail')
        .eq('id', productId)
        .maybeSingle();

    if (product == null) {
      throw Exception(
        'محصول مورد نظر پیدا نشد.',
      );
    }

    final thumbnail = _extractStoragePath(
      product['thumbnail'],
    );

    // حذف محصول از دیتابیس
    await _client
        .from('products')
        .delete()
        .eq('id', productId);

    // حذف تصویر از Storage
    if (thumbnail != null) {
      try {
        await _client.storage
            .from(_bucket)
            .remove([
          thumbnail,
        ]);
      } catch (e) {
        throw Exception(
          'محصول از دیتابیس حذف شد، '
              'اما تصویر از Storage حذف نشد.\n'
              'Path: $thumbnail\n'
              'Error: $e',
        );
      }
    }
  }

  // ===========================================================================
  // UPLOAD PRODUCT IMAGE
  // ===========================================================================

  Future<String> uploadProductImage({
    required String filePath,
    String? slug,
  }) async {
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
        '$_productFolder/$fileName.webp';

    try {
      await _client.storage
          .from(_bucket)
          .upload(
        storagePath,
        file,
        fileOptions: const FileOptions(
          contentType: 'image/webp',
          upsert: false,
        ),
      );

      return storagePath;
    } catch (e) {
      rethrow;
    }
  }

  // ===========================================================================
  // DELETE STORAGE FILE
  // ===========================================================================

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

    try {
      await _client.storage
          .from(_bucket)
          .remove([
        path,
      ]);
    } catch (e) {
      throw Exception(
        'حذف تصویر از Storage ناموفق بود.\n'
            'Path: $path\n'
            'Error: $e',
      );
    }
  }

  // ===========================================================================
  // EXTRACT STORAGE PATH
  // ===========================================================================

  String? _extractStoragePath(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is! String) {
      return null;
    }

    var path = value.trim();

    if (path.isEmpty) {
      return null;
    }

    // -------------------------------------------------------------------------
    // Raw Storage Path
    //
    // products/iphone11.webp
    // -------------------------------------------------------------------------

    if (!path.startsWith('http://') &&
        !path.startsWith('https://')) {
      path = path.split('?').first;

      // اگر به هر دلیلی bucket هم ذخیره شده باشد:
      //
      // assets/products/iphone11.webp
      //
      if (path.startsWith('$_bucket/')) {
        path = path.substring(
          _bucket.length + 1,
        );
      }

      return path;
    }

    // -------------------------------------------------------------------------
    // Full Supabase Storage URL
    // -------------------------------------------------------------------------

    final uri = Uri.tryParse(path);

    if (uri == null) {
      return null;
    }

    final uriPath = uri.path;

    const marker = '/storage/v1/object/';

    final markerIndex = uriPath.indexOf(
      marker,
    );

    if (markerIndex == -1) {
      return null;
    }

    var storagePart = uriPath.substring(
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

    // bucket
    if (parts.first == _bucket) {
      parts.removeAt(0);
    }

    if (parts.isEmpty) {
      return null;
    }

    return parts.join('/');
  }

  // ===========================================================================
  // CREATE FILE NAME
  // ===========================================================================

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

    return 'product_${DateTime.now().millisecondsSinceEpoch}';
  }

  // ===========================================================================
  // SANITIZE FILE NAME
  // ===========================================================================

  String _sanitizeFileName(
      String value,
      ) {
    var result = value.trim().toLowerCase();

    // فاصله‌ها → -
    result = result.replaceAll(
      RegExp(r'\s+'),
      '-',
    );

    // فقط حروف انگلیسی، اعداد و -
    result = result.replaceAll(
      RegExp(r'[^a-z0-9\-]'),
      '',
    );

    // چند - پشت سر هم → یک -
    result = result.replaceAll(
      RegExp(r'-+'),
      '-',
    );

    // حذف - از ابتدا و انتها
    result = result.replaceAll(
      RegExp(r'^-+|-+$'),
      '',
    );

    return result;
  }
}