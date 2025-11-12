import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../Models/Loan.dart';
import '../Models/Payment.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // ========== VERIFICATION OPERATIONS ==========

  /// Check if current user is verified
  Future<bool> isUserVerified() async {
    if (currentUserId == null) return false;

    try {
      final doc = await _firestore
          .collection('Account')
          .doc(currentUserId)
          .get();

      if (doc.exists) {
        return doc.data()?['isVerified'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Upload ID image to Firebase Storage
  Future<String> uploadIdImage(File imageFile) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'verification_${currentUserId}_$timestamp.jpg';
      final ref = _storage.ref().child('verification_ids/$fileName');

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Submit verification request with ID image
  Future<void> submitVerificationRequest({
    required File idImage,
    required String idType,
    String? additionalInfo,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    // Upload the image first
    final imageUrl = await uploadIdImage(idImage);

    // Then save the verification request with image URL
    await _firestore.collection('verificationRequests').add({
      'userId': currentUserId!,
      'idImageUrl': imageUrl,
      'idType': idType,
      'additionalInfo': additionalInfo,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ========== LOAN OPERATIONS ==========

  /// Submit a new loan application
  Future<String> submitLoanApplication({
    required double amount,
    required double interestRate,
    required double totalAmount,
    required double monthlyPayment,
    required String term,
    required String purpose,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    // Check if user is verified
    final verified = await isUserVerified();
    if (!verified) {
      throw Exception(
        'You must be verified to apply for a loan. Please complete verification first.',
      );
    }

    // Calculate next payment due date (30 days from now for monthly loans, adjust based on term)
    DateTime? nextPaymentDue;
    final termLower = term.toLowerCase();
    if (termLower.contains('month')) {
      final months = int.tryParse(term.split(' ')[0]) ?? 1;
      nextPaymentDue = DateTime.now().add(Duration(days: 30 * months));
    } else if (termLower.contains('day')) {
      final days = int.tryParse(term.split(' ')[0]) ?? 7;
      nextPaymentDue = DateTime.now().add(Duration(days: days));
    }

    final loan = Loan(
      id: '', // Will be set by Firestore
      userId: currentUserId!,
      amount: amount,
      interestRate: interestRate,
      totalAmount: totalAmount,
      monthlyPayment: monthlyPayment,
      term: term,
      purpose: purpose,
      status: 'approved', // Auto-approve for demo purposes
      createdAt: DateTime.now(),
      approvedAt: DateTime.now(),
      remainingAmount: totalAmount,
      nextPaymentDue: nextPaymentDue,
    );

    final docRef = await _firestore.collection('loans').add(loan.toMap());
    return docRef.id;
  }

  /// Get all loans for the current user
  Stream<List<Loan>> getUserLoans() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    // Query without orderBy to avoid composite index requirement
    // We'll sort in memory instead
    return _firestore
        .collection('loans')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          final loans = snapshot.docs
              .map((doc) => Loan.fromMap(doc.data(), doc.id))
              .toList();
          // Sort by createdAt descending
          loans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return loans;
        });
  }

  /// Get active loans (approved and not completed)
  Stream<List<Loan>> getActiveLoans() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    // Query without orderBy to avoid composite index requirement
    // We'll sort in memory instead
    return _firestore
        .collection('loans')
        .where('userId', isEqualTo: currentUserId)
        .where('status', whereIn: ['approved', 'active'])
        .snapshots()
        .map((snapshot) {
          final loans = snapshot.docs
              .map((doc) => Loan.fromMap(doc.data(), doc.id))
              .toList();
          // Sort by createdAt descending
          loans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return loans;
        });
  }

  /// Get a specific loan by ID
  Future<Loan?> getLoan(String loanId) async {
    final doc = await _firestore.collection('loans').doc(loanId).get();
    if (doc.exists) {
      return Loan.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // ========== PAYMENT OPERATIONS ==========

  /// Submit a payment
  Future<String> submitPayment({
    String? loanId,
    required String paymentMethod,
    required String accountHolderName,
    required String accountNumber,
    required double amount,
    String? details,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final payment = Payment(
      id: '', // Will be set by Firestore
      userId: currentUserId!,
      loanId: loanId,
      paymentMethod: paymentMethod,
      accountHolderName: accountHolderName,
      accountNumber: accountNumber,
      amount: amount,
      details: details,
      status: 'completed', // Set to completed immediately for demo
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
    );

    final docRef = await _firestore.collection('payments').add(payment.toMap());

    // If payment is for a loan, update the loan's paid amount
    if (loanId != null) {
      await _updateLoanPayment(loanId, amount);
    }

    return docRef.id;
  }

  /// Update loan payment amount
  Future<void> _updateLoanPayment(String loanId, double paymentAmount) async {
    final loanDoc = await _firestore.collection('loans').doc(loanId).get();
    if (loanDoc.exists) {
      final loan = Loan.fromMap(loanDoc.data()!, loanDoc.id);
      final newPaidAmount = loan.paidAmount + paymentAmount;
      final newRemainingAmount = loan.totalAmount - newPaidAmount;

      await _firestore.collection('loans').doc(loanId).update({
        'paidAmount': newPaidAmount,
        'remainingAmount': newRemainingAmount,
        'status': newRemainingAmount <= 0 ? 'completed' : 'active',
      });
    }
  }

  /// Get all payments for the current user
  Stream<List<Payment>> getUserPayments() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    // Query without orderBy to avoid composite index requirement
    // We'll sort in memory instead
    return _firestore
        .collection('payments')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          final payments = snapshot.docs
              .map((doc) => Payment.fromMap(doc.data(), doc.id))
              .toList();
          // Sort by createdAt descending
          payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return payments;
        });
  }

  // ========== DASHBOARD DATA ==========

  /// Get user's current balance (sum of approved loans - sum of payments)
  Future<double> getCurrentBalance() async {
    if (currentUserId == null) return 0.0;

    try {
      // Get all approved/active loans
      final loansSnapshot = await _firestore
          .collection('loans')
          .where('userId', isEqualTo: currentUserId)
          .where('status', whereIn: ['approved', 'active'])
          .get();

      double totalBorrowed = 0.0;
      double totalPaid = 0.0;

      for (var doc in loansSnapshot.docs) {
        final loan = Loan.fromMap(doc.data(), doc.id);
        totalBorrowed += loan.amount;
        totalPaid += loan.paidAmount;
      }

      // For demo purposes, we'll use a base balance
      // In a real app, this would come from account balance
      return 10000.0 - totalPaid + totalBorrowed;
    } catch (e) {
      return 0.0;
    }
  }

  /// Get next payment due date
  Future<DateTime?> getNextPaymentDue() async {
    if (currentUserId == null) return null;

    try {
      final loansSnapshot = await _firestore
          .collection('loans')
          .where('userId', isEqualTo: currentUserId)
          .where('status', whereIn: ['approved', 'active'])
          .get();

      DateTime? earliestDue;
      for (var doc in loansSnapshot.docs) {
        final loan = Loan.fromMap(doc.data(), doc.id);
        if (loan.nextPaymentDue != null) {
          if (earliestDue == null ||
              loan.nextPaymentDue!.isBefore(earliestDue)) {
            earliestDue = loan.nextPaymentDue;
          }
        }
      }

      return earliestDue;
    } catch (e) {
      return null;
    }
  }

  /// Get loan summary statistics as a stream for real-time updates
  Stream<Map<String, dynamic>> getLoanSummaryStream() {
    if (currentUserId == null) {
      return Stream.value({
        'activeLoans': 0,
        'totalBorrowed': 0.0,
        'totalPaid': 0.0,
      });
    }

    return _firestore
        .collection('loans')
        .where('userId', isEqualTo: currentUserId)
        .where('status', whereIn: ['approved', 'active'])
        .snapshots()
        .map((snapshot) {
          int activeLoans = 0;
          double totalBorrowed = 0.0;
          double totalPaid = 0.0;

          for (var doc in snapshot.docs) {
            final loan = Loan.fromMap(doc.data(), doc.id);
            activeLoans++;
            totalBorrowed += loan.amount;
            totalPaid += loan.paidAmount;
          }

          return {
            'activeLoans': activeLoans,
            'totalBorrowed': totalBorrowed,
            'totalPaid': totalPaid,
          };
        });
  }

  /// Get loan summary statistics (one-time fetch)
  Future<Map<String, dynamic>> getLoanSummary() async {
    if (currentUserId == null) {
      return {'activeLoans': 0, 'totalBorrowed': 0.0, 'totalPaid': 0.0};
    }

    try {
      final loansSnapshot = await _firestore
          .collection('loans')
          .where('userId', isEqualTo: currentUserId)
          .where('status', whereIn: ['approved', 'active'])
          .get();

      int activeLoans = 0;
      double totalBorrowed = 0.0;
      double totalPaid = 0.0;

      for (var doc in loansSnapshot.docs) {
        final loan = Loan.fromMap(doc.data(), doc.id);
        activeLoans++;
        totalBorrowed += loan.amount;
        totalPaid += loan.paidAmount;
      }

      return {
        'activeLoans': activeLoans,
        'totalBorrowed': totalBorrowed,
        'totalPaid': totalPaid,
      };
    } catch (e) {
      return {'activeLoans': 0, 'totalBorrowed': 0.0, 'totalPaid': 0.0};
    }
  }
}
