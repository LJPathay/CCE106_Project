import 'package:flutter/material.dart';
import 'theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: Text('Dashboard', style: AppTheme.heading),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.softShadow,
          ),
          child: Text(
            "You have successfully logged in!",
            style: AppTheme.heading.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
