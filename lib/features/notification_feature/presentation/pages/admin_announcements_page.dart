import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/features/notification_feature/domain/entities/admin_announcement_entity.dart';
import 'package:supastore/features/notification_feature/presentation/providers/notifications_provider.dart';

class AdminAnnouncementsPage extends StatefulWidget {
  const AdminAnnouncementsPage({super.key});

  @override
  State<AdminAnnouncementsPage> createState() =>
      _AdminAnnouncementsPageState();
}

class _AdminAnnouncementsPageState
    extends State<AdminAnnouncementsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _isCheckingAccess = true;
  bool _hasAccess = false;
  bool _isSubmitting = false;

  DateTime? _expiresAt;

  static const Color _primaryColor = Color(0xFFE21B23);
  static const Color _backgroundColor = Color(0xFFF7F7F8);
  static const Color _textColor = Color(0xFF202124);
  static const Color _mutedColor = Color(0xFF777B84);
  static const Color _borderColor = Color(0xFFE9EAEE);

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _hasAccess = false;
          _isCheckingAccess = false;
        });
        return;
      }

      final role = await supabase.rpc('current_admin_role');

      if (!mounted) return;

      final hasAccess =
          role == 'super_admin' || role == 'product_manager';

      setState(() {
        _hasAccess = hasAccess;
        _isCheckingAccess = false;
      });

      if (hasAccess) {
        await context
            .read<NotificationsProvider>()
            .loadAdminAnnouncements(refresh: true);
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _hasAccess = false;
        _isCheckingAccess = false;
      });
    }
  }

  Future<void> _selectExpirationDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _expiresAt != null && _expiresAt!.isAfter(now)
          ? _expiresAt!
          : now.add(const Duration(days: 7)),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 10),
      helpText: 'انتخاب تاریخ انقضا',
      cancelText: 'لغو',
      confirmText: 'ادامه',
    );

    if (!mounted || selectedDate == null) return;

    final initialTime = _expiresAt != null &&
        _expiresAt!.year == selectedDate.year &&
        _expiresAt!.month == selectedDate.month &&
        _expiresAt!.day == selectedDate.day
        ? TimeOfDay.fromDateTime(_expiresAt!)
        : const TimeOfDay(hour: 23, minute: 59);

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'انتخاب ساعت انقضا',
      cancelText: 'لغو',
      confirmText: 'تأیید',
    );

    if (!mounted || selectedTime == null) return;

    final expiration = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (!expiration.isAfter(DateTime.now())) {
      _showSnackBar(
        'تاریخ و ساعت انقضا باید در آینده باشد.',
      );
      return;
    }

    setState(() {
      _expiresAt = expiration;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final date = dateTime.toLocal();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$year/$month/$day - $hour:$minute';
  }

  Future<void> _publishAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    if (_expiresAt != null &&
        !_expiresAt!.isAfter(DateTime.now())) {
      _showSnackBar('تاریخ انقضا باید در آینده باشد.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<NotificationsProvider>();

    try {
      final success = await provider.publishAnnouncement(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        expiresAt: _expiresAt,
      );

      if (!mounted) return;

      if (success) {
        _titleController.clear();
        _bodyController.clear();

        setState(() {
          _expiresAt = null;
        });

        _showSnackBar(
          'اطلاعیه با موفقیت منتشر شد.',
          backgroundColor: Colors.green,
        );
      } else {
        _showSnackBar(
          provider.errorMessage ?? 'انتشار اطلاعیه ناموفق بود.',
        );
      }
    } catch (_) {
      if (!mounted) return;

      _showSnackBar('انتشار اطلاعیه ناموفق بود.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _refreshAnnouncements() async {
    await context
        .read<NotificationsProvider>()
        .loadAdminAnnouncements(refresh: true);
  }

  Future<void> _confirmDeleteAnnouncement(
      AdminAnnouncementEntity announcement,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            icon: const Icon(
              Iconsax.profile_delete_copy,
              color: _primaryColor,
              size: 30,
            ),
            title: const Text(
              'حذف اطلاعیه',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: Text(
              'آیا از حذف اطلاعیه «${announcement.title}» مطمئن هستید؟\n\n'
                  'این عملیات قابل بازگشت نیست.',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                height: 1.8,
                color: _mutedColor,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('انصراف'),
              ),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                icon: const Icon(Iconsax.profile_delete_copy, size: 18),
                label: const Text('حذف اطلاعیه'),
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || confirmed != true) return;

    final provider = context.read<NotificationsProvider>();

    final success =
    await provider.deleteAnnouncement(announcement.id);

    if (!mounted) return;

    if (success) {
      _showSnackBar(
        'اطلاعیه با موفقیت حذف شد.',
        backgroundColor: Colors.green,
      );
    } else {
      _showSnackBar(
        provider.deleteAnnouncementErrorMessage ??
            'حذف اطلاعیه ناموفق بود.',
      );
    }
  }

  void _showSnackBar(
      String message, {
        Color backgroundColor = _primaryColor,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAccess) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: _backgroundColor,
          body: Center(
            child: CircularProgressIndicator(
              color: _primaryColor,
            ),
          ),
        ),
      );
    }

    if (!_hasAccess) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: _backgroundColor,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildEmptyState(
                icon: Iconsax.lock_copy,
                title: 'دسترسی امکان‌پذیر نیست',
                message:
                'حساب شما اجازه ورود به بخش مدیریت اطلاعیه‌ها را ندارد.',
              ),
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: _textColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleSpacing: 20,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اطلاعیه‌ها',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'مدیریت پیام‌های فروشگاه',
                style: TextStyle(
                  fontSize: 11,
                  color: _mutedColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'تازه‌سازی فهرست',
              onPressed: _refreshAnnouncements,
              icon: const Icon(Iconsax.refresh_copy),
            ),
            const SizedBox(width: 8),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(
              height: 1,
              thickness: 1,
              color: _borderColor,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              _buildPublishForm(),
              const SizedBox(height: 24),
              _buildAnnouncementsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeading({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: _primaryColor,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: _textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: _mutedColor,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    IconData? icon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: alignLabelWithHint,
      prefixIcon: icon == null ? null : Icon(icon, size: 20),
      filled: true,
      fillColor: const Color(0xFFFAFAFB),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      labelStyle: const TextStyle(
        fontSize: 13,
        color: Color(0xFF626773),
      ),
      hintStyle: const TextStyle(
        fontSize: 13,
        color: Color(0xFF9A9DA5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4E6EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4E6EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _primaryColor,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _primaryColor,
          width: 1.4,
        ),
      ),
      counterStyle: const TextStyle(
        fontSize: 10,
        color: Color(0xFF858994),
      ),
    );
  }

  Widget _buildPublishForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeading(
              title: 'انتشار اطلاعیه جدید',
              subtitle: 'پیامی برای کاربران فروشگاه آماده کنید.',
              icon: Iconsax.notification_copy,
            ),
            const SizedBox(height: 22),
            const _FieldLabel(text: 'عنوان اطلاعیه'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              maxLength: 200,
              textInputAction: TextInputAction.next,
              textAlign: TextAlign.right,
              decoration: _inputDecoration(
                label: 'عنوان',
                hint: 'مثلاً تخفیف ویژه آخر هفته',
                icon: Iconsax.subtitle_copy,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'عنوان اطلاعیه را وارد کنید.';
                }
                if (value.trim().length > 200) {
                  return 'عنوان نباید بیشتر از ۲۰۰ کاراکتر باشد.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            const _FieldLabel(text: 'متن پیام'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bodyController,
              maxLength: 10000,
              minLines: 4,
              maxLines: 7,
              textAlign: TextAlign.right,
              textAlignVertical: TextAlignVertical.top,
              decoration: _inputDecoration(
                label: 'متن اطلاعیه',
                hint: 'متن پیام را بنویسید...',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'متن اطلاعیه را وارد کنید.';
                }
                if (value.trim().length > 10000) {
                  return 'متن اطلاعیه بیش از حد طولانی است.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _buildExpirationSelector(),
            const SizedBox(height: 18),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed:
                _isSubmitting ? null : _publishAnnouncement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  disabledBackgroundColor: const Color(0xFFE9A0A3),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text('در حال انتشار...'),
                  ],
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.send_1_copy, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'انتشار اطلاعیه',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpirationSelector() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E8EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Iconsax.calendar_2_copy,
                color: _primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'تاریخ انقضا',
                  style: TextStyle(
                    color: Color(0xFF30333A),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              if (_expiresAt != null)
                TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => setState(() => _expiresAt = null),
                  style: TextButton.styleFrom(
                    foregroundColor: _primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('حذف تاریخ'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _expiresAt == null
                ? 'بدون انقضا؛ تا زمان غیرفعال‌سازی نمایش داده می‌شود.'
                : 'انقضا: ${_formatDateTime(_expiresAt!)}',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _mutedColor,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed:
            _isSubmitting ? null : _selectExpirationDate,
            icon: const Icon(
              Iconsax.calendar_2_copy,
              size: 18,
            ),
            label: Text(
              _expiresAt == null
                  ? 'تعیین تاریخ انقضا'
                  : 'تغییر تاریخ و ساعت',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF333741),
              side: const BorderSide(color: Color(0xFFDCDDE2)),
              minimumSize: const Size(0, 42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    return Consumer<NotificationsProvider>(
      builder: (context, provider, child) {
        final announcements = provider.adminAnnouncements;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSectionHeading(
                      title: 'اطلاعیه‌های ثبت‌شده',
                      subtitle:
                      'مدیریت پیام‌های منتشرشده و زمان‌بندی‌شده',
                      icon: Iconsax.notification_copy,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'تازه‌سازی',
                    onPressed:
                    provider.isLoadingAdminAnnouncements
                        ? null
                        : _refreshAnnouncements,
                    icon: const Icon(Iconsax.refresh_copy),
                    style: IconButton.styleFrom(
                      foregroundColor: const Color(0xFF555B66),
                      backgroundColor: const Color(0xFFF5F6F8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (provider.isLoadingAdminAnnouncements &&
                  announcements.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _primaryColor,
                    ),
                  ),
                )
              else if (provider.adminAnnouncementsErrorMessage != null &&
                  announcements.isEmpty)
                _buildListError(
                  provider.adminAnnouncementsErrorMessage!,
                  _refreshAnnouncements,
                )
              else if (announcements.isEmpty)
                  _buildEmptyState(
                    icon: Iconsax.notification_status_copy,
                    title: 'هنوز اطلاعیه‌ای ندارید',
                    message:
                    'بعد از انتشار، اطلاعیه‌ها در این بخش نمایش داده می‌شوند.',
                  )
                else ...[
                    for (final announcement in announcements)
                      _buildAnnouncementCard(announcement, provider),
                    if (provider.adminAnnouncementsErrorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          provider.adminAnnouncementsErrorMessage!,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: _primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (provider.adminAnnouncementsHasMore)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: OutlinedButton(
                          onPressed:
                          provider.isLoadingMoreAdminAnnouncements
                              ? null
                              : provider.loadMoreAdminAnnouncements,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF333741),
                            side: const BorderSide(
                              color: Color(0xFFE0E2E7),
                            ),
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          child:
                          provider.isLoadingMoreAdminAnnouncements
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'نمایش اطلاعیه‌های بیشتر',
                          ),
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(top: 14),
                        child: Center(
                          child: Text(
                            'همه اطلاعیه‌ها نمایش داده شدند.',
                            style: TextStyle(
                              color: Color(0xFF858994),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                  ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 34,
            color: const Color(0xFF9A9DA5),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF30333A),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _mutedColor,
              height: 1.6,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListError(
      String message,
      Future<void> Function() onRetry,
      ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF6D7D8)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: _primaryColor,
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('تلاش دوباره'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(
      AdminAnnouncementEntity announcement,
      NotificationsProvider provider,
      ) {
    final status = _getAnnouncementStatus(announcement);
    final isDeleting =
    provider.isDeletingAnnouncement(announcement.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E9ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  announcement.title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF252830),
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    color: status.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              SizedBox(
                width: 34,
                height: 34,
                child: IconButton(
                  tooltip: 'حذف اطلاعیه',
                  padding: EdgeInsets.zero,
                  onPressed: isDeleting
                      ? null
                      : () =>
                      _confirmDeleteAnnouncement(announcement),
                  icon: isDeleting
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _primaryColor,
                    ),
                  )
                      : const Icon(
                    Iconsax.trash_copy,
                    color: _primaryColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            announcement.body,
            textAlign: TextAlign.right,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF5E626C),
              fontSize: 12,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            color: Color(0xFFEDEEF1),
          ),
          const SizedBox(height: 10),
          _buildMetadataRow(
            Iconsax.send_1_copy,
            'انتشار',
            _formatDateTime(announcement.publishedAt),
          ),
          const SizedBox(height: 7),
          _buildMetadataRow(
            Iconsax.clock_copy,
            'ایجاد',
            _formatDateTime(announcement.createdAt),
          ),
          const SizedBox(height: 7),
          _buildMetadataRow(
            Iconsax.calendar_2_copy,
            'انقضا',
            announcement.expiresAt == null
                ? 'بدون انقضا'
                : _formatDateTime(announcement.expiresAt!),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 15,
          color: const Color(0xFF8A8E97),
        ),
        const SizedBox(width: 7),
        SizedBox(
          width: 48,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF858994),
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF454953),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  _AnnouncementStatus _getAnnouncementStatus(
      AdminAnnouncementEntity announcement,
      ) {
    if (!announcement.isPublished) {
      return const _AnnouncementStatus(
        'منتشرنشده',
        Color(0xFF777B84),
      );
    }

    if (announcement.isExpired) {
      return const _AnnouncementStatus(
        'منقضی‌شده',
        Color(0xFFD32F2F),
      );
    }

    if (announcement.isScheduled) {
      return const _AnnouncementStatus(
        'زمان‌بندی‌شده',
        Color(0xFFB7791F),
      );
    }

    return const _AnnouncementStatus(
      'فعال',
      Color(0xFF218653),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.right,
      style: const TextStyle(
        color: Color(0xFF41454F),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _AnnouncementStatus {
  final String label;
  final Color color;

  const _AnnouncementStatus(this.label, this.color);
}