import 'package:flutter/material.dart';
import '../UI/theme.dart';

class MakePaymentPage extends StatelessWidget {
  const MakePaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: Text('Make Payment', style: AppTheme.heading),
        backgroundColor: AppTheme.primary,
      ),
      body: Center(
        child: Text('Make Payment - Placeholder', style: AppTheme.body),
      ),
    );
  }
}
