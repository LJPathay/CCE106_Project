import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../UI/theme.dart';
import '../UI/input_field.dart';
import './register.dart';
import '../UI/dashboard.dart'; // <-- Add this import!

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful!')));
      // *** Navigate to dashboard here ***
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } catch (e) {
      String errorMsg = "Unknown error";
      if (e is FirebaseAuthException) {
        errorMsg = e.message ?? e.code;
      } else {
        errorMsg = e.toString();
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Finance Planner", style: AppTheme.heading),
              const SizedBox(height: 36),
              InputField(
                icon: Icons.email_rounded,
                hint: 'Email',
                isPassword: false,
                controller: _emailController,
              ),
              const SizedBox(height: 18),
              InputField(
                icon: Icons.lock_rounded,
                hint: 'Password',
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppTheme.neonButton,
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text('LOGIN'),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: Text(
                  "Create an Account",
                  style: AppTheme.body.copyWith(
                    color: AppTheme.accent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
