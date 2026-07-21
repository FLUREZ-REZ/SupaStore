import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supastore/features/intro_feature/presentation/pages/intro_page.dart';
import 'package:supastore/features/splash_feature/presentation/pages/splash_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Auth Page'),
      ),
    );
  }
}



class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Home Page'),
      ),
    );
  }
}



class AppRouter {

  static final GoRouter router =
  GoRouter(

    initialLocation: '/',

    routes: [

      GoRoute(
        path: '/',
        builder: (context, state) =>
        const SplashPage(),
      ),

      GoRoute(
        path: '/intro',
        builder: (context, state) =>
        const IntroPage(),
      ),

      GoRoute(
        path: '/auth',
        builder: (context, state) =>
        const AuthPage(),
      ),

      GoRoute(
        path: '/home',
        builder: (context, state) =>
        const HomePage(),
      ),

    ],

  );
}