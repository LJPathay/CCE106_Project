import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../UI/theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<String?> _fetchDisplayName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc = await FirebaseFirestore.instance
        .collection('Account')
        .doc(user.uid)
        .get();
    if (!doc.exists) return user.email?.split('@').first ?? 'User';
    final data = doc.data();
    if (data == null) return user.email?.split('@').first ?? 'User';
    // Prefer username, fallback to fullName, fallback to email prefix
    return (data['username'] as String?) ??
        (data['fullName'] as String?) ??
        (user.email?.split('@').first);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: AppTheme.heading.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              // open profile or just a placeholder action
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Profile tapped')));
            },
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(
                (user?.displayName != null && user!.displayName!.isNotEmpty)
                    ? user.displayName![0].toUpperCase()
                    : (user?.email != null
                          ? user!.email![0].toUpperCase()
                          : 'U'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Notifications')));
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted)
                Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome area (fetch username)
                  FutureBuilder<String?>(
                    future: _fetchDisplayName(),
                    builder: (context, snapshot) {
                      final name =
                          snapshot.data ??
                          (user?.email?.split('@').first ?? 'User');
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome,',
                            style: AppTheme.body.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            name,
                            style: AppTheme.heading.copyWith(fontSize: 20),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),

                  // Center Label Quick Actions
                  Center(
                    child: Text(
                      'Quick Actions',
                      style: AppTheme.subheading.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Buttons grid 2x2
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.05,
                    children: [
                      _ActionTile(
                        label: 'Apply for Loan',
                        icon: Icons.note_add_outlined,
                        onTap: () =>
                            Navigator.pushNamed(context, '/apply-loan'),
                      ),
                      _ActionTile(
                        label: 'Make Payment',
                        icon: Icons.payment_outlined,
                        onTap: () =>
                            Navigator.pushNamed(context, '/make-payment'),
                      ),
                      _ActionTile(
                        label: 'View History',
                        icon: Icons.history_outlined,
                        onTap: () =>
                            Navigator.pushNamed(context, '/view-history'),
                      ),
                      _ActionTile(
                        label: 'My Loans',
                        icon: Icons.receipt_long_outlined,
                        onTap: () => Navigator.pushNamed(context, '/my-loans'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primary,
        elevation: 4,
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTheme.subheading.copyWith(
              color: AppTheme.primary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
