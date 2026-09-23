class AdminGeneralSettingsEntity {
  const AdminGeneralSettingsEntity({
    required this.id,
    required this.appName,
    required this.maintenanceMode,
    required this.registrationEnabled,
    required this.shoppingEnabled,
    required this.showUnavailableProducts,
    required this.reviewsEnabled,
    required this.verifiedPurchaseReviewsOnly,
    required this.minimumOrderAmount,
    required this.maxCartQuantity,
    required this.maintenanceMessage,
    required this.createdAt,
    required this.updatedAt,
    required this.singleton,
  });

  final String id;
  final String appName;
  final bool maintenanceMode;
  final bool registrationEnabled;
  final bool shoppingEnabled;
  final bool showUnavailableProducts;
  final bool reviewsEnabled;
  final bool verifiedPurchaseReviewsOnly;
  final int minimumOrderAmount;
  final int maxCartQuantity;
  final String maintenanceMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool singleton;
}