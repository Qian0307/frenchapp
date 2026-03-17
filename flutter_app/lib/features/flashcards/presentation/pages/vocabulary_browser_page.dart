import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/vocabulary_model.dart';
import '../../data/repositories/flashcard_repository.dart';

class VocabularyBrowserPage extends ConsumerStatefulWidget {
  const VocabularyBrowserPage({super.key});

  @override
  ConsumerState<VocabularyBrowserPage> createState() => _VocabularyBrowserPageState();
}

class _VocabularyBrowserPageState extends ConsumerState<VocabularyBrowserPage> {
  String?  _level;
  String   _search       = '';
  int      _page         = 1;
  bool     _loading      = false;
  bool     _hasMore      = true;
  String?  _error;
  List<VocabularyModel> _vocab = [];
  final Set<String> _enrollingIds = {};

  final _searchCtrl  = TextEditingController();
  final _scrollCtrl  = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_loading || !_hasMore) return;
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _page++;
      _load();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      _page    = 1;
      _vocab   = [];
      _hasMore = true;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final repo    = ref.read(flashcardRepositoryProvider);
      final results = await repo.browseVocabulary(
        level: _level,
        query: _search.isEmpty ? null : _search,
        page:  _page,
      );
      if (mounted) {
        setState(() {
          _vocab   = reset ? results : [..._vocab, ...results];
          _hasMore = results.isNotEmpty;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error   = '載入失敗，請稍後再試';
          _loading = false;
        });
      }
    }
  }

  Future<void> _enroll(VocabularyModel vocab) async {
    if (_enrollingIds.contains(vocab.id)) return;
    setState(() => _enrollingIds.add(vocab.id));
    try {
      await ref.read(flashcardRepositoryProvider).enrollCard(vocab.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${vocab.frenchWord}" 已加入單字卡')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加入失敗：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _enrollingIds.remove(vocab.id));
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => context.push('/flashcards/session'),
              icon:  const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Review'),
              style: FilledButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + filter
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    hintText:   'Search in French or English…',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) {
                    _search = v;
                    _load(reset: true);
                  },
                ),
                const SizedBox(height: 8),
                _LevelChips(
                  selected: _level,
                  onSelect: (level) {
                    setState(() => _level = level == _level ? null : level);
                    _load(reset: true);
                  },
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _loading && _vocab.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _vocab.isEmpty
                    ? _ErrorView(message: _error!, onRetry: () => _load(reset: true))
                    : _vocab.isEmpty
                        ? const _EmptyView()
                        : ListView.builder(
                            controller: _scrollCtrl,
                            itemCount:  _vocab.length + (_loading ? 1 : 0),
                            itemBuilder: (context, i) {
                              if (i == _vocab.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              final v = _vocab[i];
                              return _VocabTile(
                                vocab:       v,
                                isEnrolling: _enrollingIds.contains(v.id),
                                onEnroll:    () => _enroll(v),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _LevelChips extends StatelessWidget {
  const _LevelChips({required this.selected, required this.onSelect});
  final String?               selected;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'].map((level) {
          final color = AppTheme.cefrColors[level] ?? Colors.grey;
          final sel   = selected == level;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label:         Text(level),
              selected:      sel,
              onSelected:    (_) => onSelect(level),
              selectedColor: color.withAlpha(50),
              labelStyle: TextStyle(
                  color:      sel ? color : null,
                  fontWeight: sel ? FontWeight.w700 : null),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _VocabTile extends StatelessWidget {
  const _VocabTile({
    required this.vocab,
    required this.isEnrolling,
    required this.onEnroll,
  });
  final VocabularyModel vocab;
  final bool            isEnrolling;
  final VoidCallback    onEnroll;

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final levelColor = AppTheme.cefrColors[vocab.cefrLevel] ?? Colors.grey;

    return ListTile(
      title:    Text(vocab.frenchWord, style: theme.textTheme.titleMedium),
      subtitle: Text('${vocab.pronunciationIpa}  ·  ${vocab.englishTrans}'),
      leading: Container(
        width:      40,
        height:     40,
        alignment:  Alignment.center,
        decoration: BoxDecoration(
          color:        levelColor.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(vocab.cefrLevel,
            style: TextStyle(
                color:      levelColor,
                fontWeight: FontWeight.w700,
                fontSize:   12)),
      ),
      trailing: isEnrolling
          ? const SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(strokeWidth: 2))
          : IconButton(
              icon:      const Icon(Icons.add_circle_outline),
              tooltip:   'Add to deck',
              onPressed: onEnroll,
            ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String       message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded,
              size: 56, color: AppTheme.red.withAlpha(120)),
          const SizedBox(height: 12),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon:  const Icon(Icons.refresh_rounded),
            label: const Text('重試'),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 56, color: AppTheme.primary.withAlpha(80)),
          const SizedBox(height: 12),
          Text('找不到單字', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
