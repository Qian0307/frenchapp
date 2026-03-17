// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vocabulary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VocabularyModel _$VocabularyModelFromJson(Map<String, dynamic> json) {
  return _VocabularyModel.fromJson(json);
}

/// @nodoc
mixin _$VocabularyModel {
  String get id => throw _privateConstructorUsedError;
  String get frenchWord => throw _privateConstructorUsedError;
  String get englishTrans => throw _privateConstructorUsedError;

  /// translations JSONB: must include "zh_tw" for 繁體中文.
  /// e.g. {"zh_tw":"房子／家","es":"casa","de":"Haus"}
  Map<String, String> get translations => throw _privateConstructorUsedError;
  String get wordClass => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get pluralForm => throw _privateConstructorUsedError;
  Map<String, dynamic>? get conjugations => throw _privateConstructorUsedError;
  String get pronunciationIpa => throw _privateConstructorUsedError;
  String? get audioUrl => throw _privateConstructorUsedError;
  String get cefrLevel => throw _privateConstructorUsedError;
  List<String> get topicTags => throw _privateConstructorUsedError;
  int? get frequencyRank => throw _privateConstructorUsedError;
  List<ExampleSentence> get exampleSentences =>
      throw _privateConstructorUsedError;
  String? get usageNotes => throw _privateConstructorUsedError;
  String? get memoryTip => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VocabularyModelCopyWith<VocabularyModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VocabularyModelCopyWith<$Res> {
  factory $VocabularyModelCopyWith(
          VocabularyModel value, $Res Function(VocabularyModel) then) =
      _$VocabularyModelCopyWithImpl<$Res, VocabularyModel>;
  @useResult
  $Res call(
      {String id,
      String frenchWord,
      String englishTrans,
      Map<String, String> translations,
      String wordClass,
      String? gender,
      String? pluralForm,
      Map<String, dynamic>? conjugations,
      String pronunciationIpa,
      String? audioUrl,
      String cefrLevel,
      List<String> topicTags,
      int? frequencyRank,
      List<ExampleSentence> exampleSentences,
      String? usageNotes,
      String? memoryTip,
      bool isActive});
}

/// @nodoc
class _$VocabularyModelCopyWithImpl<$Res, $Val extends VocabularyModel>
    implements $VocabularyModelCopyWith<$Res> {
  _$VocabularyModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? frenchWord = null,
    Object? englishTrans = null,
    Object? translations = null,
    Object? wordClass = null,
    Object? gender = freezed,
    Object? pluralForm = freezed,
    Object? conjugations = freezed,
    Object? pronunciationIpa = null,
    Object? audioUrl = freezed,
    Object? cefrLevel = null,
    Object? topicTags = null,
    Object? frequencyRank = freezed,
    Object? exampleSentences = null,
    Object? usageNotes = freezed,
    Object? memoryTip = freezed,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      frenchWord: null == frenchWord
          ? _value.frenchWord
          : frenchWord // ignore: cast_nullable_to_non_nullable
              as String,
      englishTrans: null == englishTrans
          ? _value.englishTrans
          : englishTrans // ignore: cast_nullable_to_non_nullable
              as String,
      translations: null == translations
          ? _value.translations
          : translations // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      wordClass: null == wordClass
          ? _value.wordClass
          : wordClass // ignore: cast_nullable_to_non_nullable
              as String,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      pluralForm: freezed == pluralForm
          ? _value.pluralForm
          : pluralForm // ignore: cast_nullable_to_non_nullable
              as String?,
      conjugations: freezed == conjugations
          ? _value.conjugations
          : conjugations // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      pronunciationIpa: null == pronunciationIpa
          ? _value.pronunciationIpa
          : pronunciationIpa // ignore: cast_nullable_to_non_nullable
              as String,
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      cefrLevel: null == cefrLevel
          ? _value.cefrLevel
          : cefrLevel // ignore: cast_nullable_to_non_nullable
              as String,
      topicTags: null == topicTags
          ? _value.topicTags
          : topicTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      frequencyRank: freezed == frequencyRank
          ? _value.frequencyRank
          : frequencyRank // ignore: cast_nullable_to_non_nullable
              as int?,
      exampleSentences: null == exampleSentences
          ? _value.exampleSentences
          : exampleSentences // ignore: cast_nullable_to_non_nullable
              as List<ExampleSentence>,
      usageNotes: freezed == usageNotes
          ? _value.usageNotes
          : usageNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      memoryTip: freezed == memoryTip
          ? _value.memoryTip
          : memoryTip // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VocabularyModelImplCopyWith<$Res>
    implements $VocabularyModelCopyWith<$Res> {
  factory _$$VocabularyModelImplCopyWith(_$VocabularyModelImpl value,
          $Res Function(_$VocabularyModelImpl) then) =
      __$$VocabularyModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String frenchWord,
      String englishTrans,
      Map<String, String> translations,
      String wordClass,
      String? gender,
      String? pluralForm,
      Map<String, dynamic>? conjugations,
      String pronunciationIpa,
      String? audioUrl,
      String cefrLevel,
      List<String> topicTags,
      int? frequencyRank,
      List<ExampleSentence> exampleSentences,
      String? usageNotes,
      String? memoryTip,
      bool isActive});
}

