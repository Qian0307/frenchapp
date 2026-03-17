import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/repositories/article_repository.dart';
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
  bool                  _isLoading    = true;
  String?               _errorMessage;
  bool                  _audioPlaying = false;
  double                _scrollProgress = 0;
  Timer?                _progressTimer;

  @override
  void initState() {
    super.initState();
    _loadArticle();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadArticle() async {
    try {
      final repo    = ref.read(articleRepositoryProvider);
      final article = await repo.getArticle(widget.articleId);
      if (mounted) {
        setState(() {
          _article   = article;
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

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    if (max == 0) return;
    final pct = (_scrollController.offset / max * 100).clamp(0, 100).toInt();
    if (pct != (_scrollProgress * 100).toInt()) {
      setState(() => _scrollProgress = pct / 100);
      _progressTimer?.cancel();
      _progressTimer = Timer(const Duration(seconds: 2), () {
        ref.read(articleRepositoryProvider)
            .updateProgress(widget.articleId, pct)
            .ignore();
      });
    }
  }

  Future<void> _toggleAudio() async {
    final url = _article?['audio_url'] as String?;
    if (url == null) return;
    try {
      if (_audioPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
      }
      setState(() => _audioPlaying = !_audioPlaying);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('無法播放音頻')),
        );
      }
    }
  }

  void _onVocabTap(String vocabId) {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      builder: (_) => VocabularyPopup(vocabId: vocabId),
    );
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text('無法載入文章', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isLoading    = true;
                  });
                  _loadArticle();
                },
                child: const Text('重試'),
              ),
            ],
          ),
        ),
      );
    }

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
