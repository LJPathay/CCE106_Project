import 'package:flutter/material.dart';
import '../UI/theme.dart';

class MyLoansPage extends StatelessWidget {
  const MyLoansPage({super.key});

  static const Color _accentPink = Color(0xFFD81B60);

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
            'My Loans',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Text(
            '📄 Active Loans',
            style: AppTheme.subheading.copyWith(
              color: const Color(0xFF727272),
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _LoanCard(
            title: 'Personal Loan',
            subtitle: 'Borrowed: ₱5,000  •  Remaining: ₱3,600',
            progress: 0.28,
            dueLabel: 'Next due: Nov 12, 2025',
          ),
          const SizedBox(height: 10),
          _LoanCard(
            title: 'Education Loan',
            subtitle: 'Borrowed: ₱3,000  •  Remaining: ₱1,950',
            progress: 0.35,
            dueLabel: 'Next due: Nov 20, 2025',
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade200, height: 22, thickness: 1),
          const SizedBox(height: 4),
          Text(
            '📝 Recent Payments',
            style: AppTheme.subheading.copyWith(
              color: const Color(0xFF727272),
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          _PaymentTile(
            icon: Icons.payment_outlined,
            title: '₱800 · Education Loan',
            subtitle: 'Paid on Nov 01, 2025',
          ),
          _PaymentTile(
            icon: Icons.payment_outlined,
            title: '₱600 · Personal Loan',
            subtitle: 'Paid on Oct 28, 2025',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {},
              child: const Text(
                'Make a Payment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  const _LoanCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.dueLabel,
  });

  final String title;
  final String subtitle;
  final double progress;
  final String dueLabel;

  static const Color _accentPink = Color(0xFFD81B60);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300, width: 1.1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: _accentPink,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.heading.copyWith(
                          color: Colors.black,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTheme.body.copyWith(
                          color: Colors.black87,
                          fontSize: 13,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        _accentPink,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "${(progress * 100).round()}%",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dueLabel,
                  style: AppTheme.body.copyWith(
                    color: Colors.black54,
                    fontSize: 12.5,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: _accentPink),
                  child: const Text('Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  static const Color _accentPink = Color(0xFFD81B60);

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
          backgroundColor: _accentPink.withOpacity(0.12),
          child: Icon(icon, color: _accentPink),
        ),
        title: Text(
          title,
          style: AppTheme.heading.copyWith(color: Colors.black, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.body.copyWith(color: Colors.black54, fontSize: 12.5),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black26),
        onTap: () {},
      ),
    );
  }
}
