import 'package:flutter/material.dart';
import '../../layout/theme.dart';
import '../../Services/firebase_service.dart';
import '../../Models/Loan.dart';

class MakePaymentPage extends StatefulWidget {
  const MakePaymentPage({super.key});

  @override
  State<MakePaymentPage> createState() => _MakePaymentPageState();
}

class _MakePaymentPageState extends State<MakePaymentPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  final List<String> _paymentMethods = [
    "Bank Transfer",
    "GCash",
    "Credit Card",
  ];
  String _selectedMethod = "Bank Transfer";
  String? _selectedLoanId; // Selected loan ID (null means no loan selected)
  bool _isSubmitting = false;

  final FirebaseService _firebaseService = FirebaseService();

  String _formatCurrency(double amount) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  static const Color _accentPink = Color(0xFFD81B60);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.instagramGradient.createShader(bounds),
          child: const Text(
            'Make Payment',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Loan>>(
        stream: _firebaseService.getActiveLoans(),
        builder: (context, loansSnapshot) {
          final activeLoans = loansSnapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Select Loan
              const Text(
                'Select Loan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _selectedLoanId,
                    isExpanded: true,
                    hint: const Text(
                      'Select a loan to pay for (or leave blank)',
                      style: TextStyle(color: Colors.black54),
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black87,
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text(
                          'No specific loan (General payment)',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      ...activeLoans.map((loan) {
                        return DropdownMenuItem<String?>(
                          value: loan.id,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                loan.purpose,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Remaining: ${_formatCurrency(loan.remainingAmount)}',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedLoanId = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Select Payment Method
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMethod,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black87,
                    ),
                    items: _paymentMethods.map((m) {
                      return DropdownMenuItem<String>(
                        value: m,
                        child: Text(
                          m,
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedMethod = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dynamic payment fields based on selected method
              if (_selectedMethod == "Bank Transfer") ...[
                // Bank Transfer fields
                const Text(
                  'Account Holder Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Enter account holder name",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bank Account Number',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _accountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "0000 0000 0000",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black87),
                ),
              ] else if (_selectedMethod == "GCash") ...[
                // GCash fields
                const Text(
                  'Account Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Enter your name",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 16),
                const Text(
                  'GCash Number',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _accountController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "09XX XXX XXXX",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black87),
                ),
              ] else if (_selectedMethod == "Credit Card") ...[
                // Credit Card fields
                const Text(
                  'Cardholder Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Name on card",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Card Number',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _accountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "0000 0000 0000 0000",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Expiry Date',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _cvvController,
                            keyboardType: TextInputType.datetime,
                            decoration: InputDecoration(
                              hintText: "MM/YY",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CVV',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: TextEditingController(),
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            maxLength: 3,
                            decoration: InputDecoration(
                              hintText: "123",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              counterText: "",
                            ),
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Amount
              const Text(
                'Enter Amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: "₱ 0.00",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Details
              const Text(
                'Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 120,
                child: TextField(
                  controller: _detailsController,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    hintText: "Add payment details (optional)",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
              const SizedBox(height: 22),

              // Pay button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 1,
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          FocusScope.of(context).unfocus();
                          final amount =
                              double.tryParse(_amountController.text) ?? 0;
                          if (amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid amount.'),
                                backgroundColor: _accentPink,
                              ),
                            );
                            return;
                          }

                          if (_nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter account holder name.',
                                ),
                                backgroundColor: _accentPink,
                              ),
                            );
                            return;
                          }

                          if (_accountController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter account number.'),
                                backgroundColor: _accentPink,
                              ),
                            );
                            return;
                          }

                          // Show confirmation dialog
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text(
                                'Confirm Payment',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Please confirm your payment details:',
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Amount: ${_formatCurrency(amount)}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Method: $_selectedMethod',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Account: ${_accountController.text.trim()}',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Confirm',
                                    style: TextStyle(
                                      color: _accentPink,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm != true) return;

                          setState(() => _isSubmitting = true);
                          try {
                            await _firebaseService.submitPayment(
                              loanId: _selectedLoanId, // Use selected loan ID
                              paymentMethod: _selectedMethod,
                              accountHolderName: _nameController.text.trim(),
                              accountNumber: _accountController.text.trim(),
                              amount: amount,
                              details: _detailsController.text.trim().isEmpty
                                  ? null
                                  : _detailsController.text.trim(),
                            );

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Payment of ₱${amount.toStringAsFixed(2)} via $_selectedMethod submitted.',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: _accentPink,
                                ),
                              );
                              _nameController.clear();
                              _accountController.clear();
                              _cvvController.clear();
                              _amountController.clear();
                              _detailsController.clear();
                              setState(
                                () => _selectedLoanId = null,
                              ); // Reset loan selection
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isSubmitting = false);
                            }
                          }
                        },
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          "Pay",
                          style: AppTheme.heading.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
