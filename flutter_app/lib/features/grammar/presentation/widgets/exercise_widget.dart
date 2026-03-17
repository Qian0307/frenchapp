import 'package:flutter/material.dart';

/// Renders different exercise types: multiple_choice, fill_blank, reorder, matching.
class ExerciseWidget extends StatefulWidget {
  const ExerciseWidget({
    super.key,
    required this.exercise,
    required this.onResult,
  });

  final Map<String, dynamic>         exercise;
  final void Function(bool correct) onResult;

  @override
  State<ExerciseWidget> createState() => _ExerciseWidgetState();
}

class _ExerciseWidgetState extends State<ExerciseWidget> {
  String?  _selectedOption;
  bool?    _isCorrect;
  bool     _submitted        = false;

  @override
  void didUpdateWidget(ExerciseWidget old) {
    super.didUpdateWidget(old);
    if (old.exercise['id'] != widget.exercise['id']) {
      setState(() {
        _selectedOption = null;
        _isCorrect      = null;
        _submitted      = false;
      });
    }
  }

  void _submit(String answer) {
    if (_submitted) return;
    final correct = widget.exercise['correct_answer'];
    final isCorrect = answer.trim().toLowerCase() ==
        correct.toString().replaceAll('"', '').trim().toLowerCase();

    setState(() {
      _isCorrect  = isCorrect;
      _submitted   = true;
    });

    // Delay to let user read feedback, then advance
    Future.delayed(const Duration(milliseconds: 1400), () {
      widget.onResult(isCorrect);
    });
  }

  @override
  Widget build(BuildContext context) {
    final type    = widget.exercise['exercise_type'] as String? ?? 'multiple_choice';
    final theme   = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prompt
          Text(
            widget.exercise['prompt'] ?? '',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          // Exercise body
          if (type == 'multiple_choice') _MultipleChoice(
            options:  (widget.exercise['options'] as List?) ?? [],
            selected: _selectedOption,
            correct:  _submitted
                ? widget.exercise['correct_answer']?.toString().replaceAll('"', '')
                : null,
            onSelect: _submitted ? null : (id) {
              setState(() => _selectedOption = id);
              _submit(id);
            },
          ),

          if (type == 'fill_blank') _FillBlank(
            submitted: _submitted,
            isCorrect: _isCorrect,
            onSubmit:  _submit,
          ),

          // Feedback
          if (_submitted && _isCorrect != null) ...[
            const SizedBox(height: 20),
            _FeedbackBanner(
              isCorrect: _isCorrect!,
              explanation: widget.exercise['explanation'] as String?,
            ),
          ],

          // Hint (before submission)
          if (!_submitted && widget.exercise['hint'] != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16,
                    color: theme.colorScheme.onSurface.withAlpha(100)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('Hint: ${widget.exercise["hint"]}',
                      style: theme.textTheme.bodySmall!.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(130))),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Multiple choice ──────────────────────────────────────────

class _MultipleChoice extends StatelessWidget {
  const _MultipleChoice({
    required this.options,
    required this.selected,
    required this.correct,
    required this.onSelect,
  });

  final List<dynamic>                options;
  final String?                      selected;
  final String?                      correct;
  final void Function(String)? onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final opt in options)
          _OptionTile(
            id:       (opt as Map)['id'] as String,
            text:      opt['text'] as String,
            selected:  selected == opt['id'],
            isCorrect: correct != null && opt['id'] == correct,
            isWrong:   correct != null && opt['id'] == selected && opt['id'] != correct,
            onTap:     onSelect != null ? () => onSelect!(opt['id'] as String) : null,
          ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.id,
    required this.text,
    required this.selected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  final String    id;
  final String    text;
  final bool      selected;
  final bool      isCorrect;
  final bool      isWrong;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color? bg;
    Color? border;
    if (isCorrect) {
      bg     = Colors.green.withAlpha(30);
      border = Colors.green;
    } else if (isWrong) {
      bg     = Colors.red.withAlpha(30);
      border = Colors.red;
    } else if (selected) {
      bg     = theme.colorScheme.primary.withAlpha(20);
      border = theme.colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color:        bg ?? theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap:        onTap,
          child: Container(
            padding:    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(
                color: border ?? theme.colorScheme.onSurface.withAlpha(30),
              ),
            ),
            child: Row(
              children: [
                Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
                if (isCorrect) const Icon(Icons.check_circle, color: Colors.green, size: 20),
                if (isWrong)   const Icon(Icons.cancel, color: Colors.red, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Fill blank ───────────────────────────────────────────────

class _FillBlank extends StatefulWidget {
  const _FillBlank({
    required this.submitted,
    required this.isCorrect,
    required this.onSubmit,
  });

  final bool    submitted;
  final bool?   isCorrect;
  final void Function(String) onSubmit;

  @override
  State<_FillBlank> createState() => _FillBlankState();
}

class _FillBlankState extends State<_FillBlank> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller:  _ctrl,
          enabled:     !widget.submitted,
          autofocus:   true,
          decoration:  const InputDecoration(
            hintText: 'Type your answer…',
          ),
          onSubmitted: widget.onSubmit,
        ),
        const SizedBox(height: 16),
        if (!widget.submitted)
          FilledButton(
            onPressed: () => widget.onSubmit(_ctrl.text),
            child: const Text('Check'),
          ),
      ],
    );
  }
}

// ── Feedback banner ──────────────────────────────────────────

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.isCorrect, this.explanation});
  final bool    isCorrect;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCorrect ? Colors.green : Colors.red;

    return Container(
      padding:    const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isCorrect ? 'Correct!' : 'Incorrect',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: color, fontSize: 16)),
                if (explanation != null) ...[
                  const SizedBox(height: 4),
                  Text(explanation!, style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
