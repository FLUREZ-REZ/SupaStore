import 'package:supastore/features/admin_feature/dashboard/domain/entities/admin_dashboard_entity.dart';

abstract class AdminDashboardRepository {
  Future<AdminDashboardEntity> getDashboardData();
}