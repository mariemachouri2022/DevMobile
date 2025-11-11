class ClassSession {
  final int? id;
  final int? coachId;
  final String title;
  final String? intensity; // low/medium/high
  final String? objective; // Cardio/Muscle/Fitness
  final DateTime startTime;
  final DateTime endTime;
  final int? capacity;

  ClassSession({
    this.id,
    this.coachId,
    required this.title,
    this.intensity,
    this.objective,
    required this.startTime,
    required this.endTime,
    this.capacity,
  });

  factory ClassSession.fromMap(Map<String, Object?> m) => ClassSession(
        id: m['id'] as int?,
        coachId: m['coach_id'] as int?,
        title: m['title'] as String,
        intensity: m['intensity'] as String?,
        objective: m['objective'] as String?,
        startTime: DateTime.parse(m['start_time'] as String),
        endTime: DateTime.parse(m['end_time'] as String),
        capacity: m['capacity'] as int?,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'coach_id': coachId,
        'title': title,
        'intensity': intensity,
        'objective': objective,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'capacity': capacity,
      };
}
