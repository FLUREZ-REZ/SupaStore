import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentDeepLinkService {
  PaymentDeepLinkService({
    required GoRouter router,
  }) : _router = router;

  final GoRouter _router;

  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _subscription;

  bool _initialized = false;

  // ============================================================
  // Initialize
  // ============================================================

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    debugPrint(
      'PaymentDeepLinkService: initializing...',
    );

    // ==========================================================
    // Cold Start
    // ==========================================================

    try {
      final initialUri =
      await _appLinks.getInitialLink();

      if (initialUri != null) {
        debugPrint(
          'PaymentDeepLink: initial URI = $initialUri',
        );

        _handleUri(initialUri);
      }
    } catch (error) {
      debugPrint(
        'PaymentDeepLink: initial error = $error',
      );
    }

    // ==========================================================
    // App Already Running
    // ==========================================================

    _subscription =
        _appLinks.uriLinkStream.listen(
              (uri) {
            debugPrint(
              'PaymentDeepLink: received URI = $uri',
            );

            _handleUri(uri);
          },
          onError: (error) {
            debugPrint(
              'PaymentDeepLink: stream error = $error',
            );
          },
        );
  }

  // ============================================================
  // Handle URI
  // ============================================================

  void _handleUri(Uri uri) {
    debugPrint(
      'PaymentDeepLink: handling URI = $uri',
    );

    // ----------------------------------------------------------
    // Scheme
    // ----------------------------------------------------------

    if (uri.scheme != 'supastore') {
      debugPrint(
        'PaymentDeepLink: invalid scheme.',
      );

      return;
    }

    // ----------------------------------------------------------
    // Host
    // ----------------------------------------------------------

    if (uri.host != 'payment') {
      debugPrint(
        'PaymentDeepLink: invalid host.',
      );

      return;
    }

    // ----------------------------------------------------------
    // Path
    // ----------------------------------------------------------

    if (uri.path != '/result') {
      debugPrint(
        'PaymentDeepLink: invalid path.',
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

    final gateway =
    uri.queryParameters['gateway'];

    debugPrint(
      'PaymentDeepLink: order_id = $orderId',
    );

    debugPrint(
      'PaymentDeepLink: status = $status',
    );

    debugPrint(
      'PaymentDeepLink: ref_id = $refId',
    );

    debugPrint(
      'PaymentDeepLink: gateway = $gateway',
    );

    // ----------------------------------------------------------
    // Validate Order ID
    // ----------------------------------------------------------

    if (orderId == null ||
        orderId.isEmpty) {
      debugPrint(
        'PaymentDeepLink: order_id is missing.',
      );

      return;
    }

    // ----------------------------------------------------------
    // Navigate
    // ----------------------------------------------------------

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        try {
          _router.go(
            '/payment-result',
            extra: {
              'orderId': orderId,
              'status': status,
              'refId': refId,
              'gateway': gateway,
            },
          );

          debugPrint(
            'PaymentDeepLink: navigated to payment-result.',
          );
        } catch (error) {
          debugPrint(
            'PaymentDeepLink: navigation error = $error',
          );
        }
      },
    );
  }

  // ============================================================
  // Dispose
  // ============================================================

  Future<void> dispose() async {
    await _subscription?.cancel();

    _subscription = null;

    _initialized = false;
  }
}