/// @nodoc
class __$$VocabularyModelImplCopyWithImpl<$Res>
    extends _$VocabularyModelCopyWithImpl<$Res, _$VocabularyModelImpl>
    implements _$$VocabularyModelImplCopyWith<$Res> {
  __$$VocabularyModelImplCopyWithImpl(
      _$VocabularyModelImpl _value, $Res Function(_$VocabularyModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? frenchWord = null,
    Object? englishTrans = null,
    Object? translations = null,
    Object? wordClass = null,
    Object? gender = freezed,
    Object? pluralForm = freezed,
    Object? conjugations = freezed,
    Object? pronunciationIpa = null,
    Object? audioUrl = freezed,
    Object? cefrLevel = null,
    Object? topicTags = null,
    Object? frequencyRank = freezed,
    Object? exampleSentences = null,
    Object? usageNotes = freezed,
    Object? memoryTip = freezed,
    Object? isActive = null,
  }) {
    return _then(_$VocabularyModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      frenchWord: null == frenchWord
          ? _value.frenchWord
          : frenchWord // ignore: cast_nullable_to_non_nullable
              as String,
      englishTrans: null == englishTrans
          ? _value.englishTrans
          : englishTrans // ignore: cast_nullable_to_non_nullable
              as String,
      translations: null == translations
          ? _value._translations
          : translations // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      wordClass: null == wordClass
          ? _value.wordClass
          : wordClass // ignore: cast_nullable_to_non_nullable
              as String,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      pluralForm: freezed == pluralForm
          ? _value.pluralForm
          : pluralForm // ignore: cast_nullable_to_non_nullable
              as String?,
      conjugations: freezed == conjugations
          ? _value._conjugations
          : conjugations // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      pronunciationIpa: null == pronunciationIpa
          ? _value.pronunciationIpa
          : pronunciationIpa // ignore: cast_nullable_to_non_nullable
              as String,
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      cefrLevel: null == cefrLevel
          ? _value.cefrLevel
          : cefrLevel // ignore: cast_nullable_to_non_nullable
              as String,
      topicTags: null == topicTags
          ? _value._topicTags
          : topicTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      frequencyRank: freezed == frequencyRank
          ? _value.frequencyRank
          : frequencyRank // ignore: cast_nullable_to_non_nullable
              as int?,
      exampleSentences: null == exampleSentences
          ? _value._exampleSentences
          : exampleSentences // ignore: cast_nullable_to_non_nullable
              as List<ExampleSentence>,
      usageNotes: freezed == usageNotes
          ? _value.usageNotes
          : usageNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      memoryTip: freezed == memoryTip
          ? _value.memoryTip
          : memoryTip // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VocabularyModelImpl implements _VocabularyModel {
  const _$VocabularyModelImpl(
      {required this.id,
      required this.frenchWord,
      required this.englishTrans,
      final Map<String, String> translations = const {},
      required this.wordClass,
      this.gender,
      this.pluralForm,
      final Map<String, dynamic>? conjugations,
      required this.pronunciationIpa,
      this.audioUrl,
      required this.cefrLevel,
      final List<String> topicTags = const [],
      this.frequencyRank,
      final List<ExampleSentence> exampleSentences = const [],
      this.usageNotes,
      this.memoryTip,
      this.isActive = true})
      : _translations = translations,
        _conjugations = conjugations,
        _topicTags = topicTags,
        _exampleSentences = exampleSentences;

  factory _$VocabularyModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VocabularyModelImplFromJson(json);

  @override
  final String id;
  @override
  final String frenchWord;
  @override
  final String englishTrans;

  /// translations JSONB: must include "zh_tw" for 繁體中文.
  /// e.g. {"zh_tw":"房子／家","es":"casa","de":"Haus"}
  final Map<String, String> _translations;

  /// translations JSONB: must include "zh_tw" for 繁體中文.
  /// e.g. {"zh_tw":"房子／家","es":"casa","de":"Haus"}
  @override
  @JsonKey()
  Map<String, String> get translations {
    if (_translations is EqualUnmodifiableMapView) return _translations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_translations);
  }

  @override
  final String wordClass;
  @override
  final String? gender;
  @override
  final String? pluralForm;
  final Map<String, dynamic>? _conjugations;
  @override
  Map<String, dynamic>? get conjugations {
    final value = _conjugations;
    if (value == null) return null;
    if (_conjugations is EqualUnmodifiableMapView) return _conjugations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String pronunciationIpa;
  @override
  final String? audioUrl;
  @override
  final String cefrLevel;
  final List<String> _topicTags;
  @override
  @JsonKey()
  List<String> get topicTags {
    if (_topicTags is EqualUnmodifiableListView) return _topicTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topicTags);
  }

  @override
  final int? frequencyRank;
  final List<ExampleSentence> _exampleSentences;
  @override
  @JsonKey()
  List<ExampleSentence> get exampleSentences {
    if (_exampleSentences is EqualUnmodifiableListView)
      return _exampleSentences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exampleSentences);
  }

  @override
  final String? usageNotes;
  @override
  final String? memoryTip;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'VocabularyModel(id: $id, frenchWord: $frenchWord, englishTrans: $englishTrans, translations: $translations, wordClass: $wordClass, gender: $gender, pluralForm: $pluralForm, conjugations: $conjugations, pronunciationIpa: $pronunciationIpa, audioUrl: $audioUrl, cefrLevel: $cefrLevel, topicTags: $topicTags, frequencyRank: $frequencyRank, exampleSentences: $exampleSentences, usageNotes: $usageNotes, memoryTip: $memoryTip, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VocabularyModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.frenchWord, frenchWord) ||
                other.frenchWord == frenchWord) &&
            (identical(other.englishTrans, englishTrans) ||
                other.englishTrans == englishTrans) &&
            const DeepCollectionEquality()
                .equals(other._translations, _translations) &&
            (identical(other.wordClass, wordClass) ||
                other.wordClass == wordClass) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.pluralForm, pluralForm) ||
                other.pluralForm == pluralForm) &&
            const DeepCollectionEquality()
                .equals(other._conjugations, _conjugations) &&
            (identical(other.pronunciationIpa, pronunciationIpa) ||
                other.pronunciationIpa == pronunciationIpa) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            (identical(other.cefrLevel, cefrLevel) ||
                other.cefrLevel == cefrLevel) &&
            const DeepCollectionEquality()
                .equals(other._topicTags, _topicTags) &&
            (identical(other.frequencyRank, frequencyRank) ||
                other.frequencyRank == frequencyRank) &&
            const DeepCollectionEquality()
                .equals(other._exampleSentences, _exampleSentences) &&
            (identical(other.usageNotes, usageNotes) ||
                other.usageNotes == usageNotes) &&
            (identical(other.memoryTip, memoryTip) ||
                other.memoryTip == memoryTip) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      frenchWord,
      englishTrans,
      const DeepCollectionEquality().hash(_translations),
      wordClass,
      gender,
      pluralForm,
      const DeepCollectionEquality().hash(_conjugations),
      pronunciationIpa,
      audioUrl,
      cefrLevel,
      const DeepCollectionEquality().hash(_topicTags),
      frequencyRank,
      const DeepCollectionEquality().hash(_exampleSentences),
      usageNotes,
      memoryTip,
      isActive);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VocabularyModelImplCopyWith<_$VocabularyModelImpl> get copyWith =>
      __$$VocabularyModelImplCopyWithImpl<_$VocabularyModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VocabularyModelImplToJson(
      this,
    );
  }
}

