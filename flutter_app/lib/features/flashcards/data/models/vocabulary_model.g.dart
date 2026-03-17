// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VocabularyModelImpl _$$VocabularyModelImplFromJson(
        Map<String, dynamic> json) =>
    _$VocabularyModelImpl(
      id: json['id'] as String,
      frenchWord: json['frenchWord'] as String,
      englishTrans: json['englishTrans'] as String,
      translations: (json['translations'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      wordClass: json['wordClass'] as String,
      gender: json['gender'] as String?,
      pluralForm: json['pluralForm'] as String?,
      conjugations: json['conjugations'] as Map<String, dynamic>?,
      pronunciationIpa: json['pronunciationIpa'] as String,
      audioUrl: json['audioUrl'] as String?,
      cefrLevel: json['cefrLevel'] as String,
      topicTags: (json['topicTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      frequencyRank: (json['frequencyRank'] as num?)?.toInt(),
      exampleSentences: (json['exampleSentences'] as List<dynamic>?)
              ?.map((e) => ExampleSentence.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      usageNotes: json['usageNotes'] as String?,
      memoryTip: json['memoryTip'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$VocabularyModelImplToJson(
        _$VocabularyModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'frenchWord': instance.frenchWord,
      'englishTrans': instance.englishTrans,
      'translations': instance.translations,
      'wordClass': instance.wordClass,
      'gender': instance.gender,
      'pluralForm': instance.pluralForm,
      'conjugations': instance.conjugations,
      'pronunciationIpa': instance.pronunciationIpa,
      'audioUrl': instance.audioUrl,
      'cefrLevel': instance.cefrLevel,
      'topicTags': instance.topicTags,
      'frequencyRank': instance.frequencyRank,
      'exampleSentences': instance.exampleSentences,
      'usageNotes': instance.usageNotes,
      'memoryTip': instance.memoryTip,
      'isActive': instance.isActive,
    };

_$ExampleSentenceImpl _$$ExampleSentenceImplFromJson(
        Map<String, dynamic> json) =>
    _$ExampleSentenceImpl(
      fr: json['fr'] as String,
      en: json['en'] as String,
      zhTw: json['zhTw'] as String?,
      audioUrl: json['audioUrl'] as String?,
      highlight: json['highlight'] as String?,
    );

Map<String, dynamic> _$$ExampleSentenceImplToJson(
        _$ExampleSentenceImpl instance) =>
    <String, dynamic>{
      'fr': instance.fr,
      'en': instance.en,
      'zhTw': instance.zhTw,
      'audioUrl': instance.audioUrl,
      'highlight': instance.highlight,
    };

_$UserVocabProgressImpl _$$UserVocabProgressImplFromJson(
        Map<String, dynamic> json) =>
    _$UserVocabProgressImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      vocabularyId: json['vocabularyId'] as String,
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: (json['intervalDays'] as num?)?.toInt() ?? 1,
      dueDate: json['dueDate'] as String,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      correctReviews: (json['correctReviews'] as num?)?.toInt() ?? 0,
      lastReviewed: json['lastReviewed'] as String?,
      isLearned: json['isLearned'] as bool? ?? false,
      isStarred: json['isStarred'] as bool? ?? false,
      vocabulary: json['vocabulary'] == null
          ? null
          : VocabularyModel.fromJson(
              json['vocabulary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserVocabProgressImplToJson(
        _$UserVocabProgressImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'vocabularyId': instance.vocabularyId,
      'repetitions': instance.repetitions,
      'easeFactor': instance.easeFactor,
      'intervalDays': instance.intervalDays,
      'dueDate': instance.dueDate,
      'totalReviews': instance.totalReviews,
      'correctReviews': instance.correctReviews,
      'lastReviewed': instance.lastReviewed,
      'isLearned': instance.isLearned,
      'isStarred': instance.isStarred,
      'vocabulary': instance.vocabulary,
    };
