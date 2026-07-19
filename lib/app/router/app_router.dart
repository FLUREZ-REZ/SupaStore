import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:supastore/features/intro_feature/presentation/pages/intro_page.dart';
import 'package:supastore/features/splash_feature/presentation/pages/splash_page.dart';




class AuthPagePlaceholder extends StatelessWidget {
  const AuthPagePlaceholder({super.key});

  @override
  Widget build(context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Auth Page",
        ),
      ),
    );
  }
}


class HomePagePlaceholder extends StatelessWidget {
  const HomePagePlaceholder({super.key});

  @override
  Widget build(context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Home Page",
        ),
      ),
    );
  }
}



class AppRouter {

  static final router = GoRouter(

    initialLocation: '/',

    routes: [

      // Splash
      GoRoute(
        path: '/',
        name: 'splash',

        builder: (context, state) {
          return const SplashPage();
        },
      ),



      // Intro Pages
      GoRoute(
        path: '/intro',
        name: 'intro',

        builder: (context, state) {
          return const IntroPage();
        },
      ),



      // Authentication
      GoRoute(
        path: '/auth',
        name: 'auth',

        builder: (context, state) {
          return const AuthPagePlaceholder();
        },
      ),



      // Home
      GoRoute(
        path: '/home',
        name: 'home',

        builder: (context, state) {
          return const HomePagePlaceholder();
        },
      ),


    ],

  );

}