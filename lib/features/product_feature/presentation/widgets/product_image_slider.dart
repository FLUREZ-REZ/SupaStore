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

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
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
            return Icon(
              Icons.image_not_supported_outlined,
              size: 60.sp,
              color: Colors.grey,
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.only(
          top: 8.h,
          bottom: 18.h,
        ),
        child: Column(
          children: [
            // =================================================
            // SINGLE IMAGE
            // =================================================

            if (widget.images.length == 1)
              Expanded(
                child: _buildImage(0),
              )

            // =================================================
            // MULTIPLE IMAGES
            // =================================================

            else
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.images.length,

                  // RTL
                  // Swipe راست -> چپ
                  reverse: false,

                  physics:
                  const PageScrollPhysics(),

                  itemBuilder: (
                      context,
                      index,
                      ) {
                    return _buildImage(index);
                  },
                ),
              ),

            // =================================================
            // INDICATOR
            // =================================================

            if (widget.images.length > 1)
              SizedBox(
                height: 16.h,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: widget.images.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 7.h,
                      dotWidth: 7.w,
                      expansionFactor: 3,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Stack(
            children: [
              // =================================================
              // IMAGE VIEWER
              // =================================================

              PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,

                // همان جهت صفحه اصلی
                // راست -> چپ
                reverse: false,

                physics:
                const PageScrollPhysics(),

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
                      imageUrl:
                      widget.images[index],
                    ),
                  );
                },
              ),

              // =================================================
              // CLOSE BUTTON
              // =================================================

              Positioned(
                top: 12.h,
                right: 16.w,
                child: GestureDetector(
                  behavior:
                  HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color:
                      Colors.white.withValues(
                        alpha: 0.15,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 25.sp,
                    ),
                  ),
                ),
              ),

              // =================================================
              // COUNTER
              // =================================================

              if (widget.images.length > 1)
                Positioned(
                  top: 18.h,
                  left: 20.w,
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                      Colors.white.withValues(
                        alpha: 0.15,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        20.r,
                      ),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.images.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              // =================================================
              // INDICATOR
              // =================================================

              if (widget.images.length > 1)
                Positioned(
                  bottom: 20.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SmoothPageIndicator(
                      controller:
                      _pageController,
                      count:
                      widget.images.length,
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
  _controller =
  TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =============================================================
  // RESET
  // =============================================================

  void _resetImage() {
    _controller.value =
        Matrix4.identity();
  }

  // =============================================================
  // DOUBLE TAP
  // =============================================================

  void _handleDoubleTap() {
    final scale =
    _controller.value
        .getMaxScaleOnAxis();

    if (scale > 1.01) {
      _resetImage();
      return;
    }

    _controller.value =
    Matrix4.identity()
      ..scale(2.5);
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
        _controller,

        // =======================================================
        // ZOOM
        // =======================================================

        minScale: 1.0,
        maxScale: 3.0,

        // =======================================================
        // PAN
        // =======================================================

        panEnabled: true,
        scaleEnabled: true,

        // =======================================================
        // LIMIT
        // =======================================================

        boundaryMargin:
        EdgeInsets.zero,

        constrained: true,

        clipBehavior:
        Clip.hardEdge,

        // =======================================================
        // RESET
        // =======================================================

        onInteractionEnd:
            (details) {
          final scale =
          _controller.value
              .getMaxScaleOnAxis();

          if (scale <= 1.01) {
            _resetImage();
          }
        },

        // =======================================================
        // IMAGE
        // =======================================================

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
              Icons
                  .image_not_supported_outlined,
              color: Colors.white,
              size: 70.sp,
            );
          },
        ),
      ),
    );
  }
}