class Rating {
  final int? id;
  final int userId;
  final int? coachId;
  final int? classId;
  final int stars; // 1-5
  final String? comment;
  final DateTime date;

  Rating({this.id, required this.userId, this.coachId, this.classId, required this.stars, this.comment, required this.date});

  factory Rating.fromMap(Map<String, Object?> m) => Rating(
        id: m['id'] as int?,
        userId: m['user_id'] as int,
        coachId: m['coach_id'] as int?,
        classId: m['class_id'] as int?,
        stars: m['stars'] as int,
        comment: m['comment'] as String?,
        date: DateTime.parse(m['date'] as String),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'user_id': userId,
        'coach_id': coachId,
        'class_id': classId,
        'stars': stars,
        'comment': comment,
        'date': date.toIso8601String(),
      };
}
