import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/vocabulary_model.dart';

part 'flashcard_repository.g.dart';

@riverpod
FlashcardRepository flashcardRepository(FlashcardRepositoryRef ref) {
  return FlashcardRepository(Supabase.instance.client);
}

class FlashcardRepository {
  FlashcardRepository(this._supabase);

  final SupabaseClient _supabase;

  // ── Session ──────────────────────────────────────────────

  Future<String> startSession() async {
    final res = await _supabase.functions.invoke(
      'flashcards',
      body:   {},
      method: HttpMethod.post,
      // actual path controlled by edge function routing
    );
    _checkError(res);
    return (res.data as Map)['session']['id'] as String;
  }

  Future<Map<String, dynamic>> endSession({
    required String sessionId,
    required int cardsReviewed,
    required int cardsCorrect,
    required int durationSecs,
  }) async {
    final res = await _supabase.functions.invoke(
      'flashcards/end',
      body: {
        'session_id':     sessionId,
        'cards_reviewed': cardsReviewed,
        'cards_correct':  cardsCorrect,
        'duration_secs':  durationSecs,
      },
      method: HttpMethod.post,
    );
    _checkError(res);
    return res.data as Map<String, dynamic>;
  }

  // ── Cards ─────────────────────────────────────────────────

  Future<List<UserVocabProgress>> getDueCards({
    int limit = 20,
    String type = 'scheduled',
  }) async {
    final res = await _supabase.functions.invoke(
      'flashcards/due?limit=$limit&type=$type',
      method: HttpMethod.get,
    );
    _checkError(res);
    final cards = (res.data as Map)['cards'] as List;
    return cards
        .map((e) => UserVocabProgress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VocabularyModel>> browseVocabulary({
    String? level,
    String? tag,
    String? query,
    int page = 1,
  }) async {
    final params = {
      if (level != null) 'level': level,
      if (tag   != null) 'tag':   tag,
      if (query != null) 'q':     query,
      'page': page.toString(),
    };
    final qs = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final res = await _supabase.functions.invoke(
      'flashcards/browse?$qs',
      method: HttpMethod.get,
    );
    _checkError(res);
    final vocab = (res.data as Map)['vocabulary'] as List;
    return vocab
        .map((e) => VocabularyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> submitReview({
    required String sessionId,
    required String vocabularyId,
    required ReviewQuality quality,
    int? responseMs,
  }) async {
    final res = await _supabase.functions.invoke(
      'flashcards/review',
      body: {
        'session_id':    sessionId,
        'vocabulary_id': vocabularyId,
        'quality':       quality.name,
        if (responseMs != null) 'response_ms': responseMs,
      },
      method: HttpMethod.post,
    );
    _checkError(res);
    return res.data as Map<String, dynamic>;
  }

  Future<void> enrollCard(String vocabularyId) async {
    final res = await _supabase.functions.invoke(
      'flashcards/enroll',
      body:   {'vocabulary_id': vocabularyId},
      method: HttpMethod.post,
    );
    _checkError(res);
  }

  // ── Helpers ───────────────────────────────────────────────

  void _checkError(FunctionResponse res) {
    if (res.data is Map && (res.data as Map).containsKey('error')) {
      throw Exception((res.data as Map)['error']);
    }
  }
}
