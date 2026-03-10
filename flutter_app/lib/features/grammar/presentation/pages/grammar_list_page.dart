import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class GrammarListPage extends ConsumerStatefulWidget {
  const GrammarListPage({super.key});

  @override
  ConsumerState<GrammarListPage> createState() => _GrammarListPageState();
}

class _GrammarListPageState extends ConsumerState<GrammarListPage> {
  bool   _isLoading = false;
  String _filter    = 'A1';
  final List<Map<String, dynamic>> _lessons = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    // TODO: GrammarRepository.listLessons(level: _filter)
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grammar'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _TabFilter(
            selected: _filter,
            onSelect: (level) { setState(() => _filter = level); _load(); },
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lessons.isEmpty
              ? Center(
                  child: Text('No lessons available for $_filter.'),
                )
              : ListView.separated(
                  padding:          const EdgeInsets.all(16),
                  itemCount:        _lessons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder:      (context, i) {
                    final lesson = _lessons[i];
                    final prog   = lesson['progress'] as Map<String, dynamic>?;
                    final done   = prog?['is_completed'] == true;
                    final score  = prog?['best_score_pct'] as int? ?? 0;

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: done
                              ? Colors.green.withAlpha(30)
                              : theme.colorScheme.primary.withAlpha(20),
                          child: Icon(
                            done ? Icons.check_rounded : Icons.school_outlined,
                            color: done ? Colors.green : theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(lesson['title'] ?? ''),
                        subtitle: Text(
                          done ? 'Score: $score%' : lesson['description'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/grammar/${lesson['id']}'),
                      ),
                    );
                  },
                ),
    );
  }
}

class _TabFilter extends StatelessWidget {
  const _TabFilter({required this.selected, required this.onSelect});
  final String               selected;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding:         const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'].map((level) {
          final color      = AppTheme.cefrColors[level] ?? Colors.grey;
          final isSelected = selected == level;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label:           Text(level),
              selected:        isSelected,
              onSelected:      (_) => onSelect(level),
              selectedColor:   color.withAlpha(50),
              labelStyle:      TextStyle(
                color:      isSelected ? color : null,
                fontWeight: isSelected ? FontWeight.w700 : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
