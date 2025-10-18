import 'package:flutter/material.dart';
import '../UI/theme.dart';

class MyLoansPage extends StatelessWidget {
  const MyLoansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: Text('My Loans', style: AppTheme.heading),
        backgroundColor: AppTheme.primary,
      ),
      body: Center(child: Text('My Loans - Placeholder', style: AppTheme.body)),
    );
  }
}
