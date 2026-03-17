import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/vocabulary_model.dart';
import '../../data/repositories/flashcard_repository.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/review_quality_bar.dart';
import '../widgets/session_progress_bar.dart';

/// Manages a complete review session: card stack, flip, grade, advance.
class FlashcardSessionPage extends ConsumerStatefulWidget {
  const FlashcardSessionPage({super.key, required this.sessionType});
  final String sessionType; // 'scheduled' | 'mistake_review' | 'quick'

  @override
  ConsumerState<FlashcardSessionPage> createState() => _FlashcardSessionPageState();
}

class _FlashcardSessionPageState extends ConsumerState<FlashcardSessionPage> {
  List<UserVocabProgress> _cards = [];
  int     _currentIndex  = 0;
  bool    _isFlipped     = false;
  bool    _isLoading     = true;
  bool    _sessionDone   = false;
  String? _sessionId;
  String? _errorMessage;

  int _totalReviewed = 0;
  int _totalCorrect  = 0;
  final Stopwatch _sessionWatch = Stopwatch();
  final Stopwatch _cardWatch    = Stopwatch();

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    final repo = ref.read(flashcardRepositoryProvider);
    try {
      _sessionId = await repo.startSession();
      final cards = await repo.getDueCards(
        limit: 20,
        type:  widget.sessionType == 'mistake_review' ? 'scheduled' : widget.sessionType,
      );
      if (mounted) {
        setState(() {
          _cards     = cards;
          _isLoading = false;
        });
        _sessionWatch.start();
        _cardWatch.start();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading    = false;
        });
      }
    }
  }

  void _flipCard() => setState(() => _isFlipped = true);

  Future<void> _gradeCard(ReviewQuality quality) async {
    if (_sessionId == null || _currentIndex >= _cards.length) return;

    final card       = _cards[_currentIndex];
    final responseMs = _cardWatch.elapsedMilliseconds;
    _cardWatch
      ..reset()
      ..start();

    final repo = ref.read(flashcardRepositoryProvider);
    try {
      await repo.submitReview(
        sessionId:    _sessionId!,
        vocabularyId: card.vocabularyId,
        quality:      quality,
        responseMs:   responseMs,
      );
    } catch (_) {
      // Best-effort: don't block UX on review submit failure
    }

    _totalReviewed++;
    if (quality == ReviewQuality.good || quality == ReviewQuality.easy) {
      _totalCorrect++;
    }

    // If wrong, append card to end of queue (leitner-style)
    if (quality == ReviewQuality.again) {
      setState(() => _cards = [..._cards, card]);
    }

    if (_currentIndex + 1 >= _cards.length) {
      await _endSession();
    } else {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    }
  }

  Future<void> _endSession() async {
    _sessionWatch.stop();
    if (_sessionId == null) {
      setState(() => _sessionDone = true);
      return;
    }
    try {
      final repo = ref.read(flashcardRepositoryProvider);
      await repo.endSession(
        sessionId:     _sessionId!,
        cardsReviewed: _totalReviewed,
        cardsCorrect:  _totalCorrect,
        durationSecs:  _sessionWatch.elapsed.inSeconds,
      );
    } catch (_) {
      // Best-effort: show summary even if end-session call fails
    }
    if (mounted) setState(() => _sessionDone = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text('無法載入複習卡片',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _loadSession,
                child: const Text('重試'),
              ),
            ],
          ),
        ),
      );
    }

    if (_cards.isEmpty) {
      return _NoCardsView(onBack: () => context.pop());
    }

    if (_sessionDone) {
      return _SessionSummaryView(
        total:   _totalReviewed,
        correct: _totalCorrect,
        onDone:  () => context.pop(),
      );
    }

    final card = _cards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            await _endSession();
            if (mounted) context.pop();
          },
        ),
        title: const Text('複習練習'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              '${_currentIndex + 1}/${_cards.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: SessionProgressBar(
            current: _currentIndex,
            total:   _cards.length,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Flashcard
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FlashcardWidget(
                  progress:  card,
                  isFlipped: _isFlipped,
                  onTap:     _flipCard,
                ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.05, end: 0),
              ),
            ),

            // Grade buttons (only visible after flip)
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _isFlipped
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: ReviewQualityBar(onGrade: _gradeCard),
              ),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: FilledButton(
                  onPressed: _flipCard,
                  child: const Text('Show Answer'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-views ──────────────────────────────────────────────

class _NoCardsView extends StatelessWidget {
  const _NoCardsView({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            Text('All caught up!',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('No cards due for review today.',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            FilledButton(
                onPressed: onBack, child: const Text('Back to Dashboard')),
          ],
        ),
      ),
    );
  }
}

class _SessionSummaryView extends StatelessWidget {
  const _SessionSummaryView({
    required this.total,
    required this.correct,
    required this.onDone,
  });
  final int          total;
  final int          correct;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final pct   = total > 0 ? (correct / total * 100).round() : 0;
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Session Complete!',
                  style: theme.textTheme.displayMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 32),
              _StatRow(label: 'Cards reviewed', value: '$total'),
              _StatRow(label: 'Correct',        value: '$correct'),
              _StatRow(label: 'Accuracy',       value: '$pct%'),
              const SizedBox(height: 40),
              FilledButton(onPressed: onDone, child: const Text('Done')),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
