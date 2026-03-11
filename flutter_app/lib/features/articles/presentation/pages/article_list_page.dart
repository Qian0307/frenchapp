import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/article_model.dart';
import '../../data/repositories/article_repository.dart';

class ArticleListPage extends ConsumerStatefulWidget {
  const ArticleListPage({super.key});
  @override
  ConsumerState<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends ConsumerState<ArticleListPage> {
  String? _filterLevel;
  bool    _isLoading = false;
  String? _error;
  List<ArticleModel> _articles = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final repo = ref.read(articleRepositoryProvider);
      final results = await repo.listArticles(level: _filterLevel);
      setState(() => _articles = results);
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
        title: const Text('閱讀文章'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _LevelFilter(
            selected: _filterLevel,
            onSelect: (level) {
              setState(() => _filterLevel = level == _filterLevel ? null : level);
              _load();
            },
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _load)
              : _articles.isEmpty
                  ? const _EmptyState()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _articles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => _ArticleTile(
                          article: _articles[i],
                          onTap: () => context.push('/articles/${_articles[i].id}'),
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

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.article, required this.onTap});
  final ArticleModel article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final levelColor = AppTheme.cefrColors[article.cefrLevel] ?? Colors.grey;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover / icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary.withAlpha(180), AppTheme.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.article_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.title,
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (article.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(article.subtitle!,
                          style: theme.textTheme.bodySmall!.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(130)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Pill(article.cefrLevel, levelColor),
                        const SizedBox(width: 8),
                        Icon(Icons.schedule_rounded, size: 12,
                            color: theme.colorScheme.onSurface.withAlpha(100)),
                        const SizedBox(width: 3),
                        Text('${article.readingTimeMins} min',
                            style: theme.textTheme.bodySmall),
                        if (article.isCompleted) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.check_circle_rounded,
                              size: 14, color: AppTheme.cefrColors['A2']),
                        ],
                      ],
                    ),
                    if (article.progressPct > 0 && !article.isCompleted) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: article.progressPct / 100,
                          minHeight: 4,
                          backgroundColor: AppTheme.primary.withAlpha(20),
                          valueColor: AlwaysStoppedAnimation(levelColor),
                        ),
                      ),
                    ],
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
        Icon(Icons.auto_stories_outlined, size: 64,
            color: AppTheme.primary.withAlpha(80)),
        const SizedBox(height: 16),
        Text('目前沒有文章', style: Theme.of(context).textTheme.titleMedium),
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
