import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Services/firebase_service.dart';
import '../../Models/Loan.dart';
import '../../Models/Payment.dart';
import 'package:intl/intl.dart';

import '../../layout/theme.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _avatarPressed = false;
  final FirebaseService _firebaseService = FirebaseService();

  DateTime? _nextPaymentDue;

  @override
  void initState() {
    super.initState();
    _loadNextPaymentDue();
  }

  Future<void> _loadNextPaymentDue() async {
    try {
      final nextDue = await _firebaseService.getNextPaymentDue();

      if (mounted) {
        setState(() {
          _nextPaymentDue = nextDue;
        });
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Error loading payment due date: $e');
      }
    }
  }

  String _getUsername(String? email) {
    if (email == null) return "User";
    final local = email.split('@')[0];
    if (local.isEmpty) return "User";
    return local[0].toUpperCase() + local.substring(1);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "No upcoming payments";
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatCurrency(double amount) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  void _showProfileMenu(TapDownDetails details) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy + 5,
        overlay.size.width - details.globalPosition.dx,
        0,
      ),
      items: [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: const [
              Icon(Icons.person_outline),
              SizedBox(width: 6),
              Text("Profile"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'verification',
          child: Row(
            children: const [
              Icon(Icons.verified_user_outlined),
              SizedBox(width: 6),
              Text("Verification"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: const [
              Icon(Icons.logout),
              SizedBox(width: 6),
              Text("Logout"),
            ],
          ),
        ),
      ],
      elevation: 8,
    ).then((value) async {
      if (value == 'logout') {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, "/login");
      } else if (value == 'verification') {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, "/verification");
      } else if (value == 'profile') {
        // Navigate to profile page (you can create this route)
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, "/profile");
      } else if (value == 'notifications') {
        _showNotifications();
      }
    });
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.notifications, color: AppTheme.primaryPink),
                    SizedBox(width: 8),
                    Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: StreamBuilder<List<Loan>>(
                stream: _firebaseService.getUserLoans(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No notifications at this time",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final loans = snapshot.data!;
                  List<Widget> notifications = [];

                  for (var loan in loans) {
                    if (loan.status == 'approved') {
                      notifications.add(
                        _buildNotificationItem(
                          Icons.check_circle,
                          AppTheme.success,
                          "Loan Approved",
                          "Your loan of ${_formatCurrency(loan.amount)} has been approved",
                        ),
                      );
                    } else if (loan.status == 'pending') {
                      notifications.add(
                        _buildNotificationItem(
                          Icons.access_time,
                          AppTheme.warning,
                          "Loan Pending",
                          "Your loan of ${_formatCurrency(loan.amount)} is under review",
                        ),
                      );
                    } else if (loan.status == 'rejected') {
                      notifications.add(
                        _buildNotificationItem(
                          Icons.error_outline,
                          AppTheme.error,
                          "Loan Rejected",
                          "Your loan application was not approved",
                        ),
                      );
                    }
                  }

                  if (notifications.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          "No new notifications",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    );
                  }

                  return ListView(shrinkWrap: true, children: notifications);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    IconData icon,
    Color color,
    String title,
    String message,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _getUsername(user?.email),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: AppTheme.primaryPink,
              ),
            ),
            onPressed: _showNotifications,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTapDown: (d) {
                setState(() => _avatarPressed = true);
                _showProfileMenu(d);
              },
              onTapUp: (_) => setState(() => _avatarPressed = false),
              onTapCancel: () => setState(() => _avatarPressed = false),
              child: AnimatedScale(
                scale: _avatarPressed ? 0.9 : 1.0,
                duration: const Duration(milliseconds: 120),
                child: CircleAvatar(
                  backgroundColor: AppTheme.primaryPink,
                  child: Text(
                    _getUsername(user?.email)[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNextPaymentDue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              StreamBuilder<Map<String, dynamic>>(
                stream: _firebaseService.getLoanSummaryStream(),
                builder: (context, summarySnapshot) {
                  final summary =
                      summarySnapshot.data ??
                      {
                        'activeLoans': 0,
                        'totalBorrowed': 0.0,
                        'totalPaid': 0.0,
                      };

                  // Calculate outstanding balance (what they owe)
                  double outstandingBalance =
                      summary['totalBorrowed'] - summary['totalPaid'];

                  double progress = 0.0;
                  if (summary['totalBorrowed'] > 0) {
                    progress = summary['totalPaid'] / summary['totalBorrowed'];
                  }

                  return _buildBalanceCard(
                    outstandingBalance,
                    summary['activeLoans'],
                    progress,
                  );
                },
              ),
              const SizedBox(height: 20),

              // Financial Overview
              const Text(
                "Financial Overview",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              StreamBuilder<Map<String, dynamic>>(
                stream: _firebaseService.getLoanSummaryStream(),
                builder: (context, summarySnapshot) {
                  final summary =
                      summarySnapshot.data ??
                      {
                        'activeLoans': 0,
                        'totalBorrowed': 0.0,
                        'totalPaid': 0.0,
                      };

                  return _buildFinancialOverview(summary);
                },
              ),
              const SizedBox(height: 24),

              // Payment Due Card
              _buildPaymentDueCard(),
              const SizedBox(height: 24),

              // Recent Activity
              const Text(
                "Recent Activity",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<Loan>>(
                stream: _firebaseService.getUserLoans(),
                builder: (context, loansSnapshot) {
                  return StreamBuilder<List<Payment>>(
                    stream: _firebaseService.getUserPayments(),
                    builder: (context, paymentsSnapshot) {
                      return _buildRecentActivity(
                        loansSnapshot.data ?? [],
                        paymentsSnapshot.data ?? [],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryPink,
        onPressed: () => Navigator.pushNamed(context, "/apply-loan"),
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text(
          "New Loan Application",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBalanceCard(
    double outstandingBalance,
    int activeLoans,
    double progress,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFD946EF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Outstanding Balance",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatCurrency(outstandingBalance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Repayment Progress",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          "${(progress * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        Icons.description_outlined,
                        "Active Loans",
                        "$activeLoans",
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        Icons.trending_up_rounded,
                        "Status",
                        progress >= 0.8
                            ? "Excellent"
                            : progress >= 0.5
                            ? "Good"
                            : "Fair",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview(Map<String, dynamic> summary) {
    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            "Borrowed",
            _formatCurrency(summary['totalBorrowed']),
            Icons.arrow_upward_rounded,
            const Color(0xFFEF4444),
            const Color(0xFFFEE2E2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            "Paid",
            _formatCurrency(summary['totalPaid']),
            Icons.arrow_downward_rounded,
            const Color(0xFF10B981),
            const Color(0xFFD1FAE5),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    String title,
    String amount,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDueCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPink.withValues(alpha: 0.1),
            AppTheme.primaryPink.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryPink.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryPink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Next Payment Due",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(_nextPaymentDue),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, "/make-payment"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Pay Now",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<Loan> loans, List<Payment> payments) {
    if (loans.isEmpty && payments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No recent activity",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your transactions will appear here",
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    List<Widget> activityItems = [];

    for (var loan in loans.take(3)) {
      activityItems.add(
        _buildActivityItem(
          loan.status == 'approved' ? 'Loan Approved' : 'Loan ${loan.status}',
          _formatCurrency(loan.amount),
          DateFormat('MMM dd, yyyy').format(loan.createdAt),
          loan.status == 'approved'
              ? Icons.check_circle_rounded
              : Icons.pending_rounded,
          loan.status == 'approved'
              ? const Color(0xFF10B981)
              : const Color(0xFFF59E0B),
        ),
      );
    }

    for (var payment in payments.take(2)) {
      activityItems.add(
        _buildActivityItem(
          'Payment Made',
          _formatCurrency(payment.amount),
          DateFormat('MMM dd, yyyy').format(payment.createdAt),
          Icons.payment_rounded,
          const Color(0xFF3B82F6),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: activityItems.take(5).toList()),
    );
  }

  Widget _buildActivityItem(
    String title,
    String amount,
    String date,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, "/view-history"),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryPink,
        unselectedItemColor: Colors.black38,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        onTap: (index) {
          if (index == 0) return;
          const routes = [
            "",
            "/apply-loan",
            "/make-payment",
            "/my-loans",
            "/view-history",
          ];
          Navigator.pushNamed(context, routes[index]);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 26),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 26),
            label: "Apply",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_rounded, size: 26),
            label: "Payment",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded, size: 26),
            label: "Loans",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded, size: 26),
            label: "History",
          ),
        ],
      ),
    );
  }
}
