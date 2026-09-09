import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class PaymentDeepLinkService {
  PaymentDeepLinkService({
    required GlobalKey<NavigatorState> navigatorKey,
  }) : _navigatorKey = navigatorKey;

  final GlobalKey<NavigatorState> _navigatorKey;

  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _subscription;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    try {
      final initialUri =
      await _appLinks.getInitialLink();

      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (error) {
      debugPrint(
        'PaymentDeepLink initial error: $error',
      );
    }

    _subscription =
        _appLinks.uriLinkStream.listen(
              (uri) {
            _handleUri(uri);
          },
          onError: (error) {
            debugPrint(
              'PaymentDeepLink stream error: $error',
            );
          },
        );
  }

  void _handleUri(Uri uri) {
    debugPrint(
      'PaymentDeepLink received: $uri',
    );

    if (uri.scheme != 'supastore') {
      return;
    }

    if (uri.host != 'payment') {
      return;
    }

    if (uri.path != '/result') {
      return;
    }

    final orderId =
    uri.queryParameters['order_id'];

    final status =
    uri.queryParameters['status'];

    final refId =
    uri.queryParameters['ref_id'];

    if (orderId == null ||
        orderId.isEmpty) {
      debugPrint(
        'PaymentDeepLink: order_id is missing',
      );

      return;
    }

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      final navigator =
          _navigatorKey.currentState;

      if (navigator == null) {
        debugPrint(
          'PaymentDeepLink: navigator is null',
        );

        return;
      }

      navigator.pushNamed(
        '/payment-result',
        arguments: {
          'orderId': orderId,
          'status': status,
          'refId': refId,
        },
      );
    });
  }

  Future<void> dispose() async {
    await _subscription?.cancel();

    _subscription = null;

    _initialized = false;
  }
}