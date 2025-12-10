import 'package:cloud_firestore/cloud_firestore.dart';

class LoanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // try to add
  // Get all loan applicants
  Stream<List<Map<String, dynamic>>> getLoanApplicants() {
    print('Fetching loan applicants from Firestore...');
    return _firestore
        .collection('loans')
        .orderBy('dateApplied', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          print('Received ${snapshot.docs.length} loan documents');
          final futures = snapshot.docs.map((doc) async {
            // Get the raw document data
            final docData = doc.data();

            // Create a new map to store processed data
            final loanData = <String, dynamic>{};

            // Process each field in the document
            docData.forEach((key, value) {
              if (value == null) {
                loanData[key] = '';
              } else if (value is Timestamp) {
                // Convert Timestamp to ISO 8601 string
                loanData[key] = value.toDate().toIso8601String();
              } else if (value is num) {
                // Keep numbers as numbers
                loanData[key] = value;
              } else {
                // Convert everything else to string
                loanData[key] = value.toString();
              }
            });

            // Add document ID
            loanData['id'] = doc.id;

            // Set default values for required fields
            loanData['status'] = loanData['status'] ?? 'Pending';
            loanData['amount'] =
                num.tryParse(loanData['amount']?.toString() ?? '0') ?? 0;
            loanData['term'] = loanData['term'] ?? 'N/A';
            loanData['purpose'] = loanData['purpose'] ?? 'Not specified';
            loanData['email'] = loanData['email'] ?? 'No email';
            loanData['userId'] = loanData['userId'] ?? 'No user ID';

            // Fetch user name if userId is present
            String name = 'Unknown User';
            if (loanData['userId'] != 'No user ID') {
              try {
                final userDoc = await _firestore
                    .collection('Account')
                    .doc(loanData['userId'])
                    .get();
                if (userDoc.exists) {
                  final userData = userDoc.data();
                  name =
                      userData?['fullName'] ??
                      userData?['name'] ??
                      'Unknown User';
                }
              } catch (e) {
                print('Error fetching user data for loan ${doc.id}: $e');
              }
            }
            loanData['name'] = name;

            // Ensure date fields exist and are properly formatted
            final dateFields = ['dateApplied', 'dateApproved', 'dateRejected'];
            for (final field in dateFields) {
              if (docData[field] is Timestamp) {
                loanData[field] = (docData[field] as Timestamp)
                    .toDate()
                    .toIso8601String();
              } else if (docData[field] != null && loanData[field] == null) {
                loanData[field] = docData[field].toString();
              }
            }

            print('Processed loan data: $loanData');
            return loanData;
          });

          return Future.wait(futures);
        });
  }

  // Update loan application status
  Future<void> updateLoanStatus(String loanId, String status) async {
    final normalizedStatus = status.toLowerCase();

    // Get the loan document to access totalAmount
    final loanDoc = await _firestore.collection('loans').doc(loanId).get();
    final loanData = loanDoc.data();

    Map<String, dynamic> updateData = {
      'status': normalizedStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // When approving, initialize payment tracking fields
    if (normalizedStatus == 'approved') {
      final totalAmount = (loanData?['totalAmount'] ?? 0).toDouble();
      final paidAmount = (loanData?['paidAmount'] ?? 0).toDouble();
      final remainingAmount = totalAmount - paidAmount;

      updateData['dateApproved'] = FieldValue.serverTimestamp();
      updateData['paidAmount'] = paidAmount;
      updateData['remainingAmount'] = remainingAmount;
    } else if (normalizedStatus == 'rejected') {
      updateData['dateRejected'] = FieldValue.serverTimestamp();
    }

    await _firestore.collection('loans').doc(loanId).update(updateData);
  }

  // Get loan application by ID
  Future<Map<String, dynamic>?> getLoanById(String loanId) async {
    final doc = await _firestore.collection('loans').doc(loanId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;

      String name = data['name'] ?? 'Unknown User';
      if (data['userId'] != null) {
        try {
          final userDoc = await _firestore
              .collection('Account')
              .doc(data['userId'])
              .get();
          if (userDoc.exists) {
            final userData = userDoc.data();
            name = userData?['fullName'] ?? userData?['name'] ?? 'Unknown User';
          }
        } catch (e) {
          print('Error fetching user data for loan $loanId: $e');
        }
      }

      return {
        'id': doc.id,
        ...data,
        // Ensure all required fields have default values
        'name': name,
        'status': data['status'] ?? 'Pending',
        'amount': data['amount'] ?? 0,
        'term': data['term'] ?? 'N/A',
        'purpose': data['purpose'] ?? 'Not specified',
      };
    }
    return null;
  }

  // Get loan statistics
  Future<Map<String, int>> getLoanStats() async {
    final snapshot = await _firestore.collection('loans').get();
    final allLoans = snapshot.docs.length;

    // Convert status to lowercase for case-insensitive comparison
    final pending = snapshot.docs
        .where(
          (doc) =>
              (doc.data())['status']?.toString().toLowerCase() == 'pending',
        )
        .length;

    final approved = snapshot.docs
        .where(
          (doc) =>
              (doc.data())['status']?.toString().toLowerCase() == 'approved',
        )
        .length;

    final rejected = snapshot.docs
        .where(
          (doc) =>
              (doc.data())['status']?.toString().toLowerCase() == 'rejected',
        )
        .length;

    return {
      'total': allLoans,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
    };
  }
}
