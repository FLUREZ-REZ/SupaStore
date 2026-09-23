import '../../domain/entities/admin_general_settings_entity.dart';

class AdminGeneralSettingsModel
    extends AdminGeneralSettingsEntity {
  const AdminGeneralSettingsModel({
    required super.id,
    required super.appName,
    required super.maintenanceMode,
    required super.registrationEnabled,
    required super.shoppingEnabled,
    required super.showUnavailableProducts,
    required super.reviewsEnabled,
    required super.verifiedPurchaseReviewsOnly,
    required super.minimumOrderAmount,
    required super.maxCartQuantity,
    required super.maintenanceMessage,
    required super.createdAt,
    required super.updatedAt,
    required super.singleton,
  });

  factory AdminGeneralSettingsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AdminGeneralSettingsModel(
      id: json['id'] as String,
      appName: json['app_name'] as String? ?? 'SupaStore',
      maintenanceMode:
      json['maintenance_mode'] as bool? ?? false,
      registrationEnabled:
      json['registration_enabled'] as bool? ?? true,
      shoppingEnabled:
      json['shopping_enabled'] as bool? ?? true,
      showUnavailableProducts:
      json['show_unavailable_products'] as bool? ?? true,
      reviewsEnabled:
      json['reviews_enabled'] as bool? ?? true,
      verifiedPurchaseReviewsOnly:
      json['verified_purchase_reviews_only'] as bool? ?? false,
      minimumOrderAmount:
      (json['minimum_order_amount'] as num?)?.toInt() ?? 0,
      maxCartQuantity:
      (json['max_cart_quantity'] as num?)?.toInt() ?? 20,
      maintenanceMessage:
      json['maintenance_message'] as String? ??
          'فروشگاه در حال بروزرسانی است. لطفاً بعداً دوباره مراجعه کنید.',
      createdAt:
      DateTime.parse(json['created_at'] as String),
      updatedAt:
      DateTime.parse(json['updated_at'] as String),
      singleton:
      json['singleton'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_name': appName,
      'maintenance_mode': maintenanceMode,
      'registration_enabled': registrationEnabled,
      'shopping_enabled': shoppingEnabled,
      'show_unavailable_products': showUnavailableProducts,
      'reviews_enabled': reviewsEnabled,
      'verified_purchase_reviews_only':
      verifiedPurchaseReviewsOnly,
      'minimum_order_amount': minimumOrderAmount,
      'max_cart_quantity': maxCartQuantity,
      'maintenance_message': maintenanceMessage,
    };
  }
}