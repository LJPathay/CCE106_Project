import 'package:cloud_firestore/cloud_firestore.dart';

/// One-time utility to fix existing approved loans with incorrect remainingAmount
/// Run this once to update all approved loans in the database
class FixApprovedLoans {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fix all approved loans that have remainingAmount = 0
  Future<void> fixAllApprovedLoans() async {
    print('Starting to fix approved loans...');

    try {
      // Get all loans
      final loansSnapshot = await _firestore.collection('loans').get();

      int fixedCount = 0;
      int skippedCount = 0;

      for (var doc in loansSnapshot.docs) {
        final data = doc.data();
        final status = (data['status'] ?? '').toString().toLowerCase();

        // Only process approved or active loans
        if (status == 'approved' || status == 'active') {
          final totalAmount = (data['totalAmount'] ?? 0).toDouble();
          final paidAmount = (data['paidAmount'] ?? 0).toDouble();
          final currentRemainingAmount = (data['remainingAmount'] ?? 0)
              .toDouble();
          final correctRemainingAmount = totalAmount - paidAmount;

          // Only update if remainingAmount is incorrect
          if (currentRemainingAmount != correctRemainingAmount) {
            await _firestore.collection('loans').doc(doc.id).update({
              'remainingAmount': correctRemainingAmount,
            });

            print('Fixed loan ${doc.id}: ${data['purpose']}');
            print(
              '  Total: ₱$totalAmount, Paid: ₱$paidAmount, Remaining: ₱$correctRemainingAmount',
            );
            fixedCount++;
          } else {
            skippedCount++;
          }
        }
      }

      print(
        '\n✅ Done! Fixed $fixedCount loans, skipped $skippedCount loans (already correct)',
      );
    } catch (e) {
      print('❌ Error fixing loans: $e');
      rethrow;
    }
  }
}
