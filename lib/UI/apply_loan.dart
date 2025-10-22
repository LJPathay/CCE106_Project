import 'dart:math';
import 'package:flutter/material.dart';

class ApplyLoanPage extends StatefulWidget {
  const ApplyLoanPage({super.key});

  @override
  State<ApplyLoanPage> createState() => _ApplyLoanPageState();
}

class _ApplyLoanPageState extends State<ApplyLoanPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();

  final Map<String, Map<String, dynamic>> _loanTerms = {
    '7 days - 15%': {'months': 0.23, 'interestRate': 15.0, 'label': '7 days'},
    '14 days - 12%': {'months': 0.47, 'interestRate': 12.0, 'label': '14 days'},
    '1 month - 8%': {'months': 1, 'interestRate': 8.0, 'label': '1 month'},
    '3 months - 5%': {'months': 3, 'interestRate': 5.0, 'label': '3 months'},
    '6 months - 4%': {'months': 6, 'interestRate': 4.0, 'label': '6 months'},
    '12 months - 3.5%': {
      'months': 12,
      'interestRate': 3.5,
      'label': '12 months',
    },
    '24 months - 3%': {'months': 24, 'interestRate': 3.0, 'label': '24 months'},
  };
  String _selectedTerm = '3 months - 5%';

  final List<String> _loanPurposes = [
    'Personal/Emergency',
    'Medical Expenses',
    'Education',
    'Home Improvement',
    'Business Capital',
    'Debt Consolidation',
    'Travel',
    'Wedding',
    'Vehicle Purchase',
    'Others',
  ];
  String _selectedPurpose = 'Personal/Emergency';

  double _monthly = 0.0;
  double _total = 0.0;
  double _currentMonths = 3.0;
  bool _showSummary = false;

  late final AnimationController _anim;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _anim.dispose();
    super.dispose();
  }

  String _formatPeso(double v) => '₱${v.toStringAsFixed(2)}';

  void _calculate() {
    final a = double.tryParse(_amountController.text) ?? 0.0;
    if (a <= 0) {
      setState(() {
        _showSummary = false;
        _monthly = 0.0;
        _total = 0.0;
        _currentMonths = 0.0;
      });
      return;
    }
    final termData = _loanTerms[_selectedTerm]!;
    final months = termData['months'] as double;
    final interestRate = termData['interestRate'] as double;

    double total;
    if (months < 1) {
      total = a * (1 + (interestRate / 100));
    } else {
      final rate = interestRate / 100;
      total = a * pow((1 + rate), months);
    }
    final monthly = months < 1 ? total : total / months;
    setState(() {
      _total = total;
      _monthly = monthly;
      _showSummary = true;
      _currentMonths = months;
    });
    _anim.forward();
  }

  @override
  Widget build(BuildContext context) {
    final termData = _loanTerms[_selectedTerm]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        title: const Text(
          'Apply for a Loan',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Loan Amount input
          const Text(
            'Loan Amount',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black, // high-contrast label!
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.black87,
              ),
              hintText: 'Enter loan amount (max ₱50,000)',
              hintStyle: TextStyle(color: Colors.grey[700]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            onChanged: (_) => _calculate(),
          ),
          const SizedBox(height: 16),

          // Repayment term dropdown
          const Text(
            'Repayment Term & Interest',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black, // high-contrast
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
                value: _selectedTerm,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black87,
                ),
                items: _loanTerms.keys.map((term) {
                  return DropdownMenuItem<String>(
                    value: term,
                    child: Text(
                      term,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedTerm = value);
                    _calculate();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Reason dropdown
          const Text(
            'Purpose of Loan',
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
                value: _selectedPurpose,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black87,
                ),
                items: _loanPurposes.map((purpose) {
                  return DropdownMenuItem<String>(
                    value: purpose,
                    child: Text(
                      purpose,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPurpose = value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_showSummary)
            FadeTransition(
              opacity: _fade,
              child: Card(
                elevation: 3,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Loan Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Loan Amount:',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatPeso(
                              double.tryParse(_amountController.text) ?? 0.0,
                            ),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Term:',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            termData['label'],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Interest Rate:',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${termData['interestRate']}%',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Purpose:',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              _selectedPurpose,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _currentMonths < 1
                                ? 'Amount due:'
                                : 'Monthly Payment:',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatPeso(_monthly),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Payment:',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatPeso(_total),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              _calculate();
              if (_showSummary) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Loan application submitted!\nAmount: ${_formatPeso(double.tryParse(_amountController.text) ?? 0.0)}\nPurpose: $_selectedPurpose',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4B56E9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
            ),
            child: const Text(
              'Apply for Loan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
