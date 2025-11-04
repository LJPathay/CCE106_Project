import 'package:flutter/material.dart';
import '../UI/theme.dart';

class ViewHistoryPage extends StatelessWidget {
  const ViewHistoryPage({super.key});

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
            'History',
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
            '🧾 Recent Activity',
            style: AppTheme.subheading.copyWith(
              color: const Color(0xFF727272),
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _HistoryTile(
            color: Colors.green,
            icon: Icons.check_circle_outline,
            title: 'Loan Approved',
            subtitle: 'Personal Loan • Oct 22, 2025',
            amountText: '+ ₱5,000',
          ),
          _HistoryTile(
            color: Colors.blue,
            icon: Icons.payment_outlined,
            title: 'Payment Sent',
            subtitle: 'Education Loan • Nov 01, 2025',
            amountText: '− ₱800',
          ),
          _HistoryTile(
            color: Colors.orange,
            icon: Icons.edit_calendar_outlined,
            title: 'Due Date Updated',
            subtitle: 'Personal Loan • Oct 28, 2025',
            amountText: '',
          ),
          _HistoryTile(
            color: Colors.red,
            icon: Icons.warning_amber_outlined,
            title: 'Overdue Warning',
            subtitle: 'Education Loan • Oct 15, 2025',
            amountText: '',
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, height: 22, thickness: 1),
          const SizedBox(height: 4),
          Text(
            'Filters',
            style: AppTheme.subheading.copyWith(
              color: const Color(0xFF727272),
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: const [
              _FilterChip(label: 'All'),
              _FilterChip(label: 'Payments'),
              _FilterChip(label: 'Approvals'),
              _FilterChip(label: 'Overdue'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _accentPink,
                side: const BorderSide(color: _accentPink, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {},
              child: const Text(
                'Export History',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});
  final String label;

  static const Color _accentPink = Color(0xFFD81B60);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _accentPink.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _accentPink.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _accentPink,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
