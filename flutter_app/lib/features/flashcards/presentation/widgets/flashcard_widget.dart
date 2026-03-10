import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/models/vocabulary_model.dart';
import '../../../../core/theme/app_theme.dart';

/// A 3-D flip card showing French (front) → full detail (back).
class FlashcardWidget extends StatefulWidget {
  const FlashcardWidget({
    super.key,
    required this.progress,
    required this.isFlipped,
    required this.onTap,
  });

  final UserVocabProgress progress;
  final bool isFlipped;
  final VoidCallback onTap;

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 400),
    );
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(FlashcardWidget old) {
    super.didUpdateWidget(old);
    if (widget.isFlipped && !old.isFlipped) {
      _ctrl.forward();
    } else if (!widget.isFlipped && old.isFlipped) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    final url = widget.progress.vocabulary?.audioUrl;
    if (url == null) return;
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final angle = _anim.value * math.pi;
          final showBack = _anim.value > 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)   // perspective
              ..rotateY(angle),
            child: showBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _BackFace(progress: widget.progress, onPlayAudio: _playAudio),
                  )
                : _FrontFace(progress: widget.progress, onPlayAudio: _playAudio),
          );
        },
      ),
    );
  }
}

// ── Front face: French word + IPA ──────────────────────────

class _FrontFace extends StatelessWidget {
  const _FrontFace({required this.progress, required this.onPlayAudio});
  final UserVocabProgress progress;
  final VoidCallback onPlayAudio;

  @override
  Widget build(BuildContext context) {
    final vocab = progress.vocabulary;
    final theme = Theme.of(context);
    final levelColor = AppTheme.cefrColors[vocab?.cefrLevel] ?? Colors.grey;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CEFR badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color:        levelColor.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border:       Border.all(color: levelColor.withAlpha(80)),
              ),
              child: Text(
                vocab?.cefrLevel ?? '',
                style: theme.textTheme.labelLarge!.copyWith(color: levelColor),
              ),
            ),
            const SizedBox(height: 32),

            // Main word
            Text(
              vocab?.frenchWord ?? '',
              style: theme.textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // IPA + audio
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  vocab?.pronunciationIpa ?? '',
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (vocab?.audioUrl != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onPlayAudio,
                    child: Icon(Icons.volume_up_rounded,
                        color: theme.colorScheme.primary, size: 20),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),

            // Word class chip
            if (vocab?.wordClass != null)
              Chip(label: Text(vocab!.wordClass)),

            const Spacer(),

            Text(
              'Tap to reveal',
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Back face: full detail ──────────────────────────────────

class _BackFace extends StatelessWidget {
  const _BackFace({required this.progress, required this.onPlayAudio});
  final UserVocabProgress progress;
  final VoidCallback onPlayAudio;

  @override
  Widget build(BuildContext context) {
    final vocab = progress.vocabulary;
    final theme = Theme.of(context);
    final zhTw  = vocab?.chineseTransTw;

    return Card(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Primary: 繁體中文 ──────────────────────────
            if (zhTw != null && zhTw.isNotEmpty)
              Center(
                child: Text(
                  zhTw,
                  style: theme.textTheme.displayMedium!.copyWith(
                    fontFamily: GoogleFonts.notoSansTc().fontFamily,
                    fontSize: 28,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // ── Secondary: English ────────────────────────
            Center(
              child: Text(
                vocab?.englishTrans ?? '',
                style: theme.textTheme.titleMedium!.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(
                      zhTw != null && zhTw.isNotEmpty ? 153 : 255),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Gender / plural
            if (vocab?.gender != null || vocab?.pluralForm != null)
              _Section(
                title: 'Forms',
                child: Text(
                  [
                    if (vocab?.gender != null) vocab!.gender!,
                    if (vocab?.pluralForm != null) 'pl: ${vocab!.pluralForm}',
                  ].join('  ·  '),
                  style: theme.textTheme.bodyMedium,
                ),
              ),

            // Examples
            if ((vocab?.exampleSentences ?? []).isNotEmpty)
              _Section(
                title: 'Examples',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final ex in vocab!.exampleSentences.take(2)) ...[
                      Text(ex.fr,
                          style: theme.textTheme.bodyLarge!.copyWith(
                              fontStyle: FontStyle.italic)),
                      Text(ex.en,
                          style: theme.textTheme.bodyMedium!.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(153))),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),

            // Usage notes
            if (vocab?.usageNotes != null)
              _Section(
                title: 'Usage',
                child: Text(vocab!.usageNotes!, style: theme.textTheme.bodyMedium),
              ),

            // Memory tip
            if (vocab?.memoryTip != null)
              _Section(
                title: 'Memory tip',
                child: Row(
                  children: [
                    const Text('💡 '),
                    Expanded(
                      child: Text(vocab!.memoryTip!,
                          style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: theme.textTheme.labelLarge!.copyWith(
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                  fontSize: 11)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
