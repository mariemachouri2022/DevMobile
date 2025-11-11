class Payment {
  final int? id;
  final int membershipId;
  final double amount;
  final DateTime date;
  final String status; // paid, pending
  final String? method;

  Payment({this.id, required this.membershipId, required this.amount, required this.date, required this.status, this.method});

  factory Payment.fromMap(Map<String, Object?> m) => Payment(
        id: m['id'] as int?,
        membershipId: m['membership_id'] as int,
        amount: (m['amount'] as num).toDouble(),
        date: DateTime.parse(m['date'] as String),
        status: m['status'] as String,
        method: m['method'] as String?,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'membership_id': membershipId,
        'amount': amount,
        'date': date.toIso8601String(),
        'status': status,
        'method': method,
      };
}
