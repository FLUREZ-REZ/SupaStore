
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/notifications_provider.dart';

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

      setState(() {
        _hasAccess =
            role == 'super_admin' || role == 'product_manager';
        _isCheckingAccess = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _hasAccess = false;
        _isCheckingAccess = false;
      });
    }
  }

  Future<void> _publishAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<NotificationsProvider>();

    final success = await provider.publishAnnouncement(
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      _titleController.clear();
      _bodyController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اطلاعیه با موفقیت منتشر شد.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'انتشار اطلاعیه ناموفق بود.',
          ),
          backgroundColor: _primaryColor,
        ),
      );
    }
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
        appBar: AppBar(
          title: const Text('مدیریت اطلاعیه‌ها'),
          centerTitle: true,
        ),
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
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'انتشار اطلاعیه جدید',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'این اطلاعیه برای کاربران فروشگاه نمایش داده می‌شود.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                            if (value == null ||
                                value.trim().isEmpty) {
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
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'متن اطلاعیه را وارد کنید.';
                            }

                            if (value.trim().length > 10000) {
                              return 'متن اطلاعیه بیش از حد طولانی است.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting
                                ? null
                                : _publishAnnouncement,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
