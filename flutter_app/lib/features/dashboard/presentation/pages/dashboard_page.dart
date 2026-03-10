import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

/// Home dashboard: streak, daily progress, quick actions, daily article card.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: wire to providers
    const streakDays   = 7;
    const cardsDue     = 15;
    const cardsToday   = 8;
    const xpToday      = 45;
    const currentLevel = 'A2';

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bonjour!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Streak + Level banner ─────────────────────
              _StreakCard(
                streakDays: streakDays,
                level:      currentLevel,
                xpToday:    xpToday,
              ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.05),

              const SizedBox(height: 16),

              // ── Daily review card ─────────────────────────
              _ReviewCard(
                cardsDue:   cardsDue,
                cardsToday: cardsToday,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),

              const SizedBox(height: 16),

              // ── Daily article ─────────────────────────────
              Text('Today\'s Article',
                  style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _DailyArticleCard(
                title:   'La cuisine française : une tradition vivante',
                level:   'A2',
                minutes: 5,
                tag:     'culture',
                onTap:   () => context.push('/articles/daily'),
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05),

              const SizedBox(height: 16),

              // ── Quick actions ─────────────────────────────
              Text('Quick Practice',
                  style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount:  2,
                shrinkWrap:      true,
                physics:         const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.6,
                children: [
                  _QuickAction(
                    icon:  Icons.style_rounded,
                    label: 'Flashcards',
                    color: AppTheme.cefrColors['A2']!,
                    onTap: () => context.push('/flashcards/session'),
                  ),
                  _QuickAction(
                    icon:  Icons.menu_book_rounded,
                    label: 'Grammar',
                    color: AppTheme.cefrColors['B1']!,
                    onTap: () => context.push('/grammar'),
                  ),
                  _QuickAction(
                    icon:  Icons.auto_stories_rounded,
                    label: 'Articles',
                    color: AppTheme.cefrColors['A1']!,
                    onTap: () => context.push('/articles'),
                  ),
                  _QuickAction(
                    icon:  Icons.edit_note_rounded,
                    label: 'Mistake Book',
                    color: AppTheme.cefrColors['C1']!,
                    onTap: () => context.push('/mistakes'),
                  ),
                ].animate(interval: 50.ms).fadeIn().slideY(begin: 0.05),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.streakDays,
    required this.level,
    required this.xpToday,
  });
  final int    streakDays;
  final String level;
  final int    xpToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levelColor = AppTheme.cefrColors[level] ?? Colors.grey;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Streak
            Column(
              children: [
                Text('🔥', style: const TextStyle(fontSize: 32)),
                Text('$streakDays day${streakDays != 1 ? "s" : ""}',
                    style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w700)),
                Text('streak', style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(width: 24),
            Container(width: 1, height: 60, color: theme.dividerColor),
            const SizedBox(width: 24),
            // Level
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color:        levelColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                    border:       Border.all(color: levelColor),
                  ),
                  child: Text(level,
                      style: TextStyle(
                          color:      levelColor,
                          fontWeight: FontWeight.w700,
                          fontSize:   18)),
                ),
                const SizedBox(height: 4),
                Text('current level', style: theme.textTheme.bodySmall),
              ],
            ),
            const Spacer(),
            // XP today
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$xpToday XP',
                    style: theme.textTheme.titleLarge!.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700)),
                Text('today', style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.cardsDue, required this.cardsToday});
  final int cardsDue;
  final int cardsToday;

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final progress = cardsDue > 0 ? cardsToday / cardsDue : 1.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Review',
                          style: theme.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('$cardsToday / $cardsDue cards completed',
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () => GoRouter.of(context).push('/flashcards/session'),
                  style: FilledButton.styleFrom(minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                  child: Text(cardsToday >= cardsDue ? 'Done!' : 'Continue'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value:       progress,
                minHeight:   8,
                backgroundColor: theme.colorScheme.primary.withAlpha(25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyArticleCard extends StatelessWidget {
  const _DailyArticleCard({
    required this.title,
    required this.level,
    required this.minutes,
    required this.tag,
    required this.onTap,
  });
  final String    title;
  final String    level;
  final int       minutes;
  final String    tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final levelColor = AppTheme.cefrColors[level] ?? Colors.grey;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width:       56,
                height:      56,
                decoration:  BoxDecoration(
                  color:        theme.colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.article_rounded,
                    color: theme.colorScheme.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:        levelColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(level,
                              style: TextStyle(color: levelColor,
                                  fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.schedule, size: 13,
                            color: theme.colorScheme.onSurface.withAlpha(100)),
                        const SizedBox(width: 3),
                        Text('$minutes min',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withAlpha(80)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData  icon;
  final String    label;
  final Color     color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color:        color.withAlpha(25),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Text(label,
                  style: theme.textTheme.titleSmall!.copyWith(
                      color: theme.colorScheme.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}
