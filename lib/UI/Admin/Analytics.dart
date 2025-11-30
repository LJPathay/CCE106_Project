import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedIndex = 3; // Reports tab
  String _selectedPeriod = 'This Month';
  bool _isLoading = true;
  String? _error;

  // Real-time analytics data
  Map<String, dynamic> analyticsData = {
    "totalLoans": 0,
    "approvedLoans": 0,
    "pendingLoans": 0,
    "rejectedLoans": 0,
    "totalAmount": 0.0,
    "approvedAmount": 0.0,
    "pendingAmount": 0.0,
    "averageLoanAmount": 0.0,
    "averageProcessingTime": "0 days",
    "approvalRate": 0.0,
  };

  List<Map<String, dynamic>> monthlyTrends = [];
  List<Map<String, dynamic>> loanTypeDistribution = [];
  List<Map<String, dynamic>> topPerformers = [];

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Today':
        return DateTime(now.year, now.month, now.day);
      case 'This Week':
        return now.subtract(Duration(days: now.weekday - 1));
      case 'This Month':
        return DateTime(now.year, now.month, 1);
      case 'This Year':
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(now.year, now.month, 1);
    }
  }

  Future<void> _loadAnalyticsData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final startDate = _getStartDate();
      final startTimestamp = Timestamp.fromDate(startDate);

      // Fetch all loans within the selected period
      final loansQuery = await FirebaseFirestore.instance
          .collection('loans')
          .where('createdAt', isGreaterThanOrEqualTo: startTimestamp)
          .get();

      // Calculate metrics
      int totalLoans = loansQuery.docs.length;
      int approvedLoans = 0;
      int pendingLoans = 0;
      int rejectedLoans = 0;
      double totalAmount = 0.0;
      double approvedAmount = 0.0;
      double pendingAmount = 0.0;
      Map<String, int> loanTypes = {};
      int totalProcessingDays = 0;
      int processedLoans = 0;

      for (var doc in loansQuery.docs) {
        final data = doc.data();
        final status = (data['status'] ?? 'pending').toString().toLowerCase();
        final amount = (data['amount'] ?? 0).toDouble();
        final purpose = data['purpose'] ?? 'Other';

        totalAmount += amount;

        if (status == 'approved' || status == 'active') {
          approvedLoans++;
          approvedAmount += amount;

          // Calculate processing time
          if (data['createdAt'] != null && data['updatedAt'] != null) {
            final created = (data['createdAt'] as Timestamp).toDate();
            final updated = (data['updatedAt'] as Timestamp).toDate();
            totalProcessingDays += updated.difference(created).inDays;
            processedLoans++;
          }
        } else if (status == 'pending') {
          pendingLoans++;
          pendingAmount += amount;
        } else if (status == 'rejected' || status == 'denied') {
          rejectedLoans++;
        }

        // Count loan types
        loanTypes[purpose] = (loanTypes[purpose] ?? 0) + 1;
      }

      // Calculate loan type distribution
      final List<Map<String, dynamic>> distribution = [];
      final colors = [
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.red,
        Colors.teal,
      ];
      int colorIndex = 0;

      loanTypes.forEach((type, count) {
        final percentage = totalLoans > 0 ? (count / totalLoans * 100) : 0.0;
        distribution.add({
          "type": type,
          "count": count,
          "percentage": percentage,
          "color": colors[colorIndex % colors.length],
        });
        colorIndex++;
      });
      distribution.sort(
        (a, b) => (b['count'] as int).compareTo(a['count'] as int),
      );

      // Calculate monthly trends (last 6 months)
      final now = DateTime.now();
      final List<Map<String, dynamic>> trends = [];

      for (var i = 5; i >= 0; i--) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final monthStart = Timestamp.fromDate(monthDate);
        final monthEnd = Timestamp.fromDate(
          DateTime(monthDate.year, monthDate.month + 1, 0, 23, 59, 59),
        );

        final monthLoans = await FirebaseFirestore.instance
            .collection('loans')
            .where('createdAt', isGreaterThanOrEqualTo: monthStart)
            .where('createdAt', isLessThanOrEqualTo: monthEnd)
            .get();

        int applications = monthLoans.docs.length;
        int approvals = monthLoans.docs.where((doc) {
          final status = (doc.data()['status'] ?? '').toString().toLowerCase();
          return status == 'approved' || status == 'active';
        }).length;

        double amount = monthLoans.docs.fold(
          0.0,
          (sum, doc) => sum + ((doc.data()['amount'] ?? 0) as num).toDouble(),
        );

        trends.add({
          "month": DateFormat('MMM').format(monthDate),
          "applications": applications,
          "approvals": approvals,
          "amount": amount,
        });
      }

      // Get top borrowers (users with most loans)
      final usersQuery = await FirebaseFirestore.instance
          .collection('Account')
          .where('isAdmin', isNotEqualTo: true)
          .get();

      final List<Map<String, dynamic>> performers = [];
      for (var userDoc in usersQuery.docs) {
        final userId = userDoc.id;
        final userName =
            userDoc.data()['fullName'] ??
            userDoc.data()['name'] ??
            'Unknown User';

        final userLoans = loansQuery.docs
            .where((doc) => doc.data()['userId'] == userId)
            .toList();
        if (userLoans.isNotEmpty) {
          final loansProcessed = userLoans.length;
          final approvedCount = userLoans.where((doc) {
            final status = (doc.data()['status'] ?? '')
                .toString()
                .toLowerCase();
            return status == 'approved' || status == 'active';
          }).length;

          final approvalRate = (approvedCount / loansProcessed * 100);

          performers.add({
            "name": userName,
            "loansProcessed": loansProcessed,
            "approvalRate": approvalRate,
            "avgProcessingTime": "N/A",
          });
        }
      }
      performers.sort(
        (a, b) =>
            (b['loansProcessed'] as int).compareTo(a['loansProcessed'] as int),
      );

      if (mounted) {
        setState(() {
          analyticsData = {
            "totalLoans": totalLoans,
            "approvedLoans": approvedLoans,
            "pendingLoans": pendingLoans,
            "rejectedLoans": rejectedLoans,
            "totalAmount": totalAmount,
            "approvedAmount": approvedAmount,
            "pendingAmount": pendingAmount,
            "averageLoanAmount": totalLoans > 0
                ? totalAmount / totalLoans
                : 0.0,
            "averageProcessingTime": processedLoans > 0
                ? "${(totalProcessingDays / processedLoans).toStringAsFixed(1)} days"
                : "0 days",
            "approvalRate": totalLoans > 0
                ? (approvedLoans / totalLoans * 100)
                : 0.0,
          };
          monthlyTrends = trends;
          loanTypeDistribution = distribution;
          topPerformers = performers.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load analytics: $e';
          _isLoading = false;
        });
      }
      debugPrint('Error loading analytics: $e');
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/admin/loans');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/admin/verification');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/admin/users');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Analytics', style: TextStyle(color: Colors.white)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFF1E88E5),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false, // Add this line
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 28,
            ),
            onSelected: (value) {
              if (value == 'logout') {
                // Handle logout
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAnalyticsData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildPeriodChip('Today'),
                                const SizedBox(width: 8),
                                _buildPeriodChip('This Week'),
                                const SizedBox(width: 8),
                                _buildPeriodChip('This Month'),
                                const SizedBox(width: 8),
                                _buildPeriodChip('This Year'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Key Metrics Grid
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Key Metrics',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                          children: [
                            _buildMetricCard(
                              'Total Loans',
                              analyticsData['totalLoans'].toString(),
                              Icons.description_outlined,
                              Colors.blue,
                              '+12.5%',
                            ),
                            _buildMetricCard(
                              'Approved',
                              analyticsData['approvedLoans'].toString(),
                              Icons.check_circle_outline,
                              Colors.green,
                              '+8.3%',
                            ),
                            _buildMetricCard(
                              'Pending',
                              analyticsData['pendingLoans'].toString(),
                              Icons.pending_outlined,
                              Colors.orange,
                              '+5.2%',
                            ),
                            _buildMetricCard(
                              'Rejected',
                              analyticsData['rejectedLoans'].toString(),
                              Icons.cancel_outlined,
                              Colors.red,
                              '-3.1%',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Financial Overview
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Financial Overview',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildFinancialRow(
                                  'Total Loan Amount',
                                  currencyFormat.format(
                                    analyticsData['totalAmount'],
                                  ),
                                  Colors.blue,
                                ),
                                const Divider(height: 24),
                                _buildFinancialRow(
                                  'Approved Amount',
                                  currencyFormat.format(
                                    analyticsData['approvedAmount'],
                                  ),
                                  Colors.green,
                                ),
                                const Divider(height: 24),
                                _buildFinancialRow(
                                  'Pending Amount',
                                  currencyFormat.format(
                                    analyticsData['pendingAmount'],
                                  ),
                                  Colors.orange,
                                ),
                                const Divider(height: 24),
                                _buildFinancialRow(
                                  'Average Loan',
                                  currencyFormat.format(
                                    analyticsData['averageLoanAmount'],
                                  ),
                                  Colors.purple,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Loan Type Distribution
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Loan Type Distribution',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: loanTypeDistribution.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: item['color'],
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                item['type'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${item['count']} (${item['percentage']}%)',
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: item['percentage'] / 100,
                                          backgroundColor: Colors.grey[200],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                item['color'],
                                              ),
                                          minHeight: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Monthly Trends
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Trends',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Simple bar chart representation
                                SizedBox(
                                  height: 200,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: monthlyTrends.map((data) {
                                      final maxApplications = monthlyTrends
                                          .map((e) => e['applications'] as int)
                                          .reduce((a, b) => a > b ? a : b);
                                      final height =
                                          (data['applications'] as int) /
                                          maxApplications *
                                          150;

                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            data['applications'].toString(),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            width: 40,
                                            height: height,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1E88E5),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            data['month'],
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1E88E5),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Applications',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Performance Metrics
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Metrics',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPerformanceCard(
                                'Approval Rate',
                                '${analyticsData['approvalRate']}%',
                                Icons.trending_up,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildPerformanceCard(
                                'Avg Processing',
                                analyticsData['averageProcessingTime'],
                                Icons.access_time,
                                Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Top Performers
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top Performers',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: topPerformers.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final performer = topPerformers[index];
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey[200]!),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            performer['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${performer['loansProcessed']} loans • ${performer['approvalRate']}% approval',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Icon(
                                          Icons.timer_outlined,
                                          size: 16,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          performer['avgProcessingTime'],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined, size: 24),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card, size: 24),
              label: 'Loans',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.verified_user_outlined, size: 24),
              label: 'Verify',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined, size: 24),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline, size: 24),
              label: 'Users',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF1E88E5),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          iconSize: 24,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label) {
    final isSelected = _selectedPeriod == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPeriod = label;
        });
        _loadAnalyticsData(); // Reload data when period changes
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF1E88E5),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF1E88E5) : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: change.startsWith('+')
                      ? Colors.green[50]
                      : Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: change.startsWith('+') ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 14, color: Colors.black54)),
          ],
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
