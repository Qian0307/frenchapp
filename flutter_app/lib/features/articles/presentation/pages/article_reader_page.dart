import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../widgets/annotated_article_body.dart';
import '../widgets/vocabulary_popup.dart';

/// Full-screen article reader with tappable vocabulary, audio, progress tracking.
class ArticleReaderPage extends ConsumerStatefulWidget {
  const ArticleReaderPage({super.key, required this.articleId});
  final String articleId;

  @override
  ConsumerState<ArticleReaderPage> createState() => _ArticleReaderPageState();
}

class _ArticleReaderPageState extends ConsumerState<ArticleReaderPage> {
  final _scrollController = ScrollController();
  final _audioPlayer      = AudioPlayer();

  Map<String, dynamic>? _article;
  List<dynamic>         _linkedVocab  = [];
  bool                  _isLoading    = true;
  bool                  _audioPlaying = false;
  int                   _wordsLooked  = 0;
  double                _scrollProgress = 0;

  @override
  void initState() {
    super.initState();
    _loadArticle();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadArticle() async {
    // TODO: call ArticleRepository.getArticle(widget.articleId)
    setState(() => _isLoading = false);
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    if (max == 0) return;
    final pct = (_scrollController.offset / max * 100).clamp(0, 100).toInt();
    if (pct != (_scrollProgress * 100).toInt()) {
      setState(() => _scrollProgress = pct / 100);
      // TODO: debounce and call updateProgress(pct)
    }
  }

  Future<void> _toggleAudio() async {
    final url = _article?['audio_url'] as String?;
    if (url == null) return;
    if (_audioPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    }
    setState(() => _audioPlaying = !_audioPlaying);
  }

  void _onVocabTap(String vocabId) {
    _wordsLooked++;
    // Show bottom sheet with word detail
    showModalBottomSheet(
      context:     context,
      isScrollControlled: true,
      builder: (_) => VocabularyPopup(vocabId: vocabId),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Collapsing header with cover image ─────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _article?['title'] ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: _article?['cover_image_url'] != null
                  ? Image.network(_article!['cover_image_url'], fit: BoxFit.cover)
                  : Container(color: theme.colorScheme.primary.withAlpha(30)),
            ),
            actions: [
              if (_article?['audio_url'] != null)
                IconButton(
                  icon: Icon(_audioPlaying ? Icons.pause : Icons.play_circle_outline),
                  onPressed: _toggleAudio,
                ),
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () {},
              ),
            ],
          ),

          // ── Reading progress indicator ──────────────────────
          SliverToBoxAdapter(
            child: LinearProgressIndicator(
              value:           _scrollProgress,
              minHeight:       3,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),

          // ── Article meta ────────────────────────────────────
          if (_article != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_article!['subtitle'] != null)
                      Text(
                        _article!['subtitle'],
                        style: theme.textTheme.titleLarge,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(_article!['cefr_level'] ?? ''),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_article!['reading_time_mins'] ?? '?'} min read',
                          style: theme.textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Text(
                          _article!['author'] ?? '',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // ── Annotated body ──────────────────────────────────
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
                    heightFactor: 5,
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                    child: AnnotatedArticleBody(
                      annotatedBody: (_article?['body_annotated'] as List?) ?? [],
                      onVocabTap:   _onVocabTap,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
