import 'package:freezed_annotation/freezed_annotation.dart';

part 'vocabulary_model.freezed.dart';
part 'vocabulary_model.g.dart';

@freezed
class VocabularyModel with _$VocabularyModel {
  const factory VocabularyModel({
    required String id,
    required String frenchWord,
    required String englishTrans,
    /// translations JSONB: must include "zh_tw" for 繁體中文.
    /// e.g. {"zh_tw":"房子／家","es":"casa","de":"Haus"}
    @Default({}) Map<String, String> translations,
    required String wordClass,
    String? gender,
    String? pluralForm,
    Map<String, dynamic>? conjugations,
    required String pronunciationIpa,
    String? audioUrl,
    required String cefrLevel,
    @Default([]) List<String> topicTags,
    int? frequencyRank,
    @Default([]) List<ExampleSentence> exampleSentences,
    String? usageNotes,
    String? memoryTip,
    @Default(true) bool isActive,
  }) = _VocabularyModel;

  factory VocabularyModel.fromJson(Map<String, dynamic> json) =>
      _$VocabularyModelFromJson(json);
}

extension VocabularyModelX on VocabularyModel {
  /// 繁體中文翻譯 — primary translation for Chinese-interface users.
  String? get chineseTransTw => translations['zh_tw'];

  /// Primary display translation: 繁體中文 if available, else English.
  String get primaryTrans => chineseTransTw ?? englishTrans;

  /// Secondary display (shown beneath primary on flashcard back).
  String? get secondaryTrans {
    final hasChinese = chineseTransTw != null && chineseTransTw!.isNotEmpty;
    return hasChinese ? englishTrans : null;
  }
}

@freezed
class ExampleSentence with _$ExampleSentence {
  const factory ExampleSentence({
    required String fr,
    required String en,
    /// 繁體中文 example translation (optional, added by scraper when available)
    String? zhTw,
    String? audioUrl,
    String? highlight,
  }) = _ExampleSentence;

  factory ExampleSentence.fromJson(Map<String, dynamic> json) =>
      _$ExampleSentenceFromJson(json);
}

@freezed
class UserVocabProgress with _$UserVocabProgress {
  const factory UserVocabProgress({
    required String id,
    required String userId,
    required String vocabularyId,
    @Default(0)    int repetitions,
    @Default(2.5)  double easeFactor,
    @Default(1)    int intervalDays,
    required String dueDate,
    @Default(0)    int totalReviews,
    @Default(0)    int correctReviews,
    String? lastReviewed,
    @Default(false) bool isLearned,
    @Default(false) bool isStarred,
    VocabularyModel? vocabulary,
  }) = _UserVocabProgress;

  factory UserVocabProgress.fromJson(Map<String, dynamic> json) =>
      _$UserVocabProgressFromJson(json);
}

/// Review quality buttons — labels in 繁體中文
enum ReviewQuality {
  again,
  hard,
  good,
  easy;

  /// 繁體中文 label shown on button
  String get labelZhTw {
    switch (this) {
      case again: return '再來一次';
      case hard:  return '困難';
      case good:  return '良好';
      case easy:  return '簡單';
    }
  }

  /// English fallback label
  String get label {
    switch (this) {
      case again: return '再來';
      case hard:  return '困難';
      case good:  return '良好';
      case easy:  return '簡單';
    }
  }

  String get emoji {
    switch (this) {
      case again: return '✗';
      case hard:  return '~';
      case good:  return '✓';
      case easy:  return '★';
    }
  }

  /// Days hint shown below button (helps learner understand SM-2 effect)
  String get intervalHint {
    switch (this) {
      case again: return '明天';
      case hard:  return '稍後';
      case good:  return '數天後';
      case easy:  return '數週後';
    }
  }
}
