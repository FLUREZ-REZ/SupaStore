import 'package:cached_network_image/cached_network_image.dart';
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
  State<ProductImageSlider> createState() =>
      _ProductImageSliderState();
}

class _ProductImageSliderState
    extends State<ProductImageSlider> {

  late final PageController _pageController;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
  }

  @override
  void didUpdateWidget(
      covariant ProductImageSlider oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (widget.images.length != oldWidget.images.length) {
      _currentIndex = 0;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ===========================================================
  // OPEN FULL SCREEN VIEWER
  // ===========================================================

  void _openImageViewer(int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierColor: Colors.black,
        transitionDuration: const Duration(
          milliseconds: 250,
        ),
        reverseTransitionDuration: const Duration(
          milliseconds: 200,
        ),
        pageBuilder: (
            context,
            animation,
            secondaryAnimation,
            ) {
          return _ProductImageViewer(
            images: widget.images,
            initialIndex: initialIndex,
          );
        },
        transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  // ===========================================================
  // IMAGE ITEM
  // ===========================================================

  Widget _buildImage(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 8.h,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _openImageViewer(index);
        },
        child: CachedNetworkImage(
          imageUrl: widget.images[index],

          fit: BoxFit.contain,

          memCacheWidth: 900,
          memCacheHeight: 900,

          placeholder: (
              context,
              url,
              ) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            );
          },

          errorWidget: (
              context,
              url,
              error,
              ) {
            return Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 60.sp,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    // =========================================================
    // NO IMAGE
    // =========================================================

    if (widget.images.isEmpty) {
      return Container(
        width: double.infinity,
        color: Colors.white,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 70.sp,
            color: Colors.grey,
          ),
        ),
      );
    }

    // =========================================================
    // SINGLE IMAGE
    // =========================================================

    if (widget.images.length == 1) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.only(
          top: 8.h,
          bottom: 18.h,
        ),
        child: _buildImage(0),
      );
    }

    // =========================================================
    // MULTIPLE IMAGES
    // =========================================================

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.only(
        top: 8.h,
        bottom: 12.h,
      ),
      child: Column(
        children: [

          // =====================================================
          // PAGE VIEW
          // =====================================================

          Expanded(
            child: PageView.builder(
              controller: _pageController,

              itemCount: widget.images.length,

              reverse: false,

              physics:
              const BouncingScrollPhysics(),

              onPageChanged: (index) {
                if (!mounted) return;

                setState(() {
                  _currentIndex = index;
                });
              },

              itemBuilder: (
                  context,
                  index,
                  ) {
                return _buildImage(index);
              },
            ),
          ),

          // =====================================================
          // INDICATOR
          // =====================================================

          SizedBox(
            height: 22.h,
            child: Center(
              child: AnimatedSmoothIndicator(
                activeIndex: _currentIndex,
                count: widget.images.length,

                effect: ExpandingDotsEffect(
                  dotHeight: 7.h,
                  dotWidth: 7.w,
                  expansionFactor: 3,
                  spacing: 5.w,
                ),

                onDotClicked: (index) {
                  if (!_pageController.hasClients) {
                    return;
                  }

                  _pageController.animateToPage(
                    index,
                    duration: const Duration(
                      milliseconds: 300,
                    ),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// =================================================================
// FULL SCREEN IMAGE VIEWER
// =================================================================

class _ProductImageViewer extends StatefulWidget {
  const _ProductImageViewer({
    required this.images,
    required this.initialIndex,
  });

  final List<String> images;
  final int initialIndex;

  @override
  State<_ProductImageViewer> createState() =>
      _ProductImageViewerState();
}

class _ProductImageViewerState
    extends State<_ProductImageViewer> {

  late final PageController _pageController;

  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    _pageController = PageController(
      initialPage: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _close() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Stack(
          children: [

            // ===================================================
            // ZOOM IMAGE VIEWER
            // ===================================================

            PageView.builder(
              controller: _pageController,

              itemCount: widget.images.length,

              // 🔥 جهت اسلاید در صفحه زوم برعکس صفحه اصلی
              reverse: true,

              physics:
              const BouncingScrollPhysics(),

              onPageChanged: (index) {
                if (!mounted) return;

                setState(() {
                  _currentIndex = index;
                });
              },

              itemBuilder: (
                  context,
                  index,
                  ) {
                return Center(
                  child: _ZoomableImage(
                    imageUrl: widget.images[index],
                  ),
                );
              },
            ),

            // ===================================================
            // CLOSE BUTTON
            // ===================================================

            Positioned(
              top: 12.h,
              right: 16.w,

              child: Material(
                color: Colors.white.withValues(
                  alpha: 0.15,
                ),

                shape: const CircleBorder(),

                child: InkWell(
                  customBorder: const CircleBorder(),

                  onTap: _close,

                  child: SizedBox(
                    width: 44.w,
                    height: 44.w,

                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 25.sp,
                    ),
                  ),
                ),
              ),
            ),

            // ===================================================
            // COUNTER
            // ===================================================

            if (widget.images.length > 1)
              Positioned(
                top: 18.h,
                left: 20.w,

                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.15,
                    ),

                    borderRadius:
                    BorderRadius.circular(20.r),
                  ),

                  child: Text(
                    '${_currentIndex + 1} / ${widget.images.length}',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // ===================================================
            // INDICATOR
            // ===================================================

            if (widget.images.length > 1)
              Positioned(
                bottom: 20.h,
                left: 0,
                right: 0,

                child: Center(
                  child: AnimatedSmoothIndicator(
                    activeIndex: _currentIndex,

                    count: widget.images.length,

                    effect: WormEffect(
                      dotHeight: 7.h,
                      dotWidth: 7.w,
                      spacing: 5.w,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


// =================================================================
// ZOOMABLE IMAGE
// =================================================================

class _ZoomableImage extends StatefulWidget {
  const _ZoomableImage({
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  State<_ZoomableImage> createState() =>
      _ZoomableImageState();
}

class _ZoomableImageState
    extends State<_ZoomableImage> {

  final TransformationController
  _transformationController =
  TransformationController();

  // ===========================================================
  // RESET
  // ===========================================================

  void _resetImage() {
    _transformationController.value =
        Matrix4.identity();
  }

  // ===========================================================
  // DOUBLE TAP
  // ===========================================================

  void _handleDoubleTap() {
    final scale =
    _transformationController.value
        .getMaxScaleOnAxis();

    if (scale > 1.01) {
      _resetImage();
      return;
    }

    _transformationController.value =
    Matrix4.identity()
      ..scale(2.5);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior:
      HitTestBehavior.opaque,

      onDoubleTap:
      _handleDoubleTap,

      child: InteractiveViewer(
        transformationController:
        _transformationController,

        minScale: 1.0,

        maxScale: 3.0,

        panEnabled: true,

        scaleEnabled: true,

        boundaryMargin:
        EdgeInsets.zero,

        constrained: true,

        clipBehavior:
        Clip.hardEdge,

        onInteractionEnd: (_) {
          final scale =
          _transformationController
              .value
              .getMaxScaleOnAxis();

          if (scale <= 1.01) {
            _resetImage();
          }
        },

        child: CachedNetworkImage(
          imageUrl:
          widget.imageUrl,

          fit: BoxFit.contain,

          memCacheWidth: 1400,
          memCacheHeight: 1400,

          placeholder: (
              context,
              url,
              ) {
            return const Center(
              child:
              CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          },

          errorWidget: (
              context,
              url,
              error,
              ) {
            return Icon(
              Icons.image_not_supported_outlined,
              color: Colors.white,
              size: 70.sp,
            );
          },
        ),
      ),
    );
  }
}