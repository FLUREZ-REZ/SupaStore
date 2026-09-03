import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/features/review_feature/presentation/providers/review_provider.dart';

class ReviewForm extends StatefulWidget {
  const ReviewForm({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController _titleController =
  TextEditingController();

  final TextEditingController _commentController =
  TextEditingController();

  // ==========================================================
  // FORM
  // ==========================================================

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  // ==========================================================
  // RATING
  // ==========================================================

  int _rating = 0;

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  // ==========================================================
  // SUBMIT
  // ==========================================================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لطفاً امتیاز محصول را انتخاب کنید.',
          ),
        ),
      );

      return;
    }

    final provider = context.read<ReviewProvider>();

    final success = await provider.createReview(
      productId: widget.productId,
      rating: _rating,
      title: _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim(),
      comment: _commentController.text.trim(),
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error ?? 'ثبت نظر انجام نشد.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'نظر شما با موفقیت ثبت شد.',
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  // ==========================================================
  // STAR
  // ==========================================================

  Widget _buildRatingItem(int rating) {
    final selected = _rating >= rating;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _rating = rating;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: AnimatedScale(
          scale: selected ? 1.08 : 1,
          duration: const Duration(milliseconds: 150),
          child: Icon(
            selected
                ? Icons.star_rounded
                : Icons.star_outline_rounded,
            size: 40.sp,
            color: selected
                ? const Color(0xFFF9A825)
                : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // INPUT DECORATION
  // ==========================================================

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        size: 21.sp,
        color: Colors.grey.shade600,
      ),

      filled: true,
      fillColor: Colors.white,

      contentPadding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 15.h,
      ),

      labelStyle: TextStyle(
        fontSize: 13.sp,
        color: Colors.grey.shade700,
      ),

      hintStyle: TextStyle(
        fontSize: 12.sp,
        color: Colors.grey.shade400,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 1.4,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(
          color: Colors.red.shade400,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(
          color: Colors.red.shade400,
          width: 1.3,
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,

      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),

        // ======================================================
        // APP BAR
        // ======================================================

        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,

          centerTitle: true,

          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.black87,
              size: 23.sp,
            ),
          ),

          title: Text(
            'ثبت نظر',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.h),
            child: Container(
              height: 1.h,
              color: Colors.grey.shade200,
            ),
          ),
        ),

        // ======================================================
        // BODY
        // ======================================================

        body: Consumer<ReviewProvider>(
          builder: (
              context,
              provider,
              child,
              ) {
            return Form(
              key: _formKey,

              child: ListView(
                physics: const BouncingScrollPhysics(),

                padding: EdgeInsets.fromLTRB(
                  16.w,
                  20.h,
                  16.w,
                  30.h,
                ),

                children: [

                  // ==================================================
                  // TITLE
                  // ==================================================

                  Text(
                    'نظر شما درباره این محصول',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 7.h),

                  Text(
                    'تجربه‌تان را با خریداران دیگر به اشتراک بگذارید.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                  ),

                  SizedBox(height: 22.h),

                  // ==================================================
                  // RATING
                  // ==================================================

                  Container(
                    width: double.infinity,

                    padding: EdgeInsets.symmetric(
                      vertical: 18.h,
                      horizontal: 12.w,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),

                    child: Column(
                      children: [

                        Text(
                          'امتیاز شما به این محصول',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,

                          children: [
                            for (int i = 1; i <= 5; i++)
                              _buildRatingItem(i),
                          ],
                        ),

                        SizedBox(height: 8.h),

                        AnimatedSwitcher(
                          duration:
                          const Duration(milliseconds: 150),

                          child: Text(
                            _rating == 0
                                ? 'امتیاز خود را انتخاب کنید'
                                : 'امتیاز $_rating از ۵',

                            key: ValueKey(_rating),

                            style: TextStyle(
                              fontSize: 12.sp,
                              color: _rating == 0
                                  ? Colors.grey.shade500
                                  : const Color(0xFF8D6E00),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h),

                  // ==================================================
                  // TITLE INPUT
                  // ==================================================

                  TextFormField(
                    controller: _titleController,

                    maxLength: 80,

                    textInputAction:
                    TextInputAction.next,

                    decoration: _inputDecoration(
                      label: 'عنوان نظر',
                      hint: 'مثلاً کیفیت ساخت عالی',
                      icon: Icons.title_rounded,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // ==================================================
                  // COMMENT
                  // ==================================================

                  TextFormField(
                    controller: _commentController,

                    minLines: 6,
                    maxLines: 8,

                    maxLength: 1000,

                    textInputAction:
                    TextInputAction.newline,

                    validator: (value) {
                      final text =
                          value?.trim() ?? '';

                      if (text.isEmpty) {
                        return 'متن نظر را وارد کنید.';
                      }

                      if (text.length < 5) {
                        return 'نظر باید حداقل ۵ کاراکتر باشد.';
                      }

                      return null;
                    },

                    decoration: _inputDecoration(
                      label: 'متن نظر',
                      hint:
                      'تجربه خود از این محصول را بنویسید...',
                      icon: Icons.chat_bubble_outline_rounded,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // ==================================================
                  // PROVIDER ERROR
                  // ==================================================

                  if (provider.error != null)
                    Container(
                      width: double.infinity,

                      margin: EdgeInsets.only(
                        bottom: 12.h,
                      ),

                      padding: EdgeInsets.all(11.w),

                      decoration: BoxDecoration(
                        color: Colors.red.withValues(
                          alpha: 0.05,
                        ),

                        borderRadius:
                        BorderRadius.circular(9.r),

                        border: Border.all(
                          color: Colors.red.withValues(
                            alpha: 0.15,
                          ),
                        ),
                      ),

                      child: Text(
                        provider.error!,
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),

                  // ==================================================
                  // SUBMIT
                  // ==================================================

                  SizedBox(
                    height: 50.h,

                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: provider.isSubmitting
                          ? null
                          : _submit,

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        AppColors.primary,

                        foregroundColor:
                        Colors.white,

                        disabledBackgroundColor:
                        Colors.grey.shade300,

                        elevation: 0,

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(10.r),
                        ),
                      ),

                      child: provider.isSubmitting
                          ? SizedBox(
                        width: 22.w,
                        height: 22.w,

                        child:
                        const CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                          : Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,

                        children: [

                          Icon(
                            Icons
                                .send_rounded,
                            size: 19.sp,
                          ),

                          SizedBox(width: 8.w),

                          Text(
                            'ثبت نظر',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}