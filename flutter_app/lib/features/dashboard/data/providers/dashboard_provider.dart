import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'dashboard_provider.g.dart';

class DashboardStats {
  final int streakDays;
  final int cardsDue;
  final int cardsToday;
  final int xpToday;
  final String currentLevel;

  const DashboardStats({
    required this.streakDays,
    required this.cardsDue,
    required this.cardsToday,
    required this.xpToday,
    required this.currentLevel,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      streakDays:   (json['streak_days']  as num?)?.toInt() ?? 0,
      cardsDue:     (json['cards_due']    as num?)?.toInt() ?? 0,
      cardsToday:   (json['cards_today']  as num?)?.toInt() ?? 0,
      xpToday:      (json['xp_today']     as num?)?.toInt() ?? 0,
      currentLevel: json['current_level'] as String? ?? 'A1',
    );
  }

  static const empty = DashboardStats(
    streakDays: 0,
    cardsDue: 0,
    cardsToday: 0,
    xpToday: 0,
    currentLevel: 'A1',
  );
}

@riverpod
Future<DashboardStats> dashboardStats(DashboardStatsRef ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return DashboardStats.empty;

  final today = DateTime.now().toIso8601String().split('T')[0];

  // Query profile for streak and level
  final profileRes = await supabase
      .from('profiles')
      .select('streak_days, current_level')
      .eq('id', userId)
      .maybeSingle();

  final streakDays = (profileRes?['streak_days'] as num?)?.toInt() ?? 0;
  final currentLevel = profileRes?['current_level'] as String? ?? 'A1';

  // Count cards due today or overdue
  final dueRes = await supabase
      .from('user_vocabulary_progress')
      .select()
      .eq('user_id', userId)
      .lte('due_date', today)
      .count(CountOption.exact);

  final cardsDue = dueRes.count;

  // Count reviews done today
  final todayStart = '${today}T00:00:00.000Z';
  final reviewsRes = await supabase
      .from('review_events')
      .select()
      .eq('user_id', userId)
      .gte('reviewed_at', todayStart)
      .count(CountOption.exact);

  final cardsToday = reviewsRes.count;

  return DashboardStats(
    streakDays: streakDays,
    cardsDue: cardsDue,
    cardsToday: cardsToday,
    xpToday: 0,
    currentLevel: currentLevel,
  );
}
