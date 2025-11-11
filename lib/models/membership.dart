class Membership {
  final int? id;
  final int userId;
  final String type; // Standard, Student, Family, Premium
  final DateTime startDate;
  final DateTime endDate;
  final String status; // active, suspended, cancelled, expired
  final String? qrCode;

  Membership({
    this.id,
    required this.userId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.qrCode,
  });

  bool get isActive => status == 'active' && endDate.isAfter(DateTime.now());

  factory Membership.fromMap(Map<String, Object?> map) => Membership(
        id: map['id'] as int?,
        userId: map['user_id'] as int,
        type: map['type'] as String,
        startDate: DateTime.parse(map['start_date'] as String),
        endDate: DateTime.parse(map['end_date'] as String),
        status: map['status'] as String,
        qrCode: map['qr_code'] as String?,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'user_id': userId,
        'type': type,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'status': status,
        'qr_code': qrCode,
      };
}
