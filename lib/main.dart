import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supastore/core/config/env.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_theme.dart';
import 'package:supastore/features/intro_feature/intro_binding.dart';
import 'package:supastore/features/splash_feature/splash_binding.dart';
import 'package:supastore/features/favorite_feature/presentation/providers/favorite_provider.dart';
import 'app/router/app_router.dart';
import 'core/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(
    fileName: ".env",
  );

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  await setupLocator();

  await setupInjector();

  runApp(
    MultiProvider(
      providers: [
        ...SplashBinding.providers,

        ...IntroBinding.providers,

        ChangeNotifierProvider<FavoriteProvider>(
          create: (_) => getIt<FavoriteProvider>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(
        390,
        844,
      ),
      minTextAdapt: true,
      builder: (_, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}