import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  int _selectedIndex = 4; // Users tab
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<Map<String, dynamic>> users = [
    {
      "id": "USR-001",
      "name": "Juan Dela Cruz",
      "email": "juan.delacruz@email.com",
      "phone": "+63 912 345 6789",
      "role": "Borrower",
      "status": "Active",
      "joinDate": "2023-01-15",
      "totalLoans": 3,
      "activeLoans": 1,
      "creditScore": 720,
      "lastLogin": "2023-11-18 14:30",
    },
    {
      "id": "USR-002",
      "name": "Maria Santos",
      "email": "maria.santos@email.com",
      "phone": "+63 917 234 5678",
      "role": "Borrower",
      "status": "Active",
      "joinDate": "2023-02-20",
      "totalLoans": 2,
      "activeLoans": 1,
      "creditScore": 680,
      "lastLogin": "2023-11-17 09:15",
    },
    {
      "id": "USR-003",
      "name": "Pedro Bautista",
      "email": "pedro.b@email.com",
      "phone": "+63 918 345 6789",
      "role": "Admin",
      "status": "Active",
      "joinDate": "2022-11-10",
      "totalLoans": 0,
      "activeLoans": 0,
      "creditScore": 0,
      "lastLogin": "2023-11-18 16:45",
    },
    {
      "id": "USR-004",
      "name": "Ana Reyes",
      "email": "ana.reyes@email.com",
      "phone": "+63 919 456 7890",
      "role": "Borrower",
      "status": "Suspended",
      "joinDate": "2023-03-05",
      "totalLoans": 4,
      "activeLoans": 0,
      "creditScore": 580,
      "lastLogin": "2023-11-10 11:20",
    },
    {
      "id": "USR-005",
      "name": "Luis Garcia",
      "email": "luis.garcia@email.com",
      "phone": "+63 920 567 8901",
      "role": "Borrower",
      "status": "Active",
      "joinDate": "2023-04-12",
      "totalLoans": 1,
      "activeLoans": 1,
      "creditScore": 700,
      "lastLogin": "2023-11-18 10:00",
    },
    {
      "id": "USR-006",
      "name": "Carmen Lopez",
      "email": "carmen.lopez@email.com",
      "phone": "+63 921 678 9012",
      "role": "Loan Officer",
      "status": "Active",
      "joinDate": "2022-08-20",
      "totalLoans": 0,
      "activeLoans": 0,
      "creditScore": 0,
      "lastLogin": "2023-11-18 15:30",
    },
    {
      "id": "USR-007",
      "name": "Roberto Tan",
      "email": "roberto.tan@email.com",
      "phone": "+63 922 789 0123",
      "role": "Borrower",
      "status": "Inactive",
      "joinDate": "2023-05-18",
      "totalLoans": 1,
      "activeLoans": 0,
      "creditScore": 650,
      "lastLogin": "2023-10-15 08:45",
    },
    {
      "id": "USR-008",
      "name": "Sofia Mendoza",
      "email": "sofia.mendoza@email.com",
      "phone": "+63 923 890 1234",
      "role": "Loan Officer",
      "status": "Active",
      "joinDate": "2023-01-08",
      "totalLoans": 0,
      "activeLoans": 0,
      "creditScore": 0,
      "lastLogin": "2023-11-18 13:20",
    },
  ];

  List<Map<String, dynamic>> get filteredUsers {
    var filtered = users;
    
    // Filter by status/role
    if (_selectedFilter != 'All') {
      if (_selectedFilter == 'Active' || _selectedFilter == 'Inactive' || _selectedFilter == 'Suspended') {
        filtered = filtered.where((user) => user['status'] == _selectedFilter).toList();
      } else {
        filtered = filtered.where((user) => user['role'] == _selectedFilter).toList();
      }
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        final name = user['name'].toString().toLowerCase();
        final email = user['email'].toString().toLowerCase();
        final id = user['id'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || email.contains(query) || id.contains(query);
      }).toList();
    }
    
    return filtered;
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'loan officer':
        return Colors.blue;
      case 'borrower':
        return Colors.orange;
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
        case 1:
          Navigator.pushReplacementNamed(context, '/admin/loans');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/admin/verification');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/admin/analytics');
          break;
      }
    }
  }

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _viewUserDetails(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildUserDetailsSheet(user),
    );
  }

  Widget _buildUserDetailsSheet(Map<String, dynamic> user) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final dateTimeFormat = DateFormat('MMM d, yyyy HH:mm');
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'User Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: CircleAvatar(
                  backgroundColor: Colors.blue[50],
                  radius: 40,
                  child: Text(
                    user['name'].toString().substring(0, 1),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user['name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getRoleColor(user['role']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user['role'],
                    style: TextStyle(
                      color: getRoleColor(user['role']),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildDetailRow(Icons.badge_outlined, 'User ID', user['id']),
              const Divider(height: 32),
              _buildDetailRow(Icons.email_outlined, 'Email', user['email']),
              const Divider(height: 32),
              _buildDetailRow(Icons.phone_outlined, 'Phone', user['phone']),
              const Divider(height: 32),
              _buildDetailRow(
                Icons.calendar_today_outlined,
                'Join Date',
                dateFormat.format(DateTime.parse(user['joinDate'])),
              ),
              const Divider(height: 32),
              _buildDetailRow(
                Icons.access_time_outlined,
                'Last Login',
                dateTimeFormat.format(DateTime.parse(user['lastLogin'])),
              ),
              if (user['role'] == 'Borrower') ...[
                const Divider(height: 32),
                _buildDetailRow(
                  Icons.credit_score_outlined,
                  'Credit Score',
                  user['creditScore'].toString(),
                ),
                const Divider(height: 32),
                _buildDetailRow(
                  Icons.description_outlined,
                  'Total Loans',
                  user['totalLoans'].toString(),
                ),
                const Divider(height: 32),
                _buildDetailRow(
                  Icons.pending_actions_outlined,
                  'Active Loans',
                  user['activeLoans'].toString(),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit functionality coming soon')),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: const Color(0xFF1E88E5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              user['status'] == 'Active'
                                  ? 'User suspended'
                                  : 'User activated',
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        user['status'] == 'Active'
                            ? Icons.block
                            : Icons.check_circle_outline,
                      ),
                      label: Text(user['status'] == 'Active' ? 'Suspend' : 'Activate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: user['status'] == 'Active'
                            ? Colors.red
                            : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateTimeFormat = DateFormat('MMM d, HH:mm');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Users Management', style: TextStyle(color: Colors.white)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFF1E88E5),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add user functionality coming soon')),
              );
            },
          ),
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
                    hintText: 'Search by name, email or ID...',
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
                      _buildFilterChip('Active'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Inactive'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Suspended'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Admin'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Loan Officer'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Borrower'),
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
                _buildStatItem('Total', users.length.toString(), Colors.blue),
                _buildStatItem(
                  'Active',
                  users.where((u) => u['status'] == 'Active').length.toString(),
                  Colors.green,
                ),
                _buildStatItem(
                  'Borrowers',
                  users.where((u) => u['role'] == 'Borrower').length.toString(),
                  Colors.orange,
                ),
                _buildStatItem(
                  'Staff',
                  users.where((u) => u['role'] != 'Borrower').length.toString(),
                  Colors.purple,
                ),
              ],
            ),
          ),
          // Users List
          Expanded(
            child: filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No users found',
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
                    itemCount: filteredUsers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final statusColor = getStatusColor(user['status']);
                      final roleColor = getRoleColor(user['role']);
                      
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: InkWell(
                          onTap: () => _viewUserDetails(user),
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
                                        user['name'].toString().substring(0, 1),
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
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  user['name'],
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  user['status'],
                                                  style: theme.textTheme.labelSmall?.copyWith(
                                                    color: statusColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                user['id'],
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: roleColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  user['role'],
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: roleColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
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
                                    Icon(Icons.email_outlined, size: 14, color: Colors.black54),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        user['email'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.phone_outlined, size: 14, color: Colors.black54),
                                    const SizedBox(width: 6),
                                    Text(
                                      user['phone'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(Icons.access_time_outlined, size: 14, color: Colors.black54),
                                    const SizedBox(width: 6),
                                    Text(
                                      dateTimeFormat.format(DateTime.parse(user['lastLogin'])),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                if (user['role'] == 'Borrower') ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildUserStatItem(
                                        'Credit Score',
                                        user['creditScore'].toString(),
                                        Icons.credit_score,
                                      ),
                                      _buildUserStatItem(
                                        'Total Loans',
                                        user['totalLoans'].toString(),
                                        Icons.description,
                                      ),
                                      _buildUserStatItem(
                                        'Active',
                                        user['activeLoans'].toString(),
                                        Icons.pending_actions,
                                      ),
                                    ],
                                  ),
                                ],
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
        fontSize: 12,
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

  Widget _buildUserStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.black54,
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
