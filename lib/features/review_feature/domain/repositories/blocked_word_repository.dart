abstract class BlockedWordRepository {
  Future<List<String>> getBlockedWords();

  Future<bool> containsBlockedWord(
      String text,
      );
}