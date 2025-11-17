import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/Account.dart';
import '../UI/Admin/Dashboard.dart';

class AdminMiddleware {
  static Future<bool> isAdmin(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection("Account")
          .doc(user.uid)
          .get();
          
      if (doc.exists) {
        final account = Account.fromMap(
          doc.data() as Map<String, dynamic>, 
          doc.id
        );
        return account.isAdmin;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name?.startsWith('/admin') ?? false) {
      return MaterialPageRoute(
        builder: (context) => FutureBuilder<bool>(
          future: isAdmin(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (snapshot.data == true) {
              return DashboardScreen(); 
            }
            
            // Show access denied
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Admin access required'),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go back'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
    return null;
  }
}