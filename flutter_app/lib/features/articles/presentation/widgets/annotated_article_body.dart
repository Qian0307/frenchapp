import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Renders the annotated article body (body_annotated JSON) as rich text.
/// Vocabulary tokens are tappable; non-vocab tokens are plain text.
class AnnotatedArticleBody extends StatelessWidget {
  const AnnotatedArticleBody({
    super.key,
    required this.annotatedBody,
    required this.onVocabTap,
  });

  final List<dynamic> annotatedBody; // parsed body_annotated JSON
  final void Function(String vocabId) onVocabTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in annotatedBody)
          _buildBlock(context, block as Map<String, dynamic>, theme),
      ],
    );
  }

  Widget _buildBlock(
      BuildContext context, Map<String, dynamic> block, ThemeData theme) {
    final type   = block['type'] as String? ?? 'paragraph';
    final tokens = (block['tokens'] as List?) ?? [];

    final spans = <InlineSpan>[];

    for (final t in tokens) {
      final token    = t as Map<String, dynamic>;
      final text     = token['text'] as String? ?? '';
      final vocabId  = token['vocab_id'] as String?;
      final clickable = token['is_clickable'] as bool? ?? false;

      if (clickable && vocabId != null) {
        spans.add(TextSpan(
          text:      text,
          style:     _vocabStyle(theme),
          recognizer: TapGestureRecognizer()..onTap = () => onVocabTap(vocabId),
        ));
      } else {
        spans.add(TextSpan(text: text));
      }
    }

    final baseStyle = type == 'heading'
        ? GoogleFonts.spectral(
            fontSize:   22,
            fontWeight: FontWeight.w700,
            height:     1.35,
            color:      theme.colorScheme.onSurface,
          )
        : GoogleFonts.spectral(
            fontSize: 18,
            height:   1.75,
            color:    theme.colorScheme.onSurface,
          );

    return Padding(
      padding: EdgeInsets.only(bottom: type == 'heading' ? 12 : 16),
      child: RichText(
        text: TextSpan(style: baseStyle, children: spans),
      ),
    );
  }

  TextStyle _vocabStyle(ThemeData theme) {
    return TextStyle(
      color:           theme.colorScheme.primary,
      decoration:      TextDecoration.underline,
      decorationStyle: TextDecorationStyle.dotted,
      decorationColor: theme.colorScheme.primary.withAlpha(153),
      fontWeight:      FontWeight.w500,
    );
  }
}
