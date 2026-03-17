import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/providers/dashboard_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user   = Supabase.instance.client.auth.currentUser;
    final name   = user?.userMetadata?['username'] as String? ??
                   user?.email?.split('@').first ?? 'Étudiant';

    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero header ───────────────────────────────────
          SliverToBoxAdapter(
            child: statsAsync.when(
              loading: () => _HeroHeader(
                name:       name,
                level:      '—',
                streakDays: 0,
                xpToday:    0,
                isDark:     isDark,
              ).animate().fadeIn(duration: 400.ms),
              error: (_, __) => _HeroHeader(
                name:       name,
                level:      '—',
                streakDays: 0,
                xpToday:    0,
                isDark:     isDark,
              ).animate().fadeIn(duration: 400.ms),
              data: (stats) => _HeroHeader(
                name:       name,
                level:      stats.currentLevel,
                streakDays: stats.streakDays,
                xpToday:    stats.xpToday,
                isDark:     isDark,
              ).animate().fadeIn(duration: 400.ms),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Daily review ──────────────────────────
                _SectionLabel('今日複習', icon: Icons.style_rounded),
                const SizedBox(height: 10),
                statsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error:   (e, _) => _ErrorCard(message: '無法載入複習資料', onRetry: () => ref.invalidate(dashboardStatsProvider)),
                  data: (stats) => _ReviewCard(
                    cardsDue:   stats.cardsDue,
                    cardsToday: stats.cardsToday,
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.06),
                ),

                const SizedBox(height: 24),

                // ── Quick actions ─────────────────────────
                _SectionLabel('快速練習', icon: Icons.bolt_rounded),
                const SizedBox(height: 10),
                _QuickActionsGrid().animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 24),

                // ── Daily article ─────────────────────────
                _SectionLabel("Today's Article", icon: Icons.auto_stories_rounded),
                const SizedBox(height: 10),
                _DailyArticleCard(
                  title:   'La cuisine française : une tradition vivante',
                  level:   'A2',
                  minutes: 5,
                  tag:     'culture',
                  onTap:   () => context.push('/articles'),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.06),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Header ─────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.name,
    required this.level,
    required this.streakDays,
    required this.xpToday,
    required this.isDark,
  });
  final String name;
  final String level;
  final int    streakDays;
  final int    xpToday;
  final bool   isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A2545), const Color(0xFF0E1628)]
              : [AppTheme.primary, const Color(0xFF2A4D8F)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bonjour,',
                            style: TextStyle(
                                color: Colors.white.withAlpha(180),
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                        Text(name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color:        Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                      border:       Border.all(color: AppTheme.gold.withAlpha(160), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium_rounded,
                            color: AppTheme.gold, size: 16),
                        const SizedBox(width: 5),
                        Text(level,
                            style: TextStyle(
                                color:      AppTheme.gold,
                                fontWeight: FontWeight.w800,
                                fontSize:   14)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  _StatChip(icon: '🔥', value: '$streakDays', label: '天連續'),
                  const SizedBox(width: 12),
                  _StatChip(icon: '⭐', value: '$xpToday',    label: 'XP 今日'),
                  const SizedBox(width: 12),
                  _StatChip(icon: '📚', value: level,         label: '目前程度'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.value, required this.label});
  final String icon, value, label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color:        Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: Colors.white.withAlpha(25)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color:      Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize:   16)),
            Text(label,
                style: TextStyle(
                    color:      Colors.white.withAlpha(160),
                    fontSize:   10,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Error card ───────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String       message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
            TextButton(onPressed: onRetry, child: const Text('重試')),
          ],
        ),
      ),
    );
  }
}

// ── Section label ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title, {required this.icon});
  final String   title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.gold),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

// ── Review card ──────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.cardsDue, required this.cardsToday});
  final int cardsDue, cardsToday;

  @override
  Widget build(BuildContext context) {
    final progress = cardsDue > 0 ? cardsToday / cardsDue : 1.0;
    final isDone   = cardsToday >= cardsDue;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width:  56,
              height: 56,
              decoration: BoxDecoration(
                color:        isDone
                    ? AppTheme.cefrColors['A2']!.withAlpha(25)
                    : AppTheme.primary.withAlpha(18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isDone ? Icons.check_circle_rounded : Icons.style_rounded,
                color: isDone ? AppTheme.cefrColors['A2'] : AppTheme.primary,
                size:  28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isDone ? '今日複習完成！' : '待複習單字',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text('$cardsToday / $cardsDue 張',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(140))),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value:           progress,
                      minHeight:       5,
                      backgroundColor: AppTheme.primary.withAlpha(20),
                      valueColor: AlwaysStoppedAnimation(
                          isDone ? AppTheme.cefrColors['A2']! : AppTheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: () => GoRouter.of(context).push('/flashcards/session'),
              style: FilledButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: Text(isDone ? '再練習' : '開始',
                  style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick actions grid ───────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  static const _actions = [
    (Icons.style_rounded,        '單字卡',   '/flashcards/session', 'A2'),
    (Icons.auto_stories_rounded, '閱讀文章', '/articles',           'A1'),
    (Icons.school_rounded,       '文法課程', '/grammar',            'B1'),
    (Icons.edit_note_rounded,    '錯題本',   '/mistakes',           'C1'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing:  10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.0,
      children: _actions.asMap().entries.map((entry) {
        final (icon, label, route, lvl) = entry.value;
        final color = AppTheme.cefrColors[lvl]!;
        return _ActionTile(
          icon:  icon,
          label: label,
          color: color,
          onTap: () => GoRouter.of(context).push(route),
        );
      }).toList(),
    ).animate().fadeIn().slideY(begin: 0.04);
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color:        isDark ? color.withAlpha(30) : color.withAlpha(20),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap:        onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding:     const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:        color.withAlpha(isDark ? 50 : 35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label,
                    style: Theme.of(context).textTheme.titleSmall!
                        .copyWith(fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Daily article card ───────────────────────────────────────

class _DailyArticleCard extends StatelessWidget {
  const _DailyArticleCard({
    required this.title,
    required this.level,
    required this.minutes,
    required this.tag,
    required this.onTap,
  });
  final String       title, level, tag;
  final int          minutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final levelColor = AppTheme.cefrColors[level] ?? Colors.grey;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap:        onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width:  52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary.withAlpha(200), AppTheme.primary],
                    begin:  Alignment.topLeft,
                    end:    Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.article_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style:     Theme.of(context).textTheme.titleSmall,
                        maxLines:  2,
                        overflow:  TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Pill(level, levelColor),
                        const SizedBox(width: 8),
                        Icon(Icons.schedule_rounded,
                            size:  12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(100)),
                        const SizedBox(width: 3),
                        Text('$minutes min',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(width: 8),
                        _Pill(tag, AppTheme.gold),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(80)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, this.color);
  final String label;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:        color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(
              color:      color,
              fontSize:   11,
              fontWeight: FontWeight.w700)),
    );
  }
}
