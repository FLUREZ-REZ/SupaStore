
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

import '../providers/admin_payment_settings_provider.dart';

class AdminPaymentSettingsPage extends StatelessWidget {
  const AdminPaymentSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminPaymentSettingsProvider>(
      create: (_) => getIt<AdminPaymentSettingsProvider>()..loadSettings(),
      child: const _AdminPaymentSettingsView(),
    );
  }
}

class _AdminPaymentSettingsView extends StatefulWidget {
  const _AdminPaymentSettingsView();

  @override
  State<_AdminPaymentSettingsView> createState() =>
      _AdminPaymentSettingsViewState();
}

class _AdminPaymentSettingsViewState
    extends State<_AdminPaymentSettingsView> {
  bool _onlinePaymentEnabled = true;
  bool _zarinpalEnabled = true;
  bool _sepEnabled = true;
  String _defaultGateway = 'zarinpal';

  bool _initialized = false;

  static const Color _primaryColor = Color(0xFF03045E);
  static const Color _backgroundColor = Color(0xFFF7F7F8);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminPaymentSettingsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.settings == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null && provider.settings == null) {
          return _buildErrorState(context, provider);
        }

        final settings = provider.settings;

        if (settings == null) {
          return _buildEmptyState(context, provider);
        }

        if (!_initialized) {
          _onlinePaymentEnabled = settings.onlinePaymentEnabled;
          _zarinpalEnabled = settings.zarinpalEnabled;
          _sepEnabled = settings.sepEnabled;
          _defaultGateway = settings.defaultGateway;
          _initialized = true;
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: _backgroundColor,
            appBar: AppBar(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              title: Text(
                'تنظیمات پرداخت',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                _initialized = false;
                await provider.loadSettings();
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final isDesktop = width >= 1000;
                  final horizontalPadding = width >= 1200
                      ? 32.0
                      : width >= 650
                      ? 24.0
                      : 16.0;

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 24,
                    ),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 1100,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (isDesktop) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildOnlinePaymentCard(
                                        context,
                                        provider,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: _buildGatewaysCard(
                                        context,
                                        provider,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildDefaultGatewayCard(
                                  context,
                                  provider,
                                ),
                              ] else ...[
                                _buildOnlinePaymentCard(
                                  context,
                                  provider,
                                ),
                                const SizedBox(height: 16),
                                _buildGatewaysCard(
                                  context,
                                  provider,
                                ),
                                const SizedBox(height: 16),
                                _buildDefaultGatewayCard(
                                  context,
                                  provider,
                                ),
                              ],
                              const SizedBox(height: 24),
                              Align(
                                alignment: Alignment.center,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: isDesktop ? 420 : double.infinity,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: _buildSaveButton(
                                      context,
                                      provider,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOnlinePaymentCard(
      BuildContext context,
      AdminPaymentSettingsProvider provider,
      ) {
    return _buildSectionCard(
      title: 'پرداخت آنلاین',
      icon: Icons.payment_rounded,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          'فعال بودن پرداخت آنلاین',
          style: AppTextStyles.otp_title.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _onlinePaymentEnabled
              ? 'پرداخت آنلاین برای کاربران فعال است.'
              : 'پرداخت آنلاین برای کاربران غیرفعال است.',
          style: AppTextStyles.body.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        value: _onlinePaymentEnabled,
        activeColor: _primaryColor,
        onChanged: provider.isSaving
            ? null
            : (value) {
          setState(() {
            _onlinePaymentEnabled = value;
          });
        },
      ),
    );
  }

  Widget _buildGatewaysCard(
      BuildContext context,
      AdminPaymentSettingsProvider provider,
      ) {
    return _buildSectionCard(
      title: 'درگاه‌های پرداخت',
      icon: Icons.account_balance_rounded,
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'زرین‌پال',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'فعال بودن درگاه زرین‌پال',
              style: AppTextStyles.body.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            value: _zarinpalEnabled,
            activeColor: _primaryColor,
            onChanged: provider.isSaving
                ? null
                : (value) {
              setState(() {
                _zarinpalEnabled = value;

                if (!value &&
                    _defaultGateway == 'zarinpal' &&
                    _sepEnabled) {
                  _defaultGateway = 'sep';
                }
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'سامان (SEP)',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'فعال بودن درگاه سامان',
              style: AppTextStyles.body.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            value: _sepEnabled,
            activeColor: _primaryColor,
            onChanged: provider.isSaving
                ? null
                : (value) {
              setState(() {
                _sepEnabled = value;

                if (!value &&
                    _defaultGateway == 'sep' &&
                    _zarinpalEnabled) {
                  _defaultGateway = 'zarinpal';
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultGatewayCard(
      BuildContext context,
      AdminPaymentSettingsProvider provider,
      ) {
    final gateways = <String, String>{};

    if (_zarinpalEnabled) {
      gateways['zarinpal'] = 'زرین‌پال';
    }

    if (_sepEnabled) {
      gateways['sep'] = 'سامان (SEP)';
    }

    final selectedGateway = gateways.containsKey(_defaultGateway)
        ? _defaultGateway
        : gateways.isNotEmpty
        ? gateways.keys.first
        : null;

    if (selectedGateway != null && selectedGateway != _defaultGateway) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        setState(() {
          _defaultGateway = selectedGateway;
        });
      });
    }

    return _buildSectionCard(
      title: 'درگاه پیش‌فرض',
      icon: Icons.star_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'درگاه پیش‌فرض برای پرداخت آنلاین کاربران را انتخاب کنید.',
            style: AppTextStyles.body.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          if (gateways.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.orange.shade200,
                ),
              ),
              child: Text(
                'حداقل یک درگاه پرداخت باید فعال باشد.',
                style: AppTextStyles.body.copyWith(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            DropdownButtonFormField<String>(
              value: selectedGateway,
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: gateways.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: provider.isSaving
                  ? null
                  : (value) {
                if (value == null) return;

                setState(() {
                  _defaultGateway = value;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(
      BuildContext context,
      AdminPaymentSettingsProvider provider,
      ) {
    final canSave = _zarinpalEnabled || _sepEnabled;

    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: provider.isSaving || !canSave
            ? null
            : () => _save(context, provider),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: provider.isSaving
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
          'ذخیره تنظیمات',
          style: AppTextStyles.body.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _save(
      BuildContext context,
      AdminPaymentSettingsProvider provider,
      ) async {
    if (!_zarinpalEnabled && !_sepEnabled) {
      _showMessage(
        context,
        'حداقل یک درگاه پرداخت باید فعال باشد.',
        isError: true,
      );
      return;
    }

    if (!_onlinePaymentEnabled) {
      // در این حالت درگاه پیش‌فرض همچنان ذخیره می‌شود
      // تا با فعال کردن مجدد پرداخت آنلاین،
      // تنظیم قبلی حفظ شود.
    }

    final success = await provider.saveSettings(
      onlinePaymentEnabled: _onlinePaymentEnabled,
      zarinpalEnabled: _zarinpalEnabled,
      sepEnabled: _sepEnabled,
      defaultGateway: _defaultGateway,
    );

    if (!context.mounted) return;

    if (success) {
      _showMessage(
        context,
        'تنظیمات پرداخت با موفقیت ذخیره شد.',
      );
    } else if (provider.error != null) {
      _showMessage(
        context,
        provider.error!,
        isError: true,
      );
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context,
      AdminPaymentSettingsProvider provider,
      ) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 52,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              Text(
                provider.error ?? 'خطایی رخ داد.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : provider.loadSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context,
      AdminPaymentSettingsProvider provider,
      ) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.settings_outlined,
                size: 52,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 12),
              Text(
                'تنظیمات پرداخت پیدا نشد.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: provider.loadSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('بارگذاری مجدد'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(
      BuildContext context,
      String message, {
        bool isError = false,
      }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
