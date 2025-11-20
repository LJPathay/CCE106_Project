import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  int _selectedIndex = 2; // Verify tab
  String _selectedTab = 'Details';
  String _verificationStatus = 'Pending';
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
        case 3:
          Navigator.pushReplacementNamed(context, '/admin/analytics');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/admin/users');
          break;
      }
    }
  }

  void _handleApprove() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Loan Application'),
        content: const Text('Are you sure you want to approve this loan application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _verificationStatus = 'Approved';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Loan application approved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _handleReject() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Loan Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to reject this loan application?'),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _verificationStatus = 'Rejected';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Loan application rejected'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _handleRequestMoreInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Additional Information'),
        content: TextField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'What information do you need?',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Information request sent to applicant'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final dateFormat = DateFormat('MMM d, yyyy');

    // Get applicant data from arguments or use dummy data
    final Map<String, dynamic> applicant = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {
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
    };

    // Extended dummy data for verification
    final Map<String, dynamic> verificationData = {
      "personalInfo": {
        "fullName": applicant['name'],
        "dateOfBirth": "1985-05-15",
        "gender": "Male",
        "civilStatus": "Married",
        "nationality": "Filipino",
        "address": "123 Main Street, Quezon City, Metro Manila",
        "zipCode": "1100",
      },
      "employmentInfo": {
        "status": applicant['employmentStatus'],
        "employer": "ABC Corporation",
        "position": "Senior Manager",
        "yearsEmployed": "8 years",
        "monthlyIncome": applicant['monthlyIncome'],
        "otherIncome": 10000.00,
      },
      "loanDetails": {
        "type": applicant['loanType'],
        "amount": applicant['amount'],
        "purpose": applicant['purpose'],
        "term": "36 months",
        "interestRate": "12.5%",
        "monthlyPayment": 16667.00,
      },
      "financialInfo": {
        "bankName": "BDO Unibank",
        "accountNumber": "****1234",
        "averageBalance": 125000.00,
        "existingLoans": 1,
        "totalDebt": 150000.00,
        "debtToIncomeRatio": "27.3%",
      },
      "documents": [
        {"name": "Valid ID (Front)", "status": "Verified", "uploadDate": "2023-11-18"},
        {"name": "Valid ID (Back)", "status": "Verified", "uploadDate": "2023-11-18"},
        {"name": "Proof of Income", "status": "Verified", "uploadDate": "2023-11-18"},
        {"name": "Bank Statement", "status": "Pending Review", "uploadDate": "2023-11-18"},
        {"name": "Business Permit", "status": "Verified", "uploadDate": "2023-11-18"},
        {"name": "Tax Return", "status": "Pending Review", "uploadDate": "2023-11-18"},
      ],
      "creditHistory": {
        "score": applicant['creditScore'],
        "rating": "Good",
        "paymentHistory": "95% on-time payments",
        "creditUtilization": "35%",
        "accountAge": "12 years",
        "recentInquiries": 2,
      },
      "verificationChecks": [
        {"check": "Identity Verification", "status": "Passed", "verifiedBy": "System", "date": "2023-11-18"},
        {"check": "Employment Verification", "status": "Passed", "verifiedBy": "Maria Santos", "date": "2023-11-18"},
        {"check": "Income Verification", "status": "Passed", "verifiedBy": "Maria Santos", "date": "2023-11-18"},
        {"check": "Credit Check", "status": "Passed", "verifiedBy": "System", "date": "2023-11-18"},
        {"check": "Background Check", "status": "In Progress", "verifiedBy": "Pending", "date": "-"},
        {"check": "Reference Check", "status": "Pending", "verifiedBy": "Pending", "date": "-"},
      ],
      "timeline": [
        {"event": "Application Submitted", "date": "2023-11-18 09:30", "by": "Juan Dela Cruz"},
        {"event": "Initial Review Completed", "date": "2023-11-18 10:15", "by": "System"},
        {"event": "Documents Uploaded", "date": "2023-11-18 11:00", "by": "Juan Dela Cruz"},
        {"event": "Assigned to Loan Officer", "date": "2023-11-18 14:30", "by": "System"},
        {"event": "Under Verification", "date": "2023-11-18 15:00", "by": "Maria Santos"},
      ],
    };

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Loan Verification', style: TextStyle(color: Colors.white)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFF1E88E5),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Print functionality coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Applicant Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[50],
                      radius: 30,
                      child: Text(
                        applicant['name'].toString().substring(0, 1),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            applicant['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            applicant['id'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 12, color: Colors.black54),
                              const SizedBox(width: 4),
                              Text(
                                'Applied: ${dateFormat.format(DateTime.parse(applicant['dateApplied']))}',
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_verificationStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _verificationStatus,
                        style: TextStyle(
                          color: _getStatusColor(_verificationStatus),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStat('Amount', currencyFormat.format(applicant['amount'])),
                      Container(width: 1, height: 30, color: Colors.blue[200]),
                      _buildQuickStat('Type', applicant['loanType']),
                      Container(width: 1, height: 30, color: Colors.blue[200]),
                      _buildQuickStat('Credit', applicant['creditScore'].toString()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tab Bar
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTab('Details'),
                _buildTab('Documents'),
                _buildTab('Verification'),
                _buildTab('Timeline'),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTabContent(verificationData, applicant, currencyFormat, dateFormat),
                  // Action Buttons (only show when pending)
                  if (_verificationStatus == 'Pending') ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleReject,
                            icon: const Icon(Icons.close),
                            label: const Text('Reject'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleRequestMoreInfo,
                            icon: const Icon(Icons.info_outline),
                            label: const Text('More Info'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handleApprove,
                            icon: const Icon(Icons.check),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTab(String label) {
    final isSelected = _selectedTab == label;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF1E88E5) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1E88E5) : Colors.black54,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
    Map<String, dynamic> verificationData,
    Map<String, dynamic> applicant,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    switch (_selectedTab) {
      case 'Details':
        return _buildDetailsTab(verificationData, currencyFormat);
      case 'Documents':
        return _buildDocumentsTab(verificationData['documents'], dateFormat);
      case 'Verification':
        return _buildVerificationTab(verificationData, dateFormat);
      case 'Timeline':
        return _buildTimelineTab(verificationData['timeline']);
      default:
        return const SizedBox();
    }
  }

  Widget _buildDetailsTab(Map<String, dynamic> data, NumberFormat currencyFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection('Personal Information', [
          _buildInfoRow('Full Name', data['personalInfo']['fullName']),
          _buildInfoRow('Date of Birth', data['personalInfo']['dateOfBirth']),
          _buildInfoRow('Gender', data['personalInfo']['gender']),
          _buildInfoRow('Civil Status', data['personalInfo']['civilStatus']),
          _buildInfoRow('Nationality', data['personalInfo']['nationality']),
          _buildInfoRow('Address', data['personalInfo']['address']),
          _buildInfoRow('Zip Code', data['personalInfo']['zipCode']),
        ]),
        const SizedBox(height: 16),
        _buildSection('Employment Information', [
          _buildInfoRow('Status', data['employmentInfo']['status']),
          _buildInfoRow('Employer', data['employmentInfo']['employer']),
          _buildInfoRow('Position', data['employmentInfo']['position']),
          _buildInfoRow('Years Employed', data['employmentInfo']['yearsEmployed']),
          _buildInfoRow('Monthly Income', currencyFormat.format(data['employmentInfo']['monthlyIncome'])),
          _buildInfoRow('Other Income', currencyFormat.format(data['employmentInfo']['otherIncome'])),
        ]),
        const SizedBox(height: 16),
        _buildSection('Loan Details', [
          _buildInfoRow('Loan Type', data['loanDetails']['type']),
          _buildInfoRow('Amount Requested', currencyFormat.format(data['loanDetails']['amount'])),
          _buildInfoRow('Purpose', data['loanDetails']['purpose']),
          _buildInfoRow('Loan Term', data['loanDetails']['term']),
          _buildInfoRow('Interest Rate', data['loanDetails']['interestRate']),
          _buildInfoRow('Monthly Payment', currencyFormat.format(data['loanDetails']['monthlyPayment'])),
        ]),
        const SizedBox(height: 16),
        _buildSection('Financial Information', [
          _buildInfoRow('Bank Name', data['financialInfo']['bankName']),
          _buildInfoRow('Account Number', data['financialInfo']['accountNumber']),
          _buildInfoRow('Average Balance', currencyFormat.format(data['financialInfo']['averageBalance'])),
          _buildInfoRow('Existing Loans', data['financialInfo']['existingLoans'].toString()),
          _buildInfoRow('Total Debt', currencyFormat.format(data['financialInfo']['totalDebt'])),
          _buildInfoRow('Debt-to-Income Ratio', data['financialInfo']['debtToIncomeRatio']),
        ]),
        const SizedBox(height: 16),
        _buildSection('Credit History', [
          _buildInfoRow('Credit Score', data['creditHistory']['score'].toString()),
          _buildInfoRow('Rating', data['creditHistory']['rating']),
          _buildInfoRow('Payment History', data['creditHistory']['paymentHistory']),
          _buildInfoRow('Credit Utilization', data['creditHistory']['creditUtilization']),
          _buildInfoRow('Account Age', data['creditHistory']['accountAge']),
          _buildInfoRow('Recent Inquiries', data['creditHistory']['recentInquiries'].toString()),
        ]),
      ],
    );
  }

  Widget _buildDocumentsTab(List<dynamic> documents, DateFormat dateFormat) {
    return Column(
      children: documents.map((doc) {
        final status = doc['status'];
        final statusColor = status == 'Verified' ? Colors.green : Colors.orange;
        
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                status == 'Verified' ? Icons.check_circle : Icons.pending,
                color: statusColor,
              ),
            ),
            title: Text(
              doc['name'],
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            subtitle: Text(
              'Uploaded: ${dateFormat.format(DateTime.parse(doc['uploadDate']))}',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('View ${doc['name']}')),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVerificationTab(Map<String, dynamic> data, DateFormat dateFormat) {
    final checks = data['verificationChecks'] as List<dynamic>;
    
    return Column(
      children: checks.map((check) {
        final status = check['status'];
        Color statusColor;
        IconData statusIcon;
        
        switch (status) {
          case 'Passed':
            statusColor = Colors.green;
            statusIcon = Icons.check_circle;
            break;
          case 'In Progress':
            statusColor = Colors.blue;
            statusIcon = Icons.hourglass_empty;
            break;
          case 'Pending':
            statusColor = Colors.orange;
            statusIcon = Icons.pending;
            break;
          default:
            statusColor = Colors.grey;
            statusIcon = Icons.help_outline;
        }
        
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        check['check'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 12, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            check['verifiedBy'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          if (check['date'] != '-') ...[
                            const SizedBox(width: 12),
                            Icon(Icons.calendar_today, size: 12, color: Colors.black54),
                            const SizedBox(width: 4),
                            Text(
                              check['date'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimelineTab(List<dynamic> timeline) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: timeline.length,
      itemBuilder: (context, index) {
        final event = timeline[index];
        final isLast = index == timeline.length - 1;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    color: Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['event'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            event['date'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.person_outline, size: 14, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            event['by'],
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
            ),
          ],
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
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
