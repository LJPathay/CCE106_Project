import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cce106_finance_project/layout/AdminTheme.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

class VerificationRequest {
  final String id;
  final String userId;
  final String name;
  final String idType;
  final String idImageUrl;
  final String? additionalInfo;
  String status;
  final DateTime dateSubmitted;

  VerificationRequest({
    required this.id,
    required this.userId,
    required this.name,
    required this.idType,
    required this.idImageUrl,
    this.additionalInfo,
    required this.status,
    required this.dateSubmitted,
  });

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return AdminTheme.success;
      case 'rejected':
        return AdminTheme.danger;
      default:
        return AdminTheme.textSecondary;
    }
  }
}

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<VerificationRequest> _requests = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  bool _isDisposed = false;
  bool _isMounted = false;
  String? _error;
  String _searchQuery = '';
  String _statusFilter = '';
  int _selectedIndex = 2; // Verification tab index

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _loadVerificationRequests();
  }

  @override
  void dispose() {
    _isMounted = false;
    _isDisposed = true;
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (_isMounted && !_isDisposed) {
      setState(fn);
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      _safeSetState(() {
        _selectedIndex = index;
      });

      // Only navigate if the widget is still mounted
      if (!mounted) return;

      // Navigate to appropriate screen
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/admin/loans');
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

  Future<void> _loadVerificationRequests() async {
    if (!_isMounted || _isDisposed) return;

    _safeSetState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final querySnapshot = await _firestore
          .collection('verificationRequests')
          .orderBy('createdAt', descending: true)
          .get();

      if (!_isMounted || _isDisposed) return;

      final requests = await Future.wait<VerificationRequest>(
        querySnapshot.docs.map((doc) async {
          if (!_isMounted || _isDisposed) {
            return VerificationRequest(
              id: '',
              userId: '',
              name: 'Loading...',
              idType: '',
              idImageUrl: '',
              status: 'Pending',
              dateSubmitted: DateTime.now(),
            );
          }

          try {
            final data = doc.data();
            String name = 'Loading...';
            String? userId;

            try {
              userId = data['userId']?.toString();
              if (userId != null && userId.isNotEmpty) {
                // First, try to get the name from the verification request data
                name = data['fullName'] ?? data['name'] ?? 'User ID: $userId';

                // If not found in verification request, try the Account collection
                if (name == 'User ID: $userId') {
                  final userDoc = await _firestore
                      .collection('Account')
                      .doc(userId)
                      .get();
                  if (userDoc.exists) {
                    final userData = userDoc.data();
                    name =
                        userData?['fullName'] ??
                        userData?['name'] ??
                        userData?['displayName'] ??
                        name; // Keep the existing name if not found
                  } else {
                    debugPrint(
                      'User document not found in Account collection for ID: $userId',
                    );

                    // If we have an email but no name, use the email prefix as name
                    if (data['email'] != null) {
                      final email = data['email'].toString();
                      name = email.split('@').first;

                      // Try to create the account document with available data
                      try {
                        await _firestore.collection('Account').doc(userId).set({
                          'email': email,
                          'fullName': name,
                          'createdAt': FieldValue.serverTimestamp(),
                        }, SetOptions(merge: true));

                        debugPrint(
                          'Created account document for user: $userId',
                        );
                      } catch (e) {
                        debugPrint('Error creating account document: $e');
                      }
                    }
                  }
                }
              } else {
                debugPrint(
                  'Invalid or missing userId in verification request: ${doc.id}',
                );
                name = 'Unknown User';
              }
            } catch (e) {
              debugPrint('Error fetching user details: $e');
              name = 'User ID: ${userId ?? 'Unknown'}';
            }

            return VerificationRequest(
              id: doc.id,
              userId: data['userId']?.toString() ?? '',
              name: name,
              idType: data['idType']?.toString() ?? 'Unknown',
              idImageUrl: data['idImageUrl']?.toString() ?? '',
              additionalInfo: data['additionalInfo']?.toString(),
              status: (data['status'] as String?)?.capitalize() ?? 'Pending',
              dateSubmitted:
                  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          } catch (e) {
            debugPrint('Error processing verification request: $e');
            return VerificationRequest(
              id: '',
              userId: '',
              name: 'Error',
              idType: '',
              idImageUrl: '',
              status: 'Pending',
              dateSubmitted: DateTime.now(),
            );
          }
        }),
      );

      if (!_isMounted || _isDisposed) return;

      _safeSetState(() {
        _requests.clear();
        _requests.addAll(requests.where((r) => r.id.isNotEmpty));
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading verification requests: $e');
      if (!_isMounted || _isDisposed) return;

      _safeSetState(() {
        _error = 'Failed to load verification requests: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<VerificationRequest> get _filteredRequests {
    if (_searchQuery.isEmpty && _statusFilter.isEmpty) {
      return _requests;
    }
    return _requests.where((req) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          req.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          req.id.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus =
          _statusFilter.isEmpty ||
          req.status.toLowerCase() == _statusFilter.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _showRequestDetails(VerificationRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildRequestDetails(request),
    );
  }

  Widget _buildRequestCard(VerificationRequest request) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () => _showRequestDetails(request),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[50],
                child: Text(
                  request.name.isNotEmpty ? request.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.idType,
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: request.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  request.status,
                  style: TextStyle(
                    color: request.statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String status) {
    final bool isSelected = _statusFilter.toLowerCase() == status.toLowerCase();
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (selected) {
        setState(() {
          _statusFilter = isSelected ? '' : status;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF1E88E5),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF1E88E5) : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildRequestDetails(VerificationRequest request) {
    final dateFormat = DateFormat('MMM d, yyyy hh:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 24,
                decoration: BoxDecoration(
                  color: request.statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verification Details',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildDetailItem('Applicant', request.name),
                  _buildDetailItem('ID Type', request.idType),
                  _buildDetailItem(
                    'Date Submitted',
                    dateFormat.format(request.dateSubmitted),
                  ),
                  if (request.additionalInfo != null &&
                      request.additionalInfo!.isNotEmpty)
                    _buildDetailItem(
                      'Additional Info',
                      request.additionalInfo!,
                    ),

                  const SizedBox(height: 24),
                  const Text(
                    'ID Document',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  if (request.idImageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        request.idImageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey[100],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[100],
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text('Failed to load image'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Center(child: Text('No image provided')),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (request.status.toLowerCase() == 'pending') ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleReject(request),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AdminTheme.danger),
                    ),
                    child: Text(
                      'Reject',
                      style: TextStyle(color: AdminTheme.danger),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleApprove(request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.success,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ] else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: request.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Request ${request.status}',
                  style: TextStyle(
                    color: request.statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleApprove(VerificationRequest request) async {
    final confirmed = await AdminTheme.showConfirmDialog(
      context: context,
      title: 'Approve Verification',
      content:
          'Are you sure you want to approve this verification request? This will mark the user as verified.',
      confirmText: 'Approve',
      confirmColor: AdminTheme.success,
    );

    if (confirmed != true) return;

    if (!mounted) return;
    AdminTheme.showLoadingDialog(context);

    try {
      await _firestore.runTransaction((transaction) async {
        // Update verification request status
        transaction.update(
          _firestore.collection('verificationRequests').doc(request.id),
          {'status': 'approved'},
        );

        // Update user verification status
        transaction.update(
          _firestore.collection('Account').doc(request.userId),
          {'isVerified': true},
        );
      });

      setState(() {
        request.status = 'Approved';
      });

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.pop(context); // Close bottom sheet
        AdminTheme.showSuccessSnackBar(
          context,
          'Verification approved successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        AdminTheme.showErrorSnackBar(
          context,
          'Failed to approve verification: $e',
        );
      }
    }
  }

  void _handleReject(VerificationRequest request) {
    _notesController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Reject Verification', style: AdminTheme.subheading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to reject this request?'),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AdminTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = _notesController.text.trim();

              // Close the rejection dialog first
              Navigator.pop(context);

              // Show loading
              AdminTheme.showLoadingDialog(context);

              try {
                await _firestore
                    .collection('verificationRequests')
                    .doc(request.id)
                    .update({'status': 'rejected', 'rejectionReason': reason});

                setState(() {
                  request.status = 'Rejected';
                });

                if (mounted) {
                  Navigator.pop(context); // Close loading dialog
                  Navigator.pop(context); // Close bottom sheet
                  AdminTheme.showSuccessSnackBar(
                    context,
                    'Verification rejected',
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Close loading dialog
                  AdminTheme.showErrorSnackBar(
                    context,
                    'Failed to reject verification: $e',
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void handleLogout() async {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Verification',
          style: TextStyle(color: Colors.white),
        ),
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
                handleLogout();
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
                    onPressed: _loadVerificationRequests,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search requests...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                // Status filter chips
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildStatusChip('All', ''),
                      const SizedBox(width: 8),
                      _buildStatusChip('Pending', 'Pending'),
                      const SizedBox(width: 8),
                      _buildStatusChip('Approved', 'Approved'),
                      const SizedBox(width: 8),
                      _buildStatusChip('Rejected', 'Rejected'),
                    ],
                  ),
                ),

                // Request list
                Expanded(
                  child: _filteredRequests.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No verification requests found',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadVerificationRequests,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredRequests.length,
                            itemBuilder: (context, index) {
                              return _buildRequestCard(
                                _filteredRequests[index],
                              );
                            },
                          ),
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
