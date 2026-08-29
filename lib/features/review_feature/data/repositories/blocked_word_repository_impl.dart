import '../../domain/repositories/blocked_word_repository.dart';
import '../datasources/blocked_word_remote_data_source.dart';

class BlockedWordRepositoryImpl
    implements BlockedWordRepository {
  BlockedWordRepositoryImpl({
    required BlockedWordRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final BlockedWordRemoteDataSource _remoteDataSource;

  // ==========================================================
  // GET BLOCKED WORDS
  // ==========================================================

  @override
  Future<List<String>> getBlockedWords() async {
    final models =
    await _remoteDataSource.getBlockedWords();

    return models
        .map(
          (model) => model.word,
    )
        .map(
          (word) => _normalizeText(word),
    )
        .where(
          (word) => word.isNotEmpty,
    )
        .toList();
  }

  // ==========================================================
  // CONTAINS BLOCKED WORD
  // ==========================================================

  @override
  Future<bool> containsBlockedWord(
      String text,
      ) async {
    final blockedWords =
    await getBlockedWords();

    if (blockedWords.isEmpty) {
      return false;
    }

    final normalizedText =
    _normalizeText(text);

    if (normalizedText.isEmpty) {
      return false;
    }

    final compactText =
    _compactText(normalizedText);

    for (final blockedWord in blockedWords) {
      final normalizedWord =
      _normalizeText(blockedWord);

      if (normalizedWord.isEmpty) {
        continue;
      }

      final compactWord =
      _compactText(normalizedWord);

      if (compactWord.isEmpty) {
        continue;
      }

      // ========================================================
      // SHORT WORD
      //
      // برای کلمات کوتاه از substring استفاده نمی‌کنیم
      // چون احتمال تشخیص اشتباه زیاد است.
      //
      // مثال:
      //
      // "بد"
      //
      // نباید داخل یک کلمه کاملاً بی‌ربط پیدا شود.
      // ========================================================

      if (compactWord.length <= 2) {
        final escapedWord =
        RegExp.escape(normalizedWord);

        final pattern = RegExp(
          r'(^|[^a-zA-Z0-9آ-ی])'
          '$escapedWord'
          r'([^a-zA-Z0-9آ-ی]|$)',
          caseSensitive: false,
        );

        if (pattern.hasMatch(normalizedText)) {
          return true;
        }

        continue;
      }

      // ========================================================
      // LONG WORD
      //
      // Compact باعث می‌شود فاصله و کاراکترهای جداکننده
      // نتوانند فیلتر را دور بزنند.
      //
      // مثال:
      //
      // احمق
      // ا ح م ق
      // ا-ح-م-ق
      // ا_ح_م_ق
      // ا‌ح‌م‌ق
      //
      // همگی تبدیل می‌شوند به:
      //
      // احمق
      // ========================================================

      if (compactText.contains(compactWord)) {
        return true;
      }

      // ========================================================
      // REGEX CHECK
      //
      // این قسمت برای حالت عادی متن است و کمک می‌کند
      // کلمه به‌صورت مستقل هم شناسایی شود.
      // ========================================================

      final escapedWord =
      RegExp.escape(normalizedWord);

      final pattern = RegExp(
        r'(^|[^a-zA-Z0-9آ-ی])'
        '$escapedWord'
        r'([^a-zA-Z0-9آ-ی]|$)',
        caseSensitive: false,
      );

      if (pattern.hasMatch(normalizedText)) {
        return true;
      }
    }

    return false;
  }

  // ==========================================================
  // NORMALIZE TEXT
  // ==========================================================

  String _normalizeText(
      String text,
      ) {
    var result =
    text.toLowerCase();

    // --------------------------------------------------------
    // Arabic Yeh → Persian Yeh
    // --------------------------------------------------------

    result = result.replaceAll(
      'ي',
      'ی',
    );

    // --------------------------------------------------------
    // Arabic Kaf → Persian Kaf
    // --------------------------------------------------------

    result = result.replaceAll(
      'ك',
      'ک',
    );

    // --------------------------------------------------------
    // Arabic Alef variants
    // --------------------------------------------------------

    result = result.replaceAll(
      'أ',
      'ا',
    );

    result = result.replaceAll(
      'إ',
      'ا',
    );

    result = result.replaceAll(
      'ٱ',
      'ا',
    );

    // --------------------------------------------------------
    // Remove Tatweel
    // --------------------------------------------------------

    result = result.replaceAll(
      'ـ',
      '',
    );

    // --------------------------------------------------------
    // Remove Arabic diacritics
    // --------------------------------------------------------

    result = result.replaceAll(
      RegExp(
        r'[\u064B-\u065F\u0670]',
      ),
      '',
    );

    // --------------------------------------------------------
    // Remove zero-width characters
    // --------------------------------------------------------

    result = result.replaceAll(
      RegExp(
        r'[\u200B\u200C\u200D\uFEFF]',
      ),
      '',
    );

    // --------------------------------------------------------
    // Normalize Arabic/ Persian digits
    // --------------------------------------------------------

    const arabicDigits =
        '٠١٢٣٤٥٦٧٨٩';

    const persianDigits =
        '۰۱۲۳۴۵۶۷۸۹';

    const englishDigits =
        '0123456789';

    for (int i = 0;
    i < 10;
    i++) {
      result = result.replaceAll(
        arabicDigits[i],
        englishDigits[i],
      );

      result = result.replaceAll(
        persianDigits[i],
        englishDigits[i],
      );
    }

    // --------------------------------------------------------
    // Normalize spaces
    // --------------------------------------------------------

    result = result.replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    return result.trim();
  }

  // ==========================================================
  // COMPACT TEXT
  // ==========================================================
  //
  // تمام فاصله‌ها، خط تیره، نقطه، underscore و سایر
  // کاراکترهای غیرحرفی حذف می‌شوند.
  //
  // مثال:
  //
  // ا ح م ق
  // ا-ح-م-ق
  // ا_ح_م_ق
  // ا.ح.م.ق
  //
  // تبدیل می‌شود به:
  //
  // احمق
  //
  // ==========================================================

  String _compactText(
      String text,
      ) {
    return text.replaceAll(
      RegExp(
        r'[^a-zA-Z0-9آ-ی]',
      ),
      '',
    );
  }
}