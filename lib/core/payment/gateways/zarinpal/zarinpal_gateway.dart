import 'package:supabase_flutter/supabase_flutter.dart';

import '../../payment_gateway.dart';
import '../../payment_gateway_result.dart';

class ZarinPalGateway implements PaymentGateway {
  final SupabaseClient client;

  ZarinPalGateway({
    required this.client,
  });

  @override
  Future<PaymentGatewayResult> createPayment({
    required String paymentId,
    required int amount,
  }) async {
    try {
      final response = await client.functions.invoke(
        'create-payment',
        body: {
          'payment_id': paymentId,
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        return const PaymentGatewayResult(
          status: PaymentGatewayStatus.failed,
          message: 'Invalid payment response.',
        );
      }

      return PaymentGatewayResult(
        status: PaymentGatewayStatus.success,
        paymentUrl: data['payment_url'] as String?,
        authority: data['authority'] as String?,
        message: data['message'] as String?,
      );
    } catch (e) {
      return PaymentGatewayResult(
        status: PaymentGatewayStatus.failed,
        message: e.toString(),
      );
    }
  }

  @override
  Future<PaymentGatewayResult> verifyPayment({
    required String paymentId,
    required String authority,
  }) async {
    try {
      final response = await client.functions.invoke(
        'verify-payment',
        body: {
          'payment_id': paymentId,
          'authority': authority,
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        return const PaymentGatewayResult(
          status: PaymentGatewayStatus.failed,
          message: 'Invalid verification response.',
        );
      }

      final status = data['status'] as String?;

      if (status == 'paid') {
        return PaymentGatewayResult(
          status: PaymentGatewayStatus.success,
          refId: data['ref_id']?.toString(),
          authority: data['authority']?.toString(),
          message: data['message']?.toString(),
        );
      }

      if (status == 'pending') {
        return PaymentGatewayResult(
          status: PaymentGatewayStatus.pending,
          authority: data['authority']?.toString(),
          message: data['message']?.toString(),
        );
      }

      return PaymentGatewayResult(
        status: PaymentGatewayStatus.failed,
        authority: data['authority']?.toString(),
        message: data['message']?.toString(),
      );
    } catch (e) {
      return PaymentGatewayResult(
        status: PaymentGatewayStatus.failed,
        message: e.toString(),
      );
    }
  }
}