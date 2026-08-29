import 'package:flutter/foundation.dart';

@immutable
class BlockedWordEntity {
  const BlockedWordEntity({
    required this.id,
    required this.word,
    this.createdAt,
  });

  final String id;
  final String word;
  final DateTime? createdAt;
}