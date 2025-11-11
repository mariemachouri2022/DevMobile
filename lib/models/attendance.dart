class Attendance {
  final int? id;
  final int userId;
  final int? classId;
  final DateTime date;
  final bool viaQr;

  Attendance({this.id, required this.userId, this.classId, required this.date, this.viaQr = true});

  factory Attendance.fromMap(Map<String, Object?> m) => Attendance(
        id: m['id'] as int?,
        userId: m['user_id'] as int,
        classId: m['class_id'] as int?,
        date: DateTime.parse(m['date'] as String),
        viaQr: (m['via_qr'] as int) == 1,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'user_id': userId,
        'class_id': classId,
        'date': date.toIso8601String(),
        'via_qr': viaQr ? 1 : 0,
      };
}
