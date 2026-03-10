import 'package:flutter/material.dart';
import '../../data/models/vocabulary_model.dart';
import '../../../../core/theme/app_theme.dart';

/// Four grading buttons: Again / Hard / Good / Easy
class ReviewQualityBar extends StatelessWidget {
  const ReviewQualityBar({super.key, required this.onGrade});
  final void Function(ReviewQuality) onGrade;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ReviewQuality.values.map((q) {
        final color = AppTheme.qualityColors[q.name] ?? Colors.grey;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _GradeButton(quality: q, color: color, onTap: () => onGrade(q)),
          ),
        );
      }).toList(),
    );
  }
}

class _GradeButton extends StatelessWidget {
  const _GradeButton({
    required this.quality,
    required this.color,
    required this.onTap,
  });

  final ReviewQuality quality;
  final Color         color;
  final VoidCallback  onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:        color.withAlpha(30),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(quality.emoji,
                  style: TextStyle(fontSize: 18, color: color)),
              const SizedBox(height: 3),
              // 繁體中文 label (primary)
              Text(quality.label,
                  style: TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w700,
                    color:      color,
                  )),
              const SizedBox(height: 2),
              // Next review interval hint
              Text(quality.intervalHint,
                  style: TextStyle(
                    fontSize: 10,
                    color:    color.withAlpha(180),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
