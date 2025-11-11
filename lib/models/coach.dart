class Coach {
  final int? id;
  final String name;
  final String? bio;
  final double ratingAvg;

  Coach({this.id, required this.name, this.bio, this.ratingAvg = 0});

  factory Coach.fromMap(Map<String, Object?> m) => Coach(
        id: m['id'] as int?,
        name: m['name'] as String,
        bio: m['bio'] as String?,
        ratingAvg: (m['rating_avg'] as num?)?.toDouble() ?? 0,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'bio': bio,
        'rating_avg': ratingAvg,
      };
}
