import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_store_settings_model.dart';

class AdminStoreSettingsRemoteDataSource {
  AdminStoreSettingsRemoteDataSource({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<AdminStoreSettingsModel> getSettings() async {
    try {
      final response = await _client
          .from('store_settings')
          .select()
          .limit(1)
          .maybeSingle();

      if (response == null) {
        throw Exception(
          'تنظیمات فروشگاه پیدا نشد.',
        );
      }

      return AdminStoreSettingsModel.fromMap(
        Map<String, dynamic>.from(response),
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'دریافت تنظیمات فروشگاه با مشکل مواجه شد.',
      );
    }
  }

  Future<AdminStoreSettingsModel> updateSettings({
    required AdminStoreSettingsModel settings,
  }) async {
    try {
      final response = await _client
          .from('store_settings')
          .update(settings.toMap())
          .eq('id', settings.id)
          .select()
          .single();

      return AdminStoreSettingsModel.fromMap(
        Map<String, dynamic>.from(response),
      );
    } catch (e) {
      if (e is PostgrestException) {
        throw Exception(
          'ذخیره تنظیمات فروشگاه با مشکل مواجه شد.',
        );
      }

      throw Exception(
        'ذخیره تنظیمات فروشگاه با مشکل مواجه شد.',
      );
    }
  }

  Future<AdminStoreSettingsModel> updateLogo({
    required String settingsId,
    required String? oldLogoUrl,
    required Uint8List bytes,
    required String extension,
    required String contentType,
  }) async {
    try {
      final timestamp =
          DateTime.now().millisecondsSinceEpoch;

      final normalizedExtension =
      extension.toLowerCase().replaceAll('.', '');

      final filePath =
          'store/logo_$timestamp.$normalizedExtension';

      await _client.storage
          .from('assets')
          .uploadBinary(
        filePath,
        bytes,
        fileOptions: FileOptions(
          contentType: contentType,
          upsert: false,
        ),
      );

      final publicUrl = _client.storage
          .from('assets')
          .getPublicUrl(filePath);

      final response = await _client
          .from('store_settings')
          .update({
        'logo_url': publicUrl,
      })
          .eq('id', settingsId)
          .select()
          .single();

      final updatedSettings =
      AdminStoreSettingsModel.fromMap(
        Map<String, dynamic>.from(response),
      );

      if (oldLogoUrl != null &&
          oldLogoUrl.trim().isNotEmpty) {
        await _deleteLogoByUrl(
          oldLogoUrl,
        );
      }

      return updatedSettings;
    } catch (e) {
      if (e is PostgrestException) {
        throw Exception(
          'ذخیره لوگوی فروشگاه با مشکل مواجه شد.',
        );
      }

      throw Exception(
        'آپلود لوگوی فروشگاه با مشکل مواجه شد.',
      );
    }
  }

  Future<AdminStoreSettingsModel> removeLogo({
    required String settingsId,
    required String? logoUrl,
  }) async {
    try {
      final response = await _client
          .from('store_settings')
          .update({
        'logo_url': null,
      })
          .eq('id', settingsId)
          .select()
          .single();

      final updatedSettings =
      AdminStoreSettingsModel.fromMap(
        Map<String, dynamic>.from(response),
      );

      if (logoUrl != null &&
          logoUrl.trim().isNotEmpty) {
        await _deleteLogoByUrl(
          logoUrl,
        );
      }

      return updatedSettings;
    } catch (e) {
      if (e is PostgrestException) {
        throw Exception(
          'حذف لوگوی فروشگاه با مشکل مواجه شد.',
        );
      }

      throw Exception(
        'حذف لوگوی فروشگاه با مشکل مواجه شد.',
      );
    }
  }

  Future<void> _deleteLogoByUrl(
      String logoUrl,
      ) async {
    try {
      final marker =
          '/storage/v1/object/public/assets/';

      final index = logoUrl.indexOf(marker);

      if (index == -1) {
        return;
      }

      final filePath =
      logoUrl.substring(
        index + marker.length,
      );

      if (filePath.isEmpty ||
          !filePath.startsWith('store/')) {
        return;
      }

      await _client.storage
          .from('assets')
          .remove([
        filePath,
      ]);
    } catch (_) {
      // حذف فایل قبلی نباید باعث
      // شکست ذخیره لوگوی جدید شود.
    }
  }
}