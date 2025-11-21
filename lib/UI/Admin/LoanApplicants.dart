import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cce106_finance_project/services/loan_service.dart';

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
  Map<String, int> _loanStats = {
    'total': 0,
    'pending': 0,
    'approved': 0,
    'rejected': 0,
  };
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load loan applicants
      _loanApplicantsStream = _loanService.getLoanApplicants();
      
      // Load loan statistics
      final stats = await _loanService.getLoanStats();
      
      if (mounted) {
        setState(() {
          _loanStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load loan data: ${e.toString()}';
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
        filtered = filtered.where((app) => app['status'] == _selectedFilter).toList();
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

  Color getStatusColor(String status) {
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
      // Navigate to appropriate screen
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

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _updateStatus(String loanId, String status) async {
    try {
      await _loanService.updateLoanStatus(loanId, status);
      // Refresh stats after update
      final stats = await _loanService.getLoanStats();
      if (mounted) {
        setState(() {
          _loanStats = stats;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $status')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: ${e.toString()}')),
        );
      }
    }
  }

  void _viewApplicantDetails(Map<String, dynamic> applicant) {
    Navigator.pushNamed(
      context,
      '/admin/verification',
      arguments: applicant,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final dateFormat = DateFormat('MMM d, yyyy');
    
    Widget buildBody() {
      if (_isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (_errorMessage != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
      
      return StreamBuilder<List<Map<String, dynamic>>>(
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.black54),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty || _selectedFilter != 'All'
                        ? 'No matching applicants found'
                        : 'No loan applications yet',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: applicants.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final applicant = applicants[index];
              final statusColor = getStatusColor(applicant['status']);
              
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: InkWell(
                  onTap: () => _viewApplicantDetails(applicant),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue[50],
                              radius: 24,
                              child: Text(
                                applicant['name'].toString().substring(0, 1),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        applicant['name'] ?? 'No Name',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                                          applicant['status'] ?? 'Unknown',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    applicant['id'] ?? 'No ID',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (applicant['status'] == 'Pending') ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _updateStatus(applicant['id'], 'Approved'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.green),
                                  ),
                                  child: const Text('Approve', style: TextStyle(color: Colors.green)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _updateStatus(applicant['id'], 'Rejected'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  child: const Text('Reject', style: TextStyle(color: Colors.red)),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoColumn(
                                'Loan Type',
                                applicant['loanType'] ?? 'N/A',
                                Icons.category_outlined,
                              ),
                            ),
                            Expanded(
                              child: _buildInfoColumn(
                                'Amount',
                                applicant['amount'] != null 
                                    ? currencyFormat.format(applicant['amount'])
                                    : 'N/A',
                                Icons.attach_money,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoColumn(
                                'Purpose',
                                applicant['purpose'] ?? 'N/A',
                                Icons.description_outlined,
                              ),
                            ),
                            Expanded(
                              child: _buildInfoColumn(
                                'Applied',
                                applicant['dateApplied'] != null
                                    ? dateFormat.format(DateTime.parse(applicant['dateApplied']))
                                    : 'N/A',
                                Icons.calendar_today,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _viewApplicantDetails(applicant),
                              icon: const Icon(Icons.visibility_outlined, size: 18),
                              label: const Text('View Details'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF1E88E5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Loan Applicants', style: TextStyle(color: Colors.white)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFF1E88E5),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.white, size: 28),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name or ID...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1E88E5)),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Under Review'),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', _loanStats['total'].toString(), Colors.blue),
                _buildStatItem(
                  'Pending',
                  _loanStats['pending'].toString(),
                  Colors.orange,
                ),
                _buildStatItem(
                  'Approved',
                  _loanStats['approved'].toString(),
                  Colors.green,
                ),
                _buildStatItem(
                  'Rejected',
                  _loanStats['rejected'].toString(),
                  Colors.red,
                ),
              ],
            ),
          ),
          // Loading and Error States
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorMessage != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          // Applicants List
          else
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: filteredApplicantsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final applicants = snapshot.data ?? [];

                  if (applicants.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 64, color: Colors.black54),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty || _selectedFilter != 'All'
                                ? 'No matching applicants found'
                                : 'No loan applications yet',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: applicants.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final applicant = applicants[index];
                      final statusColor = getStatusColor(applicant['status']);
                      
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: InkWell(
                          onTap: () => _viewApplicantDetails(applicant),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blue[50],
                                      radius: 24,
                                      child: Text(
                                        applicant['name'].toString().substring(0, 1),
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                applicant['name'],
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
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
                                                  applicant['status'],
                                                  style: theme.textTheme.labelSmall?.copyWith(
                                                    color: statusColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            applicant['id'],
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (applicant['status'] == 'Pending')
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _updateStatus(applicant['id'], 'Approved'),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Colors.green),
                                          ),
                                          child: const Text('Approve', style: TextStyle(color: Colors.green)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _updateStatus(applicant['id'], 'Rejected'),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Colors.red),
                                          ),
                                          child: const Text('Reject', style: TextStyle(color: Colors.red)),
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInfoColumn(
                                        'Loan Type',
                                        applicant['loanType'] ?? 'N/A',
                                        Icons.category_outlined,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildInfoColumn(
                                        'Amount',
                                        applicant['amount'] != null 
                                            ? currencyFormat.format(applicant['amount'])
                                            : 'N/A',
                                        Icons.attach_money,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInfoColumn(
                                        'Purpose',
                                        applicant['purpose'] ?? 'N/A',
                                        Icons.description_outlined,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildInfoColumn(
                                        'Applied',
                                        applicant['dateApplied'] != null
                                            ? dateFormat.format(DateTime.parse(applicant['dateApplied']))
                                            : 'N/A',
                                        Icons.calendar_today,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _viewApplicantDetails(applicant),
                                      icon: const Icon(Icons.visibility_outlined, size: 18),
                                      label: const Text('View Details'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFF1E88E5),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              ),
            
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 70,
        padding: EdgeInsets.zero,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_outlined, 'Home', 0),
            _buildNavItem(Icons.attach_money, 'Loans', 1),
            _buildNavItem(Icons.check_circle_outline, 'Verify', 2),
            _buildNavItem(Icons.bar_chart_outlined, 'Reports', 3),
            _buildNavItem(Icons.person_outline, 'Users', 4),
          ],
        ),
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
          _selectedFilter = label;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF1E88E5),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF1E88E5) : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
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
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoColumn(String label, String? value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value ?? 'N/A',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.blue[800] : Colors.black54,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.blue[800] : Colors.black54,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
