import 'package:cce106_finance_project/auth/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../UI/theme.dart';
import 'auth/login.dart';
import '../UI/dashboard.dart'; // <- make sure class inside matches
import '../UI/apply_loan.dart';
import '../UI/make_payment.dart';
import '../UI/view_history.dart';
import '../UI/my_loans.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ✅ FIX for Web
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loan App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppTheme.primary,
        primaryColor: AppTheme.primary,
        textTheme: TextTheme(bodyMedium: AppTheme.body),
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null
          ? '/login'
          : '/dashboard',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/apply-loan': (context) => const LoanFormPage(),
        '/make-payment': (context) => const MakePaymentPage(),
        '/view-history': (context) => const ViewHistoryPage(),
        '/my-loans': (context) => const MyLoansPage(),
      },
    );
  }
}
