import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../UI/theme.dart';

const Color darkPink = Color(0xFFD81B60);

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // For avatar tap animation
  bool _avatarPressed = false;

  String _getUsername(String? email) {
    if (email == null) return "User";
    final local = email.split('@')[0];
    if (local.isEmpty) return "User";
    return local[0].toUpperCase() + local.substring(1);
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
          value: 'notifications',
          child: Row(
            children: const [
              Icon(Icons.notifications_none),
              SizedBox(width: 6),
              Text("Notifications"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'theme',
          child: Row(
            children: const [
              Icon(Icons.dark_mode_outlined),
              SizedBox(width: 6),
              Text("Dark Mode"),
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.instagramGradient.createShader(bounds),
          child: const Text(
            "LoanApp",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 26,
              letterSpacing: 0.5,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 17.0),
            child: GestureDetector(
              onTapDown: (d) {
                setState(() => _avatarPressed = true);
                _showProfileMenu(d);
              },
              onTapUp: (_) => setState(() => _avatarPressed = false),
              onTapCancel: () => setState(() => _avatarPressed = false),
              child: AnimatedScale(
                scale: _avatarPressed ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: darkPink, size: 23),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Use SingleChildScrollView with Column for controlled, predictable layout.
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 Welcome Card (slim and dense)
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: Colors.grey.shade300, width: 1.2),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: darkPink, size: 26),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back, ${_getUsername(user?.email)} 👋",
                          style: AppTheme.subheading.copyWith(
                            color: Colors.black87,
                            fontSize: 14.5,
                          ),
                        ),
                        Text(
                          user?.email ?? "",
                          style: AppTheme.body.copyWith(
                            color: Colors.black45,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 📘 Section: Account Overview
            Text(
              "📘 Account Overview",
              style: AppTheme.subheading.copyWith(
                color: const Color(0xFF727272), // softer gray per request
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6), // lighter grouping space

            _dashboardCard(
              title: "Current Balance",
              subtitle: "\$10,000",
              icon: Icons.account_balance_wallet_outlined,
              cta: "View Details",
              cardMinHeight: 78, // min height but can grow
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _dashboardCard(
              title: "Next Payment Due",
              subtitle: "Nov 05, 2025",
              icon: Icons.event_outlined,
              cta: "Pay Now",
              cardMinHeight: 78,
              onTap: () {},
            ),
            const SizedBox(height: 8),

            // Light divider between sections for long dashboards
            Divider(color: Colors.grey.shade200, height: 20, thickness: 1),

            // 📊 Section: Loan Details
            const SizedBox(height: 4),
            Text(
              "💰 Loan Details",
              style: AppTheme.subheading.copyWith(
                color: const Color(0xFF727272),
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),

            _dashboardCard(
              title: "Recent Activity",
              subtitle: "Loan approved · Payment sent",
              icon: Icons.history_outlined,
              notifications: [
                _activityBadge(
                  "Approved",
                  Colors.green,
                  Icons.check_circle_outline,
                ),
                _activityBadge("Paid", Colors.blue, Icons.payment_outlined),
                _activityBadge(
                  "Overdue",
                  Colors.red,
                  Icons.warning_amber_rounded,
                ),
              ],
              showArrow: true,
              cardMinHeight: 92,
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _dashboardCard(
              title: "Loan Summary",
              subtitle: "Active Loans: 2   Borrowed: \$8,000   Paid: \$2,200",
              icon: Icons.summarize,
              trailingWidget: _progressIndicator(0.28),
              cardMinHeight: 100,
              onTap: () {},
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          backgroundColor: darkPink,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, "/apply-loan");
          },
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: darkPink,
        unselectedItemColor: Colors.black38,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
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
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page_outlined),
            label: "Apply Loan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            label: "Make Payment",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: "My Loans",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: "History",
          ),
        ],
      ),
    );
  }

  // Reworked card: uses minHeight so cards can grow if subtitle wraps
  Widget _dashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    String? cta,
    List<Widget>? notifications,
    bool showArrow = false,
    Widget? trailingWidget,
    double? cardMinHeight,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300, width: 1.1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: cardMinHeight ?? 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: darkPink, size: 25),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.start, // prevents centering overflow
                    children: [
                      Text(
                        title,
                        style: AppTheme.heading.copyWith(
                          color: Colors.black,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            subtitle,
                            style: AppTheme.body.copyWith(
                              color: Colors.black87,
                              fontSize: 13,
                              height: 1.25,
                            ),
                          ),
                        ),
                      if (notifications != null && notifications.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: notifications,
                          ),
                        ),
                      if (cta != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            cta,
                            style: AppTheme.subheading.copyWith(
                              fontSize: 13,
                              color: darkPink,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (showArrow)
                  const Padding(
                    padding: EdgeInsets.only(top: 2.0),
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.black38,
                      size: 22,
                    ),
                  ),
                if (trailingWidget != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 0),
                    child: trailingWidget,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _progressIndicator(double percent) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 26,
          width: 26,
          child: CircularProgressIndicator(
            value: percent,
            strokeWidth: 3.5,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(darkPink),
          ),
        ),
        Text(
          "${(percent * 100).round()}%",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  static Widget _activityBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ), // increased padding for touch
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
