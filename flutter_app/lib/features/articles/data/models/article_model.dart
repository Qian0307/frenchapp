class ArticleModel {
  final String id;
  final String title;
  final String? subtitle;
  final String cefrLevel;
  final int readingTimeMins;
  final List<String> topicTags;
  final String? coverImageUrl;
  final double progressPct;
  final bool isCompleted;

  ArticleModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        title = json['title'] as String,
        subtitle = json['subtitle'] as String?,
        cefrLevel = json['cefr_level'] as String,
        readingTimeMins = (json['reading_time_mins'] as num?)?.toInt() ?? 5,
        topicTags = List<String>.from(json['topic_tags'] as List? ?? []),
        coverImageUrl = json['cover_image_url'] as String?,
        progressPct =
            (json['read_progress']?['progress_pct'] as num?)?.toDouble() ?? 0.0,
        isCompleted =
            json['read_progress']?['is_completed'] as bool? ?? false;
}
