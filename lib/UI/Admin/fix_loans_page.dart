import 'package:flutter/material.dart';
import '../../Services/fix_approved_loans.dart';

/// Simple page to run the one-time fix for approved loans
class FixLoansPage extends StatefulWidget {
  const FixLoansPage({super.key});

  @override
  State<FixLoansPage> createState() => _FixLoansPageState();
}

class _FixLoansPageState extends State<FixLoansPage> {
  bool _isFixing = false;
  String _statusMessage = '';

  Future<void> _runFix() async {
    setState(() {
      _isFixing = true;
      _statusMessage = 'Fixing approved loans...';
    });

    try {
      final fixer = FixApprovedLoans();
      await fixer.fixAllApprovedLoans();

      setState(() {
        _statusMessage = '✅ Successfully fixed all approved loans!';
        _isFixing = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
        _isFixing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fix Approved Loans')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fix Remaining Amount for Approved Loans',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This will update all approved loans to have the correct remainingAmount value.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Formula: remainingAmount = totalAmount - paidAmount',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isFixing ? null : _runFix,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: _isFixing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Fix All Approved Loans'),
            ),
            const SizedBox(height: 24),
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _statusMessage.startsWith('✅')
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _statusMessage.startsWith('✅')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.startsWith('✅')
                        ? Colors.green.shade900
                        : Colors.red.shade900,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
