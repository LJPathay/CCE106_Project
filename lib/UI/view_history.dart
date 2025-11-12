import 'package:flutter/material.dart';
import '../UI/theme.dart';
import '../Services/firebase_service.dart';
import '../Models/Loan.dart';
import '../Models/Payment.dart';
import 'package:intl/intl.dart';

class ViewHistoryPage extends StatefulWidget {
  const ViewHistoryPage({super.key});

  @override
  State<ViewHistoryPage> createState() => _ViewHistoryPageState();
}

class _ViewHistoryPageState extends State<ViewHistoryPage> {
  final FirebaseService _firebaseService = FirebaseService();

  String _formatCurrency(double amount) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.instagramGradient.createShader(bounds),
          child: const Text(
            'History',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Loan>>(
        stream: _firebaseService.getUserLoans(),
        builder: (context, loansSnapshot) {
          return StreamBuilder<List<Payment>>(
            stream: _firebaseService.getUserPayments(),
            builder: (context, paymentsSnapshot) {
              if (!loansSnapshot.hasData && !paymentsSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final loans = loansSnapshot.data ?? [];
              final payments = paymentsSnapshot.data ?? [];

              // Combine loans and payments into history items
              List<_HistoryItem> historyItems = [];

              // Add loan applications (pending, approved, etc.)
              for (var loan in loans) {
                if (loan.status == 'approved' || loan.status == 'active') {
                  historyItems.add(
                    _HistoryItem(type: 'approval', loan: loan, payment: null),
                  );
                } else if (loan.status == 'pending') {
                  // Show pending loans as "Loan Application"
                  historyItems.add(
                    _HistoryItem(
                      type: 'application',
                      loan: loan,
                      payment: null,
                    ),
                  );
                }
                // Add overdue warnings
                if (loan.nextPaymentDue != null &&
                    loan.nextPaymentDue!.isBefore(DateTime.now()) &&
                    loan.status != 'completed') {
                  historyItems.add(
                    _HistoryItem(type: 'overdue', loan: loan, payment: null),
                  );
                }
              }

              // Add payments
              for (var payment in payments) {
                historyItems.add(
                  _HistoryItem(type: 'payment', loan: null, payment: payment),
                );
              }

              // Sort by date (most recent first)
              historyItems.sort((a, b) {
                DateTime aDate =
                    a.payment?.createdAt ?? a.loan?.createdAt ?? DateTime.now();
                DateTime bDate =
                    b.payment?.createdAt ?? b.loan?.createdAt ?? DateTime.now();
                return bDate.compareTo(aDate);
              });

              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  Text(
                    '🧾 Recent Activity',
                    style: AppTheme.subheading.copyWith(
                      color: const Color(0xFF727272),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (historyItems.isEmpty)
                    Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'No history available',
                            style: AppTheme.body.copyWith(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    ...historyItems.map((item) {
                      if (item.type == 'payment') {
                        return _HistoryTile(
                          color: Colors.blue,
                          icon: Icons.payment_outlined,
                          title: 'Payment Sent',
                          subtitle:
                              '${item.payment!.paymentMethod} • ${_formatDate(item.payment!.createdAt)}',
                          amountText:
                              '− ${_formatCurrency(item.payment!.amount)}',
                        );
                      } else if (item.type == 'approval') {
                        return _HistoryTile(
                          color: Colors.green,
                          icon: Icons.check_circle_outline,
                          title: 'Loan Approved',
                          subtitle:
                              '${item.loan!.purpose} • ${_formatDate(item.loan!.createdAt)}',
                          amountText: '+ ${_formatCurrency(item.loan!.amount)}',
                        );
                      } else if (item.type == 'application') {
                        return _HistoryTile(
                          color: Colors.orange,
                          icon: Icons.pending_outlined,
                          title: 'Loan Application',
                          subtitle:
                              '${item.loan!.purpose} • ${_formatDate(item.loan!.createdAt)}',
                          amountText: '+ ${_formatCurrency(item.loan!.amount)}',
                        );
                      } else if (item.type == 'overdue') {
                        return _HistoryTile(
                          color: Colors.red,
                          icon: Icons.warning_amber_outlined,
                          title: 'Overdue Warning',
                          subtitle:
                              '${item.loan!.purpose} • ${_formatDate(item.loan!.nextPaymentDue!)}',
                          amountText: '',
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amountText,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final String amountText;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: AppTheme.heading.copyWith(color: Colors.black, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.body.copyWith(color: Colors.black54, fontSize: 12.5),
        ),
        trailing: amountText.isEmpty
            ? const Icon(Icons.chevron_right, color: Colors.black26)
            : Text(
                amountText,
                style: TextStyle(
                  color: amountText.trim().startsWith('+')
                      ? Colors.green
                      : Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
        onTap: () {},
      ),
    );
  }
}

class _HistoryItem {
  final String type; // 'payment', 'approval', 'application', 'overdue'
  final Loan? loan;
  final Payment? payment;

  _HistoryItem({required this.type, this.loan, this.payment});
}
