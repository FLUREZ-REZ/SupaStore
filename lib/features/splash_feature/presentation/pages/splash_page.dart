import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';



import '../providers/splash_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final provider = context.read<SplashProvider>();

    await provider.checkConnection();

    if (!mounted) return;

    if (provider.hasInternet) {
      await Future.delayed(
        const Duration(seconds: 2),
      );

      if (!mounted) return;

      context.go('/intro');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<SplashProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                ),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 90.sp,
                    ),

                    SizedBox(height: 20.h),

                    Text(
                      "Shopify",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 50.h),

                    if (provider.isLoading)
                      const CircularProgressIndicator(),

                    if (!provider.isLoading &&
                        !provider.hasInternet)
                      Column(
                        children: [
                          Text(
                            "اتصال اینترنت برقرار نیست",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),

                          SizedBox(height: 20.h),

                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: () async {
                                await provider
                                    .checkConnection();

                                if (provider
                                    .hasInternet) {
                                  if (!mounted) return;

                                  context.go(
                                    '/intro',
                                  );
                                }
                              },
                              child: const Text(
                                "تلاش مجدد",
                              ),
                            ),
                          ),
                        ],
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
}