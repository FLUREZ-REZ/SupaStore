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
  State<ReviewForm> createState() =>
      _ReviewFormState();
}

class _ReviewFormState
    extends State<ReviewForm> {

  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController _titleController =
  TextEditingController();

  final TextEditingController _commentController =
  TextEditingController();

  // ==========================================================
  // FORM KEY
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
    // --------------------------------------------------------
    // VALIDATE FORM
    // --------------------------------------------------------

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // --------------------------------------------------------
    // VALIDATE RATING
    // --------------------------------------------------------

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

    // --------------------------------------------------------
    // PROVIDER
    // --------------------------------------------------------

    final provider =
    context.read<ReviewProvider>();

    // --------------------------------------------------------
    // CREATE REVIEW
    // --------------------------------------------------------

    final success =
    await provider.createReview(
      productId: widget.productId,
      rating: _rating,
      title: _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim(),
      comment: _commentController.text.trim(),
    );

    if (!mounted) return;

    // --------------------------------------------------------
    // ERROR
    // --------------------------------------------------------

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error ??
                'ثبت نظر انجام نشد.',
          ),
        ),
      );

      return;
    }

    // --------------------------------------------------------
    // SUCCESS
    // --------------------------------------------------------

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
  // RATING ITEM
  // ==========================================================

  Widget _buildRatingItem(
      int rating,
      ) {
    final bool selected =
        _rating >= rating;

    return GestureDetector(
      behavior:
      HitTestBehavior.opaque,

      onTap: () {
        setState(() {
          _rating = rating;
        });
      },

      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
        ),

        child: Icon(
          selected
              ? Icons.star
              : Icons.star_border,

          size: 38.sp,

          color: Colors.amber,
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
      textDirection:
      TextDirection.rtl,

      child: Scaffold(
        backgroundColor:
        const Color(0xFFF5F5F5),

        appBar: AppBar(
          backgroundColor:
          AppColors.primary,

          elevation: 0,

          centerTitle: true,

          title: Text(
            'ثبت نظر',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },

            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),

        body: Consumer<ReviewProvider>(
          builder: (
              context,
              provider,
              child,
              ) {
            return Form(
              key: _formKey,

              child: ListView(
                physics:
                const BouncingScrollPhysics(),

                padding: EdgeInsets.fromLTRB(
                  16.w,
                  20.h,
                  16.w,
                  30.h,
                ),

                children: [

                  // ==========================================
                  // HEADER CARD
                  // ==========================================

                  Container(
                    width: double.infinity,

                    padding:
                    EdgeInsets.all(18.w),

                    decoration:
                    BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                      BorderRadius.circular(
                        16.r,
                      ),
                    ),

                    child: Column(
                      children: [

                        Icon(
                          Icons.rate_review_outlined,
                          size: 40.sp,
                          color:
                          AppColors.primary,
                        ),

                        SizedBox(
                          height: 10.h,
                        ),

                        Text(
                          'نظر شما درباره این محصول چیست؟',
                          textAlign:
                          TextAlign.center,

                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        SizedBox(
                          height: 6.h,
                        ),

                        Text(
                          'تجربه خود را با سایر کاربران به اشتراک بگذارید.',
                          textAlign:
                          TextAlign.center,

                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors
                                .grey
                                .shade600,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 14.h,
                  ),

                  // ==========================================
                  // RATING CARD
                  // ==========================================

                  Container(
                    width: double.infinity,

                    padding:
                    EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 18.h,
                    ),

                    decoration:
                    BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                      BorderRadius.circular(
                        16.r,
                      ),
                    ),

                    child: Column(
                      children: [

                        Text(
                          'امتیاز شما',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),

                        SizedBox(
                          height: 10.h,
                        ),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,

                          children: [
                            for (
                            int i = 1;
                            i <= 5;
                            i++
                            )
                              _buildRatingItem(i),
                          ],
                        ),

                        SizedBox(
                          height: 5.h,
                        ),

                        Text(
                          _rating == 0
                              ? 'یک امتیاز انتخاب کنید'
                              : '$_rating از 5',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color:
                            _rating == 0
                                ? Colors
                                .grey
                                .shade600
                                : Colors
                                .amber
                                .shade800,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 14.h,
                  ),

                  // ==========================================
                  // TITLE
                  // ==========================================

                  Container(
                    width: double.infinity,

                    padding:
                    EdgeInsets.all(16.w),

                    decoration:
                    BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                      BorderRadius.circular(
                        16.r,
                      ),
                    ),

                    child: TextFormField(
                      controller:
                      _titleController,

                      maxLength: 80,

                      textInputAction:
                      TextInputAction.next,

                      decoration:
                      InputDecoration(
                        labelText:
                        'عنوان نظر (اختیاری)',

                        hintText:
                        'مثلاً کیفیت ساخت عالی',

                        prefixIcon:
                        const Icon(
                          Icons.title,
                        ),

                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            12.r,
                          ),
                        ),

                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            12.r,
                          ),
                          borderSide:
                          BorderSide(
                            color: Colors
                                .grey
                                .shade300,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 14.h,
                  ),

                  // ==========================================
                  // COMMENT
                  // ==========================================

                  Container(
                    width: double.infinity,

                    padding:
                    EdgeInsets.all(16.w),

                    decoration:
                    BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                      BorderRadius.circular(
                        16.r,
                      ),
                    ),

                    child: TextFormField(
                      controller:
                      _commentController,

                      minLines: 5,

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

                      decoration:
                      InputDecoration(
                        labelText:
                        'متن نظر',

                        hintText:
                        'تجربه خود از این محصول را بنویسید...',

                        alignLabelWithHint:
                        true,

                        prefixIcon:
                        const Padding(
                          padding:
                          EdgeInsets.only(
                            bottom: 90,
                          ),
                          child: Icon(
                            Icons
                                .chat_bubble_outline,
                          ),
                        ),

                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            12.r,
                          ),
                        ),

                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            12.r,
                          ),
                          borderSide:
                          BorderSide(
                            color: Colors
                                .grey
                                .shade300,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 20.h,
                  ),

                  // ==========================================
                  // PROVIDER ERROR
                  // ==========================================

                  if (provider.error != null)
                    Padding(
                      padding:
                      EdgeInsets.only(
                        bottom: 12.h,
                      ),

                      child: Container(
                        width:
                        double.infinity,

                        padding:
                        EdgeInsets.all(12.w),

                        decoration:
                        BoxDecoration(
                          color: Colors.red
                              .withValues(
                            alpha: 0.06,
                          ),

                          borderRadius:
                          BorderRadius.circular(
                            10.r,
                          ),

                          border:
                          Border.all(
                            color: Colors.red
                                .withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),

                        child: Text(
                          provider.error!,
                          textAlign:
                          TextAlign.center,

                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors
                                .red
                                .shade700,
                          ),
                        ),
                      ),
                    ),

                  // ==========================================
                  // SUBMIT BUTTON
                  // ==========================================

                  SizedBox(
                    width:
                    double.infinity,

                    height: 52.h,

                    child: ElevatedButton(
                      onPressed:
                      provider.isSubmitting
                          ? null
                          : _submit,

                      style:
                      ElevatedButton.styleFrom(
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
                          BorderRadius.circular(
                            14.r,
                          ),
                        ),
                      ),

                      child:
                      provider.isSubmitting
                          ? SizedBox(
                        width: 23.w,
                        height: 23.w,
                        child:
                        const CircularProgressIndicator(
                          strokeWidth:
                          2.5,
                          color:
                          Colors.white,
                        ),
                      )
                          : Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,

                        children: [
                          Icon(
                            Icons
                                .send_outlined,
                            size: 20.sp,
                          ),

                          SizedBox(
                            width: 8.w,
                          ),

                          Text(
                            'ثبت نظر',
                            style:
                            TextStyle(
                              fontSize:
                              14.sp,
                              fontWeight:
                              FontWeight
                                  .w600,
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