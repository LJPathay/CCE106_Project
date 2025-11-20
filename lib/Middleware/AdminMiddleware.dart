import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/Account.dart';
import '../UI/Admin/Dashboard.dart';
import '../UI/Admin/LoanApplicants.dart';
import '../UI/Admin/Analytics.dart';
import '../UI/Admin/Users.dart';
import '../UI/Admin/Verification.dart';

class AdminMiddleware {
  static bool? _cachedIsAdmin;
  static String? _cachedUserId;

  static Future<bool> isAdmin(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _cachedIsAdmin = null;
      _cachedUserId = null;
      return false;
    }

    // Return cached result if available and user hasn't changed
    if (_cachedUserId == user.uid && _cachedIsAdmin != null) {
      return _cachedIsAdmin!;
    }
    
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
        _cachedUserId = user.uid;
        _cachedIsAdmin = account.isAdmin;
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
        settings: settings,
        builder: (context) => FutureBuilder<bool>(
          future: isAdmin(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (snapshot.data == true) {
              // Route to appropriate admin screen based on path
              switch (settings.name) {
                case '/admin/dashboard':
                  return const DashboardScreen();
                case '/admin/loans':
                  return const LoanApplicantsScreen();
                case '/admin/analytics':
                  return const AnalyticsScreen();
                case '/admin/users':
                  return const UsersScreen();
                case '/admin/verification':
                  return const VerificationScreen();
                default:
                  return const DashboardScreen(); // Default to dashboard
              }
            }
            
            // Show access denied
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Admin access required',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You do not have permission to access this page',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
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
