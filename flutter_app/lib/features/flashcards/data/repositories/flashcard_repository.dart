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
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    final data = await _supabase
        .from('review_sessions')
        .insert({'user_id': userId, 'session_type': 'scheduled'})
        .select()
        .single();
    return data['id'] as String;
  }

  Future<Map<String, dynamic>> endSession({
    required String sessionId,
    required int cardsReviewed,
    required int cardsCorrect,
    required int durationSecs,
  }) async {
    final data = await _supabase
        .from('review_sessions')
        .update({
          'ended_at':       DateTime.now().toIso8601String(),
          'cards_reviewed': cardsReviewed,
          'cards_correct':  cardsCorrect,
          'duration_secs':  durationSecs,
        })
        .eq('id', sessionId)
        .select()
        .single();
    return data;
  }

  // ── Cards ─────────────────────────────────────────────────

  /// Fetches due (or new) cards directly from the database.
  /// Uses a direct Supabase query instead of an edge function to avoid
  /// Flutter Web Authorization header issues.
  Future<List<UserVocabProgress>> getDueCards({
    int limit = 20,
    String type = 'scheduled',
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final today = DateTime.now().toIso8601String().split('T')[0];

    final rows = await _supabase
        .from('user_vocabulary_progress')
        .select('*, vocabulary:vocabulary_id(*)')
        .eq('user_id', userId)
        .lte('due_date', today)
        .order('due_date', ascending: true)
        .limit(limit);

    return (rows as List)
        .map((e) => UserVocabProgress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Browses vocabulary directly from the database.
  /// Uses a direct Supabase query instead of an edge function to avoid
  /// Flutter Web Authorization header issues.
  Future<List<VocabularyModel>> browseVocabulary({
    String? level,
    String? tag,
    String? query,
    int page = 1,
  }) async {
    const limit = 30;
    final offset = (page - 1) * limit;

    var q = _supabase
        .from('vocabulary')
        .select('id, french_word, english_trans, word_class, gender, cefr_level, topic_tags, pronunciation_ipa')
        .eq('is_active', true);

    if (level != null) {
      q = q.eq('cefr_level', level);
    }

    if (query != null && query.isNotEmpty) {
      q = q.or('french_word.ilike.%$query%,english_trans.ilike.%$query%');
    }

    if (tag != null && tag.isNotEmpty) {
      q = q.contains('topic_tags', [tag]);
    }

    final rows = await q
        .order('frequency_rank', ascending: true)
        .range(offset, offset + limit - 1);

    return (rows as List)
        .map((e) => VocabularyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> submitReview({
    required String sessionId,
    required String vocabularyId,
    required ReviewQuality quality,
    int? responseMs,
  }) async {
    final token = _supabase.auth.currentSession?.accessToken;
    final res = await _supabase.functions.invoke(
      'flashcards/review',
      body: {
        'session_id':    sessionId,
        'vocabulary_id': vocabularyId,
        'quality':       quality.name,
        if (responseMs != null) 'response_ms': responseMs,
      },
      method: HttpMethod.post,
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
    _checkError(res);
    return res.data as Map<String, dynamic>;
  }

  Future<void> enrollCard(String vocabularyId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    await _supabase
        .from('user_vocabulary_progress')
        .insert({'user_id': userId, 'vocabulary_id': vocabularyId});
  }

  // ── Helpers ───────────────────────────────────────────────

  void _checkError(FunctionResponse res) {
    if (res.data is Map && (res.data as Map).containsKey('error')) {
      throw Exception((res.data as Map)['error']);
    }
  }
}
