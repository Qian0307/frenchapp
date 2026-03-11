class GrammarLesson {
  final String id;
  final String title;
  final String? description;
  final String cefrLevel;
  final String? topicCategory;
  final bool isCompleted;
  final bool isStarted;
  final int? bestScorePct;

  GrammarLesson.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        title = json['title'] as String,
        description = json['description'] as String?,
        cefrLevel = json['cefr_level'] as String,
        topicCategory = json['topic_category'] as String?,
        isCompleted = json['progress']?['is_completed'] as bool? ?? false,
        isStarted = json['progress']?['is_started'] as bool? ?? false,
        bestScorePct =
            (json['progress']?['best_score_pct'] as num?)?.toInt();
}
