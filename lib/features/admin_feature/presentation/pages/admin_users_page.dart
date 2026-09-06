import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supastore/features/admin_feature/Users/domain/entities/admin_user.dart';
import 'package:supastore/features/admin_feature/Users/presentation/pages/admin_user_details_page.dart';
import 'package:supastore/features/admin_feature/Users/presentation/providers/admin_user_provider.dart';


class AdminUsersPage extends StatefulWidget {
  AdminUsersPage({
    super.key,
  });

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _scrollController = ScrollController();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

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
    if (!_scrollController.hasClients) {
      return;
    }

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
        builder: (_) {
          return AdminUserDetailsPage(
            user: user,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<AdminUserProvider>(
        builder: (
            context,
            provider,
            child,
            ) {
          return Column(
            children: [
              _buildHeader(
                provider,
              ),
              Expanded(
                child: _buildBody(
                  provider,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(
      AdminUserProvider provider,
      ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        16.h,
        16.w,
        12.h,
      ),
      color: Colors.white,
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
                    hintText: 'جستجوی نام یا شماره موبایل...',
                    hintStyle: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 22.sp,
                      color: Colors.grey.shade600,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      onPressed: _clearSearch,
                      icon: Icon(
                        Icons.close,
                        size: 20.sp,
                        color: Colors.grey.shade600,
                      ),
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 13.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: Color(0xFFE21B23),
                        width: 1.w,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              _buildRefreshButton(
                provider,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${provider.users.length} کاربر',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton(
      AdminUserProvider provider,
      ) {
    final isLoading =
        provider.isLoading ||
            provider.isLoadingMore;

    return Material(
      color: Color(0xFFE21B23),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: isLoading ? null : _refresh,
        child: Container(
          width: 48.w,
          height: 48.w,
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              color: Colors.white,
            ),
          )
              : Icon(
            Icons.refresh,
            color: Colors.white,
            size: 23.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
      AdminUserProvider provider,
      ) {
    if (provider.isLoading &&
        provider.users.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE21B23),
        ),
      );
    }

    if (provider.error != null &&
        provider.users.isEmpty) {
      return _buildErrorState(
        provider,
      );
    }

    if (provider.users.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: Color(0xFFE21B23),
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16.w,
          12.h,
          16.w,
          24.h,
        ),
        itemCount: provider.users.length +
            (provider.isLoadingMore ? 1 : 0),
        itemBuilder: (
            context,
            index,
            ) {
          if (index >= provider.users.length) {
            return _buildLoadingMore();
          }

          final user = provider.users[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom: 10.h,
            ),
            child: _buildUserCard(
              user,
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(
      AdminUser user,
      ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          _openUserDetails(
            user,
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _buildAvatar(
                user,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildUserInfo(
                  user,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.chevron_left,
                size: 24.sp,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(
      AdminUser user,
      ) {
    final avatarUrl = user.avatarUrl;

    if (avatarUrl != null &&
        avatarUrl.trim().isNotEmpty) {
      return Container(
        width: 58.w,
        height: 58.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: user.isAdmin
                ? Color(0xFFE21B23)
                : Colors.grey.shade300,
            width: 2.w,
          ),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: avatarUrl,
            fit: BoxFit.cover,
            placeholder: (
                context,
                url,
                ) {
              return Container(
                color: Colors.grey.shade100,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    color: Color(0xFFE21B23),
                  ),
                ),
              );
            },
            errorWidget: (
                context,
                url,
                error,
                ) {
              return _buildDefaultAvatar(
                user,
              );
            },
          ),
        ),
      );
    }

    return Container(
      width: 58.w,
      height: 58.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: user.isAdmin
            ? Color(0xFFE21B23).withValues(
          alpha: 0.08,
        )
            : Colors.grey.shade100,
        border: Border.all(
          color: user.isAdmin
              ? Color(0xFFE21B23)
              : Colors.grey.shade300,
          width: 2.w,
        ),
      ),
      child: _buildDefaultAvatar(
        user,
      ),
    );
  }

  Widget _buildDefaultAvatar(
      AdminUser user,
      ) {
    return Icon(
      user.isAdmin
          ? Icons.admin_panel_settings_outlined
          : Icons.person_outline,
      size: 30.sp,
      color: user.isAdmin
          ? Color(0xFFE21B23)
          : Colors.grey.shade500,
    );
  }

  Widget _buildUserInfo(
      AdminUser user,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getDisplayName(
            user,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
        ),
        SizedBox(height: 5.h),
        if (user.phone != null &&
            user.phone!.trim().isNotEmpty)
          Text(
            user.phone!,
            textDirection: TextDirection.ltr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          )
        else
          Text(
            'شماره موبایل ثبت نشده',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
            ),
          ),
        SizedBox(height: 8.h),
        _buildRoleBadge(
          user,
        ),
      ],
    );
  }

  Widget _buildRoleBadge(
      AdminUser user,
      ) {
    final isAdmin = user.isAdmin;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: isAdmin
            ? Color(0xFFE21B23).withValues(
          alpha: 0.08,
        )
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin
                ? Icons.admin_panel_settings_outlined
                : Icons.person_outline,
            size: 15.sp,
            color: isAdmin
                ? Color(0xFFE21B23)
                : Colors.grey.shade600,
          ),
          SizedBox(width: 5.w),
          Text(
            isAdmin
                ? 'مدیر'
                : 'کاربر',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: isAdmin
                  ? Color(0xFFE21B23)
                  : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMore() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 18.h,
      ),
      child: Center(
        child: SizedBox(
          width: 24.w,
          height: 24.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            color: Color(0xFFE21B23),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
      AdminUserProvider provider,
      ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 30.w,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: Color(0xFFE21B23).withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 36.sp,
                color: Color(0xFFE21B23),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'دریافت کاربران با مشکل مواجه شد',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _cleanErrorMessage(
                provider.error,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.6,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 18.h),
            SizedBox(
              height: 44.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  provider.loadUsers(
                    refresh: true,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE21B23),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                icon: Icon(
                  Icons.refresh,
                  size: 19.sp,
                ),
                label: Text(
                  'تلاش مجدد',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch =
        _searchController.text.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 30.w,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearch
                    ? Icons.search_off
                    : Icons.people_outline,
                size: 40.sp,
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              hasSearch
                  ? 'کاربری پیدا نشد'
                  : 'هنوز کاربری وجود ندارد',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              hasSearch
                  ? 'برای جستجوی خود عبارت دیگری را امتحان کنید.'
                  : 'کاربران ثبت‌نام‌شده در این بخش نمایش داده می‌شوند.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.6,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayName(
      AdminUser user,
      ) {
    if (user.fullName != null &&
        user.fullName!.trim().isNotEmpty) {
      return user.fullName!.trim();
    }

    if (user.phone != null &&
        user.phone!.trim().isNotEmpty) {
      return user.phone!.trim();
    }

    return 'کاربر بدون نام';
  }

  String _cleanErrorMessage(
      String? error,
      ) {
    if (error == null ||
        error.trim().isEmpty) {
      return 'لطفاً اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.';
    }

    var message = error.trim();

    if (message.startsWith('Exception:')) {
      message = message.substring(
        'Exception:'.length,
      ).trim();
    }

    return message;
  }
}