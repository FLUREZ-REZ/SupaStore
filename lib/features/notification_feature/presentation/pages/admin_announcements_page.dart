
import 'package:flutter/material.dart';
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
        backgroundColor: _primaryColor,
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
      _showSnackBar(
        'تاریخ انقضا باید در آینده باشد.',
        backgroundColor: _primaryColor,
      );
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
          backgroundColor: _primaryColor,
        );
      }
    } catch (_) {
      if (!mounted) return;

      _showSnackBar(
        'انتشار اطلاعیه ناموفق بود.',
        backgroundColor: _primaryColor,
      );
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
        return AlertDialog(
          title: const Text('حذف اطلاعیه'),
          content: Text(
            'آیا از حذف اطلاعیه «${announcement.title}» مطمئن هستید؟\n\n'
                'این عملیات قابل بازگشت نیست.',
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
              icon: const Icon(Icons.delete_outline),
              label: const Text('حذف'),
              style: FilledButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    final provider = context.read<NotificationsProvider>();

    final success = await provider.deleteAnnouncement(announcement.id);

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
        backgroundColor: _primaryColor,
      );
    }
  }

  void _showSnackBar(
      String message, {
        Color backgroundColor = _primaryColor,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasAccess) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'شما اجازه دسترسی به این بخش را ندارید.',
              textAlign: TextAlign.center,
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
          title: const Text('مدیریت اطلاعیه‌ها'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'تازه‌سازی فهرست',
              onPressed: _refreshAnnouncements,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
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

  Widget _buildPublishForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'انتشار اطلاعیه جدید',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'این اطلاعیه برای کاربران فروشگاه نمایش داده می‌شود.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              maxLength: 200,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'عنوان اطلاعیه',
                hintText: 'مثلاً تخفیف ویژه آخر هفته',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _bodyController,
              maxLength: 10000,
              minLines: 5,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'متن اطلاعیه',
                hintText: 'متن اطلاعیه را وارد کنید...',
                border: OutlineInputBorder(),
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
            const SizedBox(height: 20),
            _buildExpirationSelector(),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _publishAnnouncement,
                icon: _isSubmitting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.campaign_outlined),
                label: Text(
                  _isSubmitting
                      ? 'در حال انتشار...'
                      : 'انتشار اطلاعیه',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(
                Icons.event_available_outlined,
                color: _primaryColor,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تاریخ انقضای اطلاعیه',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _expiresAt == null
                ? 'بدون تاریخ انقضا؛ اطلاعیه تا زمان غیرفعال‌سازی نمایش داده می‌شود.'
                : 'انقضا: ${_formatDateTime(_expiresAt!)}',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isSubmitting ? null : _selectExpirationDate,
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(
              _expiresAt == null
                  ? 'انتخاب تاریخ انقضا'
                  : 'تغییر تاریخ انقضا',
            ),
          ),
          if (_expiresAt != null)
            TextButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : () {
                setState(() {
                  _expiresAt = null;
                });
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('حذف تاریخ انقضا'),
              style: TextButton.styleFrom(
                foregroundColor: _primaryColor,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'همه اطلاعیه‌ها',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'تازه‌سازی',
                    onPressed: provider.isLoadingAdminAnnouncements
                        ? null
                        : _refreshAnnouncements,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (provider.isLoadingAdminAnnouncements &&
                  announcements.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (provider.adminAnnouncementsErrorMessage != null &&
                  announcements.isEmpty)
                _buildListError(
                  provider.adminAnnouncementsErrorMessage!,
                  _refreshAnnouncements,
                )
              else if (announcements.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('هنوز اطلاعیه‌ای ثبت نشده است.'),
                    ),
                  )
                else ...[
                    for (final announcement in announcements)
                      _buildAnnouncementCard(announcement, provider),
                    if (provider.adminAnnouncementsErrorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          provider.adminAnnouncementsErrorMessage!,
                          style: const TextStyle(
                            color: _primaryColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    if (provider.adminAnnouncementsHasMore)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: OutlinedButton.icon(
                          onPressed: provider.isLoadingMoreAdminAnnouncements
                              ? null
                              : provider.loadMoreAdminAnnouncements,
                          icon: provider.isLoadingMoreAdminAnnouncements
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(Icons.expand_more),
                          label: Text(
                            provider.isLoadingMoreAdminAnnouncements
                                ? 'در حال بارگذاری...'
                                : 'بارگذاری بیشتر',
                          ),
                        ),
                      ),
                    if (!provider.adminAnnouncementsHasMore)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Center(
                          child: Text(
                            'همه اطلاعیه‌ها نمایش داده شدند.',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
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

  Widget _buildListError(
      String message,
      Future<void> Function() onRetry,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: _primaryColor,
            size: 36,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('تلاش مجدد'),
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
    final statusColor = status.color;
    final isDeleting =
    provider.isDeletingAnnouncement(announcement.id);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'حذف اطلاعیه',
                onPressed: isDeleting
                    ? null
                    : () => _confirmDeleteAnnouncement(announcement),
                icon: isDeleting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _primaryColor,
                  ),
                )
                    : const Icon(
                  Icons.delete_outline,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            announcement.body,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              height: 1.7,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _buildMetadataRow(
            Icons.schedule,
            'تاریخ انتشار',
            _formatDateTime(announcement.publishedAt),
          ),
          const SizedBox(height: 6),
          _buildMetadataRow(
            Icons.access_time,
            'تاریخ ایجاد',
            _formatDateTime(announcement.createdAt),
          ),
          const SizedBox(height: 6),
          _buildMetadataRow(
            Icons.event_busy_outlined,
            'تاریخ انقضا',
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
          size: 16,
          color: Colors.black54,
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
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
        Colors.grey,
      );
    }

    if (announcement.isExpired) {
      return const _AnnouncementStatus(
        'منقضی‌شده',
        Colors.red,
      );
    }

    if (announcement.isScheduled) {
      return const _AnnouncementStatus(
        'زمان‌بندی‌شده',
        Colors.orange,
      );
    }

    return const _AnnouncementStatus(
      'فعال',
      Colors.green,
    );
  }
}

class _AnnouncementStatus {
  final String label;
  final Color color;

  const _AnnouncementStatus(
      this.label,
      this.color,
      );
}
