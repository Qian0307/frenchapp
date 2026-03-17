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
}

@riverpod
Future<DashboardStats> dashboardStats(DashboardStatsRef ref) async {
  final supabase = Supabase.instance.client;
  final res = await supabase.functions.invoke(
    'user/stats',
    method: HttpMethod.get,
  );
  if (res.data is Map && (res.data as Map).containsKey('error')) {
    throw Exception((res.data as Map)['error']);
  }
  return DashboardStats.fromJson(res.data as Map<String, dynamic>);
}
