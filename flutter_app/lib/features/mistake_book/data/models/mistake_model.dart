class MistakeEntry {
  final String id;
  final String vocabularyId;
  final Map<String, dynamic>? vocabulary;
  final int mistakeCount;
  final String? note;
  final bool isResolved;
  final String? lastMistakeAt;

  MistakeEntry({
    required this.id,
    required this.vocabularyId,
    this.vocabulary,
    required this.mistakeCount,
    this.note,
    required this.isResolved,
    this.lastMistakeAt,
  });

  factory MistakeEntry.fromJson(Map<String, dynamic> json) {
    return MistakeEntry(
      id:            json['id']             as String,
      vocabularyId:  json['vocabulary_id']  as String,
      vocabulary:    json['vocabulary']     as Map<String, dynamic>?,
      mistakeCount:  (json['mistake_count'] as num?)?.toInt() ?? 1,
      note:          json['note']           as String?,
      isResolved:    json['is_resolved']    as bool? ?? false,
      lastMistakeAt: json['last_mistake_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id':             id,
    'vocabulary_id':  vocabularyId,
    'vocabulary':     vocabulary,
    'mistake_count':  mistakeCount,
    'note':           note,
    'is_resolved':    isResolved,
    'last_mistake_at': lastMistakeAt,
  };
}
