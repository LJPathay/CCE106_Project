import 'package:cce106_finance_project/auth/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bloc/bloc_provider.dart';
import 'layout/theme.dart';
import 'auth/login.dart';
import 'UI/User/dashboard.dart';
import 'UI/User/apply_loan.dart';
import 'UI/User/make_payment.dart';
import 'UI/User/view_history.dart';
import 'UI/User/my_loans.dart';
import 'UI/User/verification_page.dart';
import 'Services/firebase_options.dart';

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
    return AppBlocProvider(
      child: MaterialApp(
        title: 'Loan App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppTheme.primary,
          primaryColor: AppTheme.primary,
          textTheme: TextTheme(bodyMedium: AppTheme.body),
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (snapshot.hasData) {
              return const DashboardPage();
            }
            return const LoginPage();
          },
        ),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/dashboard': (context) => const DashboardPage(),
          '/apply-loan': (context) => const ApplyLoanPage(),
          '/make-payment': (context) => const MakePaymentPage(),
          '/view-history': (context) => const ViewHistoryPage(),
          '/my-loans': (context) => const MyLoansPage(),
          '/verification': (context) => const VerificationPage(),
        },
      ),
    );
  }
}
