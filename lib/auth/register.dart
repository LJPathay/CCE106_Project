import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../UI/theme.dart';
import '../UI/input_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      // Create user with Firebase Auth
      final credentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      // Add user info to Firestore "Account" collection
      await FirebaseFirestore.instance
          .collection('Account')
          .doc(credentials.user!.uid)
          .set({
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Please log in.')),
      );
      // Optionally navigate to login/dashboard
    } catch (e) {
      String errorMsg = "Unknown error";
      if (e is FirebaseAuthException) {
        errorMsg = e.message ?? "Auth error";
      } else if (e is FirebaseException) {
        errorMsg = e.message ?? "Firebase error";
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
              Text("Create Account", style: AppTheme.heading),
              const SizedBox(height: 36),
              InputField(
                icon: Icons.person_rounded,
                hint: 'Username',
                isPassword: false,
                controller: _usernameController,
              ),
              const SizedBox(height: 18),
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
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text('REGISTER'),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  "Already have an account?",
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
