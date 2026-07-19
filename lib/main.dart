import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supastore/features/intro_feature/intro_binding.dart';
import 'package:supastore/features/splash_feature/splash_binding.dart';
import 'app/router/app_router.dart';
import 'core/di/service_locator.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupLocator();

  runApp(
    MultiProvider(
      providers: [
        ...SplashBinding.providers,

        ...IntroBinding.providers,
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (_, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}