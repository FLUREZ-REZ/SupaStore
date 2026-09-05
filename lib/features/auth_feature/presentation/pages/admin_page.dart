import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/auth_feature/data/repositories/auth_repository_impl.dart';
import 'package:supastore/features/auth_feature/data/services/auth_role_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({
    super.key,
  });

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _isCheckingAccess = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();

    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final authRepository = AuthRepository();

    if (!authRepository.isLoggedIn) {
      if (!mounted) return;

      context.go('/auth');
      return;
    }

    final authRoleService =
    getIt<AuthRoleService>();

    final isAdmin =
    await authRoleService.isCurrentUserAdmin();

    if (!mounted) return;

    if (!isAdmin) {
      context.go('/home');
      return;
    }

    setState(() {
      _isAdmin = true;
      _isCheckingAccess = false;
    });
  }

  Future<void> _logout() async {
    final authRepository = AuthRepository();

    await authRepository.signOut();

    if (!mounted) return;

    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAccess) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAdmin) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'پنل مدیریت',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(
              Icons.logout,
            ),
            tooltip: 'خروج',
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'به پنل مدیریت SupaStore خوش آمدید',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}