abstract class _VocabularyModel implements VocabularyModel {
  const factory _VocabularyModel(
      {required final String id,
      required final String frenchWord,
      required final String englishTrans,
      final Map<String, String> translations,
      required final String wordClass,
      final String? gender,
      final String? pluralForm,
      final Map<String, dynamic>? conjugations,
      required final String pronunciationIpa,
      final String? audioUrl,
      required final String cefrLevel,
      final List<String> topicTags,
      final int? frequencyRank,
      final List<ExampleSentence> exampleSentences,
      final String? usageNotes,
      final String? memoryTip,
      final bool isActive}) = _$VocabularyModelImpl;

  factory _VocabularyModel.fromJson(Map<String, dynamic> json) =
      _$VocabularyModelImpl.fromJson;

  @override
  String get id;
  @override
  String get frenchWord;
  @override
  String get englishTrans;
  @override

  /// translations JSONB: must include "zh_tw" for 繁體中文.
  /// e.g. {"zh_tw":"房子／家","es":"casa","de":"Haus"}
  Map<String, String> get translations;
  @override
  String get wordClass;
  @override
  String? get gender;
  @override
  String? get pluralForm;
  @override
  Map<String, dynamic>? get conjugations;
  @override
  String get pronunciationIpa;
  @override
  String? get audioUrl;
  @override
  String get cefrLevel;
  @override
  List<String> get topicTags;
  @override
  int? get frequencyRank;
  @override
  List<ExampleSentence> get exampleSentences;
  @override
  String? get usageNotes;
  @override
  String? get memoryTip;
  @override
  bool get isActive;
  @override
  @JsonKey(ignore: true)
  _$$VocabularyModelImplCopyWith<_$VocabularyModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExampleSentence _$ExampleSentenceFromJson(Map<String, dynamic> json) {
  return _ExampleSentence.fromJson(json);
}

/// @nodoc
mixin _$ExampleSentence {
  String get fr => throw _privateConstructorUsedError;
  String get en => throw _privateConstructorUsedError;

  /// 繁體中文 example translation (optional, added by scraper when available)
  String? get zhTw => throw _privateConstructorUsedError;
  String? get audioUrl => throw _privateConstructorUsedError;
  String? get highlight => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExampleSentenceCopyWith<ExampleSentence> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExampleSentenceCopyWith<$Res> {
  factory $ExampleSentenceCopyWith(
          ExampleSentence value, $Res Function(ExampleSentence) then) =
      _$ExampleSentenceCopyWithImpl<$Res, ExampleSentence>;
  @useResult
  $Res call(
      {String fr,
      String en,
      String? zhTw,
      String? audioUrl,
      String? highlight});
}

/// @nodoc
class _$ExampleSentenceCopyWithImpl<$Res, $Val extends ExampleSentence>
    implements $ExampleSentenceCopyWith<$Res> {
  _$ExampleSentenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fr = null,
    Object? en = null,
    Object? zhTw = freezed,
    Object? audioUrl = freezed,
    Object? highlight = freezed,
  }) {
    return _then(_value.copyWith(
      fr: null == fr
          ? _value.fr
          : fr // ignore: cast_nullable_to_non_nullable
              as String,
      en: null == en
          ? _value.en
          : en // ignore: cast_nullable_to_non_nullable
              as String,
      zhTw: freezed == zhTw
          ? _value.zhTw
          : zhTw // ignore: cast_nullable_to_non_nullable
              as String?,
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      highlight: freezed == highlight
          ? _value.highlight
          : highlight // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExampleSentenceImplCopyWith<$Res>
    implements $ExampleSentenceCopyWith<$Res> {
  factory _$$ExampleSentenceImplCopyWith(_$ExampleSentenceImpl value,
          $Res Function(_$ExampleSentenceImpl) then) =
      __$$ExampleSentenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String fr,
      String en,
      String? zhTw,
      String? audioUrl,
      String? highlight});
}

/// @nodoc
class __$$ExampleSentenceImplCopyWithImpl<$Res>
    extends _$ExampleSentenceCopyWithImpl<$Res, _$ExampleSentenceImpl>
    implements _$$ExampleSentenceImplCopyWith<$Res> {
  __$$ExampleSentenceImplCopyWithImpl(
      _$ExampleSentenceImpl _value, $Res Function(_$ExampleSentenceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fr = null,
    Object? en = null,
    Object? zhTw = freezed,
    Object? audioUrl = freezed,
    Object? highlight = freezed,
  }) {
    return _then(_$ExampleSentenceImpl(
      fr: null == fr
          ? _value.fr
          : fr // ignore: cast_nullable_to_non_nullable
              as String,
      en: null == en
          ? _value.en
          : en // ignore: cast_nullable_to_non_nullable
              as String,
      zhTw: freezed == zhTw
          ? _value.zhTw
          : zhTw // ignore: cast_nullable_to_non_nullable
              as String?,
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      highlight: freezed == highlight
          ? _value.highlight
          : highlight // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExampleSentenceImpl implements _ExampleSentence {
  const _$ExampleSentenceImpl(
      {required this.fr,
      required this.en,
      this.zhTw,
      this.audioUrl,
      this.highlight});

  factory _$ExampleSentenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExampleSentenceImplFromJson(json);

  @override
  final String fr;
  @override
  final String en;

  /// 繁體中文 example translation (optional, added by scraper when available)
  @override
  final String? zhTw;
  @override
  final String? audioUrl;
  @override
  final String? highlight;

  @override
  String toString() {
    return 'ExampleSentence(fr: $fr, en: $en, zhTw: $zhTw, audioUrl: $audioUrl, highlight: $highlight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExampleSentenceImpl &&
            (identical(other.fr, fr) || other.fr == fr) &&
            (identical(other.en, en) || other.en == en) &&
            (identical(other.zhTw, zhTw) || other.zhTw == zhTw) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            (identical(other.highlight, highlight) ||
                other.highlight == highlight));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, fr, en, zhTw, audioUrl, highlight);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExampleSentenceImplCopyWith<_$ExampleSentenceImpl> get copyWith =>
      __$$ExampleSentenceImplCopyWithImpl<_$ExampleSentenceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExampleSentenceImplToJson(
      this,
    );
  }
}

abstract class _ExampleSentence implements ExampleSentence {
  const factory _ExampleSentence(
      {required final String fr,
      required final String en,
      final String? zhTw,
      final String? audioUrl,
      final String? highlight}) = _$ExampleSentenceImpl;

  factory _ExampleSentence.fromJson(Map<String, dynamic> json) =
      _$ExampleSentenceImpl.fromJson;

  @override
  String get fr;
  @override
  String get en;
  @override

  /// 繁體中文 example translation (optional, added by scraper when available)
  String? get zhTw;
  @override
  String? get audioUrl;
  @override
  String? get highlight;
  @override
  @JsonKey(ignore: true)
  _$$ExampleSentenceImplCopyWith<_$ExampleSentenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserVocabProgress _$UserVocabProgressFromJson(Map<String, dynamic> json) {
  return _UserVocabProgress.fromJson(json);
}

/// @nodoc
mixin _$UserVocabProgress {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get vocabularyId => throw _privateConstructorUsedError;
  int get repetitions => throw _privateConstructorUsedError;
  double get easeFactor => throw _privateConstructorUsedError;
  int get intervalDays => throw _privateConstructorUsedError;
  String get dueDate => throw _privateConstructorUsedError;
  int get totalReviews => throw _privateConstructorUsedError;
  int get correctReviews => throw _privateConstructorUsedError;
  String? get lastReviewed => throw _privateConstructorUsedError;
  bool get isLearned => throw _privateConstructorUsedError;
  bool get isStarred => throw _privateConstructorUsedError;
  VocabularyModel? get vocabulary => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserVocabProgressCopyWith<UserVocabProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserVocabProgressCopyWith<$Res> {
  factory $UserVocabProgressCopyWith(
          UserVocabProgress value, $Res Function(UserVocabProgress) then) =
      _$UserVocabProgressCopyWithImpl<$Res, UserVocabProgress>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String vocabularyId,
      int repetitions,
      double easeFactor,
      int intervalDays,
      String dueDate,
      int totalReviews,
      int correctReviews,
      String? lastReviewed,
      bool isLearned,
      bool isStarred,
      VocabularyModel? vocabulary});

  $VocabularyModelCopyWith<$Res>? get vocabulary;
}

/// @nodoc
class _$UserVocabProgressCopyWithImpl<$Res, $Val extends UserVocabProgress>
    implements $UserVocabProgressCopyWith<$Res> {
  _$UserVocabProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? vocabularyId = null,
    Object? repetitions = null,
    Object? easeFactor = null,
    Object? intervalDays = null,
    Object? dueDate = null,
    Object? totalReviews = null,
    Object? correctReviews = null,
    Object? lastReviewed = freezed,
    Object? isLearned = null,
    Object? isStarred = null,
    Object? vocabulary = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      vocabularyId: null == vocabularyId
          ? _value.vocabularyId
          : vocabularyId // ignore: cast_nullable_to_non_nullable
              as String,
      repetitions: null == repetitions
          ? _value.repetitions
          : repetitions // ignore: cast_nullable_to_non_nullable
              as int,
      easeFactor: null == easeFactor
          ? _value.easeFactor
          : easeFactor // ignore: cast_nullable_to_non_nullable
              as double,
      intervalDays: null == intervalDays
          ? _value.intervalDays
          : intervalDays // ignore: cast_nullable_to_non_nullable
              as int,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as String,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      correctReviews: null == correctReviews
          ? _value.correctReviews
          : correctReviews // ignore: cast_nullable_to_non_nullable
              as int,
      lastReviewed: freezed == lastReviewed
          ? _value.lastReviewed
          : lastReviewed // ignore: cast_nullable_to_non_nullable
              as String?,
      isLearned: null == isLearned
          ? _value.isLearned
          : isLearned // ignore: cast_nullable_to_non_nullable
              as bool,
      isStarred: null == isStarred
          ? _value.isStarred
          : isStarred // ignore: cast_nullable_to_non_nullable
              as bool,
      vocabulary: freezed == vocabulary
          ? _value.vocabulary
          : vocabulary // ignore: cast_nullable_to_non_nullable
              as VocabularyModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $VocabularyModelCopyWith<$Res>? get vocabulary {
    if (_value.vocabulary == null) {
      return null;
    }

    return $VocabularyModelCopyWith<$Res>(_value.vocabulary!, (value) {
      return _then(_value.copyWith(vocabulary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserVocabProgressImplCopyWith<$Res>
    implements $UserVocabProgressCopyWith<$Res> {
  factory _$$UserVocabProgressImplCopyWith(_$UserVocabProgressImpl value,
          $Res Function(_$UserVocabProgressImpl) then) =
      __$$UserVocabProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String vocabularyId,
      int repetitions,
      double easeFactor,
      int intervalDays,
      String dueDate,
      int totalReviews,
      int correctReviews,
      String? lastReviewed,
      bool isLearned,
      bool isStarred,
      VocabularyModel? vocabulary});

  @override
  $VocabularyModelCopyWith<$Res>? get vocabulary;
}

/// @nodoc
class __$$UserVocabProgressImplCopyWithImpl<$Res>
    extends _$UserVocabProgressCopyWithImpl<$Res, _$UserVocabProgressImpl>
    implements _$$UserVocabProgressImplCopyWith<$Res> {
  __$$UserVocabProgressImplCopyWithImpl(_$UserVocabProgressImpl _value,
      $Res Function(_$UserVocabProgressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? vocabularyId = null,
    Object? repetitions = null,
    Object? easeFactor = null,
    Object? intervalDays = null,
    Object? dueDate = null,
    Object? totalReviews = null,
    Object? correctReviews = null,
    Object? lastReviewed = freezed,
    Object? isLearned = null,
    Object? isStarred = null,
    Object? vocabulary = freezed,
  }) {
    return _then(_$UserVocabProgressImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      vocabularyId: null == vocabularyId
          ? _value.vocabularyId
          : vocabularyId // ignore: cast_nullable_to_non_nullable
              as String,
      repetitions: null == repetitions
          ? _value.repetitions
          : repetitions // ignore: cast_nullable_to_non_nullable
              as int,
      easeFactor: null == easeFactor
          ? _value.easeFactor
          : easeFactor // ignore: cast_nullable_to_non_nullable
              as double,
      intervalDays: null == intervalDays
          ? _value.intervalDays
          : intervalDays // ignore: cast_nullable_to_non_nullable
              as int,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as String,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      correctReviews: null == correctReviews
          ? _value.correctReviews
          : correctReviews // ignore: cast_nullable_to_non_nullable
              as int,
      lastReviewed: freezed == lastReviewed
          ? _value.lastReviewed
          : lastReviewed // ignore: cast_nullable_to_non_nullable
              as String?,
      isLearned: null == isLearned
          ? _value.isLearned
          : isLearned // ignore: cast_nullable_to_non_nullable
              as bool,
      isStarred: null == isStarred
          ? _value.isStarred
          : isStarred // ignore: cast_nullable_to_non_nullable
              as bool,
      vocabulary: freezed == vocabulary
          ? _value.vocabulary
          : vocabulary // ignore: cast_nullable_to_non_nullable
              as VocabularyModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserVocabProgressImpl implements _UserVocabProgress {
  const _$UserVocabProgressImpl(
      {required this.id,
      required this.userId,
      required this.vocabularyId,
      this.repetitions = 0,
      this.easeFactor = 2.5,
      this.intervalDays = 1,
      required this.dueDate,
      this.totalReviews = 0,
      this.correctReviews = 0,
      this.lastReviewed,
      this.isLearned = false,
      this.isStarred = false,
      this.vocabulary});

  factory _$UserVocabProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserVocabProgressImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String vocabularyId;
  @override
  @JsonKey()
  final int repetitions;
  @override
  @JsonKey()
  final double easeFactor;
  @override
  @JsonKey()
  final int intervalDays;
  @override
  final String dueDate;
  @override
  @JsonKey()
  final int totalReviews;
  @override
  @JsonKey()
  final int correctReviews;
  @override
  final String? lastReviewed;
  @override
  @JsonKey()
  final bool isLearned;
  @override
  @JsonKey()
  final bool isStarred;
  @override
  final VocabularyModel? vocabulary;

  @override
  String toString() {
    return 'UserVocabProgress(id: $id, userId: $userId, vocabularyId: $vocabularyId, repetitions: $repetitions, easeFactor: $easeFactor, intervalDays: $intervalDays, dueDate: $dueDate, totalReviews: $totalReviews, correctReviews: $correctReviews, lastReviewed: $lastReviewed, isLearned: $isLearned, isStarred: $isStarred, vocabulary: $vocabulary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserVocabProgressImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.vocabularyId, vocabularyId) ||
                other.vocabularyId == vocabularyId) &&
            (identical(other.repetitions, repetitions) ||
                other.repetitions == repetitions) &&
            (identical(other.easeFactor, easeFactor) ||
                other.easeFactor == easeFactor) &&
            (identical(other.intervalDays, intervalDays) ||
                other.intervalDays == intervalDays) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            (identical(other.correctReviews, correctReviews) ||
                other.correctReviews == correctReviews) &&
            (identical(other.lastReviewed, lastReviewed) ||
                other.lastReviewed == lastReviewed) &&
            (identical(other.isLearned, isLearned) ||
                other.isLearned == isLearned) &&
            (identical(other.isStarred, isStarred) ||
                other.isStarred == isStarred) &&
            (identical(other.vocabulary, vocabulary) ||
                other.vocabulary == vocabulary));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      vocabularyId,
      repetitions,
      easeFactor,
      intervalDays,
      dueDate,
      totalReviews,
      correctReviews,
      lastReviewed,
      isLearned,
      isStarred,
      vocabulary);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserVocabProgressImplCopyWith<_$UserVocabProgressImpl> get copyWith =>
      __$$UserVocabProgressImplCopyWithImpl<_$UserVocabProgressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserVocabProgressImplToJson(
      this,
    );
  }
}

abstract class _UserVocabProgress implements UserVocabProgress {
  const factory _UserVocabProgress(
      {required final String id,
      required final String userId,
      required final String vocabularyId,
      final int repetitions,
      final double easeFactor,
      final int intervalDays,
      required final String dueDate,
      final int totalReviews,
      final int correctReviews,
      final String? lastReviewed,
      final bool isLearned,
      final bool isStarred,
      final VocabularyModel? vocabulary}) = _$UserVocabProgressImpl;

  factory _UserVocabProgress.fromJson(Map<String, dynamic> json) =
      _$UserVocabProgressImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get vocabularyId;
  @override
  int get repetitions;
  @override
  double get easeFactor;
  @override
  int get intervalDays;
  @override
  String get dueDate;
  @override
  int get totalReviews;
  @override
  int get correctReviews;
  @override
  String? get lastReviewed;
  @override
  bool get isLearned;
  @override
  bool get isStarred;
  @override
  VocabularyModel? get vocabulary;
  @override
  @JsonKey(ignore: true)
  _$$UserVocabProgressImplCopyWith<_$UserVocabProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
