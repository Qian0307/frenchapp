import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class ArticleListPage extends ConsumerStatefulWidget {
  const ArticleListPage({super.key});

  @override
  ConsumerState<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends ConsumerState<ArticleListPage> {
  String? _filterLevel;
  bool    _isLoading  = false;
  final List<Map<String, dynamic>> _articles = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    // TODO: ArticleRepository.listArticles(level: _filterLevel)
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _LevelFilterBar(
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
          : _articles.isEmpty
              ? const Center(child: Text('No articles available.'))
              : ListView.separated(
                  padding:           const EdgeInsets.all(16),
                  itemCount:         _articles.length,
                  separatorBuilder:  (_, __) => const SizedBox(height: 10),
                  itemBuilder:       (context, i) => _ArticleTile(
                    article: _articles[i],
                    onTap:   () => context.push('/articles/${_articles[i]['id']}'),
                  ),
                ),
    );
  }
}

class _LevelFilterBar extends StatelessWidget {
  const _LevelFilterBar({required this.selected, required this.onSelect});
  final String?               selected;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding:         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: AppConstants.cefrLevels.map((level) {
          final color    = AppTheme.cefrColors[level] ?? Colors.grey;
          final isSelected = selected == level;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label:           Text(level),
              selected:        isSelected,
              onSelected:      (_) => onSelect(level),
              selectedColor:   color.withAlpha(50),
              checkmarkColor:  color,
              labelStyle:      TextStyle(
                color:      isSelected ? color : null,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.article, required this.onTap});
  final Map<String, dynamic> article;
  final VoidCallback         onTap;

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final levelColor = AppTheme.cefrColors[article['cefr_level']] ?? Colors.grey;
    final read       = article['read_progress'] as Map<String, dynamic>?;
    final pct        = read?['progress_pct'] as int? ?? 0;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Thumbnail
                  if (article['cover_image_url'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        article['cover_image_url'],
                        width: 72, height: 72, fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width:       72,
                      height:      72,
                      decoration:  BoxDecoration(
                        color:        levelColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.article_rounded, color: levelColor, size: 32),
                    ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article['title'] ?? '',
                          style:    theme.textTheme.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color:        levelColor.withAlpha(30),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(article['cefr_level'] ?? '',
                                  style: TextStyle(color: levelColor,
                                      fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 8),
                            if (article['reading_time_mins'] != null)
                              Text('${article['reading_time_mins']} min',
                                  style: theme.textTheme.bodySmall),
                            if (read?['is_completed'] == true) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle,
                                  size: 14, color: Colors.green),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Read progress bar
            if (pct > 0 && pct < 100)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: LinearProgressIndicator(
                  value:           pct / 100,
                  minHeight:       3,
                  backgroundColor: Colors.transparent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
