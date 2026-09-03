import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentRemoteDataSource {
  final SupabaseClient client;

  PaymentRemoteDataSource(this.client);

  Future<Map<String, dynamic>?> getPayment({
    required String paymentId,
  }) async {
    final response = await client
        .from('payments')
        .select()
        .eq('id', paymentId)
        .maybeSingle();

    return response;
  }

  Future<Map<String, dynamic>?> getPaymentByOrder({
    required String orderId,
  }) async {
    final response = await client
        .from('payments')
        .select()
        .eq('order_id', orderId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return response;
  }

  Future<Map<String, dynamic>> createPayment({
    required String orderId,
  }) async {
    throw UnimplementedError(
      'Payment creation will be handled by the secure backend.',
    );
  }
}