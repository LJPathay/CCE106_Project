import 'package:flutter/material.dart';
import '../UI/theme.dart';

class ViewHistoryPage extends StatelessWidget {
  const ViewHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: Text('View History', style: AppTheme.heading),
        backgroundColor: AppTheme.primary,
      ),
      body: Center(
        child: Text('View History - Placeholder', style: AppTheme.body),
      ),
    );
  }
}
