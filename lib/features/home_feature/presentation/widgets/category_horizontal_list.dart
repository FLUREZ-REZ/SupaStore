import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import 'category_item.dart';

class CategoryHorizontalList extends StatefulWidget {
  const CategoryHorizontalList({
    super.key,
  });

  @override
  State<CategoryHorizontalList> createState() =>
      _CategoryHorizontalListState();
}

class _CategoryHorizontalListState
    extends State<CategoryHorizontalList> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {

        if (provider.isLoading) {
          return SizedBox(
            height: 110.h,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.error != null) {
          return SizedBox(
            height: 110.h,
            child: Center(
              child: Text(
                provider.error!,
              ),
            ),
          );
        }

        if (provider.categories.isEmpty) {
          return SizedBox(
            height: 110.h,
            child: const Center(
              child: Text(
                'دسته‌بندی‌ای وجود ندارد',
              ),
            ),
          );
        }

        return SizedBox(
          height: 110.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
            ),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),

            itemCount: provider.categories.length,

            separatorBuilder: (_, __) =>
                SizedBox(width: 14.w),

            itemBuilder: (context, index) {
              return CategoryItem(
                category: provider.categories[index],
              );
            },
          ),
        );
      },
    );
  }
}