import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:supastore/features/admin_feature/admin_general_settings_feature/presentation/pages/maintenance_page.dart';
import 'package:supastore/features/admin_feature/admin_general_settings_feature/presentation/providers/general_settings_provider.dart';

class GeneralSettingsShell extends StatelessWidget {
  const GeneralSettingsShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<GeneralSettingsProvider>(
      builder: (
          context,
          settingsProvider,
          _,
          ) {
        // ------------------------------------------------------
        // Loading
        // ------------------------------------------------------

        if (settingsProvider.isLoading &&
            !settingsProvider.hasSettings) {
          return const _GeneralSettingsLoading();
        }

        // ------------------------------------------------------
        // Maintenance Mode
        // ------------------------------------------------------

        if (settingsProvider.maintenanceMode) {
          return MaintenancePage(
            message:
            settingsProvider.maintenanceMessage,
          );
        }

        // ------------------------------------------------------
        // Normal User App
        // ------------------------------------------------------

        return child;
      },
    );
  }
}

class _GeneralSettingsLoading extends StatelessWidget {
  const _GeneralSettingsLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}