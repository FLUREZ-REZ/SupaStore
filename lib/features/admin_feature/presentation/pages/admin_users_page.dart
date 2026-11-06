
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import 'package:supastore/features/admin_feature/Users/domain/entities/admin_user.dart';
import 'package:supastore/features/admin_feature/Users/presentation/pages/admin_user_details_page.dart';
import 'package:supastore/features/admin_feature/Users/presentation/providers/admin_user_provider.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  static const Color _primaryColor = Color(0xFF03045E);
  static const Color _secondaryColor = Color(0xFF0077B6);
  static const Color _dangerColor = Color(0xFFE21B23);

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _scrollController = ScrollController();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AdminUserProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      final provider = context.read<AdminUserProvider>();

      if (!provider.isLoading &&
          !provider.isLoadingMore &&
          provider.hasMore) {
        provider.loadUsers();
      }
    }
  }

  void _onSearchChanged(String value) {
    context.read<AdminUserProvider>().loadUsers(
      search: value,
    );
  }

  void _clearSearch() {
    _searchController.clear();

    context.read<AdminUserProvider>().loadUsers(
      search: '',
    );

    setState(() {});
  }

  Future<void> _refresh() async {
    await context.read<AdminUserProvider>().refreshUsers();
  }

  void _openUserDetails(AdminUser user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminUserDetailsPage(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<AdminUserProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildHeader(provider),
              Expanded(
                child: _buildBody(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader(AdminUserProvider provider) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
          constraints.maxWidth >= 900 ? 24.0 : 0.0;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1100,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            textDirection: TextDirection.rtl,
                            textInputAction: TextInputAction.search,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText:
                              'جستجوی نام یا شماره موبایل...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                size: 22,
                                color: Colors.grey.shade600,
                              ),
                              suffixIcon:
                              _searchController.text.isNotEmpty
                                  ? IconButton(
                                onPressed: _clearSearch,
                                icon: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: Colors.grey.shade600,
                                ),
                              )
                                  : null,
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding:
                              const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 13,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: _dangerColor,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildRefreshButton(provider),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${provider.users.length} کاربر',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRefreshButton(AdminUserProvider provider) {
    final isLoading = provider.isLoading || provider.isLoadingMore;

    return Material(
      color: _secondaryColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isLoading ? null : _refresh,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(
              Iconsax.refresh_copy,
              color: Colors.white,
              size: 23,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BODY
  // ---------------------------------------------------------------------------

  Widget _buildBody(AdminUserProvider provider) {
    if (provider.isLoading && provider.users.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF023E8A),
        ),
      );
    }

    if (provider.error != null && provider.users.isEmpty) {
      return _buildErrorState(provider);
    }

    if (provider.users.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: const Color(0xFF023E8A),
      onRefresh: _refresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
          constraints.maxWidth >= 900 ? 24.0 : 16.0;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1100,
              ),
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  12,
                  horizontalPadding,
                  24,
                ),
                itemCount: provider.users.length +
                    (provider.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= provider.users.length) {
                    return _buildLoadingMore();
                  }

                  final user = provider.users[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildUserCard(user),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // USER CARD
  // ---------------------------------------------------------------------------

  Widget _buildUserCard(AdminUser user) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openUserDetails(user),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _buildAvatar(user),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUserInfo(user),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_left,
                size: 24,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(AdminUser user) {
    final avatarUrl = user.avatarUrl;

    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      return Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: user.isAdmin
                ? _secondaryColor
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: avatarUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) {
              return Container(
                color: Colors.grey.shade100,
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _dangerColor,
                  ),
                ),
              );
            },
            errorWidget: (context, url, error) {
              return _buildDefaultAvatar(user);
            },
          ),
        ),
      );
    }

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: user.isAdmin
            ? _primaryColor.withValues(alpha: 0.08)
            : Colors.grey.shade100,
        border: Border.all(
          color: user.isAdmin
              ? _secondaryColor
              : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: _buildDefaultAvatar(user),
    );
  }

  Widget _buildDefaultAvatar(AdminUser user) {
    return Icon(
      user.isAdmin
          ? Iconsax.shield_tick_copy
          : Iconsax.user_copy,
      size: 30,
      color: user.isAdmin
          ? _primaryColor
          : Colors.grey.shade500,
    );
  }

  Widget _buildUserInfo(AdminUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getDisplayName(user),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 5),
        if (user.phone != null && user.phone!.trim().isNotEmpty)
          Text(
            user.phone!,
            textDirection: TextDirection.ltr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          )
        else
          Text(
            'شماره موبایل ثبت نشده',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        const SizedBox(height: 8),
        _buildRoleBadge(user),
      ],
    );
  }

  Widget _buildRoleBadge(AdminUser user) {
    final isAdmin = user.isAdmin;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isAdmin
            ? const Color(0xFFADE8F4).withValues(alpha: 0.88)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin
                ? Iconsax.shield_tick_copy
                : Iconsax.user_copy,
            size: 15,
            color: isAdmin
                ? _primaryColor
                : Colors.grey.shade600,
          ),
          const SizedBox(width: 5),
          Text(
            isAdmin ? 'مدیر' : 'کاربر',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isAdmin
                  ? _primaryColor
                  : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOADING MORE
  // ---------------------------------------------------------------------------

  Widget _buildLoadingMore() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _primaryColor,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ERROR STATE
  // ---------------------------------------------------------------------------

  Widget _buildErrorState(AdminUserProvider provider) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _dangerColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 36,
                  color: _dangerColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'دریافت کاربران با مشکل مواجه شد',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _cleanErrorMessage(provider.error),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {
                    provider.loadUsers(refresh: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dangerColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(
                    Iconsax.refresh_copy,
                    size: 19,
                  ),
                  label: const Text(
                    'تلاش مجدد',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    final hasSearch = _searchController.text.trim().isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasSearch
                      ? Icons.search_off
                      : Iconsax.people_copy,
                  size: 40,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                hasSearch
                    ? 'کاربری پیدا نشد'
                    : 'هنوز کاربری وجود ندارد',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasSearch
                    ? 'برای جستجوی خود عبارت دیگری را امتحان کنید.'
                    : 'کاربران ثبت‌نام‌شده در این بخش نمایش داده می‌شوند.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  String _getDisplayName(AdminUser user) {
    if (user.fullName != null && user.fullName!.trim().isNotEmpty) {
      return user.fullName!.trim();
    }

    if (user.phone != null && user.phone!.trim().isNotEmpty) {
      return user.phone!.trim();
    }

    return 'کاربر بدون نام';
  }

  String _cleanErrorMessage(String? error) {
    if (error == null || error.trim().isEmpty) {
      return 'لطفاً اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.';
    }

    var message = error.trim();

    if (message.startsWith('Exception:')) {
      message = message.substring('Exception:'.length).trim();
    }

    return message;
  }
}
