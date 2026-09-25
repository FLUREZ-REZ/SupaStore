class AdminAccessEntity {
  const AdminAccessEntity({
    required this.userId,
    required this.isAdmin,
    required this.adminRole,
    required this.isActive,
  });

  final String userId;
  final bool isAdmin;
  final String adminRole;
  final bool isActive;

  bool get canAccessAdmin =>
      isAdmin && isActive && adminRole != 'none';

  bool get isSuperAdmin =>
      adminRole == 'super_admin';

  bool get isOrderManager =>
      adminRole == 'order_manager';

  bool get isProductManager =>
      adminRole == 'product_manager';
}