import 'package:flutter/material.dart';
import '../UI/theme.dart';

class ApplyLoanPage extends StatelessWidget {
  const ApplyLoanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: Text('Apply for Loan', style: AppTheme.heading),
        backgroundColor: AppTheme.primary,
      ),
      body: Center(
        child: Text('Apply for Loan - Placeholder', style: AppTheme.body),
      ),
    );
  }
}
