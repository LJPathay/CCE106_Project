import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Models/Account.dart';

class Authenticator {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Account?> registerUser({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      Account account = Account(
        id: userCredential.user!.uid,
        username: username,
        email: email,
      );

      await _firestore
          .collection("Account")
          .doc(account.id)
          .set(account.toMap());

      return account;
    } on FirebaseAuthException {
      rethrow; // pass error back
    }
  }

  Future<Account?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userDoc = await _firestore
          .collection("Account")
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        return Account.fromMap(
          userDoc.data() as Map<String, dynamic>,
          userDoc.id,
        );
      }
      return null;
    } on FirebaseAuthException {
      rethrow;
    }
  }
}
