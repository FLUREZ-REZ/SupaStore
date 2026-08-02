import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


import '../providers/banner_provider.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BannerProvider>().loadBanners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerProvider>(
      builder: (context, provider, child) {

        if (provider.isLoading) {
          return SizedBox(
            height: 180.h,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.error != null) {
          return SizedBox(
            height: 180.h,
            child: Center(
              child: Text(provider.error!),
            ),
          );
        }

        if (provider.banners.isEmpty) {
          return SizedBox(
            height: 180.h,
            child: const Center(
              child: Text("بنری وجود ندارد"),
            ),
          );
        }

        return Column(
          children: [

            CarouselSlider.builder(

              itemCount: provider.banners.length,

              itemBuilder: (context, index, realIndex) {
                final banner = provider.banners[index];

                return GestureDetector(
                  onTap: () {
                    /// بعداً
                    /// category
                    /// product
                    /// url
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18.r),
                    child: CachedNetworkImage(
                      imageUrl: banner.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey.shade200,
                      ),
                      errorWidget: (_, __, ___) =>
                      const Icon(Icons.error),
                    ),
                  ),
                );
              },

              options: CarouselOptions(

                height: 180.h,

                viewportFraction: 0.92,

                autoPlay: true,

                autoPlayInterval:
                const Duration(seconds: 4),

                enlargeCenterPage: true,

                onPageChanged: (index, reason) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
            ),

            SizedBox(
              height: 14.h,
            ),

            AnimatedSmoothIndicator(

              activeIndex: currentIndex,

              count: provider.banners.length,

              effect: ExpandingDotsEffect(

                dotHeight: 8.h,

                dotWidth: 8.w,

                expansionFactor: 3,

              ),
            ),
          ],
        );
      },
    );
  }
}