import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/blocked_word_model.dart';

class BlockedWordRemoteDataSource {
  BlockedWordRemoteDataSource({
    required SupabaseClient client,
  }) : _client = client;

  final SupabaseClient _client;

  // ==========================================================
  // GET BLOCKED WORDS
  // ==========================================================

  Future<List<BlockedWordModel>> getBlockedWords() async {
    final response = await _client
        .from('blocked_words')
        .select()
        .order('word');

    return (response as List)
        .map(
          (json) => BlockedWordModel.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }
}