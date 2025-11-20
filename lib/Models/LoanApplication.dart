import 'package:cloud_firestore/cloud_firestore.dart';

// Model for loan applications in the admin dashboard

class LoanApplication {
  final String id;
  final String userId;
  final String name;
  final String reason;
  final double amount;
  final DateTime date;
  final String status; // 'pending', 'approved', 'denied'
  final DateTime? updatedAt;
  final String? notes;

  LoanApplication({
    required this.id,
    required this.userId,
    required this.name,
    required this.reason,
    required this.amount,
    required this.date,
    this.status = 'pending',
    this.updatedAt,
    this.notes,
  });

  factory LoanApplication.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return LoanApplication(
      id: snapshot.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      reason: data['reason'] as String,
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] as String? ?? 'pending',
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'reason': reason,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'status': status,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'notes': notes,
    };
  }
}
