import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// Bottom-sheet popup shown when the user taps a vocabulary word in an article.
class VocabularyPopup extends ConsumerStatefulWidget {
  const VocabularyPopup({super.key, required this.vocabId});
  final String vocabId;

  @override
  ConsumerState<VocabularyPopup> createState() => _VocabularyPopupState();
}

class _VocabularyPopupState extends ConsumerState<VocabularyPopup> {
  Map<String, dynamic>? _vocab;
  bool  _isLoading = true;
  bool  _enrolled  = false;
  final _player    = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadVocab();
  }

  Future<void> _loadVocab() async {
    // TODO: call ArticleRepository.lookupVocab(vocabId)
    // For now use placeholder data
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _vocab = {
        'french_word':     'exemple',
        'english_trans':   'example',
        'pronunciation_ipa': '/ɛɡ.zɑ̃pl/',
        'word_class':      'noun',
        'gender':          'masculine',
        'cefr_level':      'A1',
        'usage_notes':     'Very common word used in all registers.',
        'example_sentences': [
          {'fr': 'Voici un exemple.', 'en': 'Here is an example.'}
        ],
      };
      _isLoading = false;
    });
  }

  Future<void> _playAudio() async {
    final url = _vocab?['audio_url'] as String?;
    if (url == null) return;
    await _player.setUrl(url);
    await _player.play();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize:     0.9,
      minChildSize:     0.4,
      expand:           false,
      builder: (context, controller) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_vocab == null) {
          return const Center(child: Text('Word not found'));
        }

        return Container(
          decoration: BoxDecoration(
            color:        theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width:  40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:        theme.colorScheme.onSurface.withAlpha(40),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _vocab!['french_word'] ?? '',
                                style: theme.textTheme.displayMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _vocab!['pronunciation_ipa'] ?? '',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: theme.colorScheme.onSurface.withAlpha(153),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Audio play button
                        IconButton(
                          onPressed:  _playAudio,
                          icon:       const Icon(Icons.volume_up_rounded),
                          iconSize:   28,
                          color:      theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Chips: word class, gender, CEFR
                    Wrap(
                      spacing: 8,
                      children: [
                        if (_vocab!['word_class'] != null)
                          Chip(label: Text(_vocab!['word_class'])),
                        if (_vocab!['gender'] != null)
                          Chip(label: Text(_vocab!['gender'])),
                        if (_vocab!['cefr_level'] != null)
                          Chip(label: Text(_vocab!['cefr_level'])),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 繁體中文翻譯 (primary)
                    if ((_vocab!['translations'] as Map<String,dynamic>?)?['zh_tw'] != null) ...[
                      Text('繁體中文',
                          style: theme.textTheme.labelLarge!.copyWith(
                            color:         theme.colorScheme.primary,
                            letterSpacing: 1,
                            fontSize:      11,
                          )),
                      const SizedBox(height: 4),
                      Text(
                        (_vocab!['translations'] as Map<String,dynamic>)['zh_tw'] as String,
                        style: theme.textTheme.titleLarge!.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // English translation (secondary)
                    Text('English',
                        style: theme.textTheme.labelLarge!.copyWith(
                          color:       theme.colorScheme.primary,
                          letterSpacing: 1,
                          fontSize:    11,
                        )),
                    const SizedBox(height: 4),
                    Text(_vocab!['english_trans'] ?? '',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 16),

                    // Examples
                    if ((_vocab!['example_sentences'] as List?)?.isNotEmpty ?? false) ...[
                      Text('Examples',
                          style: theme.textTheme.labelLarge!.copyWith(
                            color: theme.colorScheme.primary, letterSpacing: 1, fontSize: 11,
                          )),
                      const SizedBox(height: 4),
                      for (final ex in (_vocab!['example_sentences'] as List).take(2)) ...[
                        Text(ex['fr'] ?? '',
                            style: theme.textTheme.bodyLarge!.copyWith(
                                fontStyle: FontStyle.italic)),
                        Text(ex['en'] ?? '',
                            style: theme.textTheme.bodyMedium!.copyWith(
                                color: theme.colorScheme.onSurface.withAlpha(153))),
                        const SizedBox(height: 8),
                      ],
                    ],

                    // Usage notes
                    if (_vocab!['usage_notes'] != null) ...[
                      const SizedBox(height: 8),
                      Text('Notes',
                          style: theme.textTheme.labelLarge!.copyWith(
                            color: theme.colorScheme.primary, letterSpacing: 1, fontSize: 11,
                          )),
                      const SizedBox(height: 4),
                      Text(_vocab!['usage_notes'],
                          style: theme.textTheme.bodyMedium),
                    ],

                    const SizedBox(height: 24),

                    // Add to deck button
                    FilledButton.icon(
                      onPressed: _enrolled
                          ? null
                          : () {
                              setState(() => _enrolled = true);
                              // TODO: call FlashcardRepository.enrollCard
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added to your flashcard deck')),
                              );
                            },
                      icon:  Icon(_enrolled ? Icons.check : Icons.add),
                      label: Text(_enrolled ? 'Added to Deck' : 'Add to Flashcard Deck'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
