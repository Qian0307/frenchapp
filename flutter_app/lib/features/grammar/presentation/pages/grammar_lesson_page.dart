import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/grammar_repository.dart';
import '../widgets/exercise_widget.dart';

/// Lesson detail: explanation markdown + exercises in a stepper-style flow.
class GrammarLessonPage extends ConsumerStatefulWidget {
  const GrammarLessonPage({super.key, required this.lessonId});
  final String lessonId;

  @override
  ConsumerState<GrammarLessonPage> createState() => _GrammarLessonPageState();
}

class _GrammarLessonPageState extends ConsumerState<GrammarLessonPage> {
  Map<String, dynamic>? _lesson;
  List<dynamic>         _exercises = [];
  bool                  _isLoading = true;
  String?               _errorMessage;

  // Exercise state
  int  _phase         = 0; // 0=reading, 1=exercises, 2=complete
  int  _exIndex       = 0;
  int  _correctCount  = 0;
  int  _totalAttempts = 0;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    try {
      final repo   = ref.read(grammarRepositoryProvider);
      final lesson = await repo.getLesson(widget.lessonId);
      if (mounted) {
        setState(() {
          _lesson    = lesson;
          _exercises = (lesson['exercises'] as List?) ?? [];
          _isLoading = false;
        });
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

  void _startExercises() => setState(() => _phase = 1);

  void _onExerciseResult(bool correct) {
    if (correct) _correctCount++;
    _totalAttempts++;

    if (_exIndex + 1 >= _exercises.length) {
      _completeLesson();
    } else {
      setState(() => _exIndex++);
    }
  }

  Future<void> _completeLesson() async {
    final score = _exercises.isEmpty
        ? 100
        : (_correctCount / _totalAttempts * 100).round();
    try {
      await ref.read(grammarRepositoryProvider)
          .completeLesson(widget.lessonId, scorePct: score);
    } catch (_) {
      // Best-effort: don't block completion UI on network error
    }
    if (mounted) setState(() => _phase = 2);
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
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text('無法載入課程', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isLoading    = true;
                  });
                  _loadLesson();
                },
                child: const Text('重試'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_lesson?['title'] ?? ''),
        actions: [
          if (_lesson?['cefr_level'] != null)
            Chip(
              label:   Text(_lesson!['cefr_level']),
              padding: EdgeInsets.zero,
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: IndexedStack(
        index: _phase,
        children: [
          // ── Phase 0: Explanation ──────────────────────────
          _ExplanationPhase(lesson: _lesson!, onStart: _startExercises),

          // ── Phase 1: Exercises ────────────────────────────
          _exercises.isEmpty
              ? _EmptyExercisesView(onComplete: _completeLesson)
              : _ExercisesPhase(
                  exercise: _exercises[_exIndex] as Map<String, dynamic>,
                  index:    _exIndex,
                  total:    _exercises.length,
                  onResult: _onExerciseResult,
                ),

          // ── Phase 2: Complete ─────────────────────────────
          _CompletionPhase(
            correct: _correctCount,
            total:   _exercises.isEmpty ? 1 : _exercises.length,
            onDone:  () => context.pop(),
          ),
        ],
      ),
    );
  }
}

// ── Phase sub-widgets ────────────────────────────────────────

class _ExplanationPhase extends StatelessWidget {
  const _ExplanationPhase({required this.lesson, required this.onStart});
  final Map<String, dynamic> lesson;
  final VoidCallback         onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Explanation text
          Text(
            lesson['explanation'] ?? '',
            style: theme.textTheme.bodyLarge!.copyWith(height: 1.7, fontSize: 17),
          ),
          const SizedBox(height: 32),

          // Examples
          if ((lesson['explanation_examples'] as List?)?.isNotEmpty ?? false) ...[
            Text('Examples',
                style: theme.textTheme.titleMedium!.copyWith(
                    color: theme.colorScheme.primary)),
            const SizedBox(height: 12),
            for (final ex in lesson['explanation_examples'] as List) ...[
              _ExampleCard(example: ex as Map<String, dynamic>),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 24),
          ],

          // Tips
          if ((lesson['tips'] as List?)?.isNotEmpty ?? false) ...[
            Text('Tips',
                style: theme.textTheme.titleMedium!.copyWith(
                    color: theme.colorScheme.primary)),
            const SizedBox(height: 8),
            for (final tip in lesson['tips'] as List)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline,
                        size: 18, color: theme.colorScheme.tertiary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(tip.toString(),
                        style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],

          FilledButton(
            onPressed: onStart,
            child: const Text('Start Exercises'),
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.example});
  final Map<String, dynamic> example;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding:     const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        theme.colorScheme.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: theme.colorScheme.primary.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(example['fr'] ?? '',
              style: theme.textTheme.bodyLarge!.copyWith(fontStyle: FontStyle.italic)),
          const SizedBox(height: 4),
          Text(example['en'] ?? '',
              style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153))),
        ],
      ),
    );
  }
}

class _ExercisesPhase extends StatelessWidget {
  const _ExercisesPhase({
    required this.exercise,
    required this.index,
    required this.total,
    required this.onResult,
  });

  final Map<String, dynamic> exercise;
  final int index;
  final int total;
  final void Function(bool correct) onResult;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (index + 1) / total,
          minHeight: 4,
          backgroundColor: Colors.transparent,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 20),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('${index + 1} / $total',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
        Expanded(
          child: ExerciseWidget(
            exercise: exercise,
            onResult: onResult,
          ).animate().fadeIn(duration: 200.ms),
        ),
      ],
    );
  }
}

class _CompletionPhase extends StatelessWidget {
  const _CompletionPhase({
    required this.correct,
    required this.total,
    required this.onDone,
  });
  final int correct;
  final int total;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final pct   = total > 0 ? (correct / total * 100).round() : 100;
    final theme = Theme.of(context);
    final pass  = pct >= 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(pass ? Icons.emoji_events : Icons.refresh,
                size:  80,
                color: pass ? const Color(0xFFFFC107) : theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(pass ? 'Lesson Complete!' : 'Keep Practising',
                style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Score: $pct%',
                style: theme.textTheme.titleLarge!.copyWith(
                    color: pass ? Colors.green : theme.colorScheme.error)),
            const SizedBox(height: 40),
            FilledButton(onPressed: onDone, child: const Text('Done')),
          ],
        ),
      ),
    );
  }
}

class _EmptyExercisesView extends StatelessWidget {
  const _EmptyExercisesView({required this.onComplete});
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No exercises for this lesson yet.'),
          const SizedBox(height: 24),
          FilledButton(onPressed: onComplete, child: const Text('Mark Complete')),
        ],
      ),
    );
  }
}
