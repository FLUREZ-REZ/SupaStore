import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supastore/features/auth_feature/presentation/pages/otp_page.dart';
import 'package:supastore/features/auth_feature/presentation/providers/otp_provider.dart';
import 'package:supastore/features/home_feature/presentation/pages/home_page.dart';
import '../../features/splash_feature/presentation/pages/splash_page.dart';
import '../../features/intro_feature/presentation/pages/intro_page.dart';
import '../../features/auth_feature/presentation/pages/auth_page.dart';


class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',

    routes: [

      /// Splash
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      /// Intro
      GoRoute(
        path: '/intro',
        name: 'intro',
        builder: (context, state) => const IntroPage(),
      ),

      /// Auth
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthPage(),
      ),

      /// Home
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),


      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final phone = state.extra as String;

          return ChangeNotifierProvider(
            create: (_) => OtpProvider(),

            child: OtpPage(
              phoneNumber: phone,
            ),
          );
        },
      ),


    ],
  );
}