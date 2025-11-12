class Loan {
  final String id;
  final String userId;
  final double amount;
  final double interestRate;
  final double totalAmount;
  final double monthlyPayment;
  final String term; // e.g., "3 months - 5%"
  final String purpose;
  final String status; // "pending", "approved", "rejected", "active", "completed"
  final DateTime createdAt;
  final DateTime? approvedAt;
  final double paidAmount;
  final double remainingAmount;
  final DateTime? nextPaymentDue;

  Loan({
    required this.id,
    required this.userId,
    required this.amount,
    required this.interestRate,
    required this.totalAmount,
    required this.monthlyPayment,
    required this.term,
    required this.purpose,
    this.status = "pending",
    required this.createdAt,
    this.approvedAt,
    this.paidAmount = 0.0,
    this.remainingAmount = 0.0,
    this.nextPaymentDue,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'interestRate': interestRate,
      'totalAmount': totalAmount,
      'monthlyPayment': monthlyPayment,
      'term': term,
      'purpose': purpose,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'nextPaymentDue': nextPaymentDue?.toIso8601String(),
    };
  }

  factory Loan.fromMap(Map<String, dynamic> map, String documentId) {
    return Loan(
      id: documentId,
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      interestRate: (map['interestRate'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      monthlyPayment: (map['monthlyPayment'] ?? 0).toDouble(),
      term: map['term'] ?? '',
      purpose: map['purpose'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      approvedAt: map['approvedAt'] != null ? DateTime.parse(map['approvedAt']) : null,
      paidAmount: (map['paidAmount'] ?? 0).toDouble(),
      remainingAmount: (map['remainingAmount'] ?? 0).toDouble(),
      nextPaymentDue: map['nextPaymentDue'] != null ? DateTime.parse(map['nextPaymentDue']) : null,
    );
  }

  double get progress => totalAmount > 0 ? paidAmount / totalAmount : 0.0;
}

