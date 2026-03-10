import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mistake Book: lists incorrectly-answered vocabulary with notes and resolve action.
class MistakeBookPage extends ConsumerStatefulWidget {
  const MistakeBookPage({super.key});

  @override
  ConsumerState<MistakeBookPage> createState() => _MistakeBookPageState();
}

class _MistakeBookPageState extends ConsumerState<MistakeBookPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _isLoading = false;
  List<Map<String, dynamic>> _mistakes   = [];
  List<Map<String, dynamic>> _resolved   = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    // TODO: MistakeBookRepository.listMistakes()
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _isLoading = false);
  }

  Future<void> _resolve(String vocabId) async {
    // TODO: MistakeBookRepository.resolve(vocabId)
    final idx = _mistakes.indexWhere((m) => m['vocabulary_id'] == vocabId);
    if (idx == -1) return;
    final resolved = _mistakes.removeAt(idx);
    setState(() => _resolved.insert(0, {...resolved, 'is_resolved': true}));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marked as resolved')),
      );
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mistake Book'),
        actions: [
          if (_mistakes.isNotEmpty)
            FilledButton.tonal(
              onPressed: () =>
                  context.push('/flashcards/session?type=mistake_review'),
              child: const Text('Review All'),
            ),
          const SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: 'Unresolved (${_mistakes.length})'),
            Tab(text: 'Resolved (${_resolved.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _MistakeList(
                  mistakes:   _mistakes,
                  showResolve: true,
                  onResolve:  _resolve,
                ),
                _MistakeList(
                  mistakes:    _resolved,
                  showResolve: false,
                  onResolve:   (_) {},
                ),
              ],
            ),
    );
  }
}

class _MistakeList extends StatelessWidget {
  const _MistakeList({
    required this.mistakes,
    required this.showResolve,
    required this.onResolve,
  });

  final List<Map<String, dynamic>> mistakes;
  final bool                        showResolve;
  final void Function(String)       onResolve;

  @override
  Widget build(BuildContext context) {
    if (mistakes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            const SizedBox(height: 12),
            Text(
              showResolve ? 'No mistakes — great work!' : 'Nothing resolved yet.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding:           const EdgeInsets.all(16),
      itemCount:         mistakes.length,
      separatorBuilder:  (_, __) => const SizedBox(height: 8),
      itemBuilder:       (context, i) {
        final m = mistakes[i];
        return _MistakeCard(mistake: m, showResolve: showResolve, onResolve: onResolve);
      },
    );
  }
}

class _MistakeCard extends StatelessWidget {
  const _MistakeCard({
    required this.mistake,
    required this.showResolve,
    required this.onResolve,
  });

  final Map<String, dynamic>  mistake;
  final bool                   showResolve;
  final void Function(String)  onResolve;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final vocab  = mistake['vocabulary'] as Map<String, dynamic>?;
    final count  = mistake['mistake_count'] as int? ?? 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    vocab?['french_word'] ?? '—',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                // Mistake count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color:        theme.colorScheme.error.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '×$count',
                    style: TextStyle(
                      color:      theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                      fontSize:   13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              vocab?['english_trans'] ?? '',
              style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153)),
            ),
            const SizedBox(height: 4),
            Text(
              vocab?['pronunciation_ipa'] ?? '',
              style: theme.textTheme.bodySmall!.copyWith(fontStyle: FontStyle.italic),
            ),

            // User note
            if (mistake['note'] != null && (mistake['note'] as String).isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.sticky_note_2_outlined,
                      size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      mistake['note'] as String,
                      style: theme.textTheme.bodySmall!.copyWith(
                          color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ],

            if (showResolve) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon:  const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Add Note'),
                    style: OutlinedButton.styleFrom(minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: () => onResolve(vocab?['id'] ?? ''),
                    child: const Text('Resolve'),
                    style: FilledButton.styleFrom(minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
