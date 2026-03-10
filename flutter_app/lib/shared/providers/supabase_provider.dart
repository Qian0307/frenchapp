import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_provider.g.dart';

@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}

@riverpod
Stream<AuthState> authState(Ref ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
}

/// Current user session — null when signed out.
@riverpod
Session? currentSession(Ref ref) {
  final authStream = ref.watch(authStateProvider);
  return authStream.valueOrNull?.session;
}

/// Current user ID (throws if not signed in).
@riverpod
String currentUserId(Ref ref) {
  final session = ref.watch(currentSessionProvider);
  if (session == null) throw Exception('Not authenticated');
  return session.user.id;
}
