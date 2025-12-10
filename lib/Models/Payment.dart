import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String userId;
  final String? loanId; // Optional, if payment is for a specific loan
  final String paymentMethod; // "Bank Transfer", "GCash", "Credit Card"
  final String accountHolderName;
  final String accountNumber;
  final double amount;
  final String? details;
  final String status; // "pending", "completed", "failed"
  final DateTime createdAt;
  final DateTime? completedAt;

  Payment({
    required this.id,
    required this.userId,
    this.loanId,
    required this.paymentMethod,
    required this.accountHolderName,
    required this.accountNumber,
    required this.amount,
    this.details,
    this.status = "pending",
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'loanId': loanId,
      'paymentMethod': paymentMethod,
      'accountHolderName': accountHolderName,
      'accountNumber': accountNumber,
      'amount': amount,
      'details': details,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // Helper method to parse dates from Firestore (handles both Timestamp and String)
  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.parse(date);
    return DateTime.now();
  }

  factory Payment.fromMap(Map<String, dynamic> map, String documentId) {
    return Payment(
      id: documentId,
      userId: map['userId'] ?? '',
      loanId: map['loanId'],
      paymentMethod: map['paymentMethod'] ?? '',
      accountHolderName: map['accountHolderName'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      details: map['details'],
      status: map['status'] ?? 'pending',
      createdAt: _parseDate(map['createdAt']),
      completedAt: map['completedAt'] != null
          ? _parseDate(map['completedAt'])
          : null,
    );
  }
}
