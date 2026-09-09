import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/app/router/app_router.dart';
import 'package:supastore/core/config/env.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/di/service_locator.dart';
import 'package:supastore/core/theme/app_theme.dart';

import 'package:supastore/features/favorite_feature/presentation/providers/favorite_provider.dart';
import 'package:supastore/features/intro_feature/intro_binding.dart';
import 'package:supastore/features/splash_feature/splash_binding.dart';


// ============================================================
// Payment Deep Link Service
// ============================================================

class PaymentDeepLinkService {
  PaymentDeepLinkService({
    required GoRouter router,
  }) : _router = router;

  final GoRouter _router;

  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _subscription;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    debugPrint(
      'PaymentDeepLinkService: initializing...',
    );

    // ----------------------------------------------------------
    // Cold Start
    // ----------------------------------------------------------

    try {
      final initialUri =
      await _appLinks.getInitialLink();

      if (initialUri != null) {
        debugPrint(
          'Initial Deep Link: $initialUri',
        );

        _handleUri(initialUri);
      }
    } catch (error) {
      debugPrint(
        'Initial Deep Link Error: $error',
      );
    }

    // ----------------------------------------------------------
    // App already running
    // ----------------------------------------------------------

    _subscription =
        _appLinks.uriLinkStream.listen(
              (uri) {
            debugPrint(
              'Deep Link Received: $uri',
            );

            _handleUri(uri);
          },
          onError: (error) {
            debugPrint(
              'Deep Link Stream Error: $error',
            );
          },
        );
  }

  void _handleUri(Uri uri) {
    debugPrint(
      'Handling Deep Link: $uri',
    );

    // ----------------------------------------------------------
    // Scheme
    // ----------------------------------------------------------

    if (uri.scheme != 'supastore') {
      debugPrint(
        'Invalid Deep Link scheme.',
      );

      return;
    }

    // ----------------------------------------------------------
    // Host
    // ----------------------------------------------------------

    if (uri.host != 'payment') {
      debugPrint(
        'Invalid Deep Link host.',
      );

      return;
    }

    // ----------------------------------------------------------
    // Path
    // ----------------------------------------------------------

    if (uri.path != '/result') {
      debugPrint(
        'Invalid Deep Link path.',
      );

      return;
    }

    // ----------------------------------------------------------
    // Parameters
    // ----------------------------------------------------------

    final orderId =
    uri.queryParameters['order_id'];

    final status =
    uri.queryParameters['status'];

    final refId =
    uri.queryParameters['ref_id'];

    debugPrint(
      'Payment Deep Link Data:',
    );

    debugPrint(
      'order_id: $orderId',
    );

    debugPrint(
      'status: $status',
    );

    debugPrint(
      'ref_id: $refId',
    );

    // ----------------------------------------------------------
    // Validate Order ID
    // ----------------------------------------------------------

    if (orderId == null ||
        orderId.isEmpty) {
      debugPrint(
        'Payment Deep Link rejected: order_id missing.',
      );

      return;
    }

    // ----------------------------------------------------------
    // Navigate
    // ----------------------------------------------------------

    WidgetsBinding.instance
        .addPostFrameCallback(
          (_) {
        try {
          _router.go(
            '/payment-result',
            extra: {
              'orderId': orderId,
              'status': status,
              'refId': refId,
            },
          );

          debugPrint(
            'Navigated to /payment-result',
          );
        } catch (error) {
          debugPrint(
            'Navigation Error: $error',
          );
        }
      },
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();

    _subscription = null;

    _initialized = false;
  }
}


// ============================================================
// Main
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ----------------------------------------------------------
  // .env
  // ----------------------------------------------------------

  await dotenv.load(
    fileName: '.env',
  );

  // ----------------------------------------------------------
  // Supabase
  // ----------------------------------------------------------

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // ----------------------------------------------------------
  // Dependency Injection
  // ----------------------------------------------------------

  await setupLocator();

  await setupInjector();

  // ----------------------------------------------------------
  // Deep Link Service
  // ----------------------------------------------------------

  final paymentDeepLinkService =
  PaymentDeepLinkService(
    router: AppRouter.router,
  );

  // ----------------------------------------------------------
  // Run App
  // ----------------------------------------------------------

  runApp(
    MultiProvider(
      providers: [
        ...SplashBinding.providers,

        ...IntroBinding.providers,

        ChangeNotifierProvider<
            FavoriteProvider>(
          create: (_) =>
              getIt<FavoriteProvider>(),
        ),
      ],
      child: const MyApp(),
    ),
  );

  // ----------------------------------------------------------
  // Start Deep Link Listener
  // ----------------------------------------------------------

  WidgetsBinding.instance
      .addPostFrameCallback(
        (_) {
      paymentDeepLinkService
          .initialize();
    },
  );
}


// ============================================================
// MyApp
// ============================================================

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return ScreenUtilInit(
      designSize: const Size(
        390,
        844,
      ),
      minTextAdapt: true,
      builder: (
          _,
          child,
          ) {
        return MaterialApp.router(
          debugShowCheckedModeBanner:
          false,

          theme:
          AppTheme.lightTheme,

          routerConfig:
          AppRouter.router,
        );
      },
    );
  }
}