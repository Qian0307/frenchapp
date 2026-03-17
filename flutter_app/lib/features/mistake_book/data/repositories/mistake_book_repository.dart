import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/mistake_model.dart';

part 'mistake_book_repository.g.dart';

@riverpod
MistakeBookRepository mistakeBookRepository(MistakeBookRepositoryRef ref) =>
    MistakeBookRepository(Supabase.instance.client);

class MistakeBookRepository {
  MistakeBookRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<MistakeEntry>> listMistakes({bool resolved = false}) async {
    final res = await _supabase.functions.invoke(
      'mistake-book/list?resolved=${resolved ? 'true' : 'false'}',
      method: HttpMethod.get,
    );
    _checkError(res);
    final list = (res.data as Map)['mistakes'] as List;
    return list
        .map((e) => MistakeEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> resolve(String vocabularyId) async {
    final res = await _supabase.functions.invoke(
      'mistake-book/resolve',
      body: {'vocabulary_id': vocabularyId},
      method: HttpMethod.post,
    );
    _checkError(res);
  }

  Future<void> addNote(String vocabularyId, String note) async {
    final res = await _supabase.functions.invoke(
      'mistake-book/note',
      body: {'vocabulary_id': vocabularyId, 'note': note},
      method: HttpMethod.post,
    );
    _checkError(res);
  }

  void _checkError(FunctionResponse res) {
    if (res.data is Map && (res.data as Map).containsKey('error')) {
      throw Exception((res.data as Map)['error']);
    }
  }
}
