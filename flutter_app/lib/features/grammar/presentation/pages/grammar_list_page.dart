import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/grammar_model.dart';
import '../../data/repositories/grammar_repository.dart';

class GrammarListPage extends ConsumerStatefulWidget {
  const GrammarListPage({super.key});
  @override
  ConsumerState<GrammarListPage> createState() => _GrammarListPageState();
}

class _GrammarListPageState extends ConsumerState<GrammarListPage> {
  String? _filter;
  bool    _isLoading = false;
  String? _error;
  List<GrammarLesson> _lessons = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final repo = ref.read(grammarRepositoryProvider);
      final results = await repo.listLessons(level: _filter);
      setState(() => _lessons = results);
    } catch (e) {
      setState(() => _error = '載入失敗，請稍後再試');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文法課程'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _LevelFilter(
            selected: _filter,
            onSelect: (level) {
              setState(() => _filter = level == _filter ? null : level);
              _load();
            },
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _load)
              : _lessons.isEmpty
                  ? const _EmptyState()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _lessons.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => _LessonTile(
                          lesson: _lessons[i],
                          onTap: () => context.push('/grammar/${_lessons[i].id}'),
                        ),
                      ),
                    ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────

class _LevelFilter extends StatelessWidget {
  const _LevelFilter({required this.selected, required this.onSelect});
  final String? selected;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _FilterChip(label: '全部', color: AppTheme.primary,
              selected: selected == null, onTap: () => onSelect('')),
          ...AppConstants.cefrLevels.map((l) => _FilterChip(
            label: l,
            color: AppTheme.cefrColors[l]!,
            selected: selected == l,
            onTap: () => onSelect(l),
          )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final Color  color;
  final bool   selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : color.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? color : color.withAlpha(60), width: 1.5),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? Colors.white : color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            )),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson, required this.onTap});
  final GrammarLesson lesson;
  final VoidCallback  onTap;

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final levelColor = AppTheme.cefrColors[lesson.cefrLevel] ?? Colors.grey;
    final isDone     = lesson.isCompleted;
    final isStarted  = lesson.isStarted;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isDone
                      ? (AppTheme.cefrColors['A2'] ?? Colors.green).withAlpha(25)
                      : isStarted
                          ? AppTheme.gold.withAlpha(25)
                          : levelColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isDone
                      ? Icons.check_circle_rounded
                      : isStarted
                          ? Icons.play_circle_outline_rounded
                          : Icons.school_rounded,
                  color: isDone
                      ? AppTheme.cefrColors['A2']
                      : isStarted
                          ? AppTheme.gold
                          : levelColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.title,
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (lesson.description != null) ...[
                      const SizedBox(height: 3),
                      Text(lesson.description!,
                          style: theme.textTheme.bodySmall!.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(130)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Pill(lesson.cefrLevel, levelColor),
                        if (lesson.topicCategory != null) ...[
                          const SizedBox(width: 6),
                          _Pill(lesson.topicCategory!, AppTheme.gold),
                        ],
                        if (isDone && lesson.bestScorePct != null) ...[
                          const SizedBox(width: 6),
                          _Pill('${lesson.bestScorePct}%',
                              AppTheme.cefrColors['A2'] ?? Colors.green),
                        ],
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

class _Pill extends StatelessWidget {
  const _Pill(this.label, this.color);
  final String label;
  final Color  color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
        color: color.withAlpha(25), borderRadius: BorderRadius.circular(10)),
    child: Text(label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.school_outlined, size: 64,
            color: AppTheme.primary.withAlpha(80)),
        const SizedBox(height: 16),
        Text('目前沒有課程', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('請稍後再查看', style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(130))),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String   message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.wifi_off_rounded, size: 64, color: AppTheme.red.withAlpha(120)),
        const SizedBox(height: 16),
        Text(message, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('重試'),
          style: FilledButton.styleFrom(minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
        ),
      ],
    ),
  );
}
