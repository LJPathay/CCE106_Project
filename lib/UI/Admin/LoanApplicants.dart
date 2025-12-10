import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cce106_finance_project/services/loan_service.dart';
import '../../layout/AdminTheme.dart';

class LoanApplicantsScreen extends StatefulWidget {
  const LoanApplicantsScreen({super.key});

  @override
  State<LoanApplicantsScreen> createState() => _LoanApplicantsScreenState();
}

class _LoanApplicantsScreenState extends State<LoanApplicantsScreen> {
  int _selectedIndex = 1; // Loans tab
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final LoanService _loanService = LoanService();
  late Stream<List<Map<String, dynamic>>> _loanApplicantsStream;
  final Map<String, int> _loanStats = {
    'total': 0,
    'pending': 0,
    'approved': 0,
    'rejected': 0,
  };
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _loanApplicantsStream = _loanService.getLoanApplicants();
      final stats = await _loanService.getLoanStats();

      if (mounted) {
        setState(() {
          _loanStats
            ..clear()
            ..addAll(stats);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load loan data: $e';
          _isLoading = false;
        });
      }
    }
  }

  Stream<List<Map<String, dynamic>>> get filteredApplicantsStream {
    return _loanApplicantsStream.map((applicants) {
      var filtered = List<Map<String, dynamic>>.from(applicants);

      // Filter by status
      if (_selectedFilter != 'All') {
        filtered = filtered
            .where((app) => app['status'] == _selectedFilter)
            .toList();
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        filtered = filtered.where((app) {
          final name = app['name']?.toString().toLowerCase() ?? '';
          final id = app['id']?.toString().toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();
          return name.contains(query) || id.contains(query);
        }).toList();
      }

      return filtered;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'under review':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
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
        case 2:
          Navigator.pushReplacementNamed(context, '/admin/verification');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/admin/analytics');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/admin/users');
          break;
      }
    }
  }

  Future<void> _updateStatus(String loanId, String status) async {
    // Show blocking loading dialog
    AdminTheme.showLoadingDialog(context);

    try {
      await _loanService.updateLoanStatus(loanId, status);

      // Refresh stats after update
      final stats = await _loanService.getLoanStats();

      if (mounted) {
        setState(() {
          _loanStats
            ..clear()
            ..addAll(stats);
        });

        // Close loading dialog
        Navigator.pop(context);

        // Show success message
        AdminTheme.showSuccessSnackBar(context, 'Status updated to $status');
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);

        // Show error message
        AdminTheme.showErrorSnackBar(context, 'Failed to update status: $e');
      }
    }
  }

  void _showLoanDetailsPopup(
    BuildContext context,
    Map<String, dynamic> applicant,
  ) {
    final status = (applicant['status']?.toString() ?? 'Pending').toLowerCase();
    final canApprove = status == 'pending' || status == 'under review';
    final canReject =
        status == 'pending' || status == 'under review' || status == 'approved';
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Loan Application Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Applicant', applicant['name'] ?? 'N/A'),
              _buildDetailRow(
                'Amount',
                currencyFormat.format(
                  double.tryParse(applicant['amount']?.toString() ?? '0') ?? 0,
                ),
              ),
              _buildDetailRow('Term', '${applicant['term']} months'),
              _buildDetailRow(
                'Purpose',
                applicant['purpose'] ?? 'Not specified',
              ),
              _buildDetailRow('Status', applicant['status'] ?? 'Pending'),
              _buildDetailRow(
                'Date Applied',
                _formatDate(applicant['dateApplied']),
              ),
              if (applicant['dateApproved'] != null)
                _buildDetailRow(
                  'Date Approved',
                  _formatDate(applicant['dateApproved']),
                ),
              if (applicant['dateRejected'] != null)
                _buildDetailRow(
                  'Date Rejected',
                  _formatDate(applicant['dateRejected']),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE', style: TextStyle(color: Colors.grey)),
          ),
          if (canReject)
            TextButton(
              onPressed: () {
                _updateStatus(applicant['id'], 'rejected');
                Navigator.pop(context);
              },
              child: const Text('REJECT', style: TextStyle(color: Colors.red)),
            ),
          if (canApprove)
            ElevatedButton(
              onPressed: () {
                _updateStatus(applicant['id'], 'approved');
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'APPROVE',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      if (date is String) {
        if (date.isEmpty) return 'N/A';
        return DateFormat('MMM d, yyyy hh:mm a').format(DateTime.parse(date));
      } else if (date is DateTime) {
        return DateFormat('MMM d, yyyy hh:mm a').format(date);
      } else if (date is Timestamp) {
        return DateFormat('MMM d, yyyy hh:mm a').format(date.toDate());
      }
      return date.toString();
    } catch (e) {
      return 'Invalid date';
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? label : 'All';
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue[800] : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildLoanCard(Map<String, dynamic> applicant, BuildContext context) {
    final status = (applicant['status']?.toString() ?? 'Pending').toLowerCase();
    final statusColor = _getStatusColor(status);
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showLoanDetailsPopup(context, applicant),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      applicant['name'] ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (applicant['status'] ?? 'Pending')
                          .toString()
                          .toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoColumn(
                    'Amount',
                    currencyFormat.format(
                      double.tryParse(applicant['amount']?.toString() ?? '0') ??
                          0,
                    ),
                    Icons.attach_money,
                  ),
                  const SizedBox(width: 16),
                  _buildInfoColumn(
                    'Term',
                    '${applicant['term']} months',
                    Icons.calendar_today,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoColumn(
                    'Applied',
                    _formatDate(applicant['dateApplied']),
                    Icons.access_time,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Loan Applicants',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFF1E88E5),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false, // This line removes the back button
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 28,
            ),
            onSelected: (value) {
              if (value == 'logout') {
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
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Column(
              children: [
                // Search and Filter Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search applicants...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Pending'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Approved'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Rejected'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Stats Summary
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  color: Colors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Total',
                          _loanStats['total'].toString(),
                          colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        _buildStatItem(
                          'Pending',
                          _loanStats['pending'].toString(),
                          Colors.orange,
                        ),
                        const SizedBox(width: 16),
                        _buildStatItem(
                          'Approved',
                          _loanStats['approved'].toString(),
                          Colors.green,
                        ),
                        const SizedBox(width: 16),
                        _buildStatItem(
                          'Rejected',
                          _loanStats['rejected'].toString(),
                          Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
                // Loan List
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: filteredApplicantsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final applicants = snapshot.data ?? [];

                      if (applicants.isEmpty) {
                        return const Center(
                          child: Text(
                            'No loan applications found',
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: applicants.length,
                        itemBuilder: (context, index) {
                          final applicant = applicants[index];
                          return _buildLoanCard(applicant, context);
                        },
                      );
                    },
                  ),
                ),
              ],
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
}
