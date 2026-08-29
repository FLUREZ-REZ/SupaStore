import '../../domain/entities/blocked_word_entity.dart';

class BlockedWordModel extends BlockedWordEntity {
  const BlockedWordModel({
    required super.id,
    required super.word,
    super.createdAt,
  });

  factory BlockedWordModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return BlockedWordModel(
      id: json['id'] as String,
      word: json['word'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(
        json['created_at'] as String,
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}