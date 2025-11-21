import 'package:cloud_firestore/cloud_firestore.dart';

class LoanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all loan applicants
  Stream<List<Map<String, dynamic>>> getLoanApplicants() {
    return _firestore
        .collection('loan_applicants')
        .orderBy('dateApplied', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  // Update loan application status
  Future<void> updateLoanStatus(String loanId, String status) async {
    await _firestore.collection('loan_applicants').doc(loanId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get loan application by ID
  Future<Map<String, dynamic>?> getLoanById(String loanId) async {
    final doc = await _firestore.collection('loan_applicants').doc(loanId).get();
    if (doc.exists) {
      return {
        'id': doc.id,
        ...doc.data()!,
      };
    }
    return null;
  }

  // Get loan statistics
  Future<Map<String, int>> getLoanStats() async {
    final snapshot = await _firestore.collection('loan_applicants').get();
    final allLoans = snapshot.docs.length;
    
    final pending = snapshot.docs.where((doc) => doc['status'] == 'Pending').length;
    final approved = snapshot.docs.where((doc) => doc['status'] == 'Approved').length;
    final rejected = snapshot.docs.where((doc) => doc['status'] == 'Rejected').length;
    
    return {
      'total': allLoans,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
    };
  }
}
