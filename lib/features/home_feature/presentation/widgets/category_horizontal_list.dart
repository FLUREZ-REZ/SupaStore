import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:supastore/features/home_feature/domain/entities/category_entity.dart';
import 'package:supastore/features/home_feature/presentation/providers/category_provider.dart';
import 'category_item.dart';

class CategoryHorizontalList extends StatefulWidget {
  const CategoryHorizontalList({
    super.key,
    this.onCategoryTap,
  });

  final Function(CategoryEntity category)? onCategoryTap;

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
      if (mounted) {
        context.read<CategoryProvider>().loadCategories();
      }
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
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),

              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
              ),

              itemCount: provider.categories.length,

              separatorBuilder: (_, __) {
                return SizedBox(
                  width: 2.w,
                );
              },

              itemBuilder: (context, index) {
                final category =
                provider.categories[index];

                return CategoryItem(
                  category: category,

                  onTap: () {
                    widget.onCategoryTap?.call(category);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}