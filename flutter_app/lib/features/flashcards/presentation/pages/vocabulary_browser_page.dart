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
  String   _search  = '';
  int      _page    = 1;
  bool     _loading = false;
  List<VocabularyModel> _vocab = [];

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) { _page = 1; _vocab = []; }
    setState(() => _loading = true);
    try {
      final repo    = ref.read(flashcardRepositoryProvider);
      final results = await repo.browseVocabulary(
        level: _level,
        query: _search.isEmpty ? null : _search,
        page:  _page,
      );
      setState(() {
        _vocab = reset ? results : [..._vocab, ...results];
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  controller:   _searchCtrl,
                  decoration:   const InputDecoration(
                    hintText:  'Search in French or English…',
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
                : ListView.builder(
                    itemCount: _vocab.length + (_loading ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == _vocab.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _VocabTile(
                        vocab: _vocab[i],
                        onEnroll: () async {
                          final repo = ref.read(flashcardRepositoryProvider);
                          await repo.enrollCard(_vocab[i].id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(
                                  '"${_vocab[i].frenchWord}" added to your deck')),
                            );
                          }
                        },
                      );
                    },
                    // Load next page when near bottom
                    // (Use NotificationListener or ScrollController in production)
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
              label:        Text(level),
              selected:     sel,
              onSelected:   (_) => onSelect(level),
              selectedColor: color.withAlpha(50),
              labelStyle:   TextStyle(color: sel ? color : null,
                                      fontWeight: sel ? FontWeight.w700 : null),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _VocabTile extends StatelessWidget {
  const _VocabTile({required this.vocab, required this.onEnroll});
  final VocabularyModel vocab;
  final VoidCallback    onEnroll;

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final levelColor = AppTheme.cefrColors[vocab.cefrLevel] ?? Colors.grey;

    return ListTile(
      title: Text(vocab.frenchWord,
          style: theme.textTheme.titleMedium),
      subtitle: Text('${vocab.pronunciationIpa}  ·  ${vocab.englishTrans}'),
      leading: Container(
        width:       40,
        height:      40,
        alignment:   Alignment.center,
        decoration:  BoxDecoration(
          color:        levelColor.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(vocab.cefrLevel,
            style: TextStyle(color: levelColor,
                fontWeight: FontWeight.w700, fontSize: 12)),
      ),
      trailing: IconButton(
        icon:      const Icon(Icons.add_circle_outline),
        tooltip:   'Add to deck',
        onPressed: onEnroll,
      ),
    );
  }
}
