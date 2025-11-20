import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/LoanApplication.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get stream of all loan applications
  Stream<List<LoanApplication>> getLoanApplications() {
    return _firestore
        .collection('loan_applications')
        .withConverter<LoanApplication>(
          fromFirestore: (snapshot, _) => 
              LoanApplication.fromFirestore(snapshot, null),
          toFirestore: (loan, _) => loan.toFirestore(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Get counts for dashboard
  Future<Map<String, int>> getDashboardCounts() async {
    try {
      final pendingCount = await _firestore
          .collection('loan_applications')
          .where('status', isEqualTo: 'pending')
          .get()
          .then((value) => value.size);

      final totalLoans = await _firestore
          .collection('loan_applications')
          .get()
          .then((value) => value.size);

      final usersCount = await _firestore
          .collection('Account')
          .where('isAdmin', isNotEqualTo: true)
          .get()
          .then((value) => value.size);

      return {
        'pendingLoans': pendingCount,
        'totalLoans': totalLoans,
        'totalUsers': usersCount,
      };
    } catch (e) {
      print('Error getting dashboard counts: $e');
      return {
        'pendingLoans': 0,
        'totalLoans': 0,
        'totalUsers': 0,
      };
    }
  }

  // Update loan status
  Future<void> updateLoanStatus({
    required String loanId,
    required String status,
    String? notes,
  }) async {
    try {
      await _firestore.collection('loan_applications').doc(loanId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        if (notes != null) 'notes': notes,
      });
    } catch (e) {
      print('Error updating loan status: $e');
      rethrow;
    }
  }
}
