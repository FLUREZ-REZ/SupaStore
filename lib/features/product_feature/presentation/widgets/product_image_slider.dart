import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductImageSlider extends StatefulWidget {
  const ProductImageSlider({
    super.key,
    required this.images,
  });

  final List<String> images;

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  final PageController _pageController = PageController();

  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: 320.h,
        color: Colors.white,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 70,
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        children: [
          SizedBox(
            height: 300.h,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: InteractiveViewer(
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 16.h),

          SmoothPageIndicator(
            controller: _pageController,
            count: widget.images.length,
            effect: ExpandingDotsEffect(
              dotHeight: 8.h,
              dotWidth: 8.w,
              expansionFactor: 3,
            ),
          ),
        ],
      ),
    );
  }
}