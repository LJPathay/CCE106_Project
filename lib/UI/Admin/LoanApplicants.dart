import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LoanApplicantsScreen extends StatefulWidget {
  const LoanApplicantsScreen({super.key});

  @override
  State<LoanApplicantsScreen> createState() => _LoanApplicantsScreenState();
}

class _LoanApplicantsScreenState extends State<LoanApplicantsScreen> {
  int _selectedIndex = 1; // Loans tab
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<Map<String, dynamic>> loanApplicants = [
    {
      "id": "LA-001",
      "name": "Juan Dela Cruz",
      "email": "juan.delacruz@email.com",
      "phone": "+63 912 345 6789",
      "loanType": "Business Loan",
      "amount": 500000.00,
      "purpose": "Business Expansion",
      "status": "Pending",
      "dateApplied": "2023-11-18",
      "creditScore": 720,
      "employmentStatus": "Employed",
      "monthlyIncome": 45000.00,
    },
    {
      "id": "LA-002",
      "name": "Maria Santos",
      "email": "maria.santos@email.com",
      "phone": "+63 917 234 5678",
      "loanType": "Home Loan",
      "amount": 1500000.00,
      "purpose": "Home Renovation",
      "status": "Under Review",
      "dateApplied": "2023-11-17",
      "creditScore": 680,
      "employmentStatus": "Self-Employed",
      "monthlyIncome": 60000.00,
    },
    {
      "id": "LA-003",
      "name": "Pedro Bautista",
      "email": "pedro.b@email.com",
      "phone": "+63 918 345 6789",
      "loanType": "Education Loan",
      "amount": 300000.00,
      "purpose": "College Tuition",
      "status": "Approved",
      "dateApplied": "2023-11-16",
      "creditScore": 750,
      "employmentStatus": "Employed",
      "monthlyIncome": 55000.00,
    },
    {
      "id": "LA-004",
      "name": "Ana Reyes",
      "email": "ana.reyes@email.com",
      "phone": "+63 919 456 7890",
      "loanType": "Medical Loan",
      "amount": 750000.00,
      "purpose": "Medical Treatment",
      "status": "Rejected",
      "dateApplied": "2023-11-15",
      "creditScore": 580,
      "employmentStatus": "Unemployed",
      "monthlyIncome": 0.00,
    },
    {
      "id": "LA-005",
      "name": "Luis Garcia",
      "email": "luis.garcia@email.com",
      "phone": "+63 920 567 8901",
      "loanType": "Auto Loan",
      "amount": 2000000.00,
      "purpose": "Vehicle Purchase",
      "status": "Pending",
      "dateApplied": "2023-11-14",
      "creditScore": 700,
      "employmentStatus": "Employed",
      "monthlyIncome": 80000.00,
    },
    {
      "id": "LA-006",
      "name": "Carmen Lopez",
      "email": "carmen.lopez@email.com",
      "phone": "+63 921 678 9012",
      "loanType": "Personal Loan",
      "amount": 100000.00,
      "purpose": "Debt Consolidation",
      "status": "Under Review",
      "dateApplied": "2023-11-13",
      "creditScore": 650,
      "employmentStatus": "Employed",
      "monthlyIncome": 40000.00,
    },
  ];

  List<Map<String, dynamic>> get filteredApplicants {
    var filtered = loanApplicants;
    
    // Filter by status
    if (_selectedFilter != 'All') {
      filtered = filtered.where((app) => app['status'] == _selectedFilter).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((app) {
        final name = app['name'].toString().toLowerCase();
        final id = app['id'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || id.contains(query);
      }).toList();
    }
    
    return filtered;
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
                _buildStatItem('Total', loanApplicants.length.toString(), Colors.blue),
                _buildStatItem(
                  'Pending',
                  loanApplicants.where((a) => a['status'] == 'Pending').length.toString(),
                  Colors.orange,
                ),
                _buildStatItem(
                  'Approved',
                  loanApplicants.where((a) => a['status'] == 'Approved').length.toString(),
                  Colors.green,
                ),
                _buildStatItem(
                  'Rejected',
                  loanApplicants.where((a) => a['status'] == 'Rejected').length.toString(),
                  Colors.red,
                ),
              ],
            ),
          ),
          // Applicants List
          Expanded(
            child: filteredApplicants.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.black54),
                        const SizedBox(height: 16),
                        Text(
                          'No applicants found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredApplicants.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final applicant = filteredApplicants[index];
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
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInfoColumn(
                                        'Loan Type',
                                        applicant['loanType'],
                                        Icons.category_outlined,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildInfoColumn(
                                        'Amount',
                                        currencyFormat.format(applicant['amount']),
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
                                        applicant['purpose'],
                                        Icons.description_outlined,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildInfoColumn(
                                        'Applied',
                                        dateFormat.format(DateTime.parse(applicant['dateApplied'])),
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

  Widget _buildInfoColumn(String label, String value, IconData icon) {
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
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
